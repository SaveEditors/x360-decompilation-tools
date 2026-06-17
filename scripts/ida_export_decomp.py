"""Export every function from the open IDA database.

Run inside IDA/IDAPython, normally through IDA MCP. Set XEX_DECOMP_OUT to
choose the destination. The exporter overwrites only files under that output
directory.
"""

from __future__ import annotations

import json
import os
import re
import shutil
import time
from pathlib import Path

import ida_bytes
import ida_funcs
import ida_hexrays
import ida_idaapi
import ida_idp
import ida_kernwin
import ida_lines
import ida_name
import ida_nalt
import ida_segment
import ida_typeinf
import ida_ua
import ida_xref
import idautils
import idc


SCRIPT_ROOT = Path(__file__).resolve().parents[1] if "__file__" in globals() else Path.cwd()


def _safe_name(name: str) -> str:
    name = re.sub(r"[^A-Za-z0-9_.@$-]+", "_", name)
    return name[:180] or "sub"


def _clean_text(text: str) -> str:
    return ida_lines.tag_remove(text or "")


def _ensure_inside(path: Path, root: Path) -> None:
    resolved = path.resolve()
    root_resolved = root.resolve()
    if resolved != root_resolved and root_resolved not in resolved.parents:
        raise RuntimeError(f"Refusing to write outside output root: {resolved}")


def _validate_output_root(path: Path) -> None:
    resolved = path.resolve()
    if len(resolved.parts) < 3:
        raise RuntimeError(f"Refusing to use shallow output path: {resolved}")


def _write(path: Path, text: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(text, encoding="utf-8", newline="\n")


def _default_output_for_input() -> Path:
    input_path = Path(ida_nalt.get_input_file_path() or "")
    stem = _safe_name(input_path.stem or "unknown")
    out_root = Path(os.environ.get("XEXD_OUTPUT_ROOT", SCRIPT_ROOT / "workspace" / "decomp"))
    return out_root / stem


def _output_path() -> Path:
    return Path(os.environ.get("XEX_DECOMP_OUT") or _default_output_for_input())


def _disassemble_function(func) -> str:
    lines = []
    for ea in idautils.FuncItems(func.start_ea):
        dis = _clean_text(idc.generate_disasm_line(ea, 0))
        lines.append(f"{ea:08X}: {dis}")
    return "\n".join(lines) + "\n"


def _decompile_function(ea: int) -> tuple[bool, str]:
    try:
        cfunc = ida_hexrays.decompile(ea)
        if cfunc is None:
            return False, "/* decompile returned None */\n"
        return True, str(cfunc)
    except Exception as exc:
        return False, f"/* decompile failed: {type(exc).__name__}: {exc} */\n"


def _prototype(ea: int) -> str:
    tif = ida_typeinf.tinfo_t()
    try:
        get_tinfo = getattr(ida_typeinf, "get_tinfo", None) or getattr(ida_nalt, "get_tinfo", None)
        if get_tinfo and get_tinfo(tif, ea):
            return str(tif)
    except Exception:
        pass
    return idc.get_type(ea) or ""


def _xref_summary(ea: int) -> dict[str, list[str]]:
    to_refs = []
    from_refs = []
    for xr in idautils.XrefsTo(ea, 0):
        to_refs.append(f"{xr.frm:08X}:{xr.type}")
    for xr in idautils.XrefsFrom(ea, 0):
        from_refs.append(f"{xr.to:08X}:{xr.type}")
    return {"to": to_refs, "from": from_refs}


def _export_strings(out: Path) -> None:
    rows = []
    for s in idautils.Strings():
        ea = int(s.ea)
        rows.append(
            {
                "address": f"0x{ea:08X}",
                "length": int(s.length),
                "type": int(s.strtype),
                "value": str(s),
                "xrefs": [f"0x{xr.frm:08X}" for xr in idautils.XrefsTo(ea, 0)],
            }
        )
    _write(out / "strings.json", json.dumps(rows, indent=2))


def _export_names(out: Path) -> None:
    rows = []
    for ea, name in idautils.Names():
        rows.append({"address": f"0x{ea:08X}", "name": name})
    _write(out / "names.json", json.dumps(rows, indent=2))


def _export_segments(out: Path) -> None:
    rows = []
    for seg_ea in idautils.Segments():
        seg = ida_segment.getseg(seg_ea)
        if not seg:
            continue
        rows.append(
            {
                "name": ida_segment.get_segm_name(seg),
                "start": f"0x{seg.start_ea:08X}",
                "end": f"0x{seg.end_ea:08X}",
                "perm": int(seg.perm),
                "bitness": int(seg.bitness),
            }
        )
    _write(out / "segments.json", json.dumps(rows, indent=2))


def _export_imports(out: Path) -> None:
    rows = []
    qty = ida_nalt.get_import_module_qty()
    for i in range(qty):
        mod_name = ida_nalt.get_import_module_name(i) or f"module_{i}"

        def cb(ea, name, ordinal):
            rows.append(
                {
                    "module": mod_name,
                    "address": f"0x{ea:08X}",
                    "name": name or "",
                    "ordinal": int(ordinal) if ordinal is not None else None,
                }
            )
            return True

        ida_nalt.enum_import_names(i, cb)
    _write(out / "imports.json", json.dumps(rows, indent=2))


def main() -> None:
    ida_kernwin.replace_wait_box("Exporting full decompile...")
    out = _output_path()
    out = out.resolve()
    _validate_output_root(out)

    if out.exists():
        shutil.rmtree(out)
    (out / "functions").mkdir(parents=True, exist_ok=True)
    (out / "disasm").mkdir(parents=True, exist_ok=True)
    (out / "pseudocode").mkdir(parents=True, exist_ok=True)

    start = time.time()
    funcs = list(idautils.Functions())
    manifest = {
        "input_file": ida_nalt.get_input_file_path(),
        "ida_version": ida_kernwin.get_kernel_version(),
        "processor": ida_idp.get_idp_name(),
        "output": str(out),
        "function_count": len(funcs),
        "generated_utc": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
        "functions": [],
    }

    all_pseudocode = []
    failures = []
    for idx, ea in enumerate(funcs, 1):
        func = ida_funcs.get_func(ea)
        if not func:
            continue
        raw_name = ida_funcs.get_func_name(ea) or f"sub_{ea:08X}"
        name = _safe_name(raw_name)
        stem = f"{ea:08X}_{name}"

        ok, pseudocode = _decompile_function(ea)
        disasm = _disassemble_function(func)
        proto = _prototype(ea)
        xrefs = _xref_summary(ea)

        header = (
            f"// address: 0x{ea:08X}\n"
            f"// name: {raw_name}\n"
            f"// size: 0x{func.end_ea - func.start_ea:X}\n"
            f"// prototype: {proto}\n\n"
        )
        _write(out / "functions" / f"{stem}.cpp", header + pseudocode)
        _write(out / "disasm" / f"{stem}.asm", disasm)
        all_pseudocode.append(header + pseudocode + "\n")

        row = {
            "index": idx,
            "address": f"0x{ea:08X}",
            "end": f"0x{func.end_ea:08X}",
            "size": func.end_ea - func.start_ea,
            "name": raw_name,
            "file_cpp": f"functions/{stem}.cpp",
            "file_asm": f"disasm/{stem}.asm",
            "decompiled": ok,
            "prototype": proto,
            "xrefs": xrefs,
        }
        manifest["functions"].append(row)
        if not ok:
            failures.append(row)

    _write(out / "pseudocode" / "all_functions.cpp", "\n".join(all_pseudocode))
    manifest["decompile_success_count"] = sum(1 for f in manifest["functions"] if f["decompiled"])
    manifest["decompile_failure_count"] = len(failures)
    manifest["elapsed_seconds"] = round(time.time() - start, 3)
    _write(out / "manifest.json", json.dumps(manifest, indent=2))
    _write(out / "failures.json", json.dumps(failures, indent=2))

    _export_strings(out)
    _export_names(out)
    _export_segments(out)
    _export_imports(out)

    readme = f"""# Full IDA Decompile Export

Input: `{manifest["input_file"]}`

- Functions: {manifest["function_count"]}
- Decompiled: {manifest["decompile_success_count"]}
- Failed: {manifest["decompile_failure_count"]}
- Processor: `{manifest["processor"]}`
- Generated UTC: `{manifest["generated_utc"]}`

Key files:

- `manifest.json`: function index and xrefs
- `functions/`: one C-like pseudocode file per function
- `disasm/`: one assembly listing per function
- `pseudocode/all_functions.cpp`: combined pseudocode
- `strings.json`, `names.json`, `imports.json`, `segments.json`: supporting inventory
"""
    _write(out / "README.md", readme)
    print(json.dumps({k: manifest[k] for k in ("output", "function_count", "decompile_success_count", "decompile_failure_count", "elapsed_seconds")}, indent=2))


if __name__ == "__main__":
    main()

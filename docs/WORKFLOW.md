# Xbox 360 Decompilation Workflow

## 1. Populate Workspace

```powershell
.\scripts\bootstrap-workspace.ps1
.\setup.ps1
```

Use `-Root` if the workspace root differs from the repo location. Use `-IdaRoot` or `XEXD_IDA_ROOT` for a custom IDA install.

## 2. Import With IDA

IDA + idaxex is the canonical path for full pseudocode and disassembly output.

1. Open a XEX/XBE module in IDA.
2. Let auto-analysis complete.
3. Run `scripts/ida_export_decomp.py` through IDA MCP or IDAPython.

Default output:

```text
workspace/decomp/<input-module-name>
```

Override output folder:

```powershell
$env:XEX_DECOMP_OUT = "D:\Research\decompiled\module_name"
```

## 3. Cross-Check With Ghidra

```powershell
.\scripts\import-xex-ghidra.ps1 -InputXex "D:\Research\module.xex" -ProjectName module_name
```

Use Ghidra for loader parity checks, strings, memory maps, function discovery, cross-reference exploration, and MCP-assisted navigation.

## 4. Output Contents

Each output folder contains:

- `manifest.json`
- `functions\*.cpp`
- `disasm\*.asm`
- `pseudocode\all_functions.cpp`
- `strings.json`
- `names.json`
- `imports.json`
- `segments.json`

## 5. Publishing Guidance

Do not commit proprietary binaries or decompiler databases. Decompiled output may also be copyright-sensitive. Keep research outputs private unless distribution rights are clear.

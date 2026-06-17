# x360 Decompilation Tools

Portable Xbox 360 reverse-engineering and decompilation workspace for IDA/idaxex, Ghidra/XEXLoaderWV, MCP-assisted analysis, cross-reference work, and repeatable decompilation output.

This repository tracks setup scripts, analysis helpers, workflow docs, and third-party notices. It does not vendor commercial tools, console binaries, decrypted modules, IDA/Ghidra databases, or cloned third-party source trees.

## Supported Workflow

- Load XEX/XBE modules in IDA with idaxex.
- Write full IDA pseudocode and disassembly output.
- Cross-check imports, memory maps, strings, and functions in Ghidra with XEXLoaderWV.
- Use GhidraMCP/IDA MCP workflows for automated cross-reference and porting tasks.
- Keep decompiled output and proprietary inputs outside public Git history.

## Layout

```text
config/       Environment/path setup
docs/         Workflow, tool, legal, and third-party notices
scripts/      Bootstrap, install, import, verify, MCP, and decompiler scripts
templates/    Reserved for project templates
schemas/      Reserved for machine-readable output schemas
```

Ignored local workspace folders:

```text
downloads/    Downloaded release archives
repos/        Cloned third-party source/reference repositories
runtime/      JDK/Maven or other local runtimes
ghidra/       Local Ghidra install
venvs/        Python virtual environments
workspace/    Project databases, logs, caches, decompilation output
xbox360/bin/  Local helper binaries
```

## Requirements

- Windows PowerShell 7 or Windows PowerShell 5.1
- Git and GitHub CLI if you plan to publish/fork
- Licensed IDA Professional install if using IDA decompiler output
- Ghidra 12.1 for the bundled Ghidra workflow
- JDK 21 and Maven for rebuilding Ghidra extensions

Set a custom IDA path with:

```powershell
$env:XEXD_IDA_ROOT = "C:\Path\To\IDA Professional 9.3"
```

## Bootstrap

From a fresh clone:

```powershell
.\scripts\bootstrap-workspace.ps1
.\setup.ps1
```

If you keep the workspace somewhere else:

```powershell
.\scripts\bootstrap-workspace.ps1 -Root "D:\Tools\x360-decompilation-tools"
.\setup.ps1 -Root "D:\Tools\x360-decompilation-tools" -IdaRoot "C:\Path\To\IDA"
```

Large runtimes are not bundled. Place or install them under the selected workspace root:

```text
ghidra/ghidra_12.1_PUBLIC
runtime/jdk-21.0.11+10
runtime/apache-maven-3.9.16
```

## Verify

```powershell
.\scripts\verify-tools.ps1
```

## Full IDA Decompilation

Open a module in IDA, wait for auto-analysis, then run `scripts/ida_export_decomp.py` through IDA MCP or IDAPython.

Output defaults to:

```text
workspace/decomp/<input-module-name>
```

Override with:

```powershell
$env:XEX_DECOMP_OUT = "D:\Research\decompiled\module_name"
```

Each output folder contains:

- `manifest.json`
- `functions/*.cpp`
- `disasm/*.asm`
- `pseudocode/all_functions.cpp`
- `strings.json`
- `names.json`
- `imports.json`
- `segments.json`

## Ghidra Import

```powershell
.\scripts\import-xex-ghidra.ps1 -InputXex "D:\Research\module.xex" -ProjectName module
```

XEXLoaderWV is rebuilt locally with JDK 21 when needed so Ghidra 12.1 headless can load it.

## More Docs

- `docs/WORKFLOW.md`
- `docs/TOOLS.md`
- `docs/THIRD_PARTY_NOTICES.md`
- `docs/LEGAL.md`

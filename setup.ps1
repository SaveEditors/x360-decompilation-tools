param(
    [string]$Root = (Split-Path -Parent $PSCommandPath),
    [string]$IdaRoot = $(if ($env:XEXD_IDA_ROOT) { $env:XEXD_IDA_ROOT } else { "" })
)

$ErrorActionPreference = "Stop"
$env:XEXD_ROOT = [System.IO.Path]::GetFullPath($Root)
if ($IdaRoot) { $env:XEXD_IDA_ROOT = [System.IO.Path]::GetFullPath($IdaRoot) }
. (Join-Path $Root "config\paths.env.ps1")

& (Join-Path $Root "scripts\install-idaxex.ps1") -Root $Root -IdaRoot $IdaRoot
& (Join-Path $Root "scripts\install-ghidra-extensions.ps1") -Root $Root
& (Join-Path $Root "scripts\verify-tools.ps1") -Root $Root

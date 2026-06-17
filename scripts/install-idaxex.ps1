param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSCommandPath)),
    [string]$IdaRoot = $(if ($env:XEXD_IDA_ROOT) { $env:XEXD_IDA_ROOT } else { "" })
)

$ErrorActionPreference = "Stop"
$env:XEXD_ROOT = [System.IO.Path]::GetFullPath($Root)
if ($IdaRoot) { $env:XEXD_IDA_ROOT = [System.IO.Path]::GetFullPath($IdaRoot) }
. (Join-Path $Root "config\paths.env.ps1")

$releaseZip = Join-Path $Root "downloads\idaxex+xex1tool-0.44_ida93sp2.zip"
$extractDir = Join-Path $Root "tools\idaxex-0.44"

if (!(Test-Path -LiteralPath $releaseZip)) {
    throw "Missing idaxex release archive: $releaseZip"
}
if (!(Test-Path -LiteralPath $IdaRoot)) {
    throw "IDA root not found: $IdaRoot"
}

if (Test-Path -LiteralPath $extractDir) {
    Remove-Item -LiteralPath $extractDir -Recurse -Force
}
Expand-Archive -LiteralPath $releaseZip -DestinationPath $extractDir -Force

New-Item -ItemType Directory -Force -Path `
    (Join-Path $IdaRoot "loaders"), `
    (Join-Path $IdaRoot "til\ppc"), `
    (Join-Path $Root "xbox360\bin") | Out-Null

Copy-Item -LiteralPath (Join-Path $extractDir "ida93sp2\loaders\idaxex.dll") -Destination (Join-Path $IdaRoot "loaders\idaxex.dll") -Force
Copy-Item -LiteralPath (Join-Path $extractDir "ida93sp2\til\ppc\x360.til") -Destination (Join-Path $IdaRoot "til\ppc\x360.til") -Force
Copy-Item -LiteralPath (Join-Path $extractDir "ida93sp2\til\ppc\xkelib.til") -Destination (Join-Path $IdaRoot "til\ppc\xkelib.til") -Force
Copy-Item -LiteralPath (Join-Path $extractDir "xex1tool.exe") -Destination (Join-Path $Root "xbox360\bin\xex1tool.exe") -Force

Get-Item -LiteralPath `
    (Join-Path $IdaRoot "loaders\idaxex.dll"), `
    (Join-Path $IdaRoot "til\ppc\x360.til"), `
    (Join-Path $IdaRoot "til\ppc\xkelib.til"), `
    (Join-Path $Root "xbox360\bin\xex1tool.exe") |
    Select-Object FullName, Length, LastWriteTime

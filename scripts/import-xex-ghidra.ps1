param(
    [Parameter(Mandatory=$true)]
    [string]$InputXex,
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSCommandPath)),
    [string]$ProjectName = "xex_import",
    [int]$AnalysisTimeoutSeconds = 900
)

$ErrorActionPreference = "Stop"
$env:XEXD_ROOT = [System.IO.Path]::GetFullPath($Root)
. (Join-Path $Root "config\paths.env.ps1")

if (!(Test-Path -LiteralPath $InputXex)) {
    throw "Input XEX not found: $InputXex"
}

$projectDir = Join-Path $script:WorkspaceRoot "ghidra-projects"
$logDir = Join-Path $script:WorkspaceRoot "ghidra-logs"
New-Item -ItemType Directory -Force -Path $projectDir, $logDir | Out-Null

$analyzeHeadless = Join-Path $script:GhidraRoot "support\analyzeHeadless.bat"
if (!(Test-Path -LiteralPath $analyzeHeadless)) {
    throw "analyzeHeadless not found: $analyzeHeadless"
}

& $analyzeHeadless `
    $projectDir `
    $ProjectName `
    -import $InputXex `
    -overwrite `
    -analysisTimeoutPerFile $AnalysisTimeoutSeconds `
    -log (Join-Path $logDir "$ProjectName-import.log") `
    -scriptlog (Join-Path $logDir "$ProjectName-script.log")

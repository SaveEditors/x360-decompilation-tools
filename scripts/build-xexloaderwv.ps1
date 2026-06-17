param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
)

$ErrorActionPreference = "Stop"
$env:XEXD_ROOT = [System.IO.Path]::GetFullPath($Root)
. (Join-Path $Root "config\paths.env.ps1")

$projectDir = Join-Path $Root "repos\XEXLoaderWV\XEXLoaderWV"
$gradleWrapper = Join-Path $script:GhidraRoot "support\gradle\gradlew.bat"
$outputZip = Join-Path $Root "downloads\ghidra_12.1_PUBLIC_XEXLoaderWV_jdk21.zip"

if (!(Test-Path -LiteralPath $projectDir)) { throw "XEXLoaderWV source repo not found: $projectDir" }
if (!(Test-Path -LiteralPath $gradleWrapper)) { throw "Ghidra Gradle wrapper not found: $gradleWrapper" }

$env:GRADLE_USER_HOME = Join-Path $script:WorkspaceRoot "gradle"
New-Item -ItemType Directory -Force -Path $env:GRADLE_USER_HOME, (Join-Path $Root "downloads") | Out-Null

Push-Location $projectDir
try {
    & $gradleWrapper --no-daemon -g $env:GRADLE_USER_HOME -PGHIDRA_INSTALL_DIR=$script:GhidraRoot buildExtension
    if ($LASTEXITCODE -ne 0) { throw "XEXLoaderWV Gradle build failed with exit code $LASTEXITCODE" }
}
finally {
    Pop-Location
}

$builtZip = Get-ChildItem -LiteralPath (Join-Path $projectDir "dist") -Filter "ghidra_12.1_PUBLIC_*_XEXLoaderWV.zip" |
    Sort-Object LastWriteTime |
    Select-Object -Last 1
if (!$builtZip) { throw "XEXLoaderWV build did not produce a Ghidra extension zip." }

Copy-Item -LiteralPath $builtZip.FullName -Destination $outputZip -Force
Get-Item -LiteralPath $outputZip | Select-Object FullName, Length, LastWriteTime

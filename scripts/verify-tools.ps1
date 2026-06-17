param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
)

$ErrorActionPreference = "Stop"
$env:XEXD_ROOT = [System.IO.Path]::GetFullPath($Root)
. (Join-Path $Root "config\paths.env.ps1")

function Test-PathStatus {
    param([string]$Name, [string]$Path, [switch]$Directory)
    $ok = if ($Directory) { Test-Path -LiteralPath $Path -PathType Container } else { Test-Path -LiteralPath $Path -PathType Leaf }
    [pscustomobject]@{ Check = $Name; OK = $ok; Path = $Path }
}

$checks = @()
$checks += Test-PathStatus "Ghidra 12.1" $script:GhidraRoot -Directory
$checks += Test-PathStatus "Ghidra analyzeHeadless" (Join-Path $script:GhidraRoot "support\analyzeHeadless.bat")
$checks += Test-PathStatus "JDK 21" (Join-Path $script:JdkRoot "bin\java.exe")
$checks += Test-PathStatus "Maven 3.9.16" (Join-Path $script:MavenRoot "bin\mvn.cmd")
$checks += Test-PathStatus "IDA Professional 9.3" $script:IdaRoot -Directory
$checks += Test-PathStatus "IDA idaxex loader" (Join-Path $script:IdaRoot "loaders\idaxex.dll")
$checks += Test-PathStatus "IDA x360 type library" (Join-Path $script:IdaRoot "til\ppc\x360.til")
$checks += Test-PathStatus "IDA xkelib type library" (Join-Path $script:IdaRoot "til\ppc\xkelib.til")
$checks += Test-PathStatus "xex1tool" $script:Xex1Tool
$checks += Test-PathStatus "XEXLoaderWV rebuilt archive" (Join-Path $Root "downloads\ghidra_12.1_PUBLIC_XEXLoaderWV_jdk21.zip")
$checks += Test-PathStatus "XEXLoaderWV feature module" (Join-Path $script:GhidraRoot "Ghidra\Features\XEXLoaderWV\lib\XEXLoaderWV.jar")
$checks += Test-PathStatus "XEXLoaderWV loader manifest" (Join-Path $script:GhidraRoot "Ghidra\Features\XEXLoaderWV\data\ExtensionPoint.manifest")
$checks += Test-PathStatus "LaurieWired GhidraMCP bridge" $script:GhidraMcpBridge
$checks += Test-PathStatus "LaurieWired GhidraMCP venv" $script:GhidraMcpPython
$checks += Test-PathStatus "xbox-reversing repo" (Join-Path $Root "repos\xbox-reversing") -Directory
$checks += Test-PathStatus "idaxex source repo" (Join-Path $Root "repos\idaxex") -Directory
$checks += Test-PathStatus "XEXLoaderWV source repo" (Join-Path $Root "repos\XEXLoaderWV") -Directory
$checks += Test-PathStatus "LaurieWired GhidraMCP source repo" (Join-Path $Root "repos\GhidraMCP-lauriewired") -Directory

$checks | Format-Table -AutoSize

if ($checks.OK -contains $false) {
    throw "One or more required tools are missing."
}

Write-Host ""
Write-Host "Java:"
& (Join-Path $script:JdkRoot "bin\java.exe") -version 2>&1 | Select-Object -First 3

Write-Host ""
Write-Host "Maven:"
& (Join-Path $script:MavenRoot "bin\mvn.cmd") -version | Select-Object -First 4

Write-Host ""
Write-Host "Python packages:"
& $script:GhidraMcpPython -m pip show mcp requests | Select-String -Pattern "Name:|Version:|Location:"

Write-Host ""
Write-Host "Workspace environment roots:"
Get-ChildItem Env:TEMP,Env:TMP,Env:USERPROFILE,Env:APPDATA,Env:LOCALAPPDATA,Env:PIP_CACHE_DIR,Env:JAVA_HOME,Env:M2_HOME |
    Select-Object Name,Value |
    Format-Table -AutoSize

$script:Root = if ($env:XEXD_ROOT) {
    [System.IO.Path]::GetFullPath($env:XEXD_ROOT)
}
else {
    [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot ".."))
}

$script:IdaRoot = if ($env:XEXD_IDA_ROOT) {
    [System.IO.Path]::GetFullPath($env:XEXD_IDA_ROOT)
}
else {
    ""
}
$script:GhidraRoot = Join-Path $script:Root "ghidra\ghidra_12.1_PUBLIC"
$script:JdkRoot = Join-Path $script:Root "runtime\jdk-21.0.11+10"
$script:MavenRoot = Join-Path $script:Root "runtime\apache-maven-3.9.16"
$script:WorkspaceRoot = Join-Path $script:Root "workspace"
$script:PythonUserBase = Join-Path $script:WorkspaceRoot "python-userbase"
$script:PipCache = Join-Path $script:WorkspaceRoot "pip-cache"
$script:TempRoot = Join-Path $script:WorkspaceRoot "temp"
$script:UserProfileRoot = Join-Path $script:WorkspaceRoot "userprofile"
$script:AppDataRoot = Join-Path $script:UserProfileRoot "AppData\Roaming"
$script:LocalAppDataRoot = Join-Path $script:UserProfileRoot "AppData\Local"
$script:MavenRepo = Join-Path $script:WorkspaceRoot "m2"
$script:GhidraMcpVenv = Join-Path $script:Root "venvs\ghidra-mcp-lauriewired"
$script:GhidraMcpPython = Join-Path $script:GhidraMcpVenv "Scripts\python.exe"
$script:GhidraMcpBridge = Join-Path $script:Root "mcp\bridge_mcp_ghidra_lauriewired.py"
$script:Xex1Tool = Join-Path $script:Root "xbox360\bin\xex1tool.exe"

function Set-XexDecompilerEnvironment {
    New-Item -ItemType Directory -Force -Path `
        $script:WorkspaceRoot, `
        $script:TempRoot, `
        $script:PythonUserBase, `
        $script:PipCache, `
        $script:UserProfileRoot, `
        $script:AppDataRoot, `
        $script:LocalAppDataRoot, `
        $script:MavenRepo | Out-Null

    $env:TEMP = $script:TempRoot
    $env:TMP = $script:TempRoot
    $env:USERPROFILE = $script:UserProfileRoot
    $env:HOME = $script:UserProfileRoot
    $env:APPDATA = $script:AppDataRoot
    $env:LOCALAPPDATA = $script:LocalAppDataRoot
    $env:PYTHONUSERBASE = $script:PythonUserBase
    $env:PIP_CACHE_DIR = $script:PipCache
    $env:JAVA_HOME = $script:JdkRoot
    $env:M2_HOME = $script:MavenRoot
    $env:MAVEN_OPTS = "-Dmaven.repo.local=$script:MavenRepo"
    $env:MAVEN_ARGS = "-Dmaven.repo.local=$script:MavenRepo"
    $env:GHIDRA_INSTALL_DIR = $script:GhidraRoot
    $env:GHIDRA_DEBUGGER_PYTHON = $script:GhidraMcpPython

    $prepend = @(
        (Join-Path $script:JdkRoot "bin"),
        (Join-Path $script:MavenRoot "bin"),
        (Join-Path $script:Root "xbox360\bin")
    ) -join ";"
    $env:PATH = "$prepend;$env:PATH"
}

Set-XexDecompilerEnvironment

param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSCommandPath)),
    [string]$Transport = "stdio",
    [string]$McpHost = "127.0.0.1",
    [int]$McpPort = 8081,
    [string]$GhidraServer = "http://127.0.0.1:8080/"
)

$ErrorActionPreference = "Stop"
$env:XEXD_ROOT = [System.IO.Path]::GetFullPath($Root)
. (Join-Path $Root "config\paths.env.ps1")

if (!(Test-Path -LiteralPath $script:GhidraMcpPython)) {
    throw "GhidraMCP venv Python not found: $script:GhidraMcpPython"
}
if (!(Test-Path -LiteralPath $script:GhidraMcpBridge)) {
    throw "GhidraMCP bridge not found: $script:GhidraMcpBridge"
}

& $script:GhidraMcpPython $script:GhidraMcpBridge `
    --transport $Transport `
    --mcp-host $McpHost `
    --mcp-port $McpPort `
    --ghidra-server $GhidraServer

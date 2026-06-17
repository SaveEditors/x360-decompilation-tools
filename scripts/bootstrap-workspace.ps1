param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSCommandPath)),
    [string]$IdaRoot = $(if ($env:XEXD_IDA_ROOT) { $env:XEXD_IDA_ROOT } else { "" }),
    [switch]$SkipLargeRuntimeDownloads
)

$ErrorActionPreference = "Stop"

function Ensure-Dir {
    param([Parameter(Mandatory=$true)][string]$Path)
    New-Item -ItemType Directory -Force -Path $Path | Out-Null
}

function Invoke-Download {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$OutFile
    )
    if (Test-Path -LiteralPath $OutFile) { return }
    Invoke-WebRequest -Uri $Url -OutFile $OutFile
}

function Clone-Or-Update {
    param(
        [Parameter(Mandatory=$true)][string]$Url,
        [Parameter(Mandatory=$true)][string]$Path
    )
    if (Test-Path -LiteralPath (Join-Path $Path ".git")) {
        Push-Location $Path
        try {
            git fetch --all --tags --prune
        }
        finally {
            Pop-Location
        }
        return
    }
    git clone --recursive $Url $Path
}

$Root = [System.IO.Path]::GetFullPath($Root)
$env:XEXD_ROOT = $Root
if ($IdaRoot) { $env:XEXD_IDA_ROOT = [System.IO.Path]::GetFullPath($IdaRoot) }
foreach ($dir in @(
    "downloads", "repos", "runtime", "ghidra", "venvs",
    "workspace", "workspace\temp", "workspace\pip-cache", "workspace\gradle",
    "mcp", "xbox360\bin"
)) {
    Ensure-Dir (Join-Path $Root $dir)
}

$repoMap = @(
    @{ Url = "https://github.com/emoose/idaxex.git"; Path = "repos\idaxex" },
    @{ Url = "https://github.com/emoose/xbox-reversing.git"; Path = "repos\xbox-reversing" },
    @{ Url = "https://github.com/zeroKilo/XEXLoaderWV.git"; Path = "repos\XEXLoaderWV" },
    @{ Url = "https://github.com/LaurieWired/GhidraMCP.git"; Path = "repos\GhidraMCP-lauriewired" },
    @{ Url = "https://github.com/meirm/reverse-engineering-skill.git"; Path = "repos\reverse-engineering-skill" },
    @{ Url = "https://github.com/alirezarezvani/claude-skills.git"; Path = "repos\claude-skills" },
    @{ Url = "https://github.com/punkpeye/awesome-mcp-servers.git"; Path = "repos\awesome-mcp-servers" },
    @{ Url = "https://github.com/patriksimek/awesome-mcp-servers-2.git"; Path = "repos\awesome-mcp-servers-2" },
    @{ Url = "https://github.com/modelcontextprotocol/servers.git"; Path = "repos\modelcontextprotocol-servers" },
    @{ Url = "https://github.com/SimonB97/win-cli-mcp-server.git"; Path = "repos\win-cli-mcp-server" }
)

foreach ($repo in $repoMap) {
    Clone-Or-Update $repo.Url (Join-Path $Root $repo.Path)
}

$downloads = Join-Path $Root "downloads"
Invoke-Download `
    "https://github.com/emoose/idaxex/releases/download/0.44/idaxex+xex1tool-0.44_ida93sp2.zip" `
    (Join-Path $downloads "idaxex+xex1tool-0.44_ida93sp2.zip")
Invoke-Download `
    "https://github.com/LaurieWired/GhidraMCP/releases/download/1.4/GhidraMCP-release-1-4.zip" `
    (Join-Path $downloads "GhidraMCP-release-1-4.zip")

if (!$SkipLargeRuntimeDownloads) {
    Write-Warning "Large runtime downloads are intentionally not bundled. Install/copy Ghidra 12.1, JDK 21, and Maven into the paths documented in README.md, then run setup.ps1."
}

Write-Host "Bootstrap complete. Next:"
Write-Host "  .\setup.ps1 -Root `"$Root`" -IdaRoot <path-to-ida>"

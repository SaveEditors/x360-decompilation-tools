param(
    [string]$Root = (Split-Path -Parent (Split-Path -Parent $PSCommandPath))
)

$ErrorActionPreference = "Stop"
$env:XEXD_ROOT = [System.IO.Path]::GetFullPath($Root)
. (Join-Path $Root "config\paths.env.ps1")

if (!(Test-Path -LiteralPath $script:GhidraRoot)) {
    throw "Ghidra root not found: $script:GhidraRoot"
}

$ghidraExtensions = Join-Path $script:GhidraRoot "Extensions\Ghidra"
$userExtensions = Join-Path $script:AppDataRoot "ghidra\ghidra_12.1_PUBLIC\Extensions"
New-Item -ItemType Directory -Force -Path $ghidraExtensions, $userExtensions, (Join-Path $Root "mcp") | Out-Null

$xexZip = Join-Path $Root "downloads\ghidra_12.1_PUBLIC_XEXLoaderWV_jdk21.zip"
$mcpRelease = Join-Path $Root "downloads\GhidraMCP-release-1-4.zip"
if (!(Test-Path -LiteralPath $xexZip)) {
    & (Join-Path $Root "scripts\build-xexloaderwv.ps1") -Root $Root
}
if (!(Test-Path -LiteralPath $xexZip)) { throw "Missing rebuilt Java 21 XEXLoaderWV archive: $xexZip" }
if (!(Test-Path -LiteralPath $mcpRelease)) { throw "Missing LaurieWired GhidraMCP release: $mcpRelease" }

function Remove-KnownTree {
    param([Parameter(Mandatory=$true)][string]$Path)
    if (!(Test-Path -LiteralPath $Path)) { return }
    $full = [System.IO.Path]::GetFullPath($Path)
    $allowedRoots = @($script:GhidraRoot, $script:AppDataRoot, $script:TempRoot) |
        ForEach-Object { [System.IO.Path]::GetFullPath($_).TrimEnd('\') + '\' }
    $isAllowed = $false
    foreach ($rootPath in $allowedRoots) {
        if (($full + '\').StartsWith($rootPath, [System.StringComparison]::OrdinalIgnoreCase)) {
            $isAllowed = $true
            break
        }
    }
    if (!$isAllowed) {
        throw "Refusing to remove unexpected path: $full"
    }
    Remove-Item -LiteralPath $full -Recurse -Force
}

Get-ChildItem -LiteralPath $ghidraExtensions -Filter "*XEXLoaderWV*.zip" |
    Remove-Item -Force
Copy-Item -LiteralPath $xexZip -Destination (Join-Path $ghidraExtensions "ghidra_12.1_PUBLIC_XEXLoaderWV_jdk21.zip") -Force

$xexFeatureModule = Join-Path $script:GhidraRoot "Ghidra\Features\XEXLoaderWV"
$xexUserExtension = Join-Path $userExtensions "XEXLoaderWV"
$xexInstallExtension = Join-Path $ghidraExtensions "XEXLoaderWV"
$xexTmp = Join-Path $script:TempRoot "XEXLoaderWV-install"
foreach ($path in @($xexFeatureModule, $xexUserExtension, $xexInstallExtension, $xexTmp)) {
    Remove-KnownTree $path
}
Expand-Archive -LiteralPath $xexZip -DestinationPath $xexTmp -Force
$xexExtracted = Join-Path $xexTmp "XEXLoaderWV"
if (!(Test-Path -LiteralPath $xexExtracted)) { throw "XEXLoaderWV archive did not contain expected root: $xexExtracted" }
New-Item -ItemType Directory -Force -Path $xexFeatureModule | Out-Null
Get-ChildItem -LiteralPath $xexExtracted | Copy-Item -Destination $xexFeatureModule -Recurse -Force

$xexManifest = Join-Path $xexFeatureModule "Module.manifest"
$xexExtensionPointManifest = Join-Path $xexFeatureModule "data\ExtensionPoint.manifest"
$xexProperties = Join-Path $xexFeatureModule "extension.properties"
Set-Content -LiteralPath $xexManifest -Value "MODULE FILE LICENSE: lib/XEXLoaderWV.jar GPL 3" -Encoding ASCII
Set-Content -LiteralPath $xexExtensionPointManifest -Value "Loader" -Encoding ASCII
if (Test-Path -LiteralPath $xexProperties) {
    $props = Get-Content -LiteralPath $xexProperties
    if ($props -notmatch '^ghidraVersion=') { $props += 'ghidraVersion=12.1' }
    $props = $props -replace '^ghidraVersion=.*$', 'ghidraVersion=12.1'
    Set-Content -LiteralPath $xexProperties -Value $props -Encoding ASCII
}

$tmp = Join-Path $script:TempRoot "GhidraMCP-release-1-4"
if (Test-Path -LiteralPath $tmp) { Remove-Item -LiteralPath $tmp -Recurse -Force }
Expand-Archive -LiteralPath $mcpRelease -DestinationPath $script:TempRoot -Force

$mcpZip = Join-Path $tmp "GhidraMCP-1-4.zip"
$mcpBridge = Join-Path $tmp "bridge_mcp_ghidra.py"
if (!(Test-Path -LiteralPath $mcpZip)) { throw "Missing extension inside GhidraMCP release: $mcpZip" }
if (!(Test-Path -LiteralPath $mcpBridge)) { throw "Missing bridge inside GhidraMCP release: $mcpBridge" }

Copy-Item -LiteralPath $mcpZip -Destination (Join-Path $ghidraExtensions "GhidraMCP-1-4.zip") -Force
Copy-Item -LiteralPath $mcpBridge -Destination $script:GhidraMcpBridge -Force
Copy-Item -LiteralPath $mcpBridge -Destination (Join-Path $script:GhidraRoot "bridge_mcp_ghidra.py") -Force
Expand-Archive -LiteralPath $mcpZip -DestinationPath $userExtensions -Force

$mcpExtensionDir = Join-Path $userExtensions "GhidraMCP"
$mcpManifest = Join-Path $mcpExtensionDir "Module.manifest"
$mcpProperties = Join-Path $mcpExtensionDir "extension.properties"
if (Test-Path -LiteralPath $mcpManifest) {
    Set-Content -LiteralPath $mcpManifest -Value "" -Encoding ASCII
}
if (Test-Path -LiteralPath $mcpProperties) {
    $props = Get-Content -LiteralPath $mcpProperties
    $props = $props -replace '^version=.*$', 'version=1.4'
    $props = $props -replace '^ghidraVersion=.*$', 'ghidraVersion=12.1'
    Set-Content -LiteralPath $mcpProperties -Value $props -Encoding ASCII
}

Get-Item -LiteralPath `
    (Join-Path $ghidraExtensions "ghidra_12.1_PUBLIC_XEXLoaderWV_jdk21.zip"), `
    (Join-Path $ghidraExtensions "GhidraMCP-1-4.zip"), `
    (Join-Path $xexFeatureModule "lib\XEXLoaderWV.jar"), `
    $script:GhidraMcpBridge |
    Select-Object FullName, Length, LastWriteTime

[CmdletBinding(SupportsShouldProcess = $true)]
param(
    [ValidateSet('Project', 'Global')]
    [string]$Scope = 'Project',

    [string]$ProjectRoot,

    [string]$DestinationRoot,

    [ValidateSet('OpenCodeStableV1')]
    [string]$PlatformSchema = 'OpenCodeStableV1',

    [switch]$IncludeEvolutionRegistry
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$packageRoot = Split-Path -Parent $PSScriptRoot
$manifestPath = Join-Path $packageRoot 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
    throw "Package manifest not found: $manifestPath"
}

$manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json
if ($PlatformSchema -ne 'OpenCodeStableV1' -or @($manifest.package.platforms) -notcontains 'opencode-stable-v1') {
    throw 'Unsupported platform schema. This package is fail-closed and only installs OpenCode stable V1 permission/bash/task assets.'
}

if ($DestinationRoot) {
    $targetRoot = [System.IO.Path]::GetFullPath($DestinationRoot)
}
elseif ($Scope -eq 'Global') {
    if (-not $env:USERPROFILE) {
        throw 'USERPROFILE is unavailable; pass -DestinationRoot explicitly.'
    }
    $targetRoot = Join-Path $env:USERPROFILE '.config/opencode'
}
else {
    if (-not $ProjectRoot) {
        throw 'Project installs require -ProjectRoot or an explicit -DestinationRoot.'
    }
    $targetRoot = Join-Path ([System.IO.Path]::GetFullPath($ProjectRoot)) '.opencode'
}
$targetRoot = [System.IO.Path]::GetFullPath($targetRoot)
$targetPrefix = $targetRoot.TrimEnd([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar) + [System.IO.Path]::DirectorySeparatorChar

function Copy-PackageFile {
    param(
        [Parameter(Mandatory)] [string]$RelativeSource,
        [Parameter(Mandatory)] [string]$RelativeDestination
    )

    foreach ($relative in @($RelativeSource, $RelativeDestination)) {
        if ([System.IO.Path]::IsPathRooted($relative) -or ($relative -split '[\\/]' -contains '..')) {
            throw "Manifest/install path must remain relative and cannot contain '..': $relative"
        }
    }
    $source = [System.IO.Path]::GetFullPath((Join-Path $packageRoot ($RelativeSource -replace '/', [System.IO.Path]::DirectorySeparatorChar)))
    $destination = [System.IO.Path]::GetFullPath((Join-Path $targetRoot ($RelativeDestination -replace '/', [System.IO.Path]::DirectorySeparatorChar)))
    if (-not $destination.StartsWith($targetPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        throw "Install destination escapes target root: $RelativeDestination"
    }
    if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
        throw "Manifest asset is missing: $RelativeSource"
    }

    $parent = Split-Path -Parent $destination
    if ($PSCmdlet.ShouldProcess($destination, "Install $RelativeSource")) {
        New-Item -ItemType Directory -Path $parent -Force | Out-Null
        Copy-Item -LiteralPath $source -Destination $destination -Force
    }
}

# Agents and skills are flattened to their canonical IDs. The manifest prevents
# filename collisions and is the only source of installable asset paths.
foreach ($agent in $manifest.agents) {
    Copy-PackageFile -RelativeSource $agent.path -RelativeDestination "agents/$($agent.id).md"
}

foreach ($skill in $manifest.skills) {
    foreach ($file in $skill.files) {
        $leaf = Split-Path -Leaf $file
        Copy-PackageFile -RelativeSource $file -RelativeDestination "skills/$($skill.id)/$leaf"
    }
}

# Shared dependencies retain their package-relative paths so references remain
# deterministic for both project and global installations.
foreach ($group in @('docs', 'references', 'rules')) {
    foreach ($file in $manifest.$group) {
        Copy-PackageFile -RelativeSource $file -RelativeDestination $file
    }
}

foreach ($metadata in @('VERSION', 'manifest.json', 'provenance.json')) {
    Copy-PackageFile -RelativeSource $metadata -RelativeDestination ".ue-game-studio/$metadata"
}

if ($IncludeEvolutionRegistry) {
    Copy-PackageFile -RelativeSource 'skills/_evolutions/evolutions.json' -RelativeDestination 'skills/_evolutions/evolutions.json'
}

Write-Host "Installed $($manifest.counts.agents) agents, $($manifest.counts.skills) skills, and shared dependencies to: $targetRoot"
Write-Host 'agents/_template.md was intentionally excluded.'

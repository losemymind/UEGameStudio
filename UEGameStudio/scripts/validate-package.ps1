[CmdletBinding()]
param(
    [string]$PackageRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$StrictReferences
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$script:errors = [System.Collections.Generic.List[string]]::new()
$script:warnings = [System.Collections.Generic.List[string]]::new()

function Add-ValidationError([string]$Message) { $script:errors.Add($Message) }
function Add-ValidationWarning([string]$Message) { $script:warnings.Add($Message) }
function To-RelativePath([string]$Path) {
    return [System.IO.Path]::GetRelativePath($PackageRoot, $Path).Replace('\', '/')
}
function Get-FrontMatter([string]$Path) {
    $content = Get-Content -LiteralPath $Path -Raw
    $match = [regex]::Match($content, '\A---\s*\r?\n(?<yaml>.*?)\r?\n---(?:\s*\r?\n|\z)', 'Singleline')
    if (-not $match.Success) { return $null }
    return $match.Groups['yaml'].Value
}
function Get-YamlScalar([string]$Yaml, [string]$Name) {
    $pattern = '(?m)^' + [regex]::Escape($Name) + ':\s*[''"]?(?<value>[^\r\n''"]+)'
    $match = [regex]::Match($Yaml, $pattern)
    if ($match.Success) { return $match.Groups['value'].Value.Trim() }
    return $null
}
function Compare-PathInventory([string]$Label, [string[]]$Expected, [string[]]$Actual) {
    $expectedSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$Expected, [System.StringComparer]::OrdinalIgnoreCase)
    $actualSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$Actual, [System.StringComparer]::OrdinalIgnoreCase)
    foreach ($path in $Expected) {
        if (-not $actualSet.Contains($path)) { Add-ValidationError "$Label manifest entry is absent on disk: $path" }
    }
    foreach ($path in $Actual) {
        if (-not $expectedSet.Contains($path)) { Add-ValidationError "$Label file is not declared in manifest.json: $path" }
    }
}

$PackageRoot = [System.IO.Path]::GetFullPath($PackageRoot)
$manifestPath = Join-Path $PackageRoot 'manifest.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) { throw "manifest.json not found: $manifestPath" }
try { $manifest = Get-Content -LiteralPath $manifestPath -Raw | ConvertFrom-Json }
catch { throw "manifest.json is invalid JSON: $($_.Exception.Message)" }

$provenancePath = Join-Path $PackageRoot 'provenance.json'
if (-not (Test-Path -LiteralPath $provenancePath -PathType Leaf)) {
    Add-ValidationError 'provenance.json is missing.'
} else {
    try { $provenance = Get-Content -LiteralPath $provenancePath -Raw | ConvertFrom-Json }
    catch { Add-ValidationError "provenance.json is invalid JSON: $($_.Exception.Message)"; $provenance = $null }
    if ($provenance) {
        $expectedSources = @('agent-skills', 'agency-agents', 'claude-code-game-studios', 'agency-agents-zh')
        $actualSources = @($provenance.sources | ForEach-Object { [string]$_.id })
        foreach ($sourceId in $expectedSources) {
            if ($actualSources -notcontains $sourceId) { Add-ValidationError "provenance source is missing: $sourceId" }
        }
        foreach ($source in $provenance.sources) {
            if (-not $source.repository) { Add-ValidationError "Provenance source lacks repository: $($source.id)" }
            if (-not ($source.PSObject.Properties.Name -contains 'pinned_revision')) { Add-ValidationError "Provenance source lacks explicit pinned_revision (null is allowed): $($source.id)" }
            if ([string]$source.local_reviewed_at -notmatch '^\d{4}-\d{2}-\d{2}$') { Add-ValidationError "Provenance source has invalid local_reviewed_at: $($source.id)" }
            if (@($source.capability_mapping).Count -eq 0) { Add-ValidationError "Provenance source lacks capability_mapping: $($source.id)" }
        }
    }
}

if ($manifest.schema_version -ne 2) { Add-ValidationError "Unsupported manifest schema_version: $($manifest.schema_version)" }
if (@($manifest.package.platforms).Count -ne 1 -or @($manifest.package.platforms) -notcontains 'opencode-stable-v1') {
    Add-ValidationError 'manifest package.platforms must declare only opencode-stable-v1 until another schema has an independently verified build.'
}

$versionPath = Join-Path $PackageRoot 'VERSION'
if (-not (Test-Path -LiteralPath $versionPath -PathType Leaf)) {
    Add-ValidationError 'VERSION is missing.'
} else {
    $version = (Get-Content -LiteralPath $versionPath -Raw).Trim()
    if ($version -ne $manifest.package.version) { Add-ValidationError "VERSION ($version) differs from manifest package.version ($($manifest.package.version))." }
}

$agentFiles = @(Get-ChildItem -LiteralPath (Join-Path $PackageRoot 'agents') -Recurse -File -Filter '*.md' | Where-Object Name -ne '_template.md')
$skillFiles = @(Get-ChildItem -LiteralPath (Join-Path $PackageRoot 'skills') -Recurse -File -Filter 'SKILL.md')
$docFiles = @(Get-ChildItem -LiteralPath (Join-Path $PackageRoot 'docs') -Recurse -File)
$referenceFiles = @(Get-ChildItem -LiteralPath (Join-Path $PackageRoot 'references') -Recurse -File)
$ruleFiles = @(Get-ChildItem -LiteralPath (Join-Path $PackageRoot 'rules') -Recurse -File)

$actualCounts = [ordered]@{
    agents = $agentFiles.Count
    skills = $skillFiles.Count
    docs = $docFiles.Count
    references = $referenceFiles.Count
    rules = $ruleFiles.Count
}
foreach ($group in $actualCounts.Keys) {
    $declaredCount = [int]$manifest.counts.$group
    if ($actualCounts[$group] -ne $declaredCount) {
        Add-ValidationError "$group count is $($actualCounts[$group]); manifest declares $declaredCount."
    }
}

$manifestAgentPaths = @($manifest.agents | ForEach-Object { [string]$_.path })
$manifestSkillPaths = @($manifest.skills | ForEach-Object { [string]$_.path })
Compare-PathInventory 'agent' $manifestAgentPaths @($agentFiles | ForEach-Object { To-RelativePath $_.FullName })
Compare-PathInventory 'skill' $manifestSkillPaths @($skillFiles | ForEach-Object { To-RelativePath $_.FullName })
Compare-PathInventory 'docs' @($manifest.docs) @($docFiles | ForEach-Object { To-RelativePath $_.FullName })
Compare-PathInventory 'references' @($manifest.references) @($referenceFiles | ForEach-Object { To-RelativePath $_.FullName })
Compare-PathInventory 'rules' @($manifest.rules) @($ruleFiles | ForEach-Object { To-RelativePath $_.FullName })

$allDeclaredPaths = @($manifestAgentPaths + $manifestSkillPaths + @($manifest.skills | ForEach-Object { $_.files } | ForEach-Object { $_ }) + @($manifest.docs) + @($manifest.references) + @($manifest.rules))
foreach ($path in $allDeclaredPaths | Select-Object -Unique) {
    if ([System.IO.Path]::IsPathRooted($path) -or ($path -split '[\\/]' -contains '..')) {
        Add-ValidationError "Manifest path must remain package-relative and cannot contain '..': $path"
        continue
    }
    if (-not (Test-Path -LiteralPath (Join-Path $PackageRoot ($path -replace '/', [System.IO.Path]::DirectorySeparatorChar)) -PathType Leaf)) {
        Add-ValidationError "Manifest path does not exist: $path"
    }
}

$agentIds = @($manifest.agents | ForEach-Object { [string]$_.id })
$skillIds = @($manifest.skills | ForEach-Object { [string]$_.id })
foreach ($duplicate in @($agentIds + $skillIds | Group-Object | Where-Object Count -gt 1)) {
    Add-ValidationError "Duplicate canonical ID: $($duplicate.Name)"
}

foreach ($entry in $manifest.agents) {
    $path = Join-Path $PackageRoot ($entry.path -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    $yaml = Get-FrontMatter $path
    if ($null -eq $yaml) { Add-ValidationError "Agent has no valid frontmatter: $($entry.path)"; continue }
    foreach ($required in @('name', 'description', 'mode')) {
        if (-not (Get-YamlScalar $yaml $required)) { Add-ValidationError "Agent frontmatter lacks '$required': $($entry.path)" }
    }
    $name = Get-YamlScalar $yaml 'name'
    if ($name -and $name -ne $entry.id) { Add-ValidationError "Agent frontmatter name '$name' differs from manifest ID '$($entry.id)': $($entry.path)" }
    if ((Get-YamlScalar $yaml 'mode') -ne 'subagent') { Add-ValidationError "Agent mode must be subagent: $($entry.path)" }

    foreach ($requiredMetadata in @('scope', 'domain', 'engine_dependency', 'evaluation_profile', 'integration_owner')) {
        if (-not ($entry.PSObject.Properties.Name -contains $requiredMetadata)) {
            Add-ValidationError "Agent manifest entry lacks '$requiredMetadata': $($entry.path)"
        }
    }
    $validScopes = @('general', 'game', 'unreal', 'integration')
    $validDependencies = @('none', 'required')
    $validProfiles = @('general-core', 'game-core', 'unreal-specialist', 'integration')
    if ($validScopes -notcontains [string]$entry.scope) { Add-ValidationError "Invalid agent scope '$($entry.scope)': $($entry.path)" }
    if ($validDependencies -notcontains [string]$entry.engine_dependency) { Add-ValidationError "Invalid engine_dependency '$($entry.engine_dependency)': $($entry.path)" }
    if ($validProfiles -notcontains [string]$entry.evaluation_profile) { Add-ValidationError "Invalid evaluation_profile '$($entry.evaluation_profile)': $($entry.path)" }
    if ($entry.evaluation_profile -eq 'unreal-specialist' -and ($entry.scope -ne 'unreal' -or $entry.engine_dependency -ne 'required')) {
        Add-ValidationError "unreal-specialist must declare scope=unreal and engine_dependency=required: $($entry.path)"
    }
    if ($entry.evaluation_profile -in @('general-core', 'game-core') -and $entry.engine_dependency -ne 'none') {
        Add-ValidationError "core profiles must declare engine_dependency=none: $($entry.path)"
    }
    if ($entry.evaluation_profile -eq 'integration' -and $entry.id -ne 'ue-studio-orchestrator') {
        Add-ValidationError "Only ue-studio-orchestrator may use integration profile: $($entry.path)"
    }

    $agentContent = Get-Content -LiteralPath $path -Raw
    if ($entry.engine_dependency -eq 'none') {
        $coreForbidden = '(?i)UEGameStudio|engine-reference/unreal|ue-studio-orchestrator|\bUnreal(?:\s+Engine)?\b|\bUE[45]?\b|\bEpic\b|\bGAS\b|GameplayAbility|GameplayTags?|World Partition|Nanite|Lumen|Niagara|MetaSounds?|\bUMG\b|CommonUI|Blueprint|UObject|UPROPERTY|UFUNCTION|BuildGraph|\bUAT\b|\bUBT\b|Gauntlet|Unreal Insights|\bFText\b|Sequencer|Enhanced Input'
        if ($agentContent -match $coreForbidden) {
            Add-ValidationError "Engine-independent core contains Unreal/integration coupling: $($entry.path)"
        }
    }
    if ($entry.evaluation_profile -eq 'unreal-specialist') {
        if ($agentContent -notmatch 'VERSION\.md' -or $agentContent -notmatch '(?i)fail-closed|BLOCKED_UNVERIFIED|未核实') {
            Add-ValidationError "Unreal specialist lacks version fail-closed evidence contract: $($entry.path)"
        }
        if ($agentContent -match 'UEGameStudio|ue-studio-orchestrator') {
            Add-ValidationError "Unreal specialist must not depend on package brand or concrete orchestrator: $($entry.path)"
        }
    }
    if ($entry.id -ne 'ue-studio-orchestrator' -and [string]$entry.integration_owner -ne 'ue-studio-orchestrator') {
        Add-ValidationError "Leaf agent must declare integration_owner=ue-studio-orchestrator in manifest: $($entry.path)"
    }

    if ($yaml -match '(?m)^permissions\s*:') { Add-ValidationError "V2 'permissions' frontmatter is unsupported; package targets stable V1 'permission': $($entry.path)" }
    $permissionMatch = [regex]::Match($yaml, '(?m)^permission:\s*\r?\n(?<block>(?:(?: {2}|\t)[^\r\n]*(?:\r?\n|$))*)')
    if (-not $permissionMatch.Success) {
        Add-ValidationError "Agent lacks stable V1 permission block: $($entry.path)"
        continue
    }
    $permissionBlock = $permissionMatch.Groups['block'].Value
    if ($permissionBlock -notmatch '(?m)^ {2}["'']?\*["'']?:\s*deny\s*$') {
        Add-ValidationError ('Agent permission must contain top-level ''"*": deny'': {0}' -f $entry.path)
    }
    if ($permissionBlock -match '(?m)^ {2}(?:shell|subagent):') {
        Add-ValidationError "V2 shell/subagent permission key found in stable V1 agent: $($entry.path)"
    }

    if ($entry.id -eq 'ue-studio-orchestrator') {
        $taskMatch = [regex]::Match($permissionBlock, '(?m)^ {2}task:\s*\r?\n(?<task>(?: {4}[^\r\n]*(?:\r?\n|$))*)')
        if (-not $taskMatch.Success) {
            Add-ValidationError "Orchestrator task permission must be a deny-first canonical whitelist object: $($entry.path)"
        } else {
            $taskBlock = $taskMatch.Groups['task'].Value
            if ($taskBlock -notmatch '(?m)^ {4}["'']?\*["'']?:\s*deny\s*$') {
                Add-ValidationError ('Orchestrator task whitelist lacks ''"*": deny'': {0}' -f $entry.path)
            }
            $taskEntries = [regex]::Matches($taskBlock, '(?m)^ {4}["'']?(?<id>[a-z*][a-z0-9*-]*)["'']?:\s*(?<effect>allow|ask|deny)\s*$')
            foreach ($taskEntry in $taskEntries) {
                $taskId = $taskEntry.Groups['id'].Value
                if ($taskId -eq '*') { continue }
                if (-not $agentIds.Contains($taskId)) { Add-ValidationError "Orchestrator task whitelist contains non-canonical agent '$taskId': $($entry.path)" }
                if ($taskEntry.Groups['effect'].Value -ne 'allow') { Add-ValidationError "Orchestrator canonical task entry must be allow: $taskId in $($entry.path)" }
            }
            if (@($taskEntries | Where-Object { $_.Groups['id'].Value -ne '*' }).Count -eq 0) {
                Add-ValidationError "Orchestrator task whitelist has no canonical allow entries: $($entry.path)"
            }
        }
    } elseif ($permissionBlock -notmatch '(?m)^ {2}task:\s*deny\s*$') {
        Add-ValidationError "Non-orchestrator agent task permission must be explicit deny: $($entry.path)"
    }
}

foreach ($entry in $manifest.skills) {
    $path = Join-Path $PackageRoot ($entry.path -replace '/', [System.IO.Path]::DirectorySeparatorChar)
    $yaml = Get-FrontMatter $path
    if ($null -eq $yaml) { Add-ValidationError "Skill has no valid frontmatter: $($entry.path)"; continue }
    foreach ($required in @('name', 'description')) {
        if (-not (Get-YamlScalar $yaml $required)) { Add-ValidationError "Skill frontmatter lacks '$required': $($entry.path)" }
    }
    $name = Get-YamlScalar $yaml 'name'
    if ($name -and $name -ne $entry.id) { Add-ValidationError "Skill frontmatter name '$name' differs from manifest ID '$($entry.id)': $($entry.path)" }
}

$templateRelative = 'agents/_template.md'
if (-not (@($manifest.install.excluded) -contains $templateRelative)) {
    Add-ValidationError 'agents/_template.md must be declared in install.excluded.'
}
if ($manifestAgentPaths -contains $templateRelative) {
    Add-ValidationError 'agents/_template.md must never be an installable agent.'
}
$templatePath = Join-Path $PackageRoot 'agents/_template.md'
if (Test-Path -LiteralPath $templatePath -PathType Leaf) {
    $templateContent = Get-Content -LiteralPath $templatePath -Raw
    if ($templateContent -match '(?i)UEGameStudio|engine-reference/unreal|ue-studio-orchestrator|\bUnreal(?:\s+Engine)?\b|\bUE[45]?\b|\bEpic\b') {
        Add-ValidationError 'agents/_template.md must remain engine- and integration-neutral.'
    }
}

$skillSupportFiles = @($manifest.skills | ForEach-Object { $_.files } | ForEach-Object {
    Get-Item -LiteralPath (Join-Path $PackageRoot ($_ -replace '/', [System.IO.Path]::DirectorySeparatorChar))
})
$contentFiles = @($agentFiles + $skillSupportFiles + $docFiles + $referenceFiles + $ruleFiles | Where-Object Extension -in @('.md', '.json', '.yaml', '.yml') | Sort-Object FullName -Unique)
$knownSkillSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$skillIds, [System.StringComparer]::OrdinalIgnoreCase)
$knownAgentSet = [System.Collections.Generic.HashSet[string]]::new([string[]]$agentIds, [System.StringComparer]::OrdinalIgnoreCase)
$platformPatterns = [ordered]@{
    'CLAUDE.md' = '(?i)\bCLAUDE\.md\b'
    'AskUserQuestion' = '\bAskUserQuestion\b'
    'Claude Task tool' = '(?i)(?:\buse\s+Task\b|\bTask\s+(?:tool|spawn)\b|用\s*Task\b)'
}

foreach ($file in $contentFiles) {
    $relative = To-RelativePath $file.FullName
    $content = Get-Content -LiteralPath $file.FullName -Raw
    foreach ($item in $platformPatterns.GetEnumerator()) {
        if ([regex]::IsMatch($content, $item.Value)) { Add-ValidationError "Legacy platform token '$($item.Key)' found in $relative" }
    }

    # Slash commands are only treated as commands when enclosed in inline code.
    # This deliberately excludes URLs, Perforce paths, prose separators, and
    # project artifact paths such as docs/patch-notes/.
    foreach ($match in [regex]::Matches($content, '`/(?<id>[a-z](?:[a-z0-9-]*[a-z0-9])?)(?:\s+[^`]*)?`')) {
        $id = $match.Groups['id'].Value
        if (-not $knownSkillSet.Contains($id)) { Add-ValidationError "Dangling skill command '/$id' in $relative" }
    }

    $lineNumber = 0
    foreach ($line in ($content -split '\r?\n')) {
        $lineNumber++
        if ($line -notmatch '(?i)派发|委派|subagent|spawn|\bagent\b') { continue }
        if ($line -match '禁止|不存在|不得|示例反例') { continue }
        foreach ($match in [regex]::Matches($line, '`(?<id>[a-z][a-z0-9-]{1,})`')) {
            $id = $match.Groups['id'].Value
            $looksLikeRole = $id -match '^(?:ue|unreal)-|-(?:agent|analyst|artist|builder|developer|designer|director|engineer|geographer|historian|lead|manager|orchestrator|programmer|prototyper|psychologist|specialist|tester|writer)$'
            if ($looksLikeRole -and -not $knownAgentSet.Contains($id) -and -not $knownSkillSet.Contains($id)) {
                Add-ValidationError "Possible dangling agent/skill ID '$id' in ${relative}:$lineNumber"
            }
        }
    }

    foreach ($match in [regex]::Matches($content, '(?<![A-Za-z0-9_])(?<path>(?:docs|references|rules)/[^\s`\)\]\"''，。；：]+\.(?:md|json|ya?ml))')) {
        $candidate = $match.Groups['path'].Value
        if ($candidate -match '[\[\]*{}<>]') { continue }
        $isPackageAssetReference = $candidate.StartsWith('references/', [System.StringComparison]::OrdinalIgnoreCase) -or
            $candidate.StartsWith('rules/', [System.StringComparison]::OrdinalIgnoreCase) -or
            $candidate.StartsWith('docs/engine-reference/', [System.StringComparison]::OrdinalIgnoreCase) -or
            $candidate.Equals('docs/workflow-catalog.yaml', [System.StringComparison]::OrdinalIgnoreCase)
        if (-not $isPackageAssetReference) { continue }
        $candidatePath = Join-Path $PackageRoot ($candidate -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        if (-not (Test-Path -LiteralPath $candidatePath -PathType Leaf)) {
            $message = "Unresolved package-relative file reference '$candidate' in $relative"
            if ($StrictReferences) { Add-ValidationError $message } else { Add-ValidationWarning $message }
        }
    }

    foreach ($match in [regex]::Matches($content, '\[[^\]]*\]\((?<target>[^\)]+)\)')) {
        $target = $match.Groups['target'].Value.Trim().Trim('<', '>')
        if ($target -match '^(?:https?://|#|mailto:)' -or $target -match '[*{}\[\]]' -or $target -match '\s') { continue }
        $targetWithoutAnchor = ($target -split '#', 2)[0]
        if (-not $targetWithoutAnchor) { continue }
        $linkPath = if ([System.IO.Path]::IsPathRooted($targetWithoutAnchor)) {
            $targetWithoutAnchor
        } else {
            Join-Path $file.Directory.FullName ($targetWithoutAnchor -replace '/', [System.IO.Path]::DirectorySeparatorChar)
        }
        if (-not (Test-Path -LiteralPath $linkPath)) {
            $message = "Broken relative Markdown link '$target' in $relative"
            if ($StrictReferences) { Add-ValidationError $message } else { Add-ValidationWarning $message }
        }
    }
}

foreach ($warning in $script:warnings | Sort-Object -Unique) { Write-Warning $warning }
if ($script:errors.Count -gt 0) {
    foreach ($message in $script:errors | Sort-Object -Unique) { Write-Error $message -ErrorAction Continue }
    Write-Host "FAILED: $($script:errors.Count) error(s), $($script:warnings.Count) warning(s)."
    exit 1
}

Write-Host "PASS: $($actualCounts.agents) agents, $($actualCounts.skills) skills, $($actualCounts.docs) docs, $($actualCounts.references) references, $($actualCounts.rules) rules."
if ($script:warnings.Count -gt 0) { Write-Host "$($script:warnings.Count) best-effort reference warning(s); use -StrictReferences to make them fatal." }
exit 0

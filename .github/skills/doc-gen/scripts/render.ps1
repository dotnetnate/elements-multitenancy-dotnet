#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Render one or more canonical doc-gen models to a linked documentation tree.

.DESCRIPTION
    Flat MSDN-style layout (no per-namespace or per-type folders). Output layout:

        <OutputDir>/
          README.<Format>                                 (workspace index; by aggregate-workspace.ps1)
          <Project>/
            README.<Format>                               (project index)
            <Namespace>.<Format>                          (one page per namespace)
            <Namespace>.<TypeName>[-<arity>].<Format>     (one page per type)
            <Namespace>.<TypeName>[-<arity>].<MemberName>.<Format>   (one page per member; overloads grouped)

    Cross-reference markers `{{xref:<id>|<label>}}` emitted by the normalizer
    are resolved to relative markdown links in a post-pass.

    Every generated file begins with `<!-- doc-gen -->` so the aggregator can
    safely prune stale pages without touching user-authored files.
#>
[CmdletBinding(DefaultParameterSetName='Single')]
param(
    [Parameter(Mandatory, ParameterSetName='Single')][string]$ModelPath,
    [Parameter(Mandatory, ParameterSetName='Multi')][string[]]$ModelPaths,
    [string]$Style = 'msdn',
    [string]$Format = 'md',
    [Parameter(Mandatory)][string]$OutputDir,
    [switch]$WriteProjectIndex = $true,
    [switch]$ManifestOnly
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$agentRoot      = Split-Path -Parent $PSScriptRoot
$stylesRoot     = Join-Path $agentRoot 'resources/styles'
$styleDir       = Join-Path $stylesRoot $Style
$formatDir      = Join-Path $styleDir $Format
$partialsDir    = Join-Path $formatDir 'partials'
$dictionaryPath = Join-Path $agentRoot 'shared/token-dictionary.json'
$marker         = '<!-- doc-gen -->'

if (-not (Test-Path -LiteralPath $formatDir)) {
    throw "Style/format not found: $formatDir."
}

if ($PSCmdlet.ParameterSetName -eq 'Single') { $ModelPaths = @($ModelPath) }
$models = @()
foreach ($p in $ModelPaths) {
    $models += (Get-Content -LiteralPath $p -Raw | ConvertFrom-Json -Depth 64)
}

$dictionary = Get-Content -LiteralPath $dictionaryPath -Raw | ConvertFrom-Json -Depth 32
$language   = $models[0].language
$typeKinds  = @('class','interface','struct','record','record struct','enum','delegate')

# ---------------------------------------------------------- Path segment helpers

function Sanitize-Segment([string]$s) {
    if (-not $s) { return '' }
    $t = $s
    $t = $t -replace '[<>]',''
    $t = $t -replace '`','-'            # generic arity backtick -> dash
    $t = $t -replace '[\\/:*?"|]','_'
    $t = $t -replace '[(),\s]+','_'
    $t = $t -replace '_+','_'
    $t = $t -replace '-+','-'
    $t.Trim('_').Trim('-')
}

function Format-TypeStem([object]$t) {
    $ns = if ($t.PSObject.Properties['namespace']) { $t.namespace } else { '' }
    $short = if ($t.PSObject.Properties['nameShort'] -and $t.nameShort) { $t.nameShort } else { $t.name }
    $stem = if ($ns) { "$ns.$short" } else { $short }
    # Use type-parameter names (not arity count) when present, e.g.
    # `MyOrg.Elements.Mapping.ITypeMapper-TSource-TDestination`.
    $tps = @()
    if ($t.PSObject.Properties['typeParameters'] -and $t.typeParameters) {
        $tps = @($t.typeParameters)
    }
    if ($tps.Count -gt 0) {
        $names = foreach ($tp in $tps) {
            if ($tp -is [string]) { $tp }
            elseif ($tp -and $tp.PSObject.Properties['name']) { $tp.name }
            else { "$tp" }
        }
        $stem = "$stem-$($names -join '-')"
    } elseif ($t.PSObject.Properties['arity'] -and [int]$t.arity -gt 0) {
        # Fallback for elements that lack typeParameters but report arity.
        $stem = "$stem-$([int]$t.arity)"
    }
    Sanitize-Segment $stem
}

function Format-MemberStem([object]$m, [string]$overloadSuffix) {
    $name = $m.name
    # MSDN convention: constructors are rendered as `-ctor` in URLs
    # (mirroring the `#ctor` CLR name with `#` -> `-`).
    if ($m.PSObject.Properties['kind'] -and $m.kind -eq 'constructor') {
        $stem = '-ctor'
        if ($overloadSuffix) { $stem = "-ctor-$overloadSuffix" }
        return $stem
    }
    if ($name -eq 'this[]') { $name = 'Item' }
    $stem = Sanitize-Segment $name
    if ($overloadSuffix) { $stem = "$stem-$overloadSuffix" }
    $stem
}

# ---------------------------------------------------------- Indexes

$byId = @{}
foreach ($m in $models) {
    foreach ($el in $m.elements) { $byId[$el.id] = $el }
}
$script:byId = $byId

# Owning project per element id.
$projectOfId = @{}
foreach ($m in $models) {
    foreach ($el in $m.elements) { $projectOfId[$el.id] = $m.project }
}

# Pre-compute href map + overload groups.
# MSDN convention: one page per (type, memberName) group. All overloads
# share the same page and are rendered as separate sections.
$hrefMap        = @{}
$memberGroupKey = @{}          # elementId -> group key
$memberGroups   = @{}          # group key -> list of elements (ordered)
$groupTypeId    = @{}          # group key -> owning typeId
$groupHref      = @{}          # group key -> href

foreach ($m in $models) {
    $proj = Sanitize-Segment $m.project

    # Types
    foreach ($t in ($m.elements | Where-Object { $typeKinds -contains $_.kind })) {
        $hrefMap[$t.id] = "$proj/$(Format-TypeStem $t).$Format"
    }

    # Namespaces
    foreach ($n in ($m.elements | Where-Object { $_.kind -eq 'namespace' })) {
        $seg = Sanitize-Segment $n.name
        $hrefMap[$n.id] = "$proj/$seg.$Format"
    }

    # Members: group by (typeId, sanitized member name). One page per group.
    foreach ($t in ($m.elements | Where-Object { $typeKinds -contains $_.kind })) {
        $typeStem = Format-TypeStem $t
        $members = @($m.elements | Where-Object {
            $_.PSObject.Properties['parent'] -and $_.parent -eq $t.id
        })
        foreach ($mm in $members) {
            $stem   = Format-MemberStem $mm ''
            $gkey   = "$($t.id)::$stem"
            if (-not $memberGroups.ContainsKey($gkey)) {
                $memberGroups[$gkey] = [System.Collections.Generic.List[object]]::new()
                $groupTypeId[$gkey]  = $t.id
                $groupHref[$gkey]    = "$proj/$typeStem.$stem.$Format"
            }
            [void]$memberGroups[$gkey].Add($mm)
            $memberGroupKey[$mm.id] = $gkey
            $hrefMap[$mm.id]        = $groupHref[$gkey]
        }
    }
}

function Resolve-Href([string]$id) {
    if (-not $id) { return '' }
    if ($hrefMap.ContainsKey($id)) { return $hrefMap[$id] }
    return ''
}

function Get-RelativeHref {
    param([string]$FromPath, [string]$ToPath)
    if (-not $ToPath) { return '' }
    $fromDir = Split-Path -Parent $FromPath
    if (-not $fromDir) { return $ToPath }
    $fromParts = @($fromDir -split '[/\\]' | Where-Object { $_ -ne '' })
    $toParts   = @($ToPath  -split '[/\\]' | Where-Object { $_ -ne '' })
    $common = 0
    while ($common -lt $fromParts.Count -and $common -lt $toParts.Count -and $fromParts[$common] -eq $toParts[$common]) {
        $common++
    }
    $upCount = $fromParts.Count - $common
    $up = @()
    for ($i = 0; $i -lt $upCount; $i++) { $up += '..' }
    $rest = @()
    if ($common -lt $toParts.Count) { $rest = $toParts[$common..($toParts.Count - 1)] }
    $combined = $up + $rest
    if ($combined.Count -eq 0) { return (Split-Path -Leaf $ToPath) }
    $combined -join '/'
}

# ---------------------------------------------------------- Dictionary tokens

function Get-Token([string]$key) {
    $parts = $key -split '\.', 2
    $name = if ($parts.Count -eq 2) { $parts[1] } else { $key }
    if ($dictionary.labels.PSObject.Properties.Name -contains $key) {
        $v = $dictionary.labels.$key
        if ($v.PSObject.Properties.Name -contains $language) { return $v.$language }
    }
    if ($dictionary.labels.PSObject.Properties.Name -contains $name) {
        $v = $dictionary.labels.$name
        if ($v.PSObject.Properties.Name -contains $language) { return $v.$language }
    }
    return ''
}

# ---------------------------------------------------------- Value access

function Get-Value {
    param([object]$Context, [string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return $null }
    if ($Path -match '^(typeLabel|memberLabel|section|heading|label)\.') { return Get-Token $Path }
    if ($Path -eq 'codeLanguage') { return $dictionary.codeLanguage.$language }
    if ($Path -eq 'typeLabel') {
        $k = if ($Context -is [psobject] -and $Context.PSObject.Properties.Name -contains 'kind') { $Context.kind } else { '' }
        return Get-Token "typeLabel.$k"
    }
    if ($dictionary.labels.PSObject.Properties.Name -contains $Path) {
        $v = $dictionary.labels.$Path
        if ($v.PSObject.Properties.Name -contains $language) { return $v.$language }
    }
    if ($Path.StartsWith('parent.')) {
        if ($Context -is [psobject] -and $Context.PSObject.Properties.Name -contains 'parentObj' -and $Context.parentObj) {
            return Get-Value -Context $Context.parentObj -Path ($Path.Substring(7))
        }
        return $null
    }
    $cur = $Context
    foreach ($part in $Path.Split('.')) {
        if ($null -eq $cur) { return $null }
        if ($cur -is [System.Collections.IDictionary]) {
            if ($cur.Contains($part)) { $cur = $cur[$part] } else { return $null }
        } elseif ($cur -is [psobject] -and $cur.PSObject.Properties.Name -contains $part) {
            $cur = $cur.$part
        } else {
            return $null
        }
    }
    return $cur
}

function Test-Truthy($v) {
    if ($null -eq $v) { return $false }
    if ($v -is [bool]) { return $v }
    if ($v -is [string]) { return $v.Length -gt 0 }
    if ($v -is [System.Collections.IEnumerable] -and -not ($v -is [string])) {
        return @($v).Count -gt 0
    }
    return $true
}

# ---------------------------------------------------------- Enrich elements

foreach ($m in $models) {
    foreach ($el in $m.elements) {
        foreach ($prop in 'seeAlso','inheritance','implements','derived') {
            if ($el.PSObject.Properties.Name -contains $prop -and $el.$prop) {
                foreach ($ref in $el.$prop) {
                    if ($ref -is [psobject] -and ($ref.PSObject.Properties.Name -contains 'id')) {
                        $resolved = Resolve-Href $ref.id
                        if ($ref.PSObject.Properties.Name -contains 'href') { $ref.href = $resolved }
                        else { $ref | Add-Member -NotePropertyName href -NotePropertyValue $resolved -Force }
                    }
                }
            }
        }
        if ($el.PSObject.Properties.Name -contains 'parent' -and $el.parent -and $byId.ContainsKey($el.parent)) {
            $el | Add-Member -NotePropertyName parentObj -NotePropertyValue $byId[$el.parent] -Force
        }
        # Resolve exception hrefs.
        if ($el.PSObject.Properties.Name -contains 'exceptions' -and $el.exceptions) {
            foreach ($ex in $el.exceptions) {
                if ($ex -is [psobject] -and $ex.PSObject.Properties.Name -contains 'type' -and $ex.type) {
                    $rel = Resolve-Href $ex.type
                    if ($ex.PSObject.Properties.Name -contains 'href') { $ex.href = $rel }
                    else { $ex | Add-Member -NotePropertyName href -NotePropertyValue $rel -Force }
                }
            }
        }
    }
}

# Attach grouped child rows onto each type element.
foreach ($m in $models) {
    foreach ($el in $m.elements) {
        if ($typeKinds -notcontains $el.kind) { continue }
        $children = @($m.elements | Where-Object { $_.PSObject.Properties.Name -contains 'parent' -and $_.parent -eq $el.id })
        $toRow = {
            param($mm)
            $sigShort = if ($mm.PSObject.Properties['signatureShort'] -and $mm.signatureShort) { $mm.signatureShort } else { $mm.name }
            # For grouped methods/operators/constructors, the link label is the member
            # name - all overloads share the same page. Single-member groups keep sig.
            $label = $sigShort
            if ($memberGroupKey.ContainsKey($mm.id)) {
                $gkey = $memberGroupKey[$mm.id]
                if ($memberGroups[$gkey].Count -gt 1) { $label = $mm.name }
            }
            $linkMarker = "{{xref:$($mm.id)|$label}}"
            [pscustomobject]@{
                name           = $mm.name
                signatureShort = $sigShort
                href           = Resolve-Href $mm.id
                link           = $linkMarker
                summary        = $mm.summary
                type           = if ($mm.PSObject.Properties.Name -contains 'returns' -and $mm.returns) { $mm.returns.type } else { '' }
                value          = if ($mm.PSObject.Properties.Name -contains 'value') { $mm.value } else { '' }
                isStatic       = [bool]($mm.PSObject.Properties['isStatic'] -and $mm.isStatic)
                groupKey       = if ($memberGroupKey.ContainsKey($mm.id)) { $memberGroupKey[$mm.id] } else { $mm.id }
            }
        }
        # Deduplicate rows whose link+label collide (overload groups).
        $dedupe = {
            param($rows)
            $seen = @{}
            $out = @()
            foreach ($r in $rows) {
                $k = if ($r.PSObject.Properties['groupKey'] -and $r.groupKey) { $r.groupKey } else { "$($r.link)|$($r.type)" }
                if ($seen.ContainsKey($k)) { continue }
                $seen[$k] = $true
                $out += $r
            }
            $out
        }
        $ctors = @($children | Where-Object { $_.kind -eq 'constructor' } | ForEach-Object { & $toRow $_ })
        $fld   = @($children | Where-Object { $_.kind -eq 'field' }       | ForEach-Object { & $toRow $_ })
        $prop  = @($children | Where-Object { $_.kind -eq 'property' }    | ForEach-Object { & $toRow $_ })
        $mth   = @($children | Where-Object { $_.kind -eq 'method' }      | ForEach-Object { & $toRow $_ })
        $evt   = @($children | Where-Object { $_.kind -eq 'event' }       | ForEach-Object { & $toRow $_ })
        $op    = @($children | Where-Object { $_.kind -eq 'operator' }    | ForEach-Object { & $toRow $_ })
        $el | Add-Member -NotePropertyName constructors     -NotePropertyValue (& $dedupe $ctors) -Force
        $el | Add-Member -NotePropertyName fields           -NotePropertyValue (& $dedupe $fld)  -Force
        $el | Add-Member -NotePropertyName properties       -NotePropertyValue (& $dedupe $prop) -Force
        $el | Add-Member -NotePropertyName methods          -NotePropertyValue (& $dedupe $mth)  -Force
        $el | Add-Member -NotePropertyName events           -NotePropertyValue (& $dedupe $evt)  -Force
        $el | Add-Member -NotePropertyName operators        -NotePropertyValue (& $dedupe $op)   -Force
        $el | Add-Member -NotePropertyName extensionMethods -NotePropertyValue @() -Force
    }
}

# ---------------------------------------------------------- Mustache engine

function Expand-Partial([string]$name) {
    $p = Join-Path $partialsDir "$name.$Format"
    if (-not (Test-Path -LiteralPath $p)) { return '' }
    Get-Content -LiteralPath $p -Raw
}

function Render-Template {
    param([string]$Template, [object]$Context)
    $out = [regex]::Replace($Template, '\{\{>\s*([\w-]+)\s*\}\}', { param($m) Expand-Partial $m.Groups[1].Value })
    $out = Expand-EachBlocks -Template $out -Context $Context
    $out = Expand-IfBlocks -Template $out -Context $Context
    $out = [regex]::Replace($out, '\{\{\s*([@\w.]+)\s*\}\}', {
        param($m)
        $key = $m.Groups[1].Value
        if ($key.StartsWith('@')) { return $m.Value }
        $v = Get-Value -Context $Context -Path $key

        if ($null -eq $v) { return '' }
        if ($v -is [System.Collections.IEnumerable] -and -not ($v -is [string])) { return '' }
        "$v"
    })
    $out
}

function Expand-IfBlocks {
    param([string]$Template, [object]$Context)
    $out = [System.Text.StringBuilder]::new()
    $i = 0
    $len = $Template.Length
    while ($i -lt $len) {
        # Find next {{#if / {{#unless
        $openRx = [regex]::new('\{\{#(if|unless)\s+([@\w.]+)\s*\}\}')
        $m = $openRx.Match($Template, $i)
        if (-not $m.Success) {
            [void]$out.Append($Template.Substring($i))
            break
        }
        [void]$out.Append($Template.Substring($i, $m.Index - $i))
        $op = $m.Groups[1].Value
        $path = $m.Groups[2].Value
        $bodyStart = $m.Index + $m.Length
        # Find matching {{/if}} or {{/unless}} with depth tracking.
        $depth = 1
        $cursor = $bodyStart
        $tokenRx = [regex]::new('\{\{#(?:if|unless)\s+[@\w.]+\s*\}\}|\{\{/(?:if|unless)\}\}')
        $close = -1
        while ($cursor -lt $len) {
            $tm = $tokenRx.Match($Template, $cursor)
            if (-not $tm.Success) { break }
            if ($tm.Value.StartsWith('{{#')) { $depth++ }
            else { $depth-- }
            if ($depth -eq 0) { $close = $tm.Index; break }
            $cursor = $tm.Index + $tm.Length
        }
        if ($close -lt 0) {
            # unbalanced; emit rest and stop.
            [void]$out.Append($Template.Substring($m.Index))
            $i = $len
            break
        }
        $body = $Template.Substring($bodyStart, $close - $bodyStart)
        $closeTag = [regex]::Match($Template.Substring($close), '^\{\{/(?:if|unless)\}\}').Value
        $v = Get-Value -Context $Context -Path $path
        $truthy = Test-Truthy $v
        $emit = ($op -eq 'if' -and $truthy) -or ($op -eq 'unless' -and -not $truthy)
        if ($emit) {
            # Recurse so nested blocks are handled now with the same context.
            [void]$out.Append((Expand-IfBlocks -Template $body -Context $Context))
        }
        $i = $close + $closeTag.Length
    }
    $out.ToString()
}

function Expand-EachBlocks {
    param([string]$Template, [object]$Context)
    $out = [System.Text.StringBuilder]::new()
    $i = 0
    $len = $Template.Length
    while ($i -lt $len) {
        $openRx = [regex]::new('\{\{#each\s+([\w.]+)\s*\}\}')
        $m = $openRx.Match($Template, $i)
        if (-not $m.Success) {
            [void]$out.Append($Template.Substring($i))
            break
        }
        [void]$out.Append($Template.Substring($i, $m.Index - $i))
        $path = $m.Groups[1].Value
        $bodyStart = $m.Index + $m.Length
        $depth = 1
        $cursor = $bodyStart
        $tokenRx = [regex]::new('\{\{#each\s+[\w.]+\s*\}\}|\{\{/each\}\}')
        $close = -1
        while ($cursor -lt $len) {
            $tm = $tokenRx.Match($Template, $cursor)
            if (-not $tm.Success) { break }
            if ($tm.Value.StartsWith('{{#')) { $depth++ }
            else { $depth-- }
            if ($depth -eq 0) { $close = $tm.Index; break }
            $cursor = $tm.Index + $tm.Length
        }
        if ($close -lt 0) {
            [void]$out.Append($Template.Substring($m.Index))
            $i = $len
            break
        }
        $body = $Template.Substring($bodyStart, $close - $bodyStart)
        $closeEnd = [regex]::Match($Template.Substring($close), '^\{\{/each\}\}').Length
        $items = Get-Value -Context $Context -Path $path
        if ($items) {
            $arr = @($items)
            for ($k = 0; $k -lt $arr.Count; $k++) {
                $item = $arr[$k]
                if (-not ($item -is [psobject]) -and -not ($item -is [System.Collections.IDictionary])) {
                    $item = [pscustomobject]@{ value = $item }
                }
                $item | Add-Member -NotePropertyName '@first' -NotePropertyValue ($k -eq 0) -Force
                $item | Add-Member -NotePropertyName '@last'  -NotePropertyValue ($k -eq $arr.Count - 1) -Force
                $item | Add-Member -NotePropertyName '@index' -NotePropertyValue $k -Force
                $chunk = $body
                $chunk = Expand-IfBlocks   -Template $chunk -Context $item
                $chunk = Expand-EachBlocks -Template $chunk -Context $item
                $chunk = [regex]::Replace($chunk, '\{\{\s*([\w.@]+)\s*\}\}', {
                    param($mm)
                    $key = $mm.Groups[1].Value
                    $v = Get-Value -Context $item -Path $key
                    if ($null -eq $v) { return '' }
                    if ($v -is [bool]) { return '' }
                    "$v"
                })
                [void]$out.Append($chunk)
            }
        }
        $i = $close + $closeEnd
    }
    $out.ToString()
}

# ---------------------------------------------------------- Template selection

function Select-Template([string]$kind) {
    $candidates = @{
        'class'            = @('class')
        'interface'        = @('interface','class')
        'struct'           = @('struct','class')
        'record'           = @('record','class')
        'record struct'    = @('record','struct','class')
        'enum'             = @('enum','class')
        'delegate'         = @('delegate','method')
        'method'           = @('method')
        'extension-method' = @('method')
        'constructor'      = @('constructor')
        'property'         = @('property')
        'field'            = @('field')
        'event'            = @('event','field')
        'operator'         = @('operator')
        'namespace'        = @('namespace-index')
    }
    $list = $candidates[$kind]
    if (-not $list) { return $null }
    foreach ($name in $list) {
        $p = Join-Path $formatDir "$name.$Format"
        if (Test-Path -LiteralPath $p) { return $p }
    }
    return $null
}

function Write-Page([string]$relHref, [string]$content) {
    $body = "$marker`n$content"
    $body = [regex]::Replace($body, '(\r?\n){3,}', "`n`n")
    $outPath = Join-Path $OutputDir $relHref
    $outDir = Split-Path -Parent $outPath
    if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
        New-Item -ItemType Directory -Path $outDir -Force | Out-Null
    }
    Set-Content -LiteralPath $outPath -Value $body -Encoding UTF8
    $script:writtenFiles[$relHref.Replace('\','/')] = $true
}

# ---------------------------------------------------------- Render

if (-not (Test-Path -LiteralPath $OutputDir)) {
    New-Item -ItemType Directory -Path $OutputDir -Force | Out-Null
}

$script:writtenFiles = @{}
$rendered = 0
$skipped  = 0

if (-not $ManifestOnly) {
    $renderedGroups = @{}
    foreach ($m in $models) {
        foreach ($el in $m.elements) {
            # Skip non-canonical overload members; they share their group's page.
            if ($memberGroupKey.ContainsKey($el.id)) {
                $gkey = $memberGroupKey[$el.id]
                if ($renderedGroups.ContainsKey($gkey)) { continue }
                $renderedGroups[$gkey] = $true
                $group = @($memberGroups[$gkey])
                $head  = $group[0]
                $tpl   = Select-Template $head.kind
                if (-not $tpl) { $skipped++; continue }
                $relHref = $hrefMap[$head.id]
                if (-not $relHref) { $skipped++; continue }
                if ($group.Count -gt 1) {
                    # Synthetic combined context: inherit kind/name/parent from first,
                    # expose 'overloads' list of per-overload contexts.
                    $mergedSeeAlso = @()
                    $seenSee = @{}
                    foreach ($ov in $group) {
                        if ($ov.PSObject.Properties['seeAlso'] -and $ov.seeAlso) {
                            foreach ($sa in $ov.seeAlso) {
                                $key = if ($sa -is [psobject] -and $sa.PSObject.Properties['id']) { $sa.id } else { "$sa" }
                                if (-not $seenSee.ContainsKey($key)) {
                                    $seenSee[$key] = $true
                                    $mergedSeeAlso += $sa
                                }
                            }
                        }
                    }
                    $combined = [pscustomobject]@{
                        id             = $gkey
                        kind           = $head.kind
                        name           = $head.name
                        parent         = $head.parent
                        parentObj      = if ($head.PSObject.Properties['parentObj']) { $head.parentObj } else { $null }
                        namespace      = $head.namespace
                        assembly       = $head.assembly
                        signature      = $head.signature
                        signatureShort = $head.signatureShort
                        summary        = $head.summary
                        overloads      = $group
                        isStatic       = $head.isStatic
                        seeAlso        = $mergedSeeAlso
                    }
                    $content = Render-Template -Template (Get-Content -LiteralPath $tpl -Raw) -Context $combined
                } else {
                    $content = Render-Template -Template (Get-Content -LiteralPath $tpl -Raw) -Context $head
                }
                Write-Page $relHref $content
                $rendered++
                continue
            }
            # Non-member elements: types and namespaces.
            $tpl = Select-Template $el.kind
            if (-not $tpl) { $skipped++; continue }
            $relHref = $hrefMap[$el.id]
            if (-not $relHref) { $skipped++; continue }
            $content = Render-Template -Template (Get-Content -LiteralPath $tpl -Raw) -Context $el
            Write-Page $relHref $content
            $rendered++
        }
    }
}

# ---------------------------------------------------------- Project index

if ($WriteProjectIndex) {
    $projectIndexTpl = Join-Path $formatDir "project-index.$Format"
    if (Test-Path -LiteralPath $projectIndexTpl) {
        $tplText = Get-Content -LiteralPath $projectIndexTpl -Raw
        foreach ($m in $models) {
            $projectSeg = Sanitize-Segment $m.project
            $relHref = "$projectSeg/README.$Format"
            $groups = @{ class=@(); interface=@(); struct=@(); record=@(); enum=@(); delegate=@() }
            foreach ($el in $m.elements) {
                $k = $el.kind
                if ($k -eq 'record struct') { $k = 'struct' }
                if ($groups.ContainsKey($k)) {
                    $groups[$k] += [pscustomobject]@{
                        name      = $el.name
                        fullName  = if ($el.PSObject.Properties['fullNameDisplay']) { $el.fullNameDisplay } else { $el.fullName }
                        namespace = $el.namespace
                        href      = Get-RelativeHref -FromPath $relHref -ToPath $hrefMap[$el.id]
                        summary   = $el.summary
                    }
                }
            }
            $ctx = [pscustomobject]@{
                project          = $m.project
                language         = $m.language
                version          = if ($m.PSObject.Properties.Name -contains 'version')  { $m.version }  else { '' }
                assembly         = if ($m.PSObject.Properties.Name -contains 'assembly') { $m.assembly } else { '' }
                defaultNamespace = if ($m.PSObject.Properties.Name -contains 'defaultNamespace') { $m.defaultNamespace } else { '' }
                classes          = $groups.class
                interfaces       = $groups.interface
                structs          = $groups.struct
                records          = $groups.record
                enums            = $groups.enum
                delegates        = $groups.delegate
                hasClasses       = ($groups.class.Count    -gt 0)
                hasInterfaces    = ($groups.interface.Count -gt 0)
                hasStructs       = ($groups.struct.Count    -gt 0)
                hasRecords       = ($groups.record.Count    -gt 0)
                hasEnums         = ($groups.enum.Count      -gt 0)
                hasDelegates     = ($groups.delegate.Count  -gt 0)
            }
            $content = Render-Template -Template $tplText -Context $ctx
            Write-Page $relHref $content
        }
    }
}

# ---------------------------------------------------------- xref resolution

$markerPattern = '\{\{xref:(.+?)\|(.*?)\}\}'
$allFiles = @(Get-ChildItem -LiteralPath $OutputDir -Recurse -File -Filter "*.$Format")
$outputFull = (Resolve-Path -LiteralPath $OutputDir).Path
foreach ($f in $allFiles) {
    $text = Get-Content -LiteralPath $f.FullName -Raw
    if ($text -notmatch $markerPattern) { continue }
    $relFromRoot = $f.FullName.Substring($outputFull.Length).TrimStart('\','/') -replace '\\','/'
    $new = [regex]::Replace($text, $markerPattern, {
        param($mm)
        $id = $mm.Groups[1].Value
        $label = $mm.Groups[2].Value
        if ([string]::IsNullOrWhiteSpace($label)) {
            $label = (($id -split '[.\(]' | Select-Object -Last 1) -replace '`\d+','')
        }
        $target = Resolve-Href $id
        if ($target) {
            $rel = Get-RelativeHref -FromPath $relFromRoot -ToPath $target
            return "[$label]($rel)"
        }
        return "``$label``"
    })
    if ($new -ne $text) {
        Set-Content -LiteralPath $f.FullName -Value $new -Encoding UTF8
    }
}

[pscustomobject]@{
    projects     = @($models | ForEach-Object { $_.project })
    style        = $Style
    format       = $Format
    output       = $outputFull
    rendered     = $rendered
    skipped      = $skipped
    files        = $script:writtenFiles.Count
    writtenFiles = @($script:writtenFiles.Keys)
} | ConvertTo-Json -Compress -Depth 8

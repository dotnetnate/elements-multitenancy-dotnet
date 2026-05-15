#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Normalize .NET API surface + compiler XML doc into the doc-gen canonical
    JSON model.

.DESCRIPTION
    The surface JSON (produced by the DocSurfaceScan Roslyn tool) is the source
    of truth for the API structure: which types and members exist, their
    visibility, kinds, property/field/return types, and so on. The compiler
    XML doc file is a side-table of summaries, remarks, params, returns, and
    other prose indexed by doc-id.

    Only externally-visible (public / public-facing protected) symbols are
    emitted by the surface scanner, so non-public members are filtered out
    automatically. Member entries without surface coverage (e.g. compiler-
    generated) are silently dropped.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$XmlPath,
    [Parameter(Mandatory)][string]$SurfacePath,
    [Parameter(Mandatory)][string]$OutputModel,
    [string]$Project = ''
)

$ErrorActionPreference = 'Stop'
# Relaxed strict mode: optional properties on PSCustomObject are accessed
# via guarded .PSObject.Properties[...] lookups throughout.
Set-StrictMode -Off

if (-not (Test-Path -LiteralPath $SurfacePath)) { throw "Surface JSON not found: $SurfacePath" }
$surface = Get-Content -LiteralPath $SurfacePath -Raw | ConvertFrom-Json
if (-not (Test-Path -LiteralPath $XmlPath)) { throw "XML doc file not found: $XmlPath" }
[xml]$xml = Get-Content -LiteralPath $XmlPath -Raw

$assemblyName = ''
$nameNode = $xml.SelectSingleNode('//doc/assembly/name')
if ($nameNode) { $assemblyName = $nameNode.InnerText }
if (-not $assemblyName) { $assemblyName = $surface.assemblyName }
if (-not $Project) { $Project = $assemblyName }

$defaultNamespace = if ($surface.PSObject.Properties['defaultNamespace']) { $surface.defaultNamespace } else { '' }

# ------------------------------------------------------------------ Helpers

function Convert-DocNode([System.Xml.XmlNode]$node) {
    if (-not $node) { return '' }
    $text = $node.InnerXml
    $text = [regex]::Replace($text, '<see\s+cref="([^"]+)"\s*/>', {
            param($x)
            $c = $x.Groups[1].Value
            $last = (($c -split '[.\(]') | Select-Object -Last 1) -replace '`\d+', ''
            "{{xref:$c|$last}}"
        })
    $text = [regex]::Replace($text, '<see\s+cref="([^"]+)"\s*>(.*?)</see>', {
            param($x)
            $c = $x.Groups[1].Value
            $label = $x.Groups[2].Value.Trim()
            if (-not $label) { $label = ((($c -split '[.\(]') | Select-Object -Last 1) -replace '`\d+', '') }
            "{{xref:$c|$label}}"
        }, 'Singleline')
    $text = [regex]::Replace($text, '<see\s+langword="([^"]+)"\s*/>', '`$1`')
    $text = [regex]::Replace($text, '<paramref\s+name="([^"]+)"\s*/>', '`$1`')
    $text = [regex]::Replace($text, '<typeparamref\s+name="([^"]+)"\s*/>', '`$1`')
    $text = [regex]::Replace($text, '<c>(.*?)</c>', '`$1`')
    $text = [regex]::Replace($text, '<code[^>]*>(.*?)</code>', {
            param($x) "`n```````n$($x.Groups[1].Value.Trim())`n``````"
        }, 'Singleline')
    $text = [regex]::Replace($text, '<para>(.*?)</para>', "`$1`n`n", 'Singleline')
    $text = [regex]::Replace($text, '<[^>]+>', '')
    $text = [System.Net.WebUtility]::HtmlDecode($text)
    ($text -replace '\s+', ' ').Trim()
}

function Read-DocBody([System.Xml.XmlNode]$m) {
    $params = @()
    foreach ($p in $m.SelectNodes('param')) {
        $params += [pscustomobject]@{ name = $p.GetAttribute('name'); summary = (Convert-DocNode $p) }
    }
    $typeParams = @()
    foreach ($p in $m.SelectNodes('typeparam')) {
        $typeParams += [pscustomobject]@{ name = $p.GetAttribute('name'); summary = (Convert-DocNode $p) }
    }
    $exceptions = @()
    foreach ($e in $m.SelectNodes('exception')) {
        $exceptions += [pscustomobject]@{ type = $e.GetAttribute('cref'); summary = (Convert-DocNode $e) }
    }
    $examples = @()
    foreach ($ex in $m.SelectNodes('example')) {
        $code = ''
        $codeNode = $ex.SelectSingleNode('code')
        if ($codeNode) {
            # Strip the common leading indentation that the C# compiler adds when it
            # aligns <code> content to match the surrounding <member> element's indent.
            $raw = $codeNode.InnerText
            $lines = $raw -split '\r?\n'
            # Find the minimum indent width among non-blank lines.
            $minIndent = ($lines | Where-Object { $_ -match '\S' } | ForEach-Object {
                    ($_ -match '^(\s*)') | Out-Null; $Matches[1].Length
                } | Measure-Object -Minimum).Minimum
            if ($minIndent -gt 0) {
                $lines = $lines | ForEach-Object {
                    if ($_ -match '^\s{0,' + $minIndent + '}$') { '' }
                    else { $_.Substring([Math]::Min($minIndent, $_.Length)) }
                }
            }
            $code = ($lines -join "`n").Trim()
        }
        $caption = (Convert-DocNode $ex) -replace '```[\s\S]*?```', ''
        $examples += [pscustomobject]@{ caption = $caption.Trim(); language = 'csharp'; code = $code }
    }
    $seeAlso = @()
    foreach ($s in $m.SelectNodes('seealso')) {
        $cr = $s.GetAttribute('cref')
        if ($cr) {
            $label = (($cr -split '[.\(]') | Select-Object -Last 1) -replace '`\d+', ''
            $seeAlso += [pscustomobject]@{ id = $cr; text = $label; href = '' }
        }
    }

    [pscustomobject]@{
        summary    = (Convert-DocNode $m.SelectSingleNode('summary'))
        remarks    = (Convert-DocNode $m.SelectSingleNode('remarks'))
        returns    = (Convert-DocNode $m.SelectSingleNode('returns'))
        value      = (Convert-DocNode $m.SelectSingleNode('value'))
        params     = $params
        typeParams = $typeParams
        exceptions = $exceptions
        examples   = $examples
        seeAlso    = $seeAlso
    }
}

function Format-GenericSig([string]$baseName, $typeParams) {
    if (-not $typeParams) { return $baseName }
    $list = @($typeParams)
    if ($list.Count -eq 0) { return $baseName }
    $names = foreach ($tp in $list) {
        if ($tp -is [string]) { $tp }
        elseif ($tp -and $tp.PSObject.Properties['name']) { $tp.name }
        else { "$tp" }
    }
    "$baseName<$($names -join ', ')>"
}

function Format-ParamType([string]$type, [object]$typeDecl, [object]$methodDecl) {
    # Surface scanner records parameter types as source text, so generic
    # arguments are already by name (T, TKey, etc.). Nothing to substitute.
    if ([string]::IsNullOrEmpty($type)) { return '' }
    return $type
}

function Format-MemberSignature([object]$member, [object]$type) {
    switch ($member.kind) {
        'constructor' {
            $args = if ($member.parameters) { ($member.parameters | ForEach-Object { $_.type }) -join ', ' } else { '' }
            return "$($type.name)($args)"
        }
        'method' {
            $args = if ($member.parameters) { ($member.parameters | ForEach-Object { $_.type }) -join ', ' } else { '' }
            $name = $member.name
            if ($member.typeParameters -and $member.typeParameters.Count -gt 0) {
                $name = Format-GenericSig $name $member.typeParameters
            }
            return "$name($args)"
        }
        'operator' {
            $args = if ($member.parameters) { ($member.parameters | ForEach-Object { $_.type }) -join ', ' } else { '' }
            return "$($member.name)($args)"
        }
        'property' {
            if ($member.parameters -and $member.parameters.Count -gt 0) {
                $args = ($member.parameters | ForEach-Object { $_.type }) -join ', '
                return "this[$args]"
            }
            return $member.name
        }
        default { return $member.name }
    }
}

# Map C# type aliases to CLR type names used in compiler-emitted doc-ids.
$script:csharpToClr = @{
    'object'  = 'System.Object'
    'string'  = 'System.String'
    'bool'    = 'System.Boolean'
    'byte'    = 'System.Byte'
    'sbyte'   = 'System.SByte'
    'char'    = 'System.Char'
    'short'   = 'System.Int16'
    'ushort'  = 'System.UInt16'
    'int'     = 'System.Int32'
    'uint'    = 'System.UInt32'
    'long'    = 'System.Int64'
    'ulong'   = 'System.UInt64'
    'float'   = 'System.Single'
    'double'  = 'System.Double'
    'decimal' = 'System.Decimal'
    'void'    = 'System.Void'
    'nint'    = 'System.IntPtr'
    'nuint'   = 'System.UIntPtr'
}

# Value-type C# keywords — X? maps to System.Nullable{CLR_X}, not just stripping the '?'.
$script:csharpValueTypes = [System.Collections.Generic.HashSet[string]]::new(
    [string[]]@('bool', 'byte', 'sbyte', 'char', 'short', 'ushort', 'int', 'uint', 'long', 'ulong', 'float', 'double', 'decimal', 'nint', 'nuint'),
    [System.StringComparer]::Ordinal)

function Expand-DocIdAliases([string]$id) {
    # Only the parameter section (inside the trailing parentheses) uses C# aliases.
    if ($id -notmatch '^(.+)\((.+)\)$') { return $id }
    $prefix = $Matches[1]
    $params = $Matches[2]

    # Step 1: Value-type nullable X? → System.Nullable{CLR_X}  (must precede general alias expansion)
    foreach ($alias in $script:csharpValueTypes) {
        $clr = $script:csharpToClr[$alias]
        $params = [regex]::Replace($params, "(?<![.\w])$([regex]::Escape($alias))\?(?=[@,(){}\[\]<>]|\z)", "System.Nullable{$clr}")
    }

    # Step 2: Expand remaining C# keyword aliases → CLR full names (string → System.String, etc.)
    foreach ($alias in $script:csharpToClr.Keys) {
        $params = [regex]::Replace($params, "(?<![.\w])$([regex]::Escape($alias))(?![.\w])", $script:csharpToClr[$alias])
    }

    # Step 3: Strip nullable annotations on reference types (string? → System.String, Foo? → Foo)
    $params = $params -replace '\?', ''

    # Step 4: Qualify unqualified user-defined short type names using the project type index.
    # $script:typeShortToFull is populated after the surface is loaded, so it is available at call time.
    if ($script:typeShortToFull -and $script:typeShortToFull.Count -gt 0) {
        foreach ($short in $script:typeShortToFull.Keys) {
            $full = $script:typeShortToFull[$short]
            $params = [regex]::Replace($params, "(?<![.\w])$([regex]::Escape($short))(?![.\w])", $full)
        }
    }

    # Step 5: Convert C# generic angle brackets to CLR curly-brace notation (< → {, > → })
    $params = $params -replace '<', '{'
    $params = $params -replace '>', '}'

    "$prefix($params)"
}

function Get-DocId([object]$docLookup, [string]$id) {
    if ($docLookup.ContainsKey($id)) { return $docLookup[$id] }
    # Surface scanner emits C# aliases; XML uses CLR names — try the expanded form.
    $expanded = Expand-DocIdAliases $id
    if ($expanded -ne $id -and $docLookup.ContainsKey($expanded)) { return $docLookup[$expanded] }
    return $null
}

# Resolve a source-text type name to a canonical XML doc-id (T:...) using
# the project's own type index. Falls back to "T:$typeName" for unknowns.
function Resolve-TypeId([string]$typeName) {
    if ([string]::IsNullOrEmpty($typeName)) { return 'T:' }
    $head = ($typeName -split '[<\[,\?\s]')[0]
    if ($typeByStripped.ContainsKey($head)) { return $typeByStripped[$head] }
    if ($typeByShort.ContainsKey($head)) { return ($typeByShort[$head] | Select-Object -First 1) }
    if ($script:csharpToClr.ContainsKey($head)) { return "T:$($script:csharpToClr[$head])" }
    return "T:$typeName"
}

# ------------------------------------------------------------ Load XML bodies

# Pre-pass: resolve <inheritdoc cref="..."/> and bare <inheritdoc/> within the
# raw XML, before we strip tags. Copies child nodes from the source member
# onto the target, so downstream processing just sees inlined prose.

# Build index of raw member XML nodes by cref.
$rawNodeById = @{}
foreach ($m in $xml.SelectNodes('//doc/members/member')) {
    $id = $m.GetAttribute('name')
    if ($id) { $rawNodeById[$id] = $m }
}

# Build a surface-driven base-member lookup: for each member docId, compute a
# list of candidate source docIds in base types / interfaces to inherit from.
# Surface base-type strings are source text (e.g. "IFoo", "Bar<T>") - we match
# them against known surface type docIds by arity-stripped full name or by
# short name when necessary.
$typeByShort = @{}  # shortName -> list of typeDocIds
$typeByStripped = @{}  # fullNameArityStripped -> typeDocId
$typeBaseHints = @{}  # typeDocId -> list of base typeDocIds (best-effort)
$memberByType = @{}  # typeDocId -> list of member surface objects

foreach ($t in $surface.types) {
    $memberByType[$t.docId] = @($t.members)
    $typeByStripped[$t.fullNameArityStripped] = $t.docId
    if (-not $typeByShort.ContainsKey($t.name)) { $typeByShort[$t.name] = @() }
    $typeByShort[$t.name] += $t.docId
}

# Build short-name → full CLR name lookup consumed by Expand-DocIdAliases (step 4).
# Key: unqualified type name (e.g. "GuardClause").  Value: fully-qualified CLR name without arity suffix.
$script:typeShortToFull = @{}
foreach ($short in $typeByShort.Keys) {
    $docId = $typeByShort[$short][0]
    if ($docId) {
        $full = $docId.Substring(2) -replace '`\d+$', ''  # strip 'T:' prefix and backtick-arity suffix
        $script:typeShortToFull[$short] = $full
    }
}

foreach ($t in $surface.types) {
    $baseIds = @()
    if ($t.baseTypes) {
        foreach ($bt in $t.baseTypes) {
            # Strip generic arguments, keep base name tokens.
            $head = ($bt -split '[<,\s]')[0]
            $short = ($head -split '\.')[-1]
            if ($typeByStripped.ContainsKey($head)) { $baseIds += $typeByStripped[$head] }
            elseif ($typeByShort.ContainsKey($short)) { $baseIds += $typeByShort[$short] }
        }
    }
    $typeBaseHints[$t.docId] = $baseIds
}

function Get-MemberSignatureKey([object]$m) {
    # Key used to match derived member to base member: kind + name + paramCount + typeParamCount.
    $kind = $m.kind
    $name = $m.name
    $pc = if ($m.parameters) { $m.parameters.Count } else { 0 }
    $tpc = if ($m.typeParameters) { $m.typeParameters.Count } else { 0 }
    "$kind|$name|$pc|$tpc"
}

function Find-InheritedCref([string]$childDocId) {
    # Locate the derived member in the surface.
    $childMember = $null
    $childType = $null
    foreach ($t in $surface.types) {
        $hit = $t.members | Where-Object { $_.docId -eq $childDocId } | Select-Object -First 1
        if ($hit) { $childMember = $hit; $childType = $t; break }
    }
    if (-not $childMember -or -not $childType) { return $null }
    $key = Get-MemberSignatureKey $childMember
    $visited = @{}
    $queue = [System.Collections.Generic.Queue[string]]::new()
    foreach ($b in $typeBaseHints[$childType.docId]) { $queue.Enqueue($b) }
    while ($queue.Count -gt 0) {
        $btId = $queue.Dequeue()
        if ($visited.ContainsKey($btId)) { continue }
        $visited[$btId] = $true
        foreach ($bm in $memberByType[$btId]) {
            if ((Get-MemberSignatureKey $bm) -eq $key) { return $bm.docId }
        }
        foreach ($nb in $typeBaseHints[$btId]) { $queue.Enqueue($nb) }
    }
    return $null
}

$maxInheritIterations = 10
for ($iter = 0; $iter -lt $maxInheritIterations; $iter++) {
    $changed = $false
    foreach ($m in @($xml.SelectNodes('//doc/members/member'))) {
        $inheritNodes = @($m.SelectNodes('inheritdoc'))
        if ($inheritNodes.Count -eq 0) { continue }
        foreach ($inh in $inheritNodes) {
            $cref = $inh.GetAttribute('cref')
            if (-not $cref) {
                # Only types/members we know about can resolve unsourced inheritdoc.
                $targetId = $m.GetAttribute('name')
                if ($targetId) { $cref = Find-InheritedCref $targetId }
            }
            if (-not $cref -or -not $rawNodeById.ContainsKey($cref)) {
                # Remove dangling inheritdoc so it doesn't leak as prose.
                [void]$m.RemoveChild($inh)
                $changed = $true
                continue
            }
            $source = $rawNodeById[$cref]
            if ($source.SelectSingleNode('inheritdoc')) {
                # source itself still needs resolution - defer to next iteration
                continue
            }
            [void]$m.RemoveChild($inh)
            foreach ($child in @($source.ChildNodes)) {
                # Do not duplicate elements that already exist on target with same name+attr.
                $imported = $xml.ImportNode($child, $true)
                [void]$m.AppendChild($imported)
            }
            $changed = $true
        }
    }
    if (-not $changed) { break }
}

$docs = @{}
foreach ($m in $xml.SelectNodes('//doc/members/member')) {
    $cref = $m.GetAttribute('name')
    if (-not $cref -or $cref.Length -lt 3 -or $cref[1] -ne ':') { continue }
    $docs[$cref] = Read-DocBody $m
}

# ------------------------------------------------------------ Build elements

$elements = [System.Collections.Generic.List[object]]::new()
$namespaceIndex = @{}

function ConvertTo-Hashtable([object]$o) {
    if ($null -eq $o) { return $null }
    $h = @{}
    foreach ($p in $o.PSObject.Properties) { $h[$p.Name] = $p.Value }
    $h
}

foreach ($t in $surface.types) {
    $typeParams = if ($t.typeParameters) { @($t.typeParameters) } else { @() }
    $shortName = $t.name
    $displayName = Format-GenericSig $shortName $typeParams
    $tdoc = Get-DocId $docs $t.docId

    $ns = $t.namespace
    if (-not $namespaceIndex.ContainsKey($ns)) {
        $namespaceIndex[$ns] = [System.Collections.Generic.List[object]]::new()
    }

    # Merge typeparam summaries from XML docs onto the surface-derived list.
    $typeParamEntries = @()
    foreach ($tpName in $typeParams) {
        $summary = ''
        if ($tdoc -and $tdoc.typeParams) {
            $hit = $tdoc.typeParams | Where-Object { $_.name -eq $tpName } | Select-Object -First 1
            if ($hit) { $summary = $hit.summary }
        }
        $typeParamEntries += [pscustomobject]@{ name = $tpName; summary = $summary }
    }

    $typeEl = [ordered]@{
        id              = $t.docId
        kind            = $t.kind
        name            = $displayName
        nameShort       = $shortName
        fullName        = if ($ns) { "$ns.$shortName" } else { $shortName }
        fullNameDisplay = if ($ns) { "$ns.$displayName" } else { $displayName }
        namespace       = $ns
        assembly        = $assemblyName
        arity           = if ($t.arity) { $t.arity } else { 0 }
        parent          = if ($ns) { "N:$ns" } else { '' }
        visibility      = $t.visibility
        isStatic        = [bool]($t.PSObject.Properties['isStatic'] -and $t.isStatic)
        isAbstract      = [bool]($t.PSObject.Properties['isAbstract'] -and $t.isAbstract)
        isSealed        = [bool]($t.PSObject.Properties['isSealed'] -and $t.isSealed)
        isPartial       = [bool]($t.PSObject.Properties['isPartial'] -and $t.isPartial)
        isReadOnly      = [bool]($t.PSObject.Properties['isReadOnly'] -and $t.isReadOnly)
        signature       = ''
        summary         = if ($tdoc) { $tdoc.summary } else { '' }
        remarks         = if ($tdoc) { $tdoc.remarks } else { '' }
        examples        = if ($tdoc) { $tdoc.examples } else { @() }
        typeParameters  = $typeParamEntries
        inheritance     = @()
        implements      = @()
        members         = @()
        seeAlso         = if ($tdoc) { $tdoc.seeAlso } else { @() }
    }

    # Classify base types from surface: first non-interface entry is base, rest are interfaces.
    # We cannot tell reliably from syntax alone which is which; heuristic: names starting with
    # 'I' followed by an upper-case letter are treated as interfaces.
    if ($t.baseTypes) {
        foreach ($bt in $t.baseTypes) {
            $head = ($bt -split '[<,\s]')[0]
            $short = ($head -split '\.')[-1]
            $resolvedId = $null
            if ($typeByStripped.ContainsKey($head)) { $resolvedId = $typeByStripped[$head] }
            elseif ($typeByShort.ContainsKey($short)) { $resolvedId = ($typeByShort[$short] | Select-Object -First 1) }
            $idValue = if ($resolvedId) { $resolvedId } else { "T:$bt" }
            $entry = [pscustomobject]@{ id = $idValue; text = $bt; href = '' }
            if ($short -match '^I[A-Z]') {
                $typeEl.implements += $entry
            }
            else {
                $typeEl.inheritance += $entry
            }
        }
    }

    # Build language-style signature.
    $mods = @()
    if ($typeEl.visibility) { $mods += $typeEl.visibility }
    if ($typeEl.isStatic) { $mods += 'static' }
    if ($typeEl.isAbstract -and -not $typeEl.isStatic -and $typeEl.kind -ne 'interface') { $mods += 'abstract' }
    if ($typeEl.isSealed -and -not $typeEl.isStatic) { $mods += 'sealed' }
    if ($typeEl.isReadOnly) { $mods += 'readonly' }
    $kindKw = switch ($t.kind) {
        'record struct' { 'record struct' }
        default { $t.kind }
    }
    $typeEl.signature = ((@($mods) + @($kindKw, $displayName)) -join ' ').Trim()

    # Delegate: type-level return + parameters.
    if ($t.kind -eq 'delegate') {
        $dParams = @()
        if ($t.parameters) {
            foreach ($p in $t.parameters) {
                $psum = ''
                if ($tdoc -and $tdoc.params) {
                    $hit = $tdoc.params | Where-Object { $_.name -eq $p.name } | Select-Object -First 1
                    if ($hit) { $psum = $hit.summary }
                }
                $dParams += [pscustomobject]@{
                    name     = $p.name
                    type     = $p.type
                    typeId   = Resolve-TypeId $p.type
                    modifier = ($p.PSObject.Properties["modifier"] ? $p.modifier : $null)
                    summary  = $psum
                }
            }
        }
        $typeEl.parameters = $dParams
        $typeEl.returns = [pscustomobject]@{
            type    = $t.returnType
            typeId  = Resolve-TypeId $t.returnType
            summary = if ($tdoc) { $tdoc.returns } else { '' }
        }
    }

    # ---- Members ----
    $memberIds = [System.Collections.Generic.List[string]]::new()
    if ($t.members) {
        foreach ($sm in $t.members) {
            $mdoc = Get-DocId $docs $sm.docId

            # Fallback for generic types: the surface scanner emits member docIds
            # without the declaring-type arity suffix (e.g. P:Ns.Range.Prop instead
            # of P:Ns.Range`1.Prop). Rebuild the canonical XML doc-id and retry.
            if (-not $mdoc -and $t.arity -gt 0 -and $t.PSObject.Properties['fullNameArityStripped']) {
                $aritySuffix = '`' + [string]$t.arity
                $strippedFqn = $t.fullNameArityStripped          # e.g. MyOrg.Elements.Range
                $withArityFqn = $strippedFqn + $aritySuffix       # e.g. MyOrg.Elements.Range`1
                $idKind = $sm.docId.Substring(0, 2)         # e.g. "P:"
                $idRest = $sm.docId.Substring(2)            # e.g. "MyOrg.Elements.Range.Prop"
                if ($idRest.StartsWith($strippedFqn)) {
                    $rewritten = $idKind + $withArityFqn + $idRest.Substring($strippedFqn.Length)
                    $mdoc = Get-DocId $docs $rewritten
                    # For methods/constructors: also map type-parameter names to
                    # positional `N notation, and qualify short param types.
                    if (-not $mdoc -and $rewritten -match '\(') {
                        $tpNames = @()
                        if ($t.typeParameters) {
                            foreach ($tp in $t.typeParameters) {
                                $tpNames += if ($tp -is [string]) { $tp } else { $tp.name }
                            }
                        }
                        $parenIdx = $rewritten.IndexOf('(')
                        $before = $rewritten.Substring(0, $parenIdx + 1)
                        $inner = $rewritten.Substring($parenIdx + 1)
                        if ($inner.EndsWith(')')) { $inner = $inner.Substring(0, $inner.Length - 1) }
                        # Replace type-parameter names with `N positional tokens.
                        for ($i = 0; $i -lt $tpNames.Count; $i++) {
                            $tpEsc = [regex]::Escape($tpNames[$i])
                            $inner = [regex]::Replace($inner, "(?<![.\w])$tpEsc(?![.\w])", ('`' + $i))
                        }
                        # Qualify short parameter type names against known project types.
                        $innerParts = $inner -split ','
                        $qualified = $innerParts | ForEach-Object {
                            $pt = $_.Trim()
                            if ($pt -match '^`') { $pt }
                            else {
                                $h2 = ($pt -split '[<\[\?\s]')[0]
                                if ($typeByStripped.ContainsKey($h2)) {
                                    $typeByStripped[$h2].Substring(2) + $pt.Substring($h2.Length)
                                }
                                elseif ($typeByShort.ContainsKey($h2)) {
                                    (($typeByShort[$h2] | Select-Object -First 1).Substring(2)) + $pt.Substring($h2.Length)
                                }
                                else { $pt }
                            }
                        }
                        $mdoc = Get-DocId $docs ($before + ($qualified -join ',') + ')')
                    }
                }
            }

            $memberParams = @()
            if ($sm.parameters) {
                foreach ($p in $sm.parameters) {
                    $psum = ''
                    if ($mdoc -and $mdoc.params) {
                        $hit = $mdoc.params | Where-Object { $_.name -eq $p.name } | Select-Object -First 1
                        if ($hit) { $psum = $hit.summary }
                    }
                    $memberParams += [pscustomobject]@{
                        name     = $p.name
                        type     = $p.type
                        typeId   = Resolve-TypeId ($p.type -replace '\?$', '')
                        modifier = ($p.PSObject.Properties["modifier"] ? $p.modifier : $null)
                        summary  = $psum
                    }
                }
            }

            $memberTypeParams = @()
            if ($sm.typeParameters) {
                foreach ($tpName in $sm.typeParameters) {
                    $psum = ''
                    if ($mdoc -and $mdoc.typeParams) {
                        $hit = $mdoc.typeParams | Where-Object { $_.name -eq $tpName } | Select-Object -First 1
                        if ($hit) { $psum = $hit.summary }
                    }
                    $memberTypeParams += [pscustomobject]@{ name = $tpName; summary = $psum }
                }
            }

            $memEl = [ordered]@{
                id             = $sm.docId
                kind           = $sm.kind
                name           = $sm.name
                fullName       = "$($typeEl.fullName).$($sm.name)"
                namespace      = $ns
                parent         = $t.docId
                assembly       = $assemblyName
                visibility     = $sm.visibility
                isStatic       = [bool]($sm.PSObject.Properties['isStatic'] -and $sm.isStatic)
                isAbstract     = [bool]($sm.PSObject.Properties['isAbstract'] -and $sm.isAbstract)
                isVirtual      = [bool]($sm.PSObject.Properties['isVirtual'] -and $sm.isVirtual)
                isOverride     = [bool]($sm.PSObject.Properties['isOverride'] -and $sm.isOverride)
                isSealed       = [bool]($sm.PSObject.Properties['isSealed'] -and $sm.isSealed)
                isAsync        = [bool]($sm.PSObject.Properties['isAsync'] -and $sm.isAsync)
                isReadOnly     = [bool]($sm.PSObject.Properties['isReadOnly'] -and $sm.isReadOnly)
                isConst        = [bool]($sm.PSObject.Properties['isConst'] -and $sm.isConst)
                isInitOnly     = [bool]($sm.PSObject.Properties['isInitOnly'] -and $sm.isInitOnly)
                hasGetter      = [bool]($sm.PSObject.Properties['hasGetter'] -and $sm.hasGetter)
                hasSetter      = [bool]($sm.PSObject.Properties['hasSetter'] -and $sm.hasSetter)
                parameters     = $memberParams
                typeParameters = $memberTypeParams
                returns        = [pscustomobject]@{
                    type    = if ($sm.PSObject.Properties['returnType']) { $sm.returnType } else { '' }
                    typeId  = $(Resolve-TypeId $(if ($sm.PSObject.Properties['returnType']) { $sm.returnType } else { '' }))
                    summary = if ($mdoc) { $mdoc.returns } else { '' }
                }
                summary        = if ($mdoc) { $mdoc.summary } else { '' }
                remarks        = if ($mdoc) { $mdoc.remarks } else { '' }
                exceptions     = if ($mdoc) { $mdoc.exceptions } else { @() }
                examples       = if ($mdoc) { $mdoc.examples } else { @() }
                seeAlso        = if ($mdoc) { $mdoc.seeAlso } else { @() }
                value          = if ($mdoc) { $mdoc.value } else { '' }
            }
            # Signature used as link text in member tables.
            $memEl.signatureShort = Format-MemberSignature ([pscustomobject]$memEl) $typeEl

            # Full one-line signature (modifiers + return + signatureShort).
            $memMods = @()
            if ($memEl.visibility) { $memMods += $memEl.visibility }
            if ($memEl.isStatic) { $memMods += 'static' }
            if ($memEl.isAbstract) { $memMods += 'abstract' }
            if ($memEl.isVirtual) { $memMods += 'virtual' }
            if ($memEl.isOverride) { $memMods += 'override' }
            if ($memEl.isSealed) { $memMods += 'sealed' }
            if ($memEl.isAsync) { $memMods += 'async' }
            if ($memEl.isReadOnly) { $memMods += 'readonly' }
            if ($memEl.isConst) { $memMods += 'const' }
            $returnsPart = if ($memEl.returns.type) { $memEl.returns.type + ' ' } else { '' }
            $memEl.signature = (($memMods -join ' ') + ' ' + $returnsPart + $memEl.signatureShort).Trim()

            $elements.Add([pscustomobject]$memEl)
            [void]$memberIds.Add($sm.docId)
        }
    }

    $typeEl.members = $memberIds.ToArray()
    $elements.Add([pscustomobject]$typeEl)

    $namespaceIndex[$ns].Add([pscustomobject]@{
            id      = $typeEl.id
            kind    = $typeEl.kind
            name    = $typeEl.name
            summary = $typeEl.summary
        })
}

# Namespace pages
foreach ($ns in ($namespaceIndex.Keys | Sort-Object)) {
    $children = $namespaceIndex[$ns]
    $elements.Add([pscustomobject][ordered]@{
            id         = "N:$ns"
            kind       = 'namespace'
            name       = $ns
            fullName   = $ns
            namespace  = $ns
            assembly   = $assemblyName
            signature  = "namespace $ns"
            summary    = ''
            classes    = @($children | Where-Object { $_.kind -eq 'class' })
            interfaces = @($children | Where-Object { $_.kind -eq 'interface' })
            structs    = @($children | Where-Object { $_.kind -in 'struct', 'record struct' })
            enums      = @($children | Where-Object { $_.kind -eq 'enum' })
            records    = @($children | Where-Object { $_.kind -eq 'record' })
            delegates  = @($children | Where-Object { $_.kind -eq 'delegate' })
        })
}

# ---------------------------------------------------------------- Serialize

$model = [ordered]@{
    project          = $Project
    language         = 'dotnet'
    assembly         = $assemblyName
    defaultNamespace = $defaultNamespace
    version          = ''
    generatedAt      = (Get-Date).ToUniversalTime().ToString('o')
    elements         = $elements
}

$outDir = Split-Path -Parent $OutputModel
if ($outDir -and -not (Test-Path -LiteralPath $outDir)) {
    New-Item -ItemType Directory -Path $outDir -Force | Out-Null
}
$model | ConvertTo-Json -Depth 32 | Set-Content -LiteralPath $OutputModel -Encoding UTF8

$typeKinds = @('class', 'interface', 'struct', 'record', 'record struct', 'enum', 'delegate')
$memberKinds = @('method', 'constructor', 'property', 'field', 'event', 'operator')
[pscustomobject]@{
    project   = $Project
    modelPath = (Resolve-Path -LiteralPath $OutputModel).Path
    types     = @($elements | Where-Object { $typeKinds -contains $_.kind }).Count
    members   = @($elements | Where-Object { $memberKinds -contains $_.kind }).Count
} | ConvertTo-Json -Compress




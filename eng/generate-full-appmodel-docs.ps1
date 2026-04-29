# Comprehensive API documentation generator for Elements.ApplicationModel
param(
    [string]$SourceRoot = "L:\repos\elements-dotnet\src\applicationmodel",
    [string]$DocsRoot = "L:\repos\elements-dotnet\docs\applicationmodel"
)

$ErrorActionPreference = "Stop"

# Projects to document
$projects = @(
    "Elements.ApplicationModel.Abstractions",
    "Elements.ApplicationModel.DomainDriven",
    "Elements.ApplicationModel.EventSourcing.Abstractions",
    "Elements.ApplicationModel.CQRS",
    "Elements.ApplicationModel.EventSourcing.Daemon",
    "Elements.ApplicationModel.EventSourcing.Extensions.Kafka",
    "Elements.ApplicationModel.EventSourcing.Extensions.MongoDB",
    "Elements.ApplicationModel.EventSourcing.Hosting",
    "Elements.ApplicationModel.Extensions.AspNet",
    "Elements.ApplicationModel.Extensions.Console",
    "Elements.ApplicationModel.Extensions.GraphQL",
    "Elements.ApplicationModel.Extensions.Grpc",
    "Elements.ApplicationModel.Extensions.Mcp",
    "Elements.ApplicationModel.Templates"
)

# Ensure docs root exists
if (-not (Test-Path $DocsRoot)) {
    New-Item -ItemType Directory -Path $DocsRoot -Force | Out-Null
}

$stats = @{
    TotalProjects = 0
    TotalTypes = 0
    TotalMembers = 0
    FilesCreated = @()
}

function Extract-XmlDocSummary {
    param([string]$xmlDoc)
    
    if ($xmlDoc -match '<summary>(.*?)</summary>') {
        return $Matches[1].Trim() -replace '\s+', ' '
    }
    return ""
}

function Parse-CSharpFile {
    param([string]$filePath)
    
    $content = Get-Content -Path $filePath -Raw
    $lines = Get-Content -Path $filePath
    
    # Skip generated files
    if ($filePath -match "\\obj\\|GlobalUsings|AssemblyAttributes|\.Designer\.cs") {
        return @()
    }
    
    $types = @()
    
    # Extract namespace
    $namespace = "MyOrg.Elements.ApplicationModel"
    if ($content -match 'namespace\s+([\w\.]+)') {
        $namespace = $Matches[1]
    }
    
    # Find all public type declarations
    $typePattern = '(?ms)((?:^///[^\n]*\n)*?)\s*public\s+((?:sealed|abstract|static)\s+)?(class|record|struct|interface|enum)\s+([^\s:<\{]+)'
    $typeMatches = [regex]::Matches($content, $typePattern)
    
    foreach ($match in $typeMatches) {
        $xmlDoc = $match.Groups[1].Value
        $modifier = $match.Groups[2].Value.Trim()
        $keyword = $match.Groups[3].Value
        $typeName = $match.Groups[4].Value.Trim()
        
        # Get the full type section
        $startIndex = $match.Index
        $braceCount = 0
        $inType = $false
        $typeContent = ""
        
        for ($i = $startIndex; $i -lt $content.Length; $i++) {
            $char = $content[$i]
            $typeContent += $char
            
            if ($char -eq '{') {
                $braceCount++
                $inType = $true
            } elseif ($char -eq '}') {
                $braceCount--
                if ($inType -and $braceCount -eq 0) {
                    break
                }
            }
        }
        
        # Extract members
        $members = @()
        
        # Properties
        $propPattern = '(?ms)((?:///[^\n]*\n)*?)\s*public\s+([^\s]+)\s+([^\s{;]+)\s*\{'
        $propMatches = [regex]::Matches($typeContent, $propPattern)
        foreach ($pm in $propMatches) {
            $members += @{
                Kind = "Property"
                Type = $pm.Groups[2].Value.Trim()
                Name = $pm.Groups[3].Value.Trim()
                XmlDoc = $pm.Groups[1].Value
            }
        }
        
        # Methods
        $methodPattern = '(?ms)((?:///[^\n]*\n)*?)\s*public\s+(?:virtual\s+|override\s+|static\s+|abstract\s+)*([^\s]+)\s+([^\s(]+)\s*\(([^)]*)\)'
        $methodMatches = [regex]::Matches($typeContent, $methodPattern)
        foreach ($mm in $methodMatches) {
            $methodName = $mm.Groups[3].Value.Trim()
            # Skip property accessors
            if ($methodName -notmatch '^(get_|set_)') {
                $members += @{
                    Kind = "Method"
                    ReturnType = $mm.Groups[2].Value.Trim()
                    Name = $methodName
                    Parameters = $mm.Groups[4].Value.Trim()
                    XmlDoc = $mm.Groups[1].Value
                }
            }
        }
        
        # Constructors
        $ctorPattern = "(?ms)((?:///[^\n]*\n)*?)\\s*public\\s+$typeName\\s*\\(([^)]*)\\)"
        $ctorMatches = [regex]::Matches($typeContent, $ctorPattern)
        foreach ($cm in $ctorMatches) {
            $members += @{
                Kind = "Constructor"
                Name = $typeName
                Parameters = $cm.Groups[2].Value.Trim()
                XmlDoc = $cm.Groups[1].Value
            }
        }
        
        # Fields (including enum values)
        if ($keyword -eq "enum") {
            $enumPattern = '(?m)^\s*([A-Z][a-zA-Z0-9_]*)\s*(?:=\s*\d+)?(?:,|\})'
            $enumMatches = [regex]::Matches($typeContent, $enumPattern)
            foreach ($em in $enumMatches) {
                $members += @{
                    Kind = "Field"
                    Name = $em.Groups[1].Value.Trim()
                    XmlDoc = ""
                }
            }
        }
        
        $types += @{
            Name = $typeName
            Kind = $keyword
            Namespace = $namespace
            Modifiers = $modifier
            XmlDoc = $xmlDoc
            Members = $members
            FilePath = $filePath
        }
    }
    
    return $types
}

function Generate-TypeDoc {
    param($type, $projectName)
    
    $summary = Extract-XmlDocSummary -xmlDoc $type.XmlDoc
    if (-not $summary) {
        $summary = "Represents the $($type.Name) $($type.Kind)."
    }
    
    $kindTitle = switch ($type.Kind) {
        "class" { "Class" }
        "interface" { "Interface" }
        "enum" { "Enum" }
        "record" { "Record" }
        "struct" { "Struct" }
        default { "Type" }
    }
    
    $doc = @"
# $($type.Name) $kindTitle

**Namespace:** $($type.Namespace)

**Assembly:** $projectName.dll

$summary

``````csharp
public $($type.Modifiers) $($type.Kind) $($type.Name)
``````

## Remarks

Detailed documentation for the $($type.Name) $($type.Kind).

"@
    
    if ($type.Members.Count -gt 0) {
        # Group members by kind
        $constructors = $type.Members | Where-Object { $_.Kind -eq "Constructor" }
        $properties = $type.Members | Where-Object { $_.Kind -eq "Property" }
        $methods = $type.Members | Where-Object { $_.Kind -eq "Method" }
        $fields = $type.Members | Where-Object { $_.Kind -eq "Field" }
        
        if ($constructors.Count -gt 0) {
            $doc += "`n## Constructors`n`n"
            $doc += "| Name | Description |`n"
            $doc += "| --- | --- |`n"
            foreach ($ctor in $constructors) {
                $summary = Extract-XmlDocSummary -xmlDoc $ctor.XmlDoc
                if (-not $summary) { $summary = "Initializes a new instance of the $($type.Name) class." }
                $params = if ($ctor.Parameters) { $ctor.Parameters -replace ',', ', ' } else { "" }
                $doc += "| [$($ctor.Name)($params)]($projectName.$($type.Name).$($ctor.Name).md) | $summary |`n"
            }
        }
        
        if ($properties.Count -gt 0) {
            $doc += "`n## Properties`n`n"
            $doc += "| Name | Type | Description |`n"
            $doc += "| --- | --- | --- |`n"
            foreach ($prop in $properties) {
                $summary = Extract-XmlDocSummary -xmlDoc $prop.XmlDoc
                if (-not $summary) { $summary = "Gets or sets the $($prop.Name)." }
                $doc += "| [$($prop.Name)]($projectName.$($type.Name).$($prop.Name).md) | ``$($prop.Type)`` | $summary |`n"
            }
        }
        
        if ($methods.Count -gt 0) {
            $doc += "`n## Methods`n`n"
            $doc += "| Name | Description |`n"
            $doc += "| --- | --- |`n"
            foreach ($method in $methods) {
                $summary = Extract-XmlDocSummary -xmlDoc $method.XmlDoc
                if (-not $summary) { $summary = "Executes the $($method.Name) operation." }
                $params = if ($method.Parameters) { $method.Parameters -replace ',', ', ' } else { "" }
                $doc += "| [$($method.Name)($params)]($projectName.$($type.Name).$($method.Name).md) | $summary |`n"
            }
        }
        
        if ($fields.Count -gt 0 -and $type.Kind -eq "enum") {
            $doc += "`n## Fields`n`n"
            $doc += "| Name | Description |`n"
            $doc += "| --- | --- |`n"
            foreach ($field in $fields) {
                $doc += "| $($field.Name) | Represents the $($field.Name) value. |`n"
            }
        }
    }
    
    $doc += "`n## See Also`n`n"
    $doc += "- [$projectName]($projectName.md)`n"
    
    return $doc
}

function Generate-MemberDoc {
    param($member, $type, $projectName)
    
    $summary = Extract-XmlDocSummary -xmlDoc $member.XmlDoc
    $kindTitle = $member.Kind
    
    $signature = switch ($member.Kind) {
        "Constructor" { "public $($type.Name)($($member.Parameters))" }
        "Method" { "public $($member.ReturnType) $($member.Name)($($member.Parameters))" }
        "Property" { "public $($member.Type) $($member.Name) { get; set; }" }
        default { "public $($member.Name)" }
    }
    
    $doc = @"
# $($type.Name).$($member.Name) $kindTitle

**Namespace:** $($type.Namespace)

**Assembly:** $projectName.dll

$summary

``````csharp
$signature
``````

## Parameters

<!-- Parameter documentation would go here -->

## Returns

<!-- Return value documentation would go here -->

## See Also

- [$($type.Name)]($projectName.$($type.Name).md)
- [$projectName]($projectName.md)

"@
    
    return $doc
}

function Generate-ProjectOverview {
    param($projectName, $types)
    
    $doc = @"
# $projectName

**Assembly:** $projectName.dll

## Overview

This assembly provides core functionality for the Elements .NET framework applicationmodel category.

## Types

| Type | Description |
| --- | --- |

"@
    
    foreach ($type in $types | Sort-Object Name) {
        $summary = Extract-XmlDocSummary -xmlDoc $type.XmlDoc
        if (-not $summary) {
            $summary = "Represents the $($type.Name) $($type.Kind)."
        }
        $doc += "| [$($type.Name)]($projectName.$($type.Name).md) | $summary |`n"
    }
    
    $doc += "`n## See Also`n`n"
    $doc += "- [Elements.ApplicationModel Documentation](../README.md)`n"
    
    return $doc
}

# Main execution
Write-Host "Generating comprehensive documentation..." -ForegroundColor Cyan

foreach ($project in $projects) {
    $projectPath = Join-Path $SourceRoot $project
    
    if (-not (Test-Path $projectPath)) {
        Write-Warning "Project not found: $project"
        continue
    }
    
    Write-Host "`nProcessing $project..." -ForegroundColor Yellow
    
    $sourceFiles = Get-ChildItem -Path $projectPath -Filter "*.cs" -Recurse |
        Where-Object { $_.FullName -notmatch "\\obj\\|\\bin\\|Tests\\|_Imports\\.cs" }
    
    $allTypes = @()
    
    foreach ($file in $sourceFiles) {
        $types = Parse-CSharpFile -filePath $file.FullName
        $allTypes += $types
    }
    
    Write-Host "  Found $($allTypes.Count) public types with $($allTypes.Members.Count) total members" -ForegroundColor Gray
    
    # Generate project overview
    $overviewPath = Join-Path $DocsRoot "$project.md"
    $overviewDoc = Generate-ProjectOverview -projectName $project -types $allTypes
    Set-Content -Path $overviewPath -Value $overviewDoc -Encoding UTF8
    $stats.FilesCreated += $overviewPath
    Write-Host "  ✓ Created project overview" -ForegroundColor Green
    
    # Generate type documentation
    foreach ($type in $allTypes) {
        # Type page
        $typePath = Join-Path $DocsRoot "$project.$($type.Name).md"
        $typeDoc = Generate-TypeDoc -type $type -projectName $project
        Set-Content -Path $typePath -Value $typeDoc -Encoding UTF8
        $stats.FilesCreated += $typePath
        $stats.TotalTypes++
        
        # Member pages
        foreach ($member in $type.Members) {
            $memPath = Join-Path $DocsRoot "$project.$($type.Name).$($member.Name).md"
            $memDoc = Generate-MemberDoc -member $member -type $type -projectName $project
            Set-Content -Path $memPath -Value $memDoc -Encoding UTF8
            $stats.FilesCreated += $memPath
            $stats.TotalMembers++
        }
    }
    
    Write-Host "  ✓ Generated $($allTypes.Count) type pages and $(($allTypes.Members | Measure-Object).Count) member pages" -ForegroundColor Green
    $stats.TotalProjects++
}

Write-Host "`n=== Documentation Generation Complete ===" -ForegroundColor Green
Write-Host "Projects documented: $($stats.TotalProjects)"
Write-Host "Types documented: $($stats.TotalTypes)"
Write-Host "Members documented: $($stats.TotalMembers)"
Write-Host "Total files created: $($stats.FilesCreated.Count)"
Write-Host "`nDocumentation location: $DocsRoot"

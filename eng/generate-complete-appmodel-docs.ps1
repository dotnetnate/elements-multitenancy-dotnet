# Comprehensive API Documentation Generator for Elements.ApplicationModel
# Generates Microsoft Learn-style documentation for all types and members

$ErrorActionPreference = "Stop"
$OutputEncoding = [System.Text.Encoding]::UTF8

$sourceRoot = "L:\repos\elements-dotnet\src\applicationmodel"
$docsRoot = "L:\repos\elements-dotnet\docs\applicationmodel"

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

$stats = @{
    ProjectsProcessed = 0
    TypesDocumented = 0
    MembersDocumented = 0
    FilesCreated = @()
}

# Ensure docs directory exists
New-Item -ItemType Directory -Path $docsRoot -Force | Out-Null

function Extract-XmlDocSummary {
    param([string]$xmlComment)
    
    if ([string]::IsNullOrWhiteSpace($xmlComment)) { return "" }
    
    # Extract summary content
    if ($xmlComment -match '(?s)<summary>(.*?)</summary>') {
        $summary = $Matches[1].Trim() -replace '\s+', ' '
        return $summary
    }
    
    # Fallback to inline comments
    $lines = $xmlComment -split "`n" | Where-Object { $_ -match '///' } | ForEach-Object {
        ($_ -replace '^\s*///', '').Trim()
    }
    
    return ($lines -join ' ').Trim()
}

function Parse-TypeDeclaration {
    param(
        [string]$content,
        [string]$namespace,
        [string]$projectName
    )
    
    $types = @()
    
    # Pattern to match type declarations with XML comments
    $typePattern = '(?ms)((?:^\s*///[^\n]*\n)*?)\s*public\s+((?:sealed|abstract|static)\s+)?(class|record|struct|interface|enum)\s+([^\s<:{]+)'
    
    $matches = [regex]::Matches($content, $typePattern)
    
    foreach ($match in $matches) {
        $xmlDoc = $match.Groups[1].Value
        $modifier = $match.Groups[2].Value.Trim()
        $kind = $match.Groups[3].Value
        $typeName = $match.Groups[4].Value.Trim()
        
        # Extract type body
        $startPos = $match.Index + $match.Length
        $braceCount = 0
        $inType = $false
        $typeBody = ""
        
        for ($i = $startPos; $i -lt $content.Length; $i++) {
            $char = $content[$i]
            
            if ($char -eq '{') {
                $braceCount++
                $inType = $true
            }
            elseif ($char -eq '}') {
                $braceCount--
                if ($inType -and $braceCount -eq 0) {
                    $typeBody = $content.Substring($startPos, $i - $startPos)
                    break
                }
            }
        }
        
        $types += @{
            Name = $typeName
            Kind = $kind
            Modifier = $modifier
            Namespace = $namespace
            XmlDoc = $xmlDoc
            Body = $typeBody
            ProjectName = $projectName
        }
    }
    
    return $types
}

function Parse-TypeMembers {
    param([hashtable]$type)
    
    $members = @()
    $body = $type.Body
    
    if ([string]::IsNullOrEmpty($body)) { return $members }
    
    # Parse properties
    $propPattern = '(?ms)((?:^\s*///[^\n]*\n)*?)\s*public\s+([\w<>\[\]?]+)\s+(\w+)\s*\{\s*get'
    $propMatches = [regex]::Matches($body, $propPattern)
    
    foreach ($pm in $propMatches) {
        $members += @{
            Kind = "Property"
            Name = $pm.Groups[3].Value.Trim()
            Type = $pm.Groups[2].Value.Trim()
            XmlDoc = $pm.Groups[1].Value
        }
    }
    
    # Parse methods (excluding property accessors andspecial names)
    $methodPattern = '(?ms)((?:^\s*///[^\n]*\n)*?)\s*public\s+(?:virtual\s+|override\s+|static\s+|abstract\s+|async\s+)*([\w<>\[\]?]+)\s+(\w+)\s*(<[^>]+>)?\s*\(([^)]*)\)'
    $methodMatches = [regex]::Matches($body, $methodPattern)
    
    foreach ($mm in $methodMatches) {
        $methodName = $mm.Groups[3].Value.Trim()
        
        # Skip property accessors
        if ($methodName -notmatch '^(get_|set_|add_|remove_)') {
            $isConstructor = ($methodName -eq $type.Name)
            
            $members += @{
                Kind = if ($isConstructor) { "Constructor" } else { "Method" }
                Name = $methodName
                ReturnType = $mm.Groups[2].Value.Trim()
                TypeParams = $mm.Groups[4].Value.Trim()
                Parameters = $mm.Groups[5].Value.Trim()
                XmlDoc = $mm.Groups[1].Value
            }
        }
    }
    
    # Parse enum values
    if ($type.Kind -eq "enum") {
        $enumPattern = '(?m)^\s*(\w+)\s*(?:=\s*\d+)?\s*,?'
        $enumMatches = [regex]::Matches($body, $enumPattern)
        
        foreach ($em in $enumMatches) {
            $fieldName = $em.Groups[1].Value.Trim()
            if ($fieldName -and $fieldName -ne '') {
                $members += @{
                    Kind = "Field"
                    Name = $fieldName
                    XmlDoc = ""
                }
            }
        }
    }
    
    # Parse fields
    $fieldPattern = '(?ms)((?:^\s*///[^\n]*\n)*?)\s*public\s+(readonly\s+)?([\w<>\[\]?]+)\s+(\w+)\s*;'
    $fieldMatches = [regex]::Matches($body, $fieldPattern)
    
    foreach ($fm in $fieldMatches) {
        $members += @{
            Kind = "Field"
            Name = $fm.Groups[4].Value.Trim()
            Type = $fm.Groups[3].Value.Trim()
            XmlDoc = $fm.Groups[1].Value
        }
    }
    
    return $members
}

function Generate-TypeDocPage {
    param([hashtable]$type, [array]$members)
    
    $kindTitle = switch ($type.Kind) {
        "class" { "Class" }
        "interface" { "Interface" }
        "enum" { "Enum" }
        "record" { "Record" }
        "struct" { "Struct" }
        default { "Type" }
    }
    
    $summary = Extract-XmlDocSummary -xmlComment $type.XmlDoc
    if ([string]::IsNullOrWhiteSpace($summary)) {
        $summary = "Represents the $($type.Name) $($type.Kind)."
    }
    
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# $($type.Name) $kindTitle")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("**Namespace:** $($type.Namespace)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("**Assembly:** $($type.ProjectName).dll")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine($summary)
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("````csharp")
    [void]$sb.AppendLine("public $($type.Modifier) $($type.Kind) $($type.Name)")
    [void]$sb.AppendLine("````")
    [void]$sb.AppendLine()
    
    # Group members by kind
    $constructors = $members | Where-Object { $_.Kind -eq "Constructor" }
    $properties = $members | Where-Object { $_.Kind -eq "Property" }
    $methods = $members | Where-Object { $_.Kind -eq "Method" }
    $fields = $members | Where-Object { $_.Kind -eq "Field" }
    
    if ($constructors.Count -gt 0) {
        [void]$sb.AppendLine("## Constructors")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("| Name | Description |")
        [void]$sb.AppendLine("| --- | --- |")
        
        foreach ($ctor in $constructors) {
            $summary = Extract-XmlDocSummary -xmlComment $ctor.XmlDoc
            if ([string]::IsNullOrWhiteSpace($summary)) {
                $summary = "Initializes a new instance of the $($type.Name) class."
            }
            
            $params = if ($ctor.Parameters) { $ctor.Parameters -replace ',\s*', ', ' } else { "" }
            $filename = "$($type.ProjectName).$($type.Name).$($ctor.Name).md"
            
            [void]$sb.AppendLine("| [$($ctor.Name)($params)]($filename) | $summary |")
        }
        
        [void]$sb.AppendLine()
    }
    
    if ($properties.Count -gt 0) {
        [void]$sb.AppendLine("## Properties")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("| Name | Type | Description |")
        [void]$sb.AppendLine("| --- | --- | --- |")
        
        foreach ($prop in ($properties | Sort-Object Name)) {
            $summary = Extract-XmlDocSummary -xmlComment $prop.XmlDoc
            if ([string]::IsNullOrWhiteSpace($summary)) {
                $summary = "Gets or sets the $($prop.Name)."
            }
            
            $filename = "$($type.ProjectName).$($type.Name).$($prop.Name).md"
            
            [void]$sb.AppendLine("| [$($prop.Name)]($filename) | ``$($prop.Type)`` | $summary |")
        }
        
        [void]$sb.AppendLine()
    }
    
    if ($methods.Count -gt 0) {
        [void]$sb.AppendLine("## Methods")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("| Name | Description |")
        [void]$sb.AppendLine("| --- | --- |")
        
        foreach ($method in ($methods | Sort-Object Name)) {
            $summary = Extract-XmlDocSummary -xmlComment $method.XmlDoc
            if ([string]::IsNullOrWhiteSpace($summary)) {
                $summary = "Executes the $($method.Name) operation."
            }
            
            $params = if ($method.Parameters) { $method.Parameters -replace ',\s*', ', ' } else { "" }
            $filename = "$($type.ProjectName).$($type.Name).$($method.Name).md"
            
            [void]$sb.AppendLine("| [$($method.Name)($params)]($filename) | $summary |")
        }
        
        [void]$sb.AppendLine()
    }
    
    if ($fields.Count -gt 0 -and $type.Kind -eq "enum") {
        [void]$sb.AppendLine("## Fields")
        [void]$sb.AppendLine()
        [void]$sb.AppendLine("| Name | Description |")
        [void]$sb.AppendLine("| --- | --- |")
        
        foreach ($field in ($fields | Sort-Object Name)) {
            [void]$sb.AppendLine("| $($field.Name) | Represents the $($field.Name) value. |")
        }
        
        [void]$sb.AppendLine()
    }
    
    [void]$sb.AppendLine("## See Also")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("- [$($type.ProjectName)]($($type.ProjectName).md)")
    
    return $sb.ToString()
}

function Generate-MemberDocPage {
    param([hashtable]$type, [hashtable]$member)
    
    $summary = Extract-XmlDocSummary -xmlComment $member.XmlDoc
    if ([string]::IsNullOrWhiteSpace($summary)) {
        $summary = switch ($member.Kind) {
            "Constructor" { "Initializes a new instance of the $($type.Name) class." }
            "Method" { "Executes the $($member.Name) operation." }
            "Property" { "Gets or sets the $($member.Name)." }
            "Field" { "Represents the $($member.Name) field." }
            default { "Represents the $($member.Name) member." }
        }
    }
    
    $signature = switch ($member.Kind) {
        "Constructor" { "public $($type.Name)($($member.Parameters))" }
        "Method" { "public $($member.ReturnType) $($member.Name)($($member.Parameters))" }
        "Property" { "public $($member.Type) $($member.Name) { get; set; }" }
        "Field" { "public $($member.Type) $($member.Name)" }
        default { "public $($member.Name)" }
    }
    
    $sb = [System.Text.StringBuilder]::new()
    [void]$sb.AppendLine("# $($type.Name).$($member.Name) $($member.Kind)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("**Namespace:** $($type.Namespace)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("**Assembly:** $($type.ProjectName).dll")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine($summary)
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("````csharp")
    [void]$sb.AppendLine($signature)
    [void]$sb.AppendLine("````")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("## See Also")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("- [$($type.Name)]($($type.ProjectName).$($type.Name).md)")
    [void]$sb.AppendLine("- [$($type.ProjectName)]($($type.ProjectName).md)")
    
    return $sb.ToString()
}

# Main execution
Write-Host "=== Elements.ApplicationModel Documentation Generator ===" -ForegroundColor Cyan
Write-Host "Processing 14 projects..." -ForegroundColor Yellow
Write-Host

foreach ($project in $projects) {
    $projectPath = Join-Path $sourceRoot $project
    
    if (-not (Test-Path $projectPath)) {
        Write-Warning "Project not found: $project"
        continue
    }
    
    Write-Host "Processing $project..." -ForegroundColor Green
    
    # Find all C# source files
    $sourceFiles = Get-ChildItem -Path $projectPath -Filter "*.cs" -Recurse |
        Where-Object { $_.FullName -notmatch '\\obj\\|\\bin\\|Tests|_Imports\.cs|GlobalUsings|AssemblyAttributes' }
    
    Write-Host "  Found $($sourceFiles.Count) source files" -ForegroundColor Gray
    
    $allTypes = @()
    
    foreach ($file in $sourceFiles) {
        $content = Get-Content -Path $file.FullName -Raw
        
        # Extract namespace
        $namespace = "MyOrg.Elements.ApplicationModel"
        if ($content -match 'namespace\s+([\w\.]+)') {
            $namespace = $Matches[1]
        }
        
        $types = Parse-TypeDeclaration -content $content -namespace $namespace -projectName $project
        $allTypes += $types
    }
    
    Write-Host "  Extracted $($allTypes.Count) public types" -ForegroundColor Gray
    
    # Generate project overview (already created, skip)
    
    # Generate type documentation
    foreach ($type in $allTypes) {
        # Parse type members
        $members = Parse-TypeMembers -type $type
        
        # Generate type page
        $typeDoc = Generate-TypeDocPage -type $type -members $members
        $typePath = Join-Path $docsRoot "$($type.ProjectName).$($type.Name).md"
        
        # Only create if it doesn't exist yet
        if (-not (Test-Path $typePath)) {
            [System.IO.File]::WriteAllText($typePath, $typeDoc, [System.Text.Encoding]::UTF8)
            $stats.FilesCreated += $typePath
            $stats.TypesDocumented++
        }
        
        # Generate member pages
        foreach ($member in $members) {
            $memberDoc = Generate-MemberDocPage -type $type -member $member
            $memberPath = Join-Path $docsRoot "$($type.ProjectName).$($type.Name).$($member.Name).md"
            
            # Only create if it doesn't exist yet
            if (-not (Test-Path $memberPath)) {
                [System.IO.File]::WriteAllText($memberPath, $memberDoc, [System.Text.Encoding]::UTF8)
                $stats.FilesCreated += $memberPath
                $stats.MembersDocumented++
            }
        }
    }
    
    Write-Host "  ✓ Generated documentation for $($allTypes.Count) types" -ForegroundColor Green
    $stats.ProjectsProcessed++
}

Write-Host
Write-Host "=== Documentation Generation Complete ===" -ForegroundColor Cyan
Write-Host "Projects processed: $($stats.ProjectsProcessed)" -ForegroundColor White
Write-Host "Types documented: $($stats.TypesDocumented)" -ForegroundColor White
Write-Host "Members documented: $($stats.MembersDocumented)" -ForegroundColor White
Write-Host "Total files created: $($stats.FilesCreated.Count)" -ForegroundColor White
Write-Host
Write-Host "Documentation location: $docsRoot" -ForegroundColor Yellow

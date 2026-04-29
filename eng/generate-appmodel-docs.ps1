# Generate comprehensive API documentation for applicationmodel projects
param(
    [string]$SourceRoot = "L:\repos\elements-dotnet\src\applicationmodel",
    [string]$DocsRoot = "L:\repos\elements-dotnet\docs\applicationmodel"
)

$ErrorActionPreference = "Stop"

# Projects to document (order matters for dependencies)
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

$totalTypes = 0
$totalMembers = 0
$fileList = @()

function Get-XmlDocComment {
    param($lines, $startLine)
    
    $docs = @()
    $i = $startLine - 1
    
    # Look backward for XML doc comments
    while ($i -ge 0) {
        $line = $lines[$i].Trim()
        if ($line -match "^///\s*(.*)$") {
            $docs = @($Matches[1]) + $docs
            $i--
        } else {
            break
        }
    }
    
    return ($docs -join "`n")
}

function Get-PublicTypes {
    param($sourceFile)
    
    $content = Get-Content $sourceFile -Raw
    $lines = Get-Content $sourceFile
    
    # Skip generated files
    if ($sourceFile -match "\\obj\\|GlobalUsings|AssemblyAttributes") {
        return @()
    }
    
    $types = @()
    
    # Match public classes, records, structs, interfaces, enums
    $pattern = '(?ms)^(\s*)(///[^\n]*\n)*\s*(public\s+(?:sealed\s+|abstract\s+|static\s+)?(?:class|record|struct|interface|enum))\s+([^\s:<\{]+)'
    
    $matches = [regex]::Matches($content, $pattern)
    
    foreach ($match in $matches) {
        $typeKeyword = $match.Groups[3].Value.Trim()
        $typeName = $match.Groups[4].Value.Trim()
        
        # Get line number
        $lineNum = ($content.Substring(0, $match.Index) -split "`n").Count
        
        # Extract XML doc
        $doc = Get-XmlDocComment -lines $lines -startLine ($lineNum - 1)
        
        $types += @{
            Name = $typeName
            Kind = if ($typeKeyword -match "class") { "class" } 
                   elseif ($typeKeyword -match "interface") { "interface" }
                   elseif ($typeKeyword -match "enum") { "enum" }
                   elseif ($typeKeyword -match "record") { "record" }
                   elseif ($typeKeyword -match "struct") { "struct" }
                   else { "class" }
            XmlDoc = $doc
            File = $sourceFile
            LineNumber = $lineNum
        }
    }
    
    return $types
}

Write-Host "Scanning projects..." -ForegroundColor Cyan

foreach ($project in $projects) {
    $projectPath = Join-Path $SourceRoot $project
    
    if (-not (Test-Path $projectPath)) {
        Write-Warning "Project not found: $project"
        continue
    }
    
    Write-Host "`nProcessing $project..." -ForegroundColor Yellow
    
    # Find all C# source files (excluding tests and generated files)
    $sourceFiles = Get-ChildItem -Path $projectPath -Filter "*.cs" -Recurse | 
        Where-Object { $_.FullName -notmatch "\\obj\\|\\bin\\|Tests\\|_Imports\\.cs|AssemblyInfo|GlobalUsings" }
    
    Write-Host "  Found $($sourceFiles.Count) source files" -ForegroundColor Gray
    
    $projectTypes = @()
    
    foreach ($file in $sourceFiles) {
        $types = Get-PublicTypes -sourceFile $file.FullName
        $projectTypes += $types
    }
    
    Write-Host "  Extracted $($projectTypes.Count) public types" -ForegroundColor Gray
    
    $totalTypes += $projectTypes.Count
    
    # Output summary
    $projectTypes | Group-Object Kind | ForEach-Object {
        Write-Host "    - $($_.Count) $($_.Name)s" -ForegroundColor DarkGray
    }
}

Write-Host "`n=== Summary ===" -ForegroundColor Green
Write-Host "Total Projects: $($projects.Count)"
Write-Host "Total Public Types: $totalTypes"
Write-Host "Documentation files will be created in: $DocsRoot"
Write-Host "`nNote: This script only scans types. Full documentation generation requires parsing members."

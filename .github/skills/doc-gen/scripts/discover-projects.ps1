#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Discover documentable projects under one or more folders.

.DESCRIPTION
    Returns a JSON array of project records:

        {
          "path":      "<project-root-dir>",
          "type":      "dotnet|java|kotlin|typescript|javascript",
          "manifest":  "<solution-or-project-filename>",
          "project":   "<assembly-or-package-name>",
          "xmlPath":   "<project-root>/bin/docs/docs.xml" | null
        }

    For .NET, every non-test .csproj below each folder becomes one record. The
    sln file, if present, is used only to discover the csproj set and is not
    returned as its own record. `xmlPath` is populated when the compiler-
    emitted XML doc file exists at `<project>/bin/docs/docs.xml` (the convention
    enforced by the repo's `Directory.Build.props`).

    For other languages, the detection is still coarse (one record per root
    folder) — they will be refined when those language normalizers are wired up.

.PARAMETER Folders
    One or more root folders to scan.

.PARAMETER XmlPattern
    Override the per-project relative path at which to look for the extracted
    XML doc file. Default: `bin/docs/docs.xml`.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory, Position = 0)][string[]]$Folders,
    [string]$XmlPattern = 'bin/docs/docs.xml'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

if (-not $Folders -or $Folders.Count -eq 0) {
    '[]'
    return
}

$results = [System.Collections.Generic.List[object]]::new()

function Resolve-XmlPath {
    param([string]$ProjectDir)
    $candidate = Join-Path $ProjectDir $XmlPattern
    if (Test-Path -LiteralPath $candidate) {
        return (Resolve-Path -LiteralPath $candidate).Path
    }
    return $null
}

function Add-Project {
    param([string]$Path, [string]$Type, [string]$Manifest, [string]$Project)
    $resolved = (Resolve-Path -LiteralPath $Path).Path
    $xml = if ($Type -eq 'dotnet') { Resolve-XmlPath -ProjectDir $resolved } else { $null }
    $results.Add([pscustomobject]@{
        path     = $resolved
        type     = $Type
        manifest = $Manifest
        project  = $Project
        xmlPath  = $xml
    })
}

function Get-AssemblyName([string]$CsprojPath) {
    try {
        [xml]$doc = Get-Content -LiteralPath $CsprojPath -Raw
        $node = $doc.SelectSingleNode('//AssemblyName')
        if ($node -and $node.InnerText) { return $node.InnerText.Trim() }
    } catch { }
    return [System.IO.Path]::GetFileNameWithoutExtension($CsprojPath)
}

foreach ($folder in $Folders) {
    if (-not (Test-Path -LiteralPath $folder)) { continue }
    $root = (Resolve-Path -LiteralPath $folder).Path

    # --- .NET ---
    $csprojFiles = @(Get-ChildItem -Path $root -Filter '*.csproj' -File -Recurse -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch '[\\/](bin|obj|node_modules|packages)[\\/]' })
    $nonTest = @($csprojFiles | Where-Object { $_.BaseName -notmatch '\.Tests\.' })
    if ($nonTest.Count -gt 0) {
        foreach ($csproj in $nonTest) {
            $asmName = Get-AssemblyName $csproj.FullName
            Add-Project -Path $csproj.Directory.FullName -Type 'dotnet' -Manifest $csproj.Name -Project $asmName
        }
    }

    # --- Kotlin ---
    $ktsRoot = Join-Path $root 'build.gradle.kts'
    if (Test-Path -LiteralPath $ktsRoot) {
        Add-Project -Path $root -Type 'kotlin' -Manifest 'build.gradle.kts' -Project (Split-Path -Leaf $root)
    }
    # --- Java (maven) ---
    $pom = Join-Path $root 'pom.xml'
    if (Test-Path -LiteralPath $pom) {
        Add-Project -Path $root -Type 'java' -Manifest 'pom.xml' -Project (Split-Path -Leaf $root)
    }
    # --- Java (gradle, non-kts) ---
    $gradleRoot = Join-Path $root 'build.gradle'
    if ((Test-Path -LiteralPath $gradleRoot) -and -not (Test-Path -LiteralPath $ktsRoot)) {
        Add-Project -Path $root -Type 'java' -Manifest 'build.gradle' -Project (Split-Path -Leaf $root)
    }

    # --- TypeScript / JavaScript ---
    $pkg = Join-Path $root 'package.json'
    $tsconfig = Join-Path $root 'tsconfig.json'
    if (Test-Path -LiteralPath $pkg) {
        $name = (Split-Path -Leaf $root)
        try {
            $pkgData = Get-Content -LiteralPath $pkg -Raw | ConvertFrom-Json
            if ($pkgData.PSObject.Properties.Name -contains 'name' -and $pkgData.name) { $name = $pkgData.name }
        } catch { }
        if (Test-Path -LiteralPath $tsconfig) {
            Add-Project -Path $root -Type 'typescript' -Manifest 'package.json' -Project $name
        } else {
            Add-Project -Path $root -Type 'javascript' -Manifest 'package.json' -Project $name
        }
    }
}

if ($results.Count -eq 0) { '[]'; return }
# PowerShell ConvertTo-Json emits a scalar for single-element arrays; force array.
$results | ConvertTo-Json -Depth 5 -AsArray

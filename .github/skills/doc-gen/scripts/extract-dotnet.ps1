#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Build a .NET project with XML documentation generation enabled and return
    the paths of the produced assembly and XML doc file.

.DESCRIPTION
    Does not modify the project file. Uses a temporary output directory so the
    real build output is not polluted. Emits a JSON object:
        { "assembly": "<path>", "xml": "<path>", "outputDir": "<path>" }
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$ProjectPath,
    [Parameter(Mandatory)][string]$Manifest
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$manifestPath = Join-Path $ProjectPath $Manifest
if (-not (Test-Path -LiteralPath $manifestPath)) {
    throw "Manifest not found: $manifestPath"
}

$outDir = Join-Path ([System.IO.Path]::GetTempPath()) ("doc-gen-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$buildArgs = @(
    'build', $manifestPath,
    '-c', 'Release',
    '-p:GenerateDocumentationFile=true',
    '-p:TreatWarningsAsErrors=false',
    '-p:NoWarn=CS1591',
    '-o', $outDir,
    '--nologo', '--verbosity', 'quiet'
)

$buildOutput = & dotnet @buildArgs 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error ("dotnet build failed (exit $LASTEXITCODE):`n" + ($buildOutput -join "`n"))
    exit $LASTEXITCODE
}

# Prefer the project's own assembly — match <AssemblyName> or use manifest basename.
$baseName = [System.IO.Path]::GetFileNameWithoutExtension($Manifest)
$asm = Get-ChildItem -Path $outDir -Filter ($baseName + '.dll') -File -ErrorAction SilentlyContinue | Select-Object -First 1
$xml = Get-ChildItem -Path $outDir -Filter ($baseName + '.xml') -File -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $asm) { throw "Build succeeded but no assembly named $baseName.dll was produced in $outDir." }
if (-not $xml) { throw "Build succeeded but no XML doc file named $baseName.xml was produced. Ensure the project has XML comments." }

[pscustomobject]@{
    assembly  = $asm.FullName
    xml       = $xml.FullName
    outputDir = $outDir
} | ConvertTo-Json -Depth 4 -Compress

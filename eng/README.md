This folder is for build and general engineering support tooling such as build scripts, tools, etc.

## Available Scripts

### setup-hooks.ps1

Configures the local Git repository to use the shared hooks in `.githooks/`. Run this **once** after cloning.

**Usage:**

```powershell
.\eng\scripts\setup-hooks.ps1
```

Or manually:

```bash
git config core.hooksPath .githooks
```

**Active hooks:**

| Hook | Trigger | Behavior |
|------|---------|----------|
| `pre-push` | Before every `git push` | Runs `dotnet test src/src.sln`. Blocks the push if any test fails. |

> **Note:** Git's `--no-verify` flag is a built-in escape hatch that bypasses hooks. This cannot be disabled programmatically.

### Analyze-AllFiles-SonarQube.ps1

Triggers SonarQube analysis on all production C# files in the workspace (excluding test projects, templates, and build artifacts).

**Usage:**

```powershell
# Analyze with default settings (batch size 10)
.\Analyze-AllFiles-SonarQube.ps1

# Analyze with custom batch size
.\Analyze-AllFiles-SonarQube.ps1 -BatchSize 20

# Analyze specific source path
.\Analyze-AllFiles-SonarQube.ps1 -SourcePath "C:\MyProject\src" -BatchSize 5

# Include template files in analysis
.\Analyze-AllFiles-SonarQube.ps1 -IncludeTemplates
```

**Parameters:**
- `-SourcePath`: Root source directory to scan (default: `../src`)
- `-BatchSize`: Number of files to analyze per batch (default: 10, range: 1-100)
- `-IncludeTemplates`: Include template files in analysis

**Requirements:**
- SonarQube for IDE (formerly SonarLint) extension installed in VS Code
- Run from within VS Code with GitHub Copilot CLI integration

### pack-and-push.ps1

NuGet package building and publishing script.

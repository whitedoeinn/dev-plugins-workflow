# Machine Setup for Claude Code (Windows Native)
# Run this once on a new Windows machine to configure plugins and settings.
# Also safe to re-run to clean up and reset to a known good state.
#
# Usage:
#   irm https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/main/scripts/machine-setup.ps1 | iex
#   # or
#   .\scripts\machine-setup.ps1

$ErrorActionPreference = "Stop"

Write-Host "Setting up Claude Code environment..." -ForegroundColor Cyan
Write-Host ""

# Ensure ~/.claude directory exists
$claudeDir = "$env:USERPROFILE\.claude"
$pluginsDir = "$claudeDir\plugins"
if (-not (Test-Path $claudeDir)) { New-Item -ItemType Directory -Path $claudeDir -Force | Out-Null }
if (-not (Test-Path $pluginsDir)) { New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null }

# Check for claude CLI
if (-not (Get-Command claude -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Claude Code CLI not found. Install it first:" -ForegroundColor Red
    Write-Host "  irm https://claude.ai/install.ps1 | iex"
    exit 1
}

# Step 1: Clear plugin caches
Write-Host "Step 1: Clearing plugin caches..." -ForegroundColor Yellow
$cachePaths = @(
    "$pluginsDir\cache\wdi-marketplace",
    "$pluginsDir\cache\every-marketplace"
)
foreach ($path in $cachePaths) {
    if (Test-Path $path) {
        Remove-Item -Recurse -Force $path -ErrorAction SilentlyContinue
    }
}
Write-Host "  Done" -ForegroundColor Green

# Step 2: Update marketplaces
Write-Host ""
Write-Host "Step 2: Updating marketplaces..." -ForegroundColor Yellow
try { claude plugin marketplace update wdi-marketplace 2>$null } catch {}
try { claude plugin marketplace update every-marketplace 2>$null } catch {}
Write-Host "  Done" -ForegroundColor Green

# Step 3: Clean installed_plugins.json
Write-Host ""
Write-Host "Step 3: Cleaning plugin registry..." -ForegroundColor Yellow
$installedPlugins = "$pluginsDir\installed_plugins.json"

if (Test-Path $installedPlugins) {
    try {
        $json = Get-Content $installedPlugins -Raw | ConvertFrom-Json

        # Filter to keep only user-scope entries
        $plugins = @("wdi@wdi-marketplace", "compound-engineering@every-marketplace", "frontend-design@claude-plugins-official")

        foreach ($plugin in $plugins) {
            if ($json.plugins.PSObject.Properties.Name -contains $plugin) {
                $entries = @($json.plugins.$plugin | Where-Object { $_.scope -eq "user" })
                if ($entries.Count -gt 1) {
                    # Keep only the most recent
                    $entries = @($entries | Sort-Object installedAt | Select-Object -Last 1)
                }
                $json.plugins.$plugin = $entries
            }
        }

        $json | ConvertTo-Json -Depth 10 | Set-Content $installedPlugins -Encoding UTF8
        Write-Host "  Cleaned registry (kept user-scope entries)" -ForegroundColor Green
    } catch {
        Write-Host "  Warning: Could not clean registry: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "  No existing registry (fresh install)" -ForegroundColor Green
}

# Step 4: Remove project-scope settings files
Write-Host ""
Write-Host "Step 4: Removing stale project settings files..." -ForegroundColor Yellow
$projectPaths = @(
    "$env:USERPROFILE\github\whitedoeinn\dev-plugins-workflow",
    "$env:USERPROFILE\github\whitedoeinn\events",
    "$env:USERPROFILE\github\whitedoeinn\google-ads",
    "$env:USERPROFILE\github\whitedoeinn\integration"
)

foreach ($project in $projectPaths) {
    $settingsFile = "$project\.claude\settings.json"
    if (Test-Path $settingsFile) {
        Remove-Item -Force $settingsFile
        Write-Host "  Removed: $settingsFile" -ForegroundColor Gray
    }
}
Write-Host "  Done" -ForegroundColor Green

# Step 5: Ensure plugins are installed at user scope
Write-Host ""
Write-Host "Step 5: Ensuring plugins at user scope..." -ForegroundColor Yellow

$pluginsToInstall = @(
    "compound-engineering@every-marketplace",
    "wdi@wdi-marketplace",
    "frontend-design@claude-plugins-official"
)

foreach ($plugin in $pluginsToInstall) {
    try {
        $listOutput = claude plugin list --json 2>$null | ConvertFrom-Json
        $installed = @($listOutput | Where-Object { $_.id -eq $plugin -and $_.scope -eq "user" })

        if ($installed.Count -eq 0) {
            Write-Host "  Installing $plugin..." -ForegroundColor Gray
            claude plugin install $plugin --scope user
        } else {
            Write-Host "  Updating $plugin..." -ForegroundColor Gray
            try { claude plugin update $plugin 2>$null } catch {}
        }
    } catch {
        Write-Host "  Installing $plugin..." -ForegroundColor Gray
        try { claude plugin install $plugin --scope user } catch {}
    }
}
Write-Host "  Done" -ForegroundColor Green

# Step 6: Create settings.json
Write-Host ""
Write-Host "Step 6: Creating settings.json..." -ForegroundColor Yellow

$settingsContent = @'
{
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "enabledPlugins": {
    "frontend-design@claude-plugins-official": true,
    "compound-engineering@every-marketplace": true,
    "wdi@wdi-marketplace": true
  }
}
'@

$settingsContent | Set-Content "$claudeDir\settings.json" -Encoding UTF8
Write-Host "  Done" -ForegroundColor Green

# Step 7: Create global CLAUDE.md
Write-Host ""
Write-Host "Step 7: Creating global CLAUDE.md..." -ForegroundColor Yellow

$claudeMdContent = @'
# Global Claude Code Settings

## White Doe Inn Business Information

Central reference for business details used across forms, filings, and integrations.

### Legal Entity

| Field | Value |
|-------|-------|
| Legal Name | Inspired Manteo Moments, Inc. |
| DBA | White Doe Inn |
| Entity Type | C-Corporation |
| Formation Date | January 24, 2024 |
| Fiscal Year End | December 31 |

### Federal IDs

| Field | Value |
|-------|-------|
| Federal EIN | 99-1023961 |
| EFTPS PIN | 7033 |
| EFTPS Enrollment # | 654352517081036052 |

### North Carolina State IDs

| Field | Value |
|-------|-------|
| NC Secretary of State ID | 2853579 |
| NC Income Tax Withholding ID | 601593676 |
| NC Sales & Use Tax ID | 601593676 |
| NC Unemployment Tax Account | 0100026519 |
| NC DHHS Facility ID | 028230011 |

### Dare County IDs

| Field | Value |
|-------|-------|
| Personal Property Tax Account | 9807980090 |
| BPP Customer # | 23099149 |
| Occupancy Tax Account | 7977 |
| F&B Tax Account | 8021 |
| District | Town of Manteo |

### Property

| Field | Value |
|-------|-------|
| Physical Address | 319 Sir Walter Raleigh St., Manteo, NC 27954 |
| Parcel # (Main) | 024747000 |
| Parcel # (Uppowoc) | 024747001 |
| County | Dare |

### Contacts

| Role | Name | Email | Phone |
|------|------|-------|-------|
| Primary Contact | David Roberts | dave@whitedoeinn.com | 314-409-4016 |
| Procurement | Tonia Roberts | tonia@whitedoeinn.com | 314-378-2898 |

| Field | Value |
|-------|-------|
| Mailing Address | 319 Sir Walter Raleigh St., Manteo, NC 27954 |
| Website (Main) | https://www.whitedoeinn.com |
| Website (Reservations) | https://secure.thinkreservations.com/whitedoeinn/reservations |

### Industry Codes

| Field | Value |
|-------|-------|
| NAICS | 721191 - Bed-and-Breakfast Inns |
| SIC | 7011 - Hotels and Motels |

### Banking

| Field | Value |
|-------|-------|
| Primary Bank | |
| Operating Account | |
| Savings Account | |

### Insurance

| Type | Carrier | Policy # | Agent |
|------|---------|----------|-------|
| Property/Liability | | | |
| Workers Comp | | | |
| Umbrella | | | |

### Licenses & Permits

| License | Number | Expiration |
|---------|--------|------------|
| ABC Permit | | |
| Health Permit | | |
| Business License | | |

### Key Vendors

| Vendor | Account # | Purpose |
|--------|-----------|---------|
| | | |

### Professional Services

| Role | Contact | Firm |
|------|---------|------|
| CPA/Accountant | | |
| Attorney | | |
| Registered Agent | | |

---

## Google Drive

Google Drive is synced locally at `C:\Users\dgrst\Google Drive\`.

**Primary shared drive:**
- **White Doe Inn**: `C:\Users\dgrst\Google Drive\Shared drives\White Doe Inn\`

When I mention "Google Drive" or files related to White Doe Inn business operations, look in the shared drive path above.

### Common locations:
- Kitchen Remodel: `C:\Users\dgrst\Google Drive\Shared drives\White Doe Inn\Operations\Building and Maintenance \Kitchen Remodel\`
- Weathertek files: `C:\Users\dgrst\Google Drive\Shared drives\White Doe Inn\Operations\Building and Maintenance \Kitchen Remodel\Weathertek Construction & Restoration\`

## Claude Code Environment Standards

### Path Resolution

I use Claude Code on Windows (native CLI) and Ubuntu/WSL (CLI). Interpret `~` based on platform:

| Platform | Environment | `~` resolves to |
|----------|-------------|-----------------|
| `win32` | Native Windows CLI | `C:\Users\dgrst\` |
| `linux` | CLI in Ubuntu/WSL | `/home/dave/` |

**Cross-filesystem access:**
- From Windows: WSL files at `\\wsl.localhost\Ubuntu\home\dave\`
- From WSL: Windows files at `/mnt/c/Users/dgrst/`

### Plugin Installation Policy

**All plugins MUST be installed at user scope (global), NOT project scope.**

Expected configuration in `~\.claude\settings.json`:
```json
{
  "enabledPlugins": {
    "compound-engineering@every-marketplace": true,
    "wdi@wdi-marketplace": true
  }
}
```

**DRIFT ALERT:** If you see ANY of these conditions, stop and alert me:
- A `.claude\settings.json` file exists in ANY project directory
- `claude plugin list` shows the same plugin at both user AND project scope
- Any plugin installed at project scope (should always be user scope)

**Why this matters:** Project-scope installations create version conflicts and stale caches. User-scope ensures all projects use the same version and updates propagate correctly.

### Protected Settings

These settings should NEVER be modified without explicit user request:
- Plugin installation scope (must stay at user scope)
- Permission mode settings
- Status line configuration
- Hook configurations

If any workflow or script attempts to modify these settings, warn me before proceeding.
'@

$claudeMdContent | Set-Content "$claudeDir\CLAUDE.md" -Encoding UTF8
Write-Host "  Done" -ForegroundColor Green

# Step 8: Verify installation
Write-Host ""
Write-Host "Step 8: Verifying installation..." -ForegroundColor Yellow
Write-Host ""

try {
    $pluginList = claude plugin list --json 2>$null | ConvertFrom-Json

    $checkPlugins = @(
        @{ id = "compound-engineering@every-marketplace"; name = "compound-engineering" },
        @{ id = "wdi@wdi-marketplace"; name = "wdi" },
        @{ id = "frontend-design@claude-plugins-official"; name = "frontend-design" }
    )

    foreach ($check in $checkPlugins) {
        $userCount = @($pluginList | Where-Object { $_.id -eq $check.id -and $_.scope -eq "user" }).Count
        $projectCount = @($pluginList | Where-Object { $_.id -eq $check.id -and $_.scope -eq "project" }).Count
        $version = ($pluginList | Where-Object { $_.id -eq $check.id -and $_.scope -eq "user" } | Select-Object -First 1).version

        if ($userCount -eq 1 -and $projectCount -eq 0) {
            Write-Host "  [OK] $($check.name): user scope, v$version" -ForegroundColor Green
        } else {
            Write-Host "  [!!] $($check.name): user=$userCount, project=$projectCount" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "  Warning: Could not verify plugins: $_" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "  Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "  Restart Claude Code to activate plugins."
Write-Host "  To verify: claude plugin list"
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan

# WDI CLI Testing Context

**Saved**: 2026-01-11
**Purpose**: Resume testing the new `wdi` CLI

## What We Built

Created `scripts/wdi` - a bash CLI for standards-aware project bootstrapping that runs **before** Claude Code starts.

### Commands
- `wdi install` - Self-install via curl | bash
- `wdi config` - Set GitHub org, domains, project location
- `wdi doctor` - Check/install deps (git, gh, jq, claude)
- `wdi create_project` - Interactive project creation with REPO-STANDARDS compliance
- `wdi update` - Update to latest version

### Commit
- Pushed to main: `39bcb85`
- All basic tests pass on macOS

## Next Steps

### 1. Create Feature Branch for Testing
```bash
git checkout -b feature/test-wdi-cli
git push -u origin feature/test-wdi-cli
```

### 2. Set GitHub Token (you're doing this now)
Create fine-grained PAT at: https://github.com/settings/tokens?type=beta
- Permissions: Administration (RW), Contents (RW), Metadata (R)
- Save as `GITHUB_TOKEN` env var

### 3. Docker Test
```bash
docker run -it --rm \
  -e GITHUB_TOKEN="$GITHUB_TOKEN" \
  -e GITHUB_ORG="whitedoeinn" \
  ubuntu:22.04 bash

# Inside container:
apt update && apt install -y curl git sudo
curl -sSL https://raw.githubusercontent.com/whitedoeinn/dev-plugins-workflow/feature/test-wdi-cli/scripts/wdi | bash -s install
echo "$GITHUB_TOKEN" | gh auth login --with-token
wdi create_project
```

### 4. Test Matrix

| Test | Status |
|------|--------|
| Fresh install (Docker/Linux) | TODO |
| Fresh install (macOS) | ✓ Done |
| `wdi doctor` missing deps | TODO |
| `wdi config` | TODO |
| Create: Plugin | TODO |
| Create: Business Domain | TODO |
| Create: Standalone | TODO |
| Create: Experiment | TODO |
| Custom name + exception | TODO |
| Existing directory handling | TODO |
| Existing GitHub repo handling | TODO |

### 5. Cleanup Test Repos
```bash
gh repo list whitedoeinn --json name -q '.[].name' | grep '^test-wdi-' | while read repo; do
  gh repo delete "whitedoeinn/$repo" --yes
done
```

## Potential Enhancements to Add

1. `--test-prefix` flag to auto-prefix repos with `test-wdi-{timestamp}`
2. `--dry-run` flag to skip GitHub creation
3. Better error messages for auth failures

## Files Changed

- `scripts/wdi` - New CLI (1122 lines)
- `docs/changelog.md` - Added wdi CLI section

## Plan File

Full implementation plan saved at:
`/Users/davidroberts/.claude/plans/golden-snuggling-curry.md`

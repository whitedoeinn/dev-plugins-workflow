# CLAUDE Code CLI — macOS install

This repository requires the `claude` command-line tool (Claude Code). The following steps describe safe, common ways to install it on macOS.

1) Verify current state

  claude --version

If the command prints a version, you're ready.

2) Homebrew (recommended when available)

- If you use Homebrew, try:

  brew update
  brew install claude || brew install --cask claude

- If the formula/cask isn't available, check the project website below.

Homebrew cask note:

- The Homebrew `claude` cask installs the desktop app and may create a shim
  at `/opt/homebrew/bin/claude` that points to the GUI bundle. That shim is
  not the CLI and will fail when run as `claude --version`.

- If you see `claude` on your PATH but running `claude --version` crashes,
  remove the GUI shim and run the official installer (or reinstall the CLI):

  sudo rm -f /opt/homebrew/bin/claude
  # then run the official installer (review first):
  curl -fsSL https://claude.ai/install.sh | bash

Or to uninstall the desktop app via Homebrew first:

  brew uninstall --cask claude


3) Official installer (review before running)

The project provides an official installer script. Always review remote scripts before piping to `bash`.

  curl -fsSL https://claude.ai/install.sh | bash

To allow this repository's helper script to run the remote installer automatically, set the environment variable `CLAUDE_ALLOW_REMOTE_INSTALL=1`.

4) Non-interactive automation

If you want the repository helper to attempt automated installs (Homebrew first, then optional remote installer), set:

  CLAUDE_AUTO_INSTALL=1 CLAUDE_ALLOW_REMOTE_INSTALL=1 bash scripts/ensure-claude.sh

Use this only if you trust the installer and want unattended behavior.

5) After installation

Reload your shell so newly installed binaries are on the `PATH`:

  exec $SHELL

Then verify again:

  claude --version

6) Troubleshooting

- If `claude` is installed but not found, ensure the install directory (e.g. `/usr/local/bin` or `/opt/homebrew/bin`) is in your `PATH`.
- If Homebrew install fails, visit the official site: https://claude.com or the installer URL: https://claude.ai/install.sh

Want me to run the repository helper script now? I can either:
- run a non-destructive check (no install attempts), or
- attempt Homebrew install (requires permission), or
- allow the script to run the remote installer (requires explicit permission).

Choose which behavior you prefer when you reply.
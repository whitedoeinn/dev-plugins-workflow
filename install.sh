#!/bin/bash

# Install Claude workflows into a project via symlinks

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:-.}"

if [[ ! -d "$PROJECT_DIR" ]]; then
    echo "Error: Project directory not found: $PROJECT_DIR"
    exit 1
fi

# Resolve to absolute path
PROJECT_DIR="$(cd "$PROJECT_DIR" && pwd)"

# Create .claude/commands if it doesn't exist
mkdir -p "$PROJECT_DIR/.claude/commands"

# Create symlinks (force overwrites existing)
ln -sf "$SCRIPT_DIR/commands/feature.md" "$PROJECT_DIR/.claude/commands/feature.md"
ln -sf "$SCRIPT_DIR/commands/commit.md" "$PROJECT_DIR/.claude/commands/commit.md"

echo "Installed Claude workflows to $PROJECT_DIR/.claude/commands/"
echo "  - feature.md -> $SCRIPT_DIR/commands/feature.md"
echo "  - commit.md -> $SCRIPT_DIR/commands/commit.md"

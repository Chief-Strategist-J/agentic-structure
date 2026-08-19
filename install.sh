#!/usr/bin/env bash
# ==============================================================================
# Agentic Structure Platform Installer (CLI Installation Script)
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Chief-Strategist-J/agentic-structure/main/install.sh | bash
# ==============================================================================

set -euo pipefail

REPO_URL="https://github.com/Chief-Strategist-J/agentic-structure.git"
INSTALL_DIR="${TARGET_DIR:-$HOME/agentic-structure}"

BOLD='\033[1;32m'
BLUE='\033[1;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}======================================================================${NC}"
echo -e "${BOLD}       Installing Agentic Structure Architecture & Platform          ${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo ""

# 1. Check prerequisites
echo -e "➜ Checking system prerequisites..."
for cmd in git bash python3; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "ERROR: Required command '$cmd' is not installed." >&2
    exit 1
  fi
done
echo "✔ Prerequisites verified."

# 2. Clone repository into target directory
if [ -d "$INSTALL_DIR" ]; then
  echo -e "➜ Target directory '$INSTALL_DIR' already exists."
  cd "$INSTALL_DIR"
  if [ -d ".git" ]; then
    echo "➜ Pulling latest main..."
    git pull origin main --quiet || true
  fi
else
  echo -e "➜ Cloning platform repository into '$INSTALL_DIR'..."
  git clone "$REPO_URL" "$INSTALL_DIR" --quiet
  cd "$INSTALL_DIR"
fi

# 3. Ensure agent-kit platform structure exists if installing into existing repo
if [ ! -d "agent-kit" ]; then
  echo "➜ Copying agent-kit infrastructure into target workspace..."
  tmp_dir=$(mktemp -d)
  git clone "$REPO_URL" "$tmp_dir" --quiet
  cp -r "$tmp_dir/agent-kit" .
  cp -r "$tmp_dir/AGENTS.md" . 2>/dev/null || true
  cp -r "$tmp_dir/CLAUDE.md" . 2>/dev/null || true
  cp -r "$tmp_dir/GEMINI.md" . 2>/dev/null || true
  rm -rf "$tmp_dir"
fi

# 4. Install Git pre-commit hooks
echo -e "➜ Installing 41-rule mechanical Git pre-commit gates..."
bash agent-kit/scripts/install-git-hooks.sh >/dev/null 2>&1 || true
echo "✔ Git hooks installed."

# 5. Execute Rule Engine Verification
echo -e "➜ Executing 41-rule manifest verification..."
bash agent-kit/scripts/run-rules-manifest.sh

echo ""
echo -e "${BLUE}======================================================================${NC}"
echo -e "${BOLD}               Installation Successfully Completed!                   ${NC}"
echo -e "${BLUE}======================================================================${NC}"
echo ""
echo "To get started:"
echo -e "  ${BOLD}cd $INSTALL_DIR${NC}"
echo -e "  ${BOLD}docker compose up --build -d${NC}"
echo ""
echo "Enforced Rules & Manifest:"
echo -e "  Manifest: ${INSTALL_DIR}/agent-kit/platform/rules-manifest.yaml"
echo -e "  Pre-commit gate: ${INSTALL_DIR}/.git/hooks/pre-commit"
echo ""

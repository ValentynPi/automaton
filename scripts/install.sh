#!/usr/bin/env bash
# Install self-hosted Automaton (OpenAI, no Conway Cloud).
set -euo pipefail

REPO_URL="${AUTOMATON_REPO:-https://github.com/ValentynPi/automaton.git}"
INSTALL_DIR="${AUTOMATON_DIR:-$HOME/automaton}"
BRANCH="${AUTOMATON_BRANCH:-main}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing '$1'. Install it, then re-run this script." >&2
    exit 1
  }
}

need git
need node
need npm

NODE_MAJOR="$(node -p "process.versions.node.split('.')[0]")"
if [ "$NODE_MAJOR" -lt 20 ]; then
  echo "Node.js 20+ is required (found $(node -v))." >&2
  exit 1
fi

if [ -d "$INSTALL_DIR/.git" ]; then
  echo "Updating existing install at $INSTALL_DIR"
  git -C "$INSTALL_DIR" fetch origin
  git -C "$INSTALL_DIR" checkout "$BRANCH"
  git -C "$INSTALL_DIR" pull --ff-only origin "$BRANCH"
else
  echo "Cloning $REPO_URL → $INSTALL_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"
npm install
npx tsc
npm install -g .

echo
echo "Installed. Run:"
echo "  automaton --run"
echo
echo "First run opens the setup wizard (OpenAI key + name + genesis prompt)."
echo "Config is stored in ~/.automaton/"

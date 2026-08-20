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
  echo "Updating install at $INSTALL_DIR from $REPO_URL"
  git -C "$INSTALL_DIR" remote set-url origin "$REPO_URL"
  git -C "$INSTALL_DIR" fetch origin
  git -C "$INSTALL_DIR" checkout "$BRANCH"
  git -C "$INSTALL_DIR" reset --hard "origin/$BRANCH"
else
  echo "Cloning $REPO_URL → $INSTALL_DIR"
  git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

cd "$INSTALL_DIR"
echo "Using repo: $(git remote get-url origin)"
npm install
npx tsc
chmod +x dist/index.js
npm install -g .

# Some npm prefixes leave the global shim non-executable (common with ~/.npm-global).
for candidate in \
  "$(npm prefix -g 2>/dev/null)/bin/automaton" \
  "$HOME/.npm-global/bin/automaton" \
  "/usr/local/bin/automaton"; do
  if [ -e "$candidate" ]; then
    chmod +x "$candidate" || true
    if [ -L "$candidate" ]; then
      target="$(readlink -f "$candidate" 2>/dev/null || true)"
      [ -n "$target" ] && chmod +x "$target" || true
    fi
  fi
done

echo
echo "Installed. Run:"
echo "  automaton --run"
echo
echo "If you see Permission denied, run:"
echo "  chmod +x \"\$(npm prefix -g)/bin/automaton\" ~/automaton/dist/index.js"
echo "  # or: node ~/automaton/dist/index.js --run"
echo
echo "First run opens the setup wizard (OpenAI key + name + genesis prompt)."
echo "Do NOT run automaton --provision (that is Conway Cloud only)."
echo "Config is stored in ~/.automaton/"

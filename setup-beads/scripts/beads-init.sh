#!/usr/bin/env bash
#
# beads-init.sh — install + initialize Beads (bd) for LOCAL-ONLY use.
#
# What it guarantees:
#   • No changes to any git-tracked or shared file (.gitignore is restored,
#     .claude/settings.json is never touched).
#   • No Beads sync: the Dolt remote is unset, so issues never leave your machine.
#   • Idempotent: safe to re-run; skips work that's already done.
#
# Usage:  bash scripts/beads-init.sh [prefix]
#   prefix defaults to "bead" (override with arg or BEADS_PREFIX env var).
#
# This is a LOCAL developer-tool setup on a non-production machine. Review it
# before running (org policy: treat AI-generated scripts as untrusted, run in
# non-production first).

set -euo pipefail

PREFIX="${1:-${BEADS_PREFIX:-bead}}"

# --- run from the repo root ---------------------------------------------------
ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$ROOT" ]; then
  echo "ERROR: not inside a git repository." >&2
  exit 1
fi
cd "$ROOT"
echo "Repo: $ROOT"

# --- 1. install bd if missing -------------------------------------------------
if command -v bd >/dev/null 2>&1; then
  echo "✓ bd already installed: $(bd version 2>/dev/null || echo unknown)"
elif [ "$(uname)" = "Darwin" ] && command -v brew >/dev/null 2>&1; then
  echo "Installing bd via Homebrew (homebrew-core formula, checksum-verified)..."
  brew install beads
elif command -v npm >/dev/null 2>&1; then
  echo "Installing bd via npm..."
  npm install -g @beads/bd
elif command -v go >/dev/null 2>&1; then
  echo "Installing bd via go install..."
  CGO_ENABLED=0 go install github.com/steveyegge/beads/cmd/bd@latest
  echo "NOTE: ensure \$(go env GOBIN) (or \$(go env GOPATH)/bin) is on your PATH."
else
  echo "ERROR: no installer found. Install bd manually: https://github.com/steveyegge/beads" >&2
  exit 1
fi
command -v bd >/dev/null 2>&1 || { echo "ERROR: bd not on PATH after install." >&2; exit 1; }

# --- 2. initialize (only if not already initialized) --------------------------
# Flags chosen for a clean local setup:
#   --setup-exclude : keep beads files out of git via repo-local .git/info/exclude
#   --skip-hooks    : this repo uses core.hooksPath=.githooks, so .git/hooks won't fire
#   --skip-agents   : skip the CLAUDE.md / AGENTS.md / .codex / settings.json kitchen-sink
#   --non-interactive : no prompts (also auto-detected in non-TTY)
if [ -d .beads ]; then
  echo "✓ beads already initialized (.beads/ exists) — skipping bd init"
else
  echo "Initializing beads (prefix: $PREFIX)..."
  # Preserve the tracked .gitignore exactly: bd appends Dolt patterns to it,
  # which we don't want in a shared/tracked file. Back up, then restore.
  GI_BAK=""
  if [ -f .gitignore ]; then
    GI_BAK="$(mktemp)"
    cp .gitignore "$GI_BAK"
  fi

  bd init --prefix "$PREFIX" --setup-exclude --skip-hooks --skip-agents --non-interactive

  if [ -n "$GI_BAK" ]; then
    cp "$GI_BAK" .gitignore   # drop bd's appended block, restore exact original
    rm -f "$GI_BAK"
    echo "  restored .gitignore (removed bd's appended Dolt patterns)"
  elif [ -f .gitignore ]; then
    rm -f .gitignore          # repo had none; remove the one bd created
  fi
fi

# --- 3. no sync: unset the Dolt remote bd may have auto-configured ------------
# Keeps personal issue data from ever being pushed to the shared git server.
bd config unset sync.remote >/dev/null 2>&1 || true
echo "✓ sync.remote unset (beads stays local; no push to shared server)"

# --- 4. keep beads/Dolt + personal-settings files out of git (local only) -----
EXCLUDE=.git/info/exclude
add_exclude() {
  grep -qxF "$1" "$EXCLUDE" 2>/dev/null || printf '%s\n' "$1" >> "$EXCLUDE"
}
for p in ".dolt/" ".beads-credential-key" ".claude/settings.local.json"; do
  add_exclude "$p"
done
echo "✓ ensured local-only excludes in $EXCLUDE"

# --- 5. wire the bd-prime SessionStart hook into PERSONAL settings -------------
# .claude/settings.local.json is per-user and gitignored — never committed.
if command -v python3 >/dev/null 2>&1; then
  python3 - <<'PY'
import json, os
p = ".claude/settings.local.json"
os.makedirs(".claude", exist_ok=True)
data = {}
if os.path.exists(p):
    with open(p) as f:
        txt = f.read().strip()
        data = json.loads(txt) if txt else {}
ss = data.setdefault("hooks", {}).setdefault("SessionStart", [])
cmd = "bd prime --hook-json"
present = any(h.get("command") == cmd for grp in ss for h in grp.get("hooks", []))
if present:
    print("✓ SessionStart hook already present in settings.local.json")
else:
    ss.append({"matcher": "", "hooks": [{"type": "command", "command": cmd}]})
    with open(p, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")
    print("✓ added 'bd prime' SessionStart hook to .claude/settings.local.json")
PY
else
  echo "⚠ python3 not found — add this to .claude/settings.local.json manually:"
  echo '    {"hooks":{"SessionStart":[{"matcher":"","hooks":[{"type":"command","command":"bd prime --hook-json"}]}]}}'
fi

# --- 6. verify ----------------------------------------------------------------
echo
echo "=== verify ==="
bd list >/dev/null 2>&1 && echo "✓ bd works ($(bd count 2>/dev/null || echo '0') issues)"
LEAK="$(git status --porcelain | grep -E '\.beads|CLAUDE\.md|AGENTS\.md|\.codex|\.gitignore|settings\.json' || true)"
if [ -z "$LEAK" ]; then
  echo "✓ no beads/Dolt files appear in git status — nothing will be committed"
else
  echo "⚠ unexpected git changes — review before committing:"
  echo "$LEAK"
fi
echo
echo "Done. Restart Claude Code so the SessionStart hook loads beads context."
echo "Try:  bd quickstart   |   bd q \"my first task\"   |   bd ready"

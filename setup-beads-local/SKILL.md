---
name: setup-beads-local
description: Install and initialize the Beads (bd) issue tracker for LOCAL-ONLY use in this repo — no sync, no shared-repo changes. Use when onboarding a developer to beads, or when someone asks to "set up beads", "install bd", or wants personal/local AI-agent task tracking without committing beads files or pushing issues to the team git server.
---

# Set up Beads locally (no sync)

Gives a developer a personal [Beads](https://github.com/steveyegge/beads) (`bd`)
issue tracker for their local AI-agent workflow. Issues stay on their machine —
nothing is committed, nothing is pushed to the shared git server.

## Quick start

```bash
bash .claude/skills/setup-beads-local/scripts/setup-beads.sh
```

Restart Claude Code afterward so the SessionStart hook loads beads context.
Default issue prefix is `mbb` (override via an arg or `BEADS_PREFIX`).

> Per org policy, review the script before running. It is idempotent — safe to re-run.

## What the script does

1. **Installs `bd`** if missing — Homebrew (checksum-verified) → npm → `go install`.
2. **`bd init`** with `--setup-exclude --skip-hooks --skip-agents --non-interactive`.
3. **Unsets `sync.remote`** so beads never pushes to the shared git server.
4. **Excludes** beads/Dolt and personal-settings files via repo-local `.git/info/exclude`.
5. **Adds the `bd prime` SessionStart hook** to the gitignored `.claude/settings.local.json`.
6. **Verifies** `bd` works and that nothing beads-related appears in `git status`.

## What it does NOT touch

- No tracked/shared files — `.gitignore` is backed up and restored, and `.claude/settings.json` is left alone (hence `--skip-agents`).
- No `CLAUDE.md` / `AGENTS.md` / `.codex/` (the bd-init "kitchen sink").
- No sync, backup-push, or auto-export to the team server.
- No `.git/hooks` install — this repo uses `core.hooksPath=.githooks`, so they'd never fire.

Because this is a shared team repo, beads must stay invisible to teammates and CI.
That's why `--setup-exclude` (repo-local) is used instead of `--stealth`, which
writes to your **global** git config and affects all your repos.

## Verify / first commands

```bash
bd list          # empty on a fresh setup
bd quickstart    # guided intro
bd q "my task"   # quick-capture an issue → prints the ID
bd ready         # issues with no open blockers
```

`git status` should show **no** beads files. If it does, the script warns you —
investigate before committing.

## Manual fallback

```bash
cp .gitignore /tmp/gi.bak                                              # preserve tracked .gitignore
bd init --prefix mbb --setup-exclude --skip-hooks --skip-agents --non-interactive
cp /tmp/gi.bak .gitignore                                             # drop bd's appended Dolt patterns
bd config unset sync.remote                                          # no push to shared server
# add the SessionStart hook to .claude/settings.local.json (personal, gitignored):
#   {"hooks":{"SessionStart":[{"matcher":"","hooks":[{"type":"command","command":"bd prime --hook-json"}]}]}}
```

## Notes

- Beads 1.0.5 uses an **embedded Dolt** backend (not SQLite); the DB lives under the excluded `.beads/`.
- To later make beads team-shared (commit `.beads/issues.jsonl` + enable a Dolt remote), that's a separate team decision — out of scope here.

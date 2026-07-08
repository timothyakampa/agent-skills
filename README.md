# Agent Skills

Claude Code skills I'm open-sourcing.

## Install

Skills are installed via the [`npx skills`](https://github.com/vercel-labs/skills) CLI:

```bash
npx skills@latest add timothyakampa/agent-skills --skill capability-model
```

This drops the skill into your Claude Code config directory so it auto-activates on matching prompts.

## Skills

### capability-model

Decompose a monolith by mapping its business capabilities — a workshop pre-read drafted directly from the code, identifying customer experiences, user journeys, capabilities, and the seams along which the monolith can be broken down.

Use when you want to:

- *"Model the business capabilities of this app"*
- *"Build a capability model"*
- *"Find seams to break this monolith down"*
- *"Prepare a monolith for microservice breakdown"*

See [capability-model/SKILL.md](capability-model/SKILL.md) for the full rulebook.

### setup-beads-local

Install and initialize the [Beads](https://github.com/steveyegge/beads) (`bd`) issue tracker for **local-only** use in a shared repo — a personal task tracker for your AI-agent workflow with no sync, no committed files, and nothing pushed to the team git server.

Use when you want to:

- *"Set up beads"* / *"install bd"*
- *"Give me local AI-agent task tracking"*
- *"Onboard me to beads without touching the shared repo"*

See [setup-beads-local/SKILL.md](setup-beads-local/SKILL.md) for the full details.

## License

MIT — see [LICENSE](LICENSE).

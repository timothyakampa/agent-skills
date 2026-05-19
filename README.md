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

## License

MIT — see [LICENSE](LICENSE).

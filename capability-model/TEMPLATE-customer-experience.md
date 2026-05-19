# Customer Experience Artifact Template

Fill this in for each Customer Experience (in `customer-experiences/`). The CE is a composition of capabilities for one customer goal.

---

```markdown
# {{CE Name — e.g. "Ability to book a Provider"}}

| | |
|---|---|
| **Customer Touch Point** | [{{Touch Point Name}}](../capabilities/{{slug}}.md) |
| **Composed Capabilities** | {{count}} |
| **Journey Confidence** | {{high / medium / low}} |

## Customer

[NEEDS-SME-CONFIRM: {{guess from product brief}}] <!-- id=ce:{{slug}}/customer -->

## User Journey

The sequence of steps a customer takes to accomplish this experience.

1. {{Step 1 in user language}}
2. {{Step 2}}
3. ...

<!-- journey source: {{e2e-tests / analytics / nav+routes / user-supplied / mixed}} -->

## Composed Capabilities

Capabilities used by this experience, in approximate order of first use in the journey.

<!-- auto:composed-capabilities:start -->
| Capability | Type | Role in this CE |
|---|---|---|
| [{{Capability Name}}](../capabilities/{{slug}}.md) | {{business / customer-touch-point}} | {{which steps it serves}} |
| [{{Capability Name}}](../capabilities/{{slug}}.md) | business | {{which steps it serves}} |
<!-- auto:end -->

## Cross-CE Reuse

How many other Customer Experiences each composed capability also appears in. High reuse = high leverage = strong candidate for early extraction or dedicated team.

<!-- auto:cross-ce-reuse:start -->
| Capability | Also used in |
|---|---|
| {{Capability Name}} | {{N other CEs: [CE-A](...), [CE-B](...)}} |
| {{Capability Name}} | only this CE |
<!-- auto:end -->

## Open Questions

<!-- auto:open-questions:start -->
- `ce:{{slug}}/customer` — Who is the customer for this experience?
- {{any other CE-level markers}}
<!-- auto:end -->
```

---

## Notes on filling this in

- CE names use customer-language: `Ability to <verb> <object>` or similar. Not implementation language. Not internal codenames.
- The journey here is the **confirmed** journey from the per-journey gate. Identical to the entry in `_journeys.md`.
- "Composed Capabilities" must include exactly **one** Customer Touch Point capability. If a CE somehow uses multiple touch points (e.g., starts on Web, completes on Mobile), record both and flag in `## Notes` — it's worth the workshop's attention.
- `Journey Confidence` reflects the signals available (see SIGNAL-HIERARCHY.md). Be honest — low-confidence journeys need more workshop scrutiny.
- Cross-CE reuse table is the high-leverage signal — capabilities that show up everywhere are usually the most important to get right.

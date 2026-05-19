# Journey Template

Used inside Customer Experience artifacts and aggregated in `_journeys.md`. A journey is one customer goal told as a 3–10-step sequence in user language.

## Single-journey block

```markdown
### {{CE Name — also the journey's title}}

**Touch Point**: {{Touch Point Name}}
**Confidence**: {{high / medium / low}}
**Source**: {{e2e-tests / analytics / nav+routes / user-supplied / mixed}}

1. {{Step in user language}}
2. {{Step in user language}}
3. {{Step in user language}}
...
N. {{Final step — accomplishes the CE goal}}

<!-- evidence:start -->
- {{E2E test, analytics event, or route that supports this journey, file:line}}
- ...
<!-- evidence:end -->
```

## Step phrasing rules

- **User language, not code language.**
  - ✅ "Views list of all available Providers"
  - ❌ "GET /providers"
  - ❌ "ProviderController#index"

- **Active verbs from the user's perspective.**
  - ✅ "Selects a Provider"
  - ❌ "Provider is selected"

- **Granularity**: page-level or screen-level transitions, plus significant in-page actions. Don't enumerate every click; do enumerate every meaningful state change.
  - ✅ "Search for available Provider" (a meaningful query)
  - ❌ "Types letter 'p' into search box" (too granular)
  - ❌ "Uses the app" (too coarse)

- **3–10 steps per journey.**
  - Fewer than 3 → probably not a journey, just an action.
  - More than 10 → probably multiple journeys; split.

## Evidence block

Each journey is grounded by listing the code signals that support each step. This is what makes a journey *grounded in reality* rather than *inferred from a vibe*.

For each step, name:

- An E2E test scenario (file:line) — strongest evidence
- An analytics event name with where it's emitted (file:line)
- A route + the file:line of its handler
- For user-supplied journeys: "user-supplied, validated against route `{{path}}`"

Evidence block is wrapped in `<!-- evidence:start --> ... <!-- evidence:end -->` and is **not** an auto-region — it's recorded once during inference and not regenerated on refine (because the steps may have been edited by hand). Refine mode validates that evidence is still reachable but won't rewrite the list.

## Confidence

| Signals supporting the journey | Confidence |
|---|---|
| Whole journey covered by an E2E test | **high** |
| Whole journey supported by analytics events + routes | **high** |
| Major steps supported by nav + routes | **medium** |
| Only routes / controllers as evidence | **low** |

If confidence is low, the per-journey confirmation gate is doing real work. Lean on the user.

## `_journeys.md` aggregate format

`_journeys.md` is the master list of all confirmed journeys.

```markdown
# Confirmed User Journeys

This file is the source of truth for journey definitions used by the capability model. Edits here propagate to Customer Experience artifacts (in refine mode) and the capability code mapping.

## {{Touch Point Name}}

### {{CE Name}}

{{...full journey block from above...}}

### {{Next CE Name}}

{{...}}

## {{Other Touch Point Name}}

### {{CE Name}}

{{...}}
```

Journeys are grouped by Touch Point so the reader sees, at a glance, which experiences each touch point supports.

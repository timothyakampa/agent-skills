---
name: capability-model
description: Produce a Business Capability Model of a monolithic application by inferring user journeys from code and grouping them into capabilities, surfacing the seams along which the monolith can be decomposed. Use when the user wants to model business capabilities, find decomposition seams, map an application into bounded contexts, or prepare a monolith for microservice breakdown.
---

# Capability Model

Produce a **workshop pre-read**: a structured, code-grounded draft Business Capability Model the team can refine in a real Business Capability Mapping workshop.

The model identifies:

- **Customer Touch Points** — entry points (Web, Mobile, API)
- **Customer Experiences** — composed goals the customer accomplishes
- **User Journeys** — the steps to accomplish each Customer Experience
- **Business Capabilities** — sets of features with a distinct value proposition, named in `Object Verb` or `Verb` form
- **Technology Capabilities** — engineering-team-facing capabilities (auth, logging, feature flags), partitioned separately
- **Code mapping** — which files implement each capability
- **Coupling inventory** — where capabilities share state or code; the seams the team will negotiate

This skill **does not** produce extraction order, team assignments, or service boundaries — those are workshop decisions. The skill ends, naming the next step.

Read all of [PRINCIPLES.md](PRINCIPLES.md), [VOCABULARY.md](VOCABULARY.md), [NAMING.md](NAMING.md), and [CLASSIFICATION.md](CLASSIFICATION.md) before starting. They are the rulebook. Refer to [SIGNAL-HIERARCHY.md](SIGNAL-HIERARCHY.md) during journey inference and [COUPLING-ANALYSIS.md](COUPLING-ANALYSIS.md) during seam construction. [EXAMPLE-provider-booking.md](EXAMPLE-provider-booking.md) is the canonical walkthrough.

## When to run

Strong, specific intents (auto-activate):

- *"Model the business capabilities of this app"*
- *"Build a capability model"*
- *"Find seams to break this monolith down"*
- *"Map this codebase into bounded contexts"*
- *"Prepare this app for microservice decomposition"*

Vague intents (suggest, don't fire):

- *"How does this app work?"* → describe the skill, ask if they want to run it
- *"Refactor this"* → wrong scope
- *"Explain this code"* → wrong skill

## Refuse early

Stop before starting if any of the following holds. Refuse clearly, explain why.

1. **CWD is not an application.** It's a library, framework, CLI tool with no user journeys, or has no recognisable application shape. The framework requires customers and journeys; if neither exists, the artifact would be theatre.
2. **No product brief available and the user declines to provide one.** The framework needs a customer name. Without it every value proposition becomes `[NEEDS-SME: customer?]` and the draft is hollow.
3. **The skill has already been run** and existing output is unreadable or in an inconsistent state. Ask the user to either delete `docs/capability-model/` or resolve the state before continuing.

## Re-run modes

If `docs/capability-model/` already exists, ask which mode:

- **Refine** *(default)* — keep human edits, regenerate only auto-derived sections (those between `<!-- auto:*:start -->` ... `<!-- auto:end -->` fences). Re-scans the code; rebuilds the coupling inventory and code mappings.
- **Resume** — same as refine, but jumps straight to the walkthrough on remaining `[NEEDS-SME*]` markers. No code re-scan.
- **Fresh** — overwrite everything. Requires explicit confirmation; warn that workshop edits will be lost.

Default behaviour with no existing model: **fresh** (it is the only option).

## Pipeline

### 1. Stack detection and shape check

Detect:

- **Languages and frameworks** present (Rails, Django, Spring, Express, Next.js, etc.).
- **Sub-applications.** Repos with multiple apps (`apps/admin`, `apps/portal`, `apps/api`) require the user to pick one — different apps usually serve different customers and need separate models.
- **UI vs API-only.** If there's no UI code, treat the API as the sole Customer Touch Point and tell the user (it changes the customer story).
- **Test surface.** Note presence of E2E tests, integration tests, analytics events — these are journey-language signals.
- **Application shape.** Confirm this is an application, not a library. Refuse cleanly otherwise.

State your detection summary to the user in a few lines.

### 2. Product brief

Scan for a brief automatically:

- Check `README.md`, `README*`, `CONTEXT.md`, `docs/README.md`, `docs/PRODUCT.md`, `docs/overview*` at root.
- Signal threshold: the content must reference a **customer noun** (patient, store manager, buyer, employee, citizen…) and a **primary verb** (book, manage, search, file, transfer…).

If found, extract a one-paragraph brief and **show it back to the user for confirmation** before proceeding.

If not found, ask the user one question:

> *"What is this product and who are its customers? One short paragraph is enough."*

If the user declines, **stop**. Explain that the framework requires a customer and the artifact would otherwise be hollow.

The confirmed brief is persisted in `docs/capability-model/README.md` under `## Product Brief`.

### 3. Optional journey input

Ask: *"Do you have existing user journeys to validate against? Markdown, text, or images of flow diagrams / whiteboards are all fine."*

If provided:

- For images, use Read (it handles images natively). Transcribe each into a journey representation and confirm the transcription with the user before proceeding.
- The skill **validates and refines** these against code rather than inferring from scratch.

If not provided, the skill infers them in step 5.

### 4. Front-door pass — Customer Touch Points & Customer Experiences

Enumerate front doors:

- **Customer Touch Points**: Web UI, Mobile UI, Public API, Admin Portal, etc. Distinguish customer-facing from internal/admin.
- **Primary goals** offered at each touch point: top-level navigation items, most-tested E2E scenarios, most-used API resource paths.

Present them to the user as a flat list:

> *"Here are the Customer Experiences this codebase appears to support across N touch points. Confirm which to include in this run; add or remove as needed. Admin touch points: include them or skip them?"*

For large codebases (>~50 routes / multiple touch points), the user **must** pick scope here — 1–N Customer Experiences to model in this run. The skill is iterative across runs.

This pass produces a confirmed list of `(touch-point, customer-experience)` pairs that drive everything downstream.

### 5. Per-journey pass

For **each** confirmed Customer Experience:

1. Build a candidate journey: 3–10 human-readable steps in user language ("Selects a Provider"), not code language ("POST /providers/:id").
2. Signal priority during inference: see [SIGNAL-HIERARCHY.md](SIGNAL-HIERARCHY.md).
3. Present the journey to the user with the confirmation gate:

> *"Journey for `<CE name>`:*
> *1. ...*
> *2. ...*
> *Accept, edit, reject, split, or merge with another?"*

4. On `edit`, accept the user's rewrite and re-render before locking in. On `reject`, drop the CE from scope (and remove from the front-door list). On `split`/`merge`, restructure and re-confirm.

All confirmed journeys are persisted in `_journeys.md`.

### 6. Journeys → Business Capabilities

For each confirmed journey, extract capabilities by grouping journey steps by **shared value proposition** ([PRINCIPLES.md](PRINCIPLES.md) §unification).

For each candidate:

- **Validate the name** against [NAMING.md](NAMING.md). Reject noun-only names (`Provider`, `Store Information`) — must be `Object Verb` or `Verb`.
- **Separate the Customer Touch Point capability** (the medium, `Web` / `Mobile App` / `Public API`) from the business capabilities. This is a hard rule.
- **Classify** as Business / Technology / Customer Touch Point per [CLASSIFICATION.md](CLASSIFICATION.md). Business capabilities have a **customer** in their value proposition; technology capabilities have the **engineering team** as the "customer."
- **Draft the value proposition** using [TEMPLATE-value-proposition.md](TEMPLATE-value-proposition.md). `UNLIKE` is **always** `[NEEDS-SME]`; `FOR`/`WHO`/`supports` get `[NEEDS-SME-CONFIRM: <guess>]` when the brief gives enough signal, else `[NEEDS-SME]`.

Present per journey:

> *"From this journey I extracted N capabilities: ...*
> *Accept, edit, reject, split, merge, or reclassify any?"*

After **all** journeys are processed, run a **global dedupe pass**:

> *"Across all journeys I see N unique capabilities total. Here is each one with the journeys it participates in. Confirm the final set."*

Capabilities that appear in many journeys are high-leverage — that's the seam signal.

### 7. Capability → code mapping

For each confirmed capability:

1. Resolve each journey step that uses this capability to its **entry point in code** — a route, a controller action, an API endpoint, frontend assets for touch points.
2. Walk the call/import graph from the entry point through the layers (controller → service → repository → model → query).
3. Tag each file touched with `{capability, via-journey-step}`.
4. Aggregate. Files tagged by only this capability → confident members. Files tagged by 2+ capabilities → **crosscutting** (record in the coupling inventory, not in any single capability's "implements" list as primary).
5. Tables/models referenced by the SQL/ORM along the path are recorded as **persistent state** for the capability (first-class coupling signal per [COUPLING-ANALYSIS.md](COUPLING-ANALYSIS.md)).
6. Compute `[mapping-confidence: high | medium | low]` per capability. High = framework with strong conventions + clear journey-to-entry-point mapping. Medium = conventions partial or call graph partial. Low = no conventions, dynamic dispatch dominates, journey couldn't be resolved cleanly.

Confidence is informational; don't suppress low-confidence mappings, but label them honestly so the workshop knows where to do more work.

### 8. Coupling inventory (`_seams.md`)

Following [COUPLING-ANALYSIS.md](COUPLING-ANALYSIS.md), build the inventory:

For each pair (or n-tuple) of capabilities, list:

- **Shared persistent state** — tables/models both read or write. Highest weight.
- **Shared service/utility modules** — code both depend on directly.
- **Cross-capability calls** — Capability A's code calls into Capability B's code directly.
- **Crosscutting files** — files implementing both.

Score each pairing `[coupling: low | medium | high]` per [COUPLING-ANALYSIS.md](COUPLING-ANALYSIS.md). **Do not** recommend an extraction order; the team decides.

### 9. Pre-draft summary gate

Before writing any artifacts, summarise:

> *"Ready to write:*
> *- N Customer Experiences*
> *- N Business Capabilities*
> *- N Technology Capabilities*
> *- N Customer Touch Points*
> *- M files total under `docs/capability-model/`*
> *- _seams.md with K coupling entries*
> *Proceed, or adjust anything first?"*

This is the last cheap moment to change scope.

### 10. Write the artifacts

Use the templates verbatim — every artifact is a filled-in template:

- `customer-experiences/<kebab-name>.md` from [TEMPLATE-customer-experience.md](TEMPLATE-customer-experience.md)
- `capabilities/<kebab-name>.md` from [TEMPLATE-capability.md](TEMPLATE-capability.md)
- `technology-capabilities/<kebab-name>.md` from [TEMPLATE-capability.md](TEMPLATE-capability.md) (same template; classification field differs)
- `_journeys.md` master list of confirmed journeys
- `_seams.md` from [TEMPLATE-seams.md](TEMPLATE-seams.md)
- `_open-questions.md` from [TEMPLATE-open-questions.md](TEMPLATE-open-questions.md), aggregating every `[NEEDS-SME*]` marker
- `README.md` with run metadata + persisted product brief

**Auto-region fences.** Auto-derived sections (code mapping, coupling, journey-participation reverse index) are wrapped in HTML-comment fences:

```markdown
<!-- auto:code-mapping:start -->
... auto-derived content ...
<!-- auto:end -->
```

Refine mode only touches content inside these fences. Everything outside is treated as human-edited and preserved.

**Stable IDs in markers.** Every `[NEEDS-SME*]` marker carries a stable ID in an adjacent HTML comment:

```markdown
FOR [NEEDS-SME-CONFIRM: patients] <!-- id=cap:provider-discovering/who -->
```

The ID is what makes the walkthrough idempotent and what makes resume possible.

### 11. Walkthrough offer

After writing:

> *"I generated the model with N open questions in `_open-questions.md`. Walk through them with me now?"*

If yes:

1. Iterate `_open-questions.md` entry by entry.
2. For each, present capability name + field + (if `[NEEDS-SME-CONFIRM]`) the current guess.
3. Ask: confirm, edit, skip, or stop.
4. Write the answer back into the source file (replacing the marker), and remove the entry from `_open-questions.md`.
5. `skip` leaves the marker; `stop` preserves all unanswered markers and exits.

Re-invoking the skill on a directory with remaining markers in `_open-questions.md` triggers Resume mode (skip steps 1–10, go straight to walkthrough).

### 12. CONTEXT.md pointer

If `CONTEXT.md` exists at the project root, append a one-line pointer if one isn't already there:

```markdown
- Capability model: [docs/capability-model/](docs/capability-model/)
```

Do **not** create CONTEXT.md if it doesn't exist; that's a different skill's territory.

### 13. Exit

End with an explicit handoff message, e.g.:

> *"Capability model written. This is a workshop pre-read, not a finished artifact. Next steps:*
>
> *1. Run a Business Capability Mapping workshop with PMs + lead engineers + a facilitator. Use the model as the starting point.*
> *2. Fill in remaining `[NEEDS-SME]` answers — there are N. Re-running this skill resumes the walkthrough.*
> *3. Use `_seams.md` to estimate extraction cost; the team decides extraction order.*
> *4. Capabilities with the most coupling are not the right place to start; capabilities with low coupling and high cross-CE reuse usually are.*
> *5. A team should own one or more closely-related capabilities (the deck's guideline). The model gives you the candidates."*

## Hard rules (read these every run)

1. **Names obey `Object Verb` or `Verb` form.** No noun-only capability names. See [NAMING.md](NAMING.md).
2. **Touch points are separated from business capabilities.** Web, Mobile, Public API are their own `Customer Touch Point` capabilities.
3. **Business vs Technology classification.** Customer in the value prop = Business. Engineering team is the consumer = Technology. Tech capabilities live in their own directory; never mix into business map.
4. **`UNLIKE` is always `[NEEDS-SME]`.** It's competitive positioning; not derivable from code, ever.
5. **No cut recommendations.** The skill inventories coupling. It never says "extract X first."
6. **Stop if no customer is known.** No brief = no skill run.
7. **Confirm per journey, then global dedupe.** Don't write artifacts before the user has confirmed the capability set.
8. **Auto-region fences protect human writing.** Refine mode never touches content outside fences.

## What this skill is not

- **Not an architecture review.** It maps capabilities; it does not critique code quality.
- **Not a microservice extraction tool.** It produces the input to that work; it does not perform it.
- **Not a substitute for a workshop.** PMs and lead engineers still need to be in the room. The skill compresses weeks of archaeology into hours so the workshop can start from a real draft.

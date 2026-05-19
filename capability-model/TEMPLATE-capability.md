# Capability Artifact Template

Fill this in for each business capability (in `capabilities/`), customer touch point (in `capabilities/`, classification differs), and technology capability (in `technology-capabilities/`).

Replace `{{ ... }}` placeholders. Keep section ordering as-is. Auto-derived sections **must** be wrapped in `<!-- auto:*:start --> ... <!-- auto:end -->` fences.

---

```markdown
# {{Capability Name in Object Verb form}}

| | |
|---|---|
| **Classification** | {{business / customer-touch-point / technology}} |
| **Mapping confidence** | {{high / medium / low}} |
| **Customer Experiences** | {{count and names — populated from reverse index}} |

## Value Proposition

> **FOR** {{customer}} <!-- id=cap:{{slug}}/for -->
> **WHO** {{want X}} <!-- id=cap:{{slug}}/who -->
> **THE** {{Capability Name}}
> **IS** {{a type of thing — e.g. a searchable API, a checkout UI, a notification service}}
> **THAT** {{does what — derived from journey steps and code}}
> **UNLIKE** [NEEDS-SME: alternatives this is positioned against?] <!-- id=cap:{{slug}}/unlike -->
> **THE** {{Capability Name}} **supports** {{unique benefit}} <!-- id=cap:{{slug}}/supports -->

Notes on derivation:

- `FOR` / `WHO`: filled from product brief + journey context. Mark `[NEEDS-SME-CONFIRM: <guess>]` when the brief gave enough signal to guess; `[NEEDS-SME]` when it didn't.
- `IS`: structural — what kind of thing this is in the codebase (API, UI, library, service).
- `THAT`: short summary of what the capability does, derived from journey steps + endpoints.
- `UNLIKE`: **always** `[NEEDS-SME]`. Competitive positioning is never derivable from code.
- `supports`: best-guess derived from distinctive features; mark `[NEEDS-SME-CONFIRM]`.

## Does

What this capability explicitly does. Code-derived; refined by SME.

<!-- auto:does:start -->
- {{operation 1 in business language}}
- {{operation 2}}
- ...
<!-- auto:end -->

## Does Not

### Boundary-inferred (derived from sibling capabilities)

<!-- auto:does-not-boundary:start -->
- Does not {{X}} — handled by [{{Sibling Capability Name}}]({{relative-link}})
- Does not {{Y}} — handled by [{{Sibling Capability Name}}]({{relative-link}})
<!-- auto:end -->

### Intentional non-features

Deliberate scope decisions; not derivable from code.

- [NEEDS-SME: deliberate non-features?] <!-- id=cap:{{slug}}/does-not-intentional -->

## Customer Experiences

Customer Experiences this capability participates in. Populated by the reverse index.

<!-- auto:customer-experiences:start -->
- [{{CE Name}}]({{relative-link-to-ce-file}})
- [{{CE Name}}]({{relative-link-to-ce-file}})
<!-- auto:end -->

## Code Mapping

Files and persistent state this capability owns or uses primarily.

<!-- auto:code-mapping:start -->
### Files (primary)

- `{{path/to/file1.ext}}` — {{one-line role}}
- `{{path/to/file2.ext}}` — {{one-line role}}

### Files (shared / crosscutting)

These files are also tagged to other capabilities; see [_seams.md](../_seams.md) for the coupling entries.

- `{{path/to/shared.ext}}` — also in: {{Other Capability}}

### Persistent state

- `{{table_name}}` ({{read / write / read-write}}) — {{model class if any}}

### Entry points

Routes / endpoints / asset URLs that drive into this capability.

- `{{METHOD /path}}` — used by journey step "{{step text}}"
<!-- auto:end -->

## Coupling Summary

<!-- auto:coupling-summary:start -->
Coupling with other capabilities. Full details in [_seams.md](../_seams.md).

| Coupled Capability | Severity | Shared state? | Shared modules? | Cross-calls? |
|---|---|---|---|---|
| {{Capability Name}} | {{high/medium/low}} | {{yes/no}} | {{count}} | {{count}} |
<!-- auto:end -->

## Open Questions

Aggregated `[NEEDS-SME*]` markers from this artifact. The walkthrough iterates these and writes answers back in place.

<!-- auto:open-questions:start -->
- `cap:{{slug}}/for` — FOR: who is the customer for this capability?
- `cap:{{slug}}/who` — WHO: what does the customer want?
- `cap:{{slug}}/unlike` — UNLIKE: what alternatives is this positioned against?
- `cap:{{slug}}/supports` — supports: what unique benefit does this capability provide?
- `cap:{{slug}}/does-not-intentional` — Does Not (intentional): deliberate non-features?
<!-- auto:end -->
```

---

## Notes on filling this in

- `{{slug}}` is the kebab-case file name without `.md`. E.g., for `provider-discovering.md`, slug is `provider-discovering`.
- Marker IDs are stable across re-runs. Walkthrough replaces markers in-place; refine mode never touches sections inside auto fences except to regenerate them.
- If a Customer Touch Point capability is being filled in, use `classification: customer-touch-point` and the `IS` line typically reads "a {{web|mobile|API|portal}} interface."
- Keep `Does` items terse — 1 line each, business language not implementation language.
- The `Coupling Summary` table is a roll-up; full details live in `_seams.md`. Don't repeat the full coupling analysis here.

# `_seams.md` Template

The coupling inventory across capability pairs. Ordering: **least coupled first** (low → medium → high). The team reads top-down to estimate extraction cost.

The skill **does not** recommend an extraction order. This file inventories; the team decides.

---

```markdown
# Coupling Inventory

Coupling between Business Capabilities, sorted from least to most coupled. Each entry describes shared state, shared code, cross-capability calls, and crosscutting files between a pair (or n-tuple) of capabilities.

**This is an inventory, not a recommendation.** The team determines extraction order using this as input, alongside business priorities the skill cannot see.

See [COUPLING-ANALYSIS.md](../../.claude/skills/capability-model/COUPLING-ANALYSIS.md) for how coupling is measured.

<!-- auto:coupling-inventory:start -->

## Low coupling

### {{Capability A}} ↔ {{Capability B}} `[coupling: low]`

- **Shared persistent state**: none
- **Shared modules**: `{{path/to/util.ext}}` (used by both)
- **Cross-capability calls**: 1 call site — `{{file.ext:line}}` calls `{{function}}` defined in `{{other-file.ext:line}}`
- **Crosscutting files**: none

**Extraction notes**: a single shared utility is usually easy to lift — either inline at the call site, or extract into a Technology Capability used by both.

---

### {{Capability A}} ↔ {{Capability C}} `[coupling: low]`

{{...}}

## Medium coupling

### {{Capability A}} ↔ {{Capability D}} `[coupling: medium]`

- **Shared persistent state**: none
- **Shared modules**: 2 — `{{path}}`, `{{path}}`
- **Cross-capability calls**: 5 call sites
- **Crosscutting files**: 1 — `{{path}}` (also belongs to: {{Capability D}})

**Extraction notes**: no shared state is the most important fact here. The shared modules are candidates for becoming Technology Capabilities or being inlined.

---

## High coupling

### {{Capability A}} ↔ {{Capability E}} `[coupling: high]`

- **Shared persistent state**: 2 tables — `orders`, `order_items` (both capabilities read and write).
- **Shared modules**: 1 — `{{path}}`
- **Cross-capability calls**: 8 call sites
- **Crosscutting files**: 3 — `{{path}}`, `{{path}}`, `{{path}}`

**Extraction notes**: shared persistent state is the highest-cost coupling type. Three options to consider in workshop:
1. Does the shared state belong to one of these capabilities (and the other becomes its consumer)?
2. Does the shared state need its own capability (e.g., `Order Tracking`)?
3. Is the boundary wrong and these are actually one capability?

This entry does **not** recommend an option — the team decides.

---

{{... repeat per pair ...}}

<!-- auto:end -->

## Pairs with no detected coupling

<!-- auto:no-coupling-pairs:start -->
The following capability pairs share nothing detectable: {{list, or "n/a"}}.

**Caveat**: "no detected coupling" depends on the mapping confidence of each capability. Pairs where one capability has low mapping confidence may have undetected coupling.
<!-- auto:end -->

## Coupling involving Technology Capabilities

Tech capabilities are shared infrastructure by design. The following Business ↔ Tech couplings are noted only because they appear unusually heavy (Business capability reaching past the Tech capability's interface into its internals, etc.). Regular usage is not recorded.

<!-- auto:tech-coupling:start -->
- {{Business Capability}} ↔ {{Technology Capability}}: {{notes on unusual reach}}
<!-- auto:end -->
```

---

## Notes on filling this in

- **One entry per pair.** N-tuples (3+ capabilities sharing the same thing) are listed under the most-tightly-coupled pair within the n-tuple, with a `Also coupled to: ...` line.
- **Don't repeat the same shared item in multiple entries.** If `users` table is shared across 4 capabilities, list it under the highest-severity pair, then reference: `Also shared with: {{Cap X}}, {{Cap Y}}`.
- **"Extraction notes" are descriptive, not prescriptive.** Use phrases like "options to consider," "candidates for," "questions for workshop." Never "do X" or "extract Y first."
- **Sort within each severity bucket by entropy of coupling** — entries with more types of coupling (state + calls + crosscut, vs just calls) go later within the bucket.
- **Refine-mode behaviour**: this whole file is regenerated on refine. Human edits inside the auto fences will be lost; the workshop should add commentary in a `## Workshop Notes` section *outside* the fences if it wants notes preserved.

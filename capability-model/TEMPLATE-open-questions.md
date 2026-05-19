# `_open-questions.md` Template

Aggregates every `[NEEDS-SME*]` marker across the entire model into one walkable list. The walkthrough iterates this file; answered entries are removed and written back to their source.

---

```markdown
# Open Questions

Questions the model couldn't answer from code alone. Each entry has a stable ID matching the `<!-- id=... -->` marker in its source file.

Run the skill again to resume the walkthrough on remaining entries.

## How to read this

- **[NEEDS-SME]** — the model has no guess; needs an SME answer.
- **[NEEDS-SME-CONFIRM: <guess>]** — the model has a best guess; needs confirmation, edit, or rejection.

## Pending — by capability

<!-- auto:open-questions:start -->

### [{{Capability Name}}](capabilities/{{slug}}.md)

- **`cap:{{slug}}/for`** — FOR: who is the customer? `[NEEDS-SME-CONFIRM: patients]`
- **`cap:{{slug}}/who`** — WHO: what do they want? `[NEEDS-SME-CONFIRM: to find available providers]`
- **`cap:{{slug}}/unlike`** — UNLIKE: what alternatives? `[NEEDS-SME]`
- **`cap:{{slug}}/supports`** — supports: unique benefit? `[NEEDS-SME]`
- **`cap:{{slug}}/does-not-intentional`** — Does Not (intentional non-features)? `[NEEDS-SME]`

### [{{Other Capability Name}}](capabilities/{{slug}}.md)

- {{...}}

## Pending — by customer experience

### [{{CE Name}}](customer-experiences/{{slug}}.md)

- **`ce:{{slug}}/customer`** — Customer for this experience? `[NEEDS-SME-CONFIRM: ...]`

<!-- auto:end -->

## Answered

Entries the walkthrough has resolved. Kept here as a log of what was decided.

<!-- auto:answered-log:start -->
- **`cap:provider-discovering/for`** — FOR `patients` (answered {{date}})
- **`cap:provider-discovering/unlike`** — UNLIKE `traditional Yellow Pages directories` (answered {{date}})
<!-- auto:end -->
```

---

## Walkthrough mechanics

When the user accepts the walkthrough offer, iterate the `Pending` section:

1. Read the next entry's ID.
2. Open the source file by ID prefix:
   - `cap:<slug>/...` → `capabilities/<slug>.md` or `technology-capabilities/<slug>.md`
   - `ce:<slug>/...` → `customer-experiences/<slug>.md`
3. Locate the marker by its `<!-- id=... -->` comment.
4. Present to user:
   - For `[NEEDS-SME-CONFIRM: <guess>]`: show the guess, ask confirm/edit/skip/stop.
   - For `[NEEDS-SME]`: open-ended; ask the field's question, accept any answer, allow skip/stop.
5. On a real answer: replace the marker (and its `<!-- id=... -->` comment) with the answer text in the source file. Move the entry to the `Answered` log with date.
6. On `skip`: leave both the source marker and the open-questions entry in place; proceed.
7. On `stop`: stop iterating immediately; everything still pending remains.

## Behaviour notes

- The walkthrough is **idempotent and resumable**. Re-running the skill on a directory with non-empty `Pending` enters Resume mode.
- The Answered log is a workshop-friendly audit: it shows what was decided and when. The workshop can review it later.
- If the user edits a source file directly (manually filling a marker), the next refine-mode run detects the marker is gone and removes the corresponding entry from `Pending` (no Answered-log entry, since the skill didn't record the change).
- Markers without IDs are ignored by the walkthrough. Always include the `<!-- id=... -->` comment when writing markers.

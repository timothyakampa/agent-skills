# Coupling Analysis

How `_seams.md` is built. The seam report is the differentiated value of producing a capability model from code rather than from a whiteboard. It tells the team **how clean each seam is** — and therefore how expensive each potential extraction will be.

The skill **does not recommend an extraction order**. It inventories coupling. The team decides.

## What gets recorded

For every **pair (or n-tuple) of capabilities** that share something, record one entry containing the four coupling types below. If two capabilities share nothing, no entry.

### Type 1 — Shared persistent state (highest weight)

Tables, ORM models, or schemas that **both** capabilities read or write.

Source: walk the call/import graph from each capability's entry points down to the persistence layer; record every model/table touched. Then intersect across capabilities.

Examples:

- `Provider Discovering` and `Provider Booking` both read/write the `providers` table.
- `Order Placement` and `Order Fulfilment` both write to `orders`.

**Why highest weight**: shared state can't be cleanly split by drawing a line. You either replicate it, introduce eventual consistency, or extract the state into its own capability (often called a "supporting" capability or a domain service in DDD terms). All three are expensive.

### Type 2 — Shared service / utility modules

Code modules (classes, packages, libraries internal to the monolith) that both capabilities depend on directly.

Source: import graph. For each capability's files, list their imports. Intersect.

Examples:

- `Provider Booking` and `Provider Messaging` both import `lib/notifications/email_sender.rb`.
- Three capabilities all import `app/services/audit_logger.py`.

**Why medium weight**: a shared utility often indicates a genuine cross-cutting concern (which might become its own Technology Capability) or a missing abstraction (the utility is doing too much).

### Type 3 — Cross-capability direct calls

Capability A's code **calls into** Capability B's code directly (without going through an interface, a queue, or an API).

Source: function-call graph; if a file mapped to capability A calls a function defined in a file mapped to capability B, count it.

Examples:

- `Order Fulfilment` directly calls `BillingClient.charge()` inside its order completion path.
- `Provider Booking` directly instantiates `MessagingService` to notify the provider.

**Why low–medium weight**: direct calls can be replaced with API/event boundaries relatively mechanically. The cost scales with how many distinct call sites exist.

### Type 4 — Crosscutting files

Files that the mapping pass tagged with **more than one capability**.

Source: the capability → code mapping itself. Any file in 2+ capabilities' mapping is crosscutting.

Examples:

- `app/models/user.rb` is tagged by `User Account Management`, `Provider Discovering` (uses User), and `Provider Booking` (uses User).
- A "God" controller handling many resources.

**Why noted separately**: crosscutting files often *are* shared state or shared utilities (and so already covered by types 1–2), but they specifically indicate code-level entanglement that needs untangling regardless of state/utility status.

## Scoring per pair

Each pair gets a `[coupling: low | medium | high]` label. Use this rubric:

| Conditions | Severity |
|---|---|
| Any shared persistent state OR ≥3 shared utility modules OR ≥10 distinct cross-capability call sites OR ≥5 crosscutting files | **high** |
| 1–2 shared utilities OR 3–9 cross-capability calls OR 2–4 crosscutting files OR (no state share but multiple lower types present) | **medium** |
| Only 1 shared utility OR 1–2 cross-capability calls OR 1 crosscutting file | **low** |

Adjust qualitatively when the counts mislead — e.g., a single shared `users` table that everything reads is genuinely high coupling even though only one table is involved.

## Layout of `_seams.md`

See [TEMPLATE-seams.md](TEMPLATE-seams.md) for the format. Ordering: **least to most coupled** (low → high). Reading order = order of "easier to extract" candidates. The team uses this as input to its extraction prioritisation — **but the skill itself never says "do X first."**

## What not to include

- **Coupling within a single capability.** Files inside `Provider Discovering` calling each other are not a seam — they're the internal structure of one capability. Skip.
- **Pairs with no coupling.** Don't emit empty entries. Absence of an entry means absence of detected coupling, which is informative.
- **Coupling involving only Technology Capabilities.** Tech capabilities are shared infrastructure by design; their coupling with business capabilities is expected. Note Tech↔Business coupling only if it's unusually heavy (e.g., a business capability is bypassing the tech-capability interface and reaching directly into its internals).
- **Coupling via standard library or third-party packages.** Two capabilities both importing `requests` or `lodash` is not a seam.

## DB-as-first-class — why this matters

In many monoliths, the database schema is the **strongest evidence of an undrawn boundary**. Two capabilities both write to `orders` and both read `users` — that's the bounded context speaking. The state shows you where the seams actually are, not where the code organisation pretends they are.

When DB coupling is high, draw the team's attention to it explicitly:

> *"Shared persistent state between A and B (`orders`, `order_items`). This is the highest-cost coupling type. Splitting these capabilities requires deciding: (i) does the shared state belong to one of them, (ii) does it need its own capability, or (iii) is the boundary wrong and these are actually one capability?"*

The skill can describe the trade-offs neutrally. It still does not recommend a choice.

## What about call frequency?

Static analysis can count call sites but not runtime call frequency. The skill records **call-site count** (static) as a proxy. If the team needs runtime data, they instrument production.

## Edge case: pure backend with no persistent state

If the monolith is stateless (e.g., a transformation API in front of upstream services), there's no shared persistent state to record. Coupling reduces to Types 2–4. Note this explicitly in the README so the seam report's reduced size isn't read as "we're well-decoupled."

## Edge case: shared queues / event buses

If two capabilities communicate via a message queue or event bus within the monolith (in-process pub-sub), that's a form of coupling worth recording. Classify it as Type 3 (cross-capability call), but flag it as `via-queue` — extracting these capabilities can keep the queue boundary and is often easier than direct-call coupling.

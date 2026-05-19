# Vocabulary

Use these terms exactly. The framework collapses if "capability," "service," "feature," "module," "domain," and "bounded context" are used interchangeably.

## Business Capability

A set of related features that meet a **specific value proposition for a customer**.

- Named in `Object Verb` or `Verb` form ([NAMING.md](NAMING.md)).
- Has an explicit value proposition ([TEMPLATE-value-proposition.md](TEMPLATE-value-proposition.md)).
- Has explicit `Does` and `Does Not` lines.
- Can be supported by one or more services or codebases — **services and codebases are secondary**. The capability is primary.
- Is a **Bounded Context**.
- Is the **primary unit by which a monolith is decomposed**.

Examples: `Provider Discovering`, `Provider Booking`, `Provider Messaging`, `Store Asset Tracking`, `Store Hierarchy Management`, `User Account Management`.

Counter-examples: `Provider` (noun-only), `Store Information` (noun-only), `Racoon` (codename), `Auth Service` (a service, not a capability — what does it *do*?).

## Customer Experience

A **composition of business capabilities** for a specific customer need. Named as a customer-facing goal.

- Phrased as `Ability to <verb> <object>` or similar customer-language.
- Maps to one or more user journeys.
- Touches 1+ Customer Touch Points and 1+ Business Capabilities.

Examples: `Ability to book a Provider`, `Ability to transfer a store from corporate to franchise`, `Ability to onboard a new employee`.

Counter-examples: `Booking system` (not a customer outcome), `Provider workflow` (not a goal).

## Customer Touch Point

A special type of business capability that **acts as an entry point** for customers. The medium through which a customer experiences the system.

Examples: `Web` (web browser UI), `Mobile App` (iOS / Android), `Public API` (for partner integrations), `Phone System` (IVR).

Always separated from the business capabilities it carries. The touch point has its own value proposition ("supports mobile, supports desktops, does not support IE10").

## Technology Capability

A set of related features that meet a specific value proposition **for the engineering team**, not for an external customer.

Examples: `Pipeline Orchestration`, `Feature Flagging`, `Service Discovery`, `Authentication`, `Observability`.

Same naming and boundary rules as business capabilities; classified differently because the consumer is internal. Tech capabilities live in `technology-capabilities/`.

The line is not always obvious. If a customer wouldn't notice the capability going away (other than via degradation of business capabilities), it's tech. See [CLASSIFICATION.md](CLASSIFICATION.md).

## User Journey

The **sequence of steps a customer takes** to accomplish a Customer Experience, written in user language.

- 3–10 steps. Goal-sized arcs, not screen-sized or click-sized.
- Steps describe user action in user language (`Views list of available Providers`), not code action (`GET /providers`).
- Ends when the customer accomplishes the goal of the Customer Experience.
- A journey decomposes into 1+ capabilities (often 2–5, including the touch point).

## Bounded Context

In Domain Driven Design, a bounded context is a boundary within which a particular domain model is defined and consistent. A Business Capability **is** a good Bounded Context. Inside a capability, words and models are unambiguous; across capabilities they may mean different things.

Used here as a synonym for "the boundary around a capability" — useful when talking to engineers familiar with DDD.

## Seam

The line along which a monolith can be cut. **The capability boundary is the seam.** "Seam" is the language of decomposition; "capability" is the language of modelling. Same thing, different audience.

The skill's `_seams.md` is a coupling inventory across seams — it measures how clean each seam is.

## Coupling

Cross-capability dependency. Capabilities are coupled when they share state (DB tables, in-memory caches), share code modules (utility functions, base classes), or call into each other directly. Coupling is what makes seams expensive to cut.

The skill records four coupling types:

1. **Shared persistent state** — highest weight (hardest to undo).
2. **Shared service/utility modules** — medium weight.
3. **Cross-capability calls** — low–medium weight depending on volume.
4. **Crosscutting files** — files implementing multiple capabilities.

See [COUPLING-ANALYSIS.md](COUPLING-ANALYSIS.md).

## Customer

The person or system that derives value from a capability. **A business capability has an external customer; a technology capability has the engineering team as its customer.**

The `FOR <customer>` line in every value proposition. Without a known customer, the capability cannot be named or bounded — the skill refuses to run.

## Product Line

A group of related Customer Experiences serving a coherent market segment. The skill **does not** auto-classify by product line; it produces capabilities and CEs, and product lines emerge from how teams choose to group them in the workshop.

## Value Proposition

The statement of *what specific value this capability delivers and to whom*. Uses the FOR/WHO/THE/IS/THAT/UNLIKE template ([TEMPLATE-value-proposition.md](TEMPLATE-value-proposition.md)).

If two candidate capabilities have the same value proposition → they are one capability. **This is the unification rule.**

## What's not in this vocabulary

These words exist elsewhere in software but are deliberately not used as synonyms for the above:

- **Service** — an implementation artifact, possibly one of many supporting a capability. Not a synonym for capability.
- **Module** / **package** / **component** — implementation structure. Don't conflate with capability.
- **Domain** — too broad. A domain usually contains multiple capabilities.
- **Feature** — too narrow. A capability is a set of related features.
- **Bounded Context** — used as a synonym for capability, only when talking to DDD audiences.

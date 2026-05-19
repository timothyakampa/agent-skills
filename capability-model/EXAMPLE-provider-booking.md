# Example: Provider Booking Walkthrough

A worked example using the deck's canonical scenario — a healthcare-style application where patients book appointments with providers. This shows what the skill produces end-to-end for **one Customer Experience**.

This is fiction (no real codebase), but the shapes of the artifacts are exactly what the skill produces.

---

## Setup

**Product brief** (provided by user when asked):

> *MediConnect is a marketplace where patients find and book appointments with healthcare providers. Providers manage their schedules, message patients, and complete visit summaries. Patients are the primary customer; providers are a customer too (B2B-style).*

**Codebase shape**: Rails monolith. `app/controllers/`, `app/models/`, ERB views + Stimulus. Cypress E2E tests in `cypress/e2e/`. Analytics via Segment.

---

## Pipeline run — abbreviated

### Step 1 — Detection

- Language: Ruby on Rails 7.
- One app, no sub-apps.
- UI present (server-rendered ERB + Stimulus).
- E2E tests present: `cypress/e2e/booking.cy.js`, `provider-schedule.cy.js`, etc.
- Analytics events present: `app/javascript/controllers/analytics.js` calls `segment.track(...)`.
- Shape: application ✓.

### Step 2 — Product brief

- Auto-discovered a brief in `README.md` matching the customer-noun + verb threshold.
- Showed it back; user confirmed.

### Step 3 — Optional journey input

- User had no existing journey docs. Proceed with inference.

### Step 4 — Front-door pass

Touch points discovered:

- **Web** — patient and provider-facing browser UI.
- **Public API** — partner-facing (third-party clinic systems). Marked customer-facing.
- **Admin Portal** — internal staff (MediConnect support team). Marked internal.

User chose: include Web (full scope) + Public API (front-door pass only — defer detailed modelling). Excluded Admin Portal for this run.

Customer Experiences discovered at Web:

1. *Ability to book a Provider* (patient)
2. *Ability to cancel a booking* (patient)
3. *Ability to manage a provider schedule* (provider)
4. *Ability to message a patient* (provider)
5. *Ability to complete a visit summary* (provider)
6. *Ability to view past bookings* (patient)

User confirmed all 6 for this run.

### Step 5 — Per-journey pass

For **Ability to book a Provider**, Claude proposed:

> Touch Point: Web · Confidence: high · Source: e2e + nav + routes
>
> 1. Go to the website
> 2. Views list of all available Providers
> 3. Searches for available Provider
> 4. Views Provider Search Results
> 5. Selects a Provider
> 6. Views Provider details
> 7. Selects Book

Evidence: `cypress/e2e/booking.cy.js:12-89`, route `/providers` → `ProvidersController#index`, route `/providers/:id` → `ProvidersController#show`, route `/bookings` → `BookingsController#create`, analytics events `provider_search_initiated`, `provider_selected`, `booking_started`.

User: *accept*. (Other 5 journeys similarly confirmed — abbreviating for the example.)

### Step 6 — Journeys → Capabilities

For *Ability to book a Provider*, Claude extracted:

| Step | Candidate capability | Validated name |
|---|---|---|
| 1 | (touch point) | `Web` (Customer Touch Point) |
| 2, 3, 4 | All about finding providers — shared value prop | `Provider Discovering` (Business) |
| 5, 6 | Viewing details still serves "find" — same value prop as 2–4 | merged into `Provider Discovering` |
| 7 | Reserving a slot — different value prop | `Provider Booking` (Business) |

User: *accept*.

After all 6 journeys, global dedupe pass discovered:

- `Web` (touch point) — in 6 CEs
- `Provider Discovering` (business) — in 2 CEs (book a Provider, view past bookings)
- `Provider Booking` (business) — in 3 CEs (book, cancel, view past bookings)
- `Provider Schedule Management` (business) — in 1 CE (manage schedule)
- `Provider Messaging` (business) — in 2 CEs (provider→patient, patient→provider implied)
- `Visit Summary Recording` (business) — in 1 CE (complete a visit summary)

Plus Technology Capabilities surfaced from infrastructure code:

- `Authenticating` (Tech) — Devise + Warden
- `Authorising` (Tech) — Pundit policies
- `Notifying` (Tech) — ActionMailer + Twilio
- `Job Scheduling` (Tech) — Sidekiq

User confirmed the final set.

---

## Resulting artifacts (excerpts)

### `docs/capability-model/capabilities/provider-discovering.md`

```markdown
# Provider Discovering

| | |
|---|---|
| **Classification** | business |
| **Mapping confidence** | high |
| **Customer Experiences** | 2 — Ability to book a Provider, Ability to view past bookings |

## Value Proposition

> **FOR** patients <!-- id=cap:provider-discovering/for -->
> **WHO** want to find available Providers <!-- id=cap:provider-discovering/who -->
> **THE** Provider Discovering capability
> **IS** a searchable, ERB-rendered web interface backed by a JSON search API
> **THAT** allows users to flexibly search for, browse, and view available Providers
> **UNLIKE** [NEEDS-SME: alternatives this is positioned against?] <!-- id=cap:provider-discovering/unlike -->
> **THE** Provider Discovering capability **supports** [NEEDS-SME-CONFIRM: filtering by specialty, language, location, and insurance acceptance] <!-- id=cap:provider-discovering/supports -->

## Does

<!-- auto:does:start -->
- Lists available providers
- Searches providers by specialty, location, and availability window
- Renders provider profile pages (bio, credentials, schedule preview)
- Surfaces provider reviews and ratings
<!-- auto:end -->

## Does Not

### Boundary-inferred

<!-- auto:does-not-boundary:start -->
- Does not reserve provider time — handled by [Provider Booking](provider-booking.md)
- Does not send messages between patients and providers — handled by [Provider Messaging](provider-messaging.md)
- Does not handle authentication — handled by [Authenticating](../technology-capabilities/authenticating.md)
<!-- auto:end -->

### Intentional non-features

- [NEEDS-SME: deliberate non-features?] <!-- id=cap:provider-discovering/does-not-intentional -->

## Customer Experiences

<!-- auto:customer-experiences:start -->
- [Ability to book a Provider](../customer-experiences/ability-to-book-a-provider.md)
- [Ability to view past bookings](../customer-experiences/ability-to-view-past-bookings.md)
<!-- auto:end -->

## Code Mapping

<!-- auto:code-mapping:start -->
### Files (primary)

- `app/controllers/providers_controller.rb` — index, show, search actions
- `app/services/provider_search.rb` — query construction + filtering
- `app/views/providers/index.html.erb` — provider list view
- `app/views/providers/show.html.erb` — provider profile view
- `app/javascript/controllers/provider_search_controller.js` — Stimulus controller for filters

### Files (shared / crosscutting)

- `app/models/provider.rb` — also in: Provider Booking, Provider Schedule Management, Provider Messaging

### Persistent state

- `providers` (read) — `Provider` model
- `provider_specialties` (read) — `ProviderSpecialty` model
- `reviews` (read) — `Review` model

### Entry points

- `GET /providers` — used by journey step "Views list of all available Providers"
- `GET /providers/search` — used by journey step "Searches for available Provider"
- `GET /providers/:id` — used by journey step "Views Provider details"
<!-- auto:end -->

## Coupling Summary

<!-- auto:coupling-summary:start -->
| Coupled Capability | Severity | Shared state? | Shared modules? | Cross-calls? |
|---|---|---|---|---|
| Provider Booking | high | yes (`providers`) | 1 | 4 |
| Provider Schedule Management | medium | yes (`providers`) | 0 | 1 |
| Provider Messaging | low | yes (`providers`) | 0 | 0 |
<!-- auto:end -->

## Open Questions

<!-- auto:open-questions:start -->
- `cap:provider-discovering/unlike` — UNLIKE: alternatives?
- `cap:provider-discovering/supports` — supports: unique benefit (current guess: filtering by specialty/language/location/insurance — confirm or revise)?
- `cap:provider-discovering/does-not-intentional` — Intentional non-features?
<!-- auto:end -->
```

### `docs/capability-model/customer-experiences/ability-to-book-a-provider.md`

```markdown
# Ability to book a Provider

| | |
|---|---|
| **Customer Touch Point** | [Web](../capabilities/web.md) |
| **Composed Capabilities** | 3 |
| **Journey Confidence** | high |

## Customer

[NEEDS-SME-CONFIRM: patients] <!-- id=ce:ability-to-book-a-provider/customer -->

## User Journey

1. Go to the website
2. Views list of all available Providers
3. Searches for available Provider
4. Views Provider Search Results
5. Selects a Provider
6. Views Provider details
7. Selects Book

<!-- journey source: e2e-tests + nav + routes -->

## Composed Capabilities

<!-- auto:composed-capabilities:start -->
| Capability | Type | Role in this CE |
|---|---|---|
| [Web](../capabilities/web.md) | customer-touch-point | All steps — the medium |
| [Provider Discovering](../capabilities/provider-discovering.md) | business | Steps 2–6 |
| [Provider Booking](../capabilities/provider-booking.md) | business | Step 7 |
<!-- auto:end -->

## Cross-CE Reuse

<!-- auto:cross-ce-reuse:start -->
| Capability | Also used in |
|---|---|
| Web | 5 other CEs (all of them) |
| Provider Discovering | 1 other CE: [Ability to view past bookings](ability-to-view-past-bookings.md) |
| Provider Booking | 2 other CEs: [Ability to cancel a booking](ability-to-cancel-a-booking.md), [Ability to view past bookings](ability-to-view-past-bookings.md) |
<!-- auto:end -->

## Open Questions

<!-- auto:open-questions:start -->
- `ce:ability-to-book-a-provider/customer` — confirm customer is "patients"?
<!-- auto:end -->
```

### `docs/capability-model/_seams.md` (excerpt)

```markdown
## High coupling

### Provider Discovering ↔ Provider Booking `[coupling: high]`

- **Shared persistent state**: `providers` (both read; Booking also reads availability fields).
- **Shared modules**: 1 — `app/services/provider_finder.rb`.
- **Cross-capability calls**: 4 — `BookingsController` calls `Provider.find` and `provider.available_slots(...)`; `ProviderSearch` calls `Booking.upcoming_for(provider)`.
- **Crosscutting files**: `app/models/provider.rb`.

**Extraction notes**: shared `providers` state is the highest-cost coupling. Three options for workshop:
1. `Provider Booking` becomes a consumer of `Provider Discovering` (one owns provider state, the other queries it).
2. A new capability `Provider Profile Management` owns `providers` and both Discovery and Booking consume it.
3. These two capabilities are actually one ("Provider Marketplace") and should be modelled as such.

This entry does not recommend an option.

---
```

---

## What this example demonstrates

1. **Object-Verb naming worked.** Notice no "Provider" capability — the verb is forced into every name. Notice `Provider Discovering` is *not* `Provider Search` — discovering is more general than searching (which is one implementation).
2. **Unification by value prop worked.** Journey steps 2–6 all serve "find available providers" so they collapse into one capability, not five.
3. **Touch point separation worked.** `Web` is its own capability, distinct from `Provider Discovering`.
4. **DB-first-class coupling worked.** The `providers` table being shared between Discovery and Booking is the most important finding — it's the seam the team will negotiate.
5. **No cut recommendations.** Notice the seam entry lists *options for the workshop*, not "extract this first."
6. **`UNLIKE` is `[NEEDS-SME]`.** It was never guessed.
7. **`FOR` was confirmable.** Because the brief named "patients," the skill could mark `[NEEDS-SME-CONFIRM: patients]` rather than `[NEEDS-SME]`. The walkthrough resolves it quickly.

---

## What the workshop does with this

After the skill exits, the team holds a Business Capability Mapping workshop:

1. PM walks through each Customer Experience, sharpens journey wording.
2. Team fills in remaining `[NEEDS-SME]` markers — running this skill again resumes the walkthrough.
3. Team uses `_seams.md` to discuss extraction trade-offs. The high-coupling pair (Discovery ↔ Booking) gets the most workshop time.
4. Team draws team boundaries around closely-related capabilities. Maybe one team owns Discovery + Booking initially; another owns Schedule + Visit-Summary; another owns Messaging.
5. Team prioritises extractions. The `Web` touch point is often the first extraction (frontend SPA out of the monolith); low-coupling capabilities follow.

The skill is the pre-read for this workshop. It's not the workshop.

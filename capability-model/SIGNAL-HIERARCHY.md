# Signal Hierarchy for Journey Inference

Code offers many signals at very different levels of fidelity for inferring user journeys. Use them in this priority order, and validate higher-priority signals against lower-priority ones.

## Priority order

### 1. E2E tests / feature specs (highest fidelity)

Look in: `cypress/`, `e2e/`, `playwright/`, `tests/e2e/`, `tests/features/`, `spec/features/`, `test/system/`, `*.spec.ts` files with browser-driver imports.

These are written in **journey language by design**. Cypress tests literally say `cy.visit('/providers')`, `cy.click('[data-testid="search"]')`, `cy.contains('Book').click()` — the steps a real user takes.

Lift the test scenario names directly when they're well-written (`it('lets a patient book an available provider')`). Use the test bodies to flesh out the steps.

**Caveat**: tests don't always reflect production journeys; sometimes they cover only the happy path or only a narrow regression. Validate against routes/nav (signals 2–3) for coverage.

### 2. Analytics events / instrumentation

Look in: code calling `track()`, `analytics.event()`, `segment.track()`, `mixpanel.track()`, `gtag()`, or framework-specific instrumentation hooks.

Event names like `track('provider_selected')`, `track('booking_completed')` are journey markers in journey language. The sequence of events in a session reconstructs the journey.

If events are documented in a tracking plan (`docs/events.md`, `events.yml`, `tracking-plan.md`) — use that document.

### 3. Top-level navigation / sitemap

Look in: `<nav>` components, sidebar menus, sitemap.xml, top-level routes in router config.

These enumerate the **front doors** — the primary goals offered at each Customer Touch Point. Useful for the front-door pass (Pipeline step 4) more than for individual journey inference.

### 4. Router / route config

Look in: `routes.rb` (Rails), `urls.py` (Django), `app/router` / `pages/` (Next.js), Express route declarations, Spring `@RequestMapping`.

Routes correspond to **screens or actions**. Useful for:

- mapping a journey step ("Views Provider details") to a concrete URL (`/providers/:id`).
- enumerating all reachable screens.
- detecting multi-step flows by URL patterns (`/checkout/cart`, `/checkout/address`, `/checkout/payment`).

**Caveat**: routes are one-to-many with journey steps. A single screen can correspond to multiple steps; a single step can span multiple routes. Use routes to **validate** steps proposed from higher signals, not to invent steps.

### 5. Multi-step forms / wizards

Look in: form components, step-state, controllers managing form submission across multiple POSTs.

Encodes **intra-screen sequence**. A multi-step form is usually one journey arc compressed into one screen.

### 6. Controllers / action handlers

Look in: Rails controllers, Django views, Express handlers, Spring `@Controller`.

API-level operations. **Too granular for journey steps** — one screen often triggers many controller calls. Use these to validate that a proposed step has corresponding code behind it, **not** to generate steps.

### 7. OpenAPI / Swagger / GraphQL schema

Look in: `openapi.yaml`, `swagger.json`, `schema.graphql`.

Useful for capability mapping later (step 7) but **not** for journeys. The API surface enumerates operations, which is the wrong abstraction layer for journeys.

### 8. DB schema / models

Look in: migrations, ORM models, `schema.sql`.

**Wrong layer for journey inference**. Tables hint at bounded contexts but not at sequences. Use only for capability code mapping and coupling analysis (step 7, step 8).

## How to combine signals

The general procedure:

1. **Start at signal 1** (E2E tests). If well-developed E2E tests exist, they alone produce most journeys; later signals validate and fill gaps.
2. If E2E coverage is thin or absent, **drop to signals 2–3** (analytics + navigation) and synthesise journeys from primary goals.
3. **Validate against signal 4** (routes): every journey step should map to a real reachable URL/action.
4. **Cross-check with signal 5** (forms): if a step's URL is a multi-step form, the journey may need to expand to include the sub-steps if they're customer-relevant.
5. **Don't use signals 6–8 to invent steps.** They confirm code exists; they don't tell you what the user does.

## Quality flags during inference

While building journeys, set `journey-confidence` based on which signals supported them:

| Supported by | Confidence |
|---|---|
| E2E tests + nav + routes | **high** |
| Analytics + nav + routes | **high** |
| Nav + routes only | **medium** |
| Routes only | **low** |
| Inferred from controllers / DB shape | **very low** — surface to user explicitly |

When confidence is medium or below, the per-journey confirmation gate is doing real work. Lean on the user.

## Stack-specific notes

### Rails

- Routes: `config/routes.rb`. Nested resources reveal hierarchy.
- Tests: `spec/features/*` (Capybara), `spec/system/*` (Rails 5.1+).
- Strong conventions → expect **high** confidence.

### Django

- Routes: `urls.py` files, nested per app.
- Tests: `tests.py` per app; selenium-based functional tests if present.
- Conventions vary; confidence **medium** by default.

### Next.js / React

- Routes: file-system routing in `pages/` or `app/`.
- Components map to screens fairly directly.
- E2E tests usually in Playwright/Cypress at repo root.

### Express / Node monoliths

- Routes scattered; look for `app.use`, `router.get`, framework-specific (Fastify, Koa).
- Often **medium-to-low** confidence due to dynamic route registration.

### Spring (Java/Kotlin)

- `@Controller` / `@RestController` with `@RequestMapping`.
- Frontend often a separate SPA; the monolith is API-only and the touch point is the API itself.

### Server-rendered PHP / classic monolith

- Routes often implicit (filesystem-as-router) or in custom dispatchers.
- Expect **low** confidence. Lean heavily on user input.

## What to ignore

- Vendor / third-party / generated code: `node_modules/`, `vendor/`, `dist/`, `build/`, `.next/`, `target/`, generated SDK directories.
- Auto-generated test scaffolds.
- Database migrations as journey input (they're for coupling analysis later).
- Background-job code (cron jobs, queue workers) as journey input — these are not journeys, they're capabilities the journeys may indirectly use.

# Classification: Business vs Technology vs Customer Touch Point

Every capability is classified as exactly one of three types. The classification determines which directory it lives in and how it's presented.

## The three types

### Business Capability

- **Customer**: external (patients, store managers, buyers, employees-as-customers, etc.).
- **Removed scenario**: if this capability disappeared, customers would notice immediately and the product loses value.
- **Examples**: `Provider Discovering`, `Provider Booking`, `Provider Messaging`, `Store Asset Tracking`, `Order Fulfilment`.
- **Lives in**: `capabilities/`.

### Customer Touch Point

- A **special kind of Business Capability** that acts as the entry point.
- **Customer**: same external customer.
- **Removed scenario**: customer can't reach the system at all (no UI, no API).
- **Examples**: `Web`, `Mobile App`, `Public API`, `Admin Portal`.
- **Lives in**: `capabilities/` alongside other business capabilities, but marked `classification: customer-touch-point` in the artifact header.

There must be **at least one** Customer Touch Point per Customer Experience. Every journey starts at a touch point.

### Technology Capability

- **Customer**: the engineering team (internal).
- **Removed scenario**: customer doesn't notice directly; engineering velocity drops; reliability degrades.
- **Examples**: `Pipeline Orchestration`, `Feature Flagging`, `Service Discovery`, `Observability`, `Job Scheduling`.
- **Lives in**: `technology-capabilities/`.

## The classification test

For each candidate capability, ask the questions **in order**:

### Q1 — Who is the value proposition for?

Write the `FOR <customer>` line. Then ask: is the named customer an external user of the product?

- External user (patient, buyer, store manager, citizen, B2B partner) → **Business** or **Customer Touch Point** (go to Q2)
- Engineering team / internal developers / "the platform" → **Technology**
- Mixed or unclear → ask the user; don't guess

### Q2 — Is this the entry point or the work?

- The capability is **how the customer reaches the system** (a UI, an API surface, an IVR menu) → **Customer Touch Point**
- The capability is **what the customer accomplishes once they're in** (discovering, booking, messaging) → **Business**

### Edge case: capability "serving" external customers via internal customers

Some capabilities sit in the middle. Example: `Authentication`.

- If the value proposition is *"FOR engineering teams WHO need to verify identity..."* → Technology.
- If the value proposition is *"FOR users WHO want to access their own account..."* → Business (`User Account Management`).

Usually you have **both**: the user-facing `User Account Management` is Business, while the underlying `Authenticating` library/middleware is Technology. The skill should produce both if they're genuinely separate concerns.

When in doubt, write the value proposition first and see which name fits the customer.

## Disambiguation examples

| Candidate | Classification | Why |
|---|---|---|
| `Provider Discovering` | Business | Customer = patient; they search and pick a provider. |
| `Provider Booking` | Business | Customer = patient; they reserve a slot. |
| `Web` | Customer Touch Point | The medium by which patients reach the system. |
| `Public API` | Customer Touch Point (if external) / Tech (if internal) | Depends who consumes it. |
| `Feature Flagging` | Technology | Customer = engineering team; needed to ship safely. |
| `Pipeline Orchestration` | Technology | Customer = engineering team; runs background work. |
| `Authentication` *(library)* | Technology | Customer = other capabilities that need to verify identity. |
| `User Account Management` | Business | Customer = the user; they sign up, log in, manage profile. |
| `Auditing` | Technology *or* Business | Depends — internal audit log = Tech; user-facing activity feed = Business. |
| `Notifications` | Usually Business | Customer = the user receiving them. The transport layer underneath might be Tech. |

## Why partition matters

The business map is the **decomposition story**. If it's polluted with `Feature Flagging`, `Job Scheduling`, and `Service Discovery`, the team can't see the shape of the product. The framework treats the business map as the primary artifact.

Technology capabilities are real and worth modelling — they have their own teams, value propositions, and `Does Not` lines — but they live in a parallel directory so they don't interfere.

The business capabilities the primary unit by which a monolithic applications are decomposed. Tech capabilities are part of the picture, just not part of the front line.

## Anti-patterns

- **Inflating business capabilities**: classifying `Database Access`, `Caching`, `Logging` as business capabilities because they "support customers." They don't. Those are Tech.
- **Hiding business capabilities**: marking a real customer-facing capability as Tech because its implementation looks infrastructure-y. If a customer would notice it disappearing, it's Business — regardless of how it's built.
- **Skipping the touch point**: failing to extract `Web` / `Mobile` as its own capability. The touch point is almost always the cleanest first seam in monolith decomposition. Missing it loses the biggest decomposition opportunity.

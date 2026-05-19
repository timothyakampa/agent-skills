# Principles

The four founding guidelines for mapping out Business Capabilities. These are the rules every step of the skill must obey.

## 1. Start from things everyone agrees are real

Abstractions are constructed from reality. Don't invent capabilities top-down from a domain model in your head. Start from the **user journey** — the concrete sequence of steps a real customer takes to accomplish a real goal. Group those steps into capabilities afterwards.

Why this matters: a capability invented top-down often turns out to map to nothing real (no journey actually uses it), or splits things real customers experience as one. Starting from journeys is what makes the capability set fall out of the actual product, not out of architectural taste.

The skill enforces this by **forbidding capability generation before journeys are confirmed**.

## 2. Capabilities are named `Object Verb` or `Verb`

Capability names describe **what a system does**, not what it is. Systems do things.

- ✅ `Provider Discovering`, `Store Asset Tracking`, `Account Provisioning`
- ❌ `Provider`, `Store`, `Account` (these are nouns; they describe what the system *is*, not what it does)
- ❌ `Prema`, `Racoon`, `Wingman` (these are project codenames, not capabilities)

See [NAMING.md](NAMING.md) for the full rules and the rejection logic.

The reason `Object Verb` matters more than it sounds: noun-only names hide the value proposition. "Provider" doesn't tell anyone what the capability *does*. "Provider Discovering" forces a specific action, which forces a specific value proposition, which forces a specific boundary. The naming rule is doing real boundary-defining work.

## 3. Every capability has a distinct value proposition

If two candidate capabilities would share the same value proposition, they are one capability — merge them. If a candidate has no clear value proposition, it isn't a capability — it's noise.

The value proposition uses the deck's template:

```
FOR    <customer>
WHO    <want X>
THE    <capability name>
IS     <type of thing>
THAT   <does what>
UNLIKE <alternative>
THE    <capability name> supports <unique benefit>
```

See [TEMPLATE-value-proposition.md](TEMPLATE-value-proposition.md) for the format and what fields are derivable.

**This is the unification rule.** It is the only principled answer to "should these be one capability or two?" Two candidates have the same `FOR/WHO/IS/THAT` lines → they are one capability. Different lines → they are two. The skill makes this decision by *trying to write the value proposition* — when the test forces you to write the same sentence twice, merge.

## 4. Every capability has explicit `Does` and `Does Not`

A capability isn't fully defined until its boundary is stated. The boundary is what the capability **explicitly does** and **explicitly does not**.

`Does` is positive scope. Code-derivable.

`Does Not` has two flavours:

- **Boundary-inferred** — derivable from the presence of sibling capabilities. If `Billing Management` exists, then `Provider Booking → Does Not handle invoicing` is mechanical.
- **Intentional non-features** — deliberate scope decisions ("Does Not support IE10", "Does Not return provider recommendations"). Not derivable from code; needs SME input.

The skill produces both, labelled separately.

---

## Composition rules

### Customer Touch Points are their own capability

The medium (Web, Mobile App, Public API) is a Customer Touch Point — a special kind of business capability. It has its own value proposition ("supports mobile / supports desktop / does not support IE10"). Always separate it from the business logic capabilities it carries.

Why: the touch point is the most common *first seam* in monolith decomposition (extract the frontend from the backend). Conflating it with business logic hides this seam.

### Capabilities can appear in many Customer Experiences

This is the point. A capability appearing in 5 CEs is high-leverage — it's the reason to invest in making it a real boundary. The skill records this as a **reverse index** on each capability artifact.

### A team owns one or more *closely related* capabilities

The skill **does not** assign teams. But the model should produce capabilities at a granularity where this rule makes sense — closely-related capabilities can be owned together, but they're still distinct capabilities. Don't fuse them into one because they share a team.

### Business vs Technology capabilities

Business capabilities have a **customer** in the value proposition. Technology capabilities have the **engineering team** as the consumer (Pipeline Orchestration, Feature Flagging, Auth Middleware). Both are real. The skill partitions them into separate directories so the business map stays clean.

See [CLASSIFICATION.md](CLASSIFICATION.md).

## Anti-principles

Things the skill must not do:

1. **Don't invent customers.** If the product brief doesn't name a customer, don't make one up. Use `[NEEDS-SME]`.
2. **Don't invent value propositions.** `UNLIKE` is never derivable from code. Always `[NEEDS-SME]`.
3. **Don't recommend cuts.** The skill inventories coupling. The team decides extraction order.
4. **Don't map by file structure alone.** Two files in `models/` are not in the same capability just because they share a directory. Map by journey participation, not by path.
5. **Don't try to be complete on large monoliths in one run.** Pick scope. Iterate.

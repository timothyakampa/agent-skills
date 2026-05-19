# Value Proposition Template

Every Business Capability and Customer Touch Point requires a value proposition. Technology Capabilities use the same template but with `engineering team` in the customer slot.

## Template

```
FOR    <customer>
WHO    <want X>
THE    <capability name>
IS     <type of thing>
THAT   <does what>
UNLIKE <alternative>
THE    <capability name> supports <unique benefit>
```

## Filled example (from the deck)

```
FOR    Customers
WHO    want to find available Providers
THE    Provider Discovering Capability
IS     a searchable, business-truthful and easy to consume API
THAT   allows users to flexibly search for Providers
UNLIKE traditional location-based listings
THE    Provider Discovering Capability supports customised search
       results in our provider database
```

## Field-by-field derivation guide

### FOR `<customer>`

**Source**: Product brief (Pipeline step 2). The brief names the customers; pick the one most directly served by this capability.

- Brief-rich, single customer type → fill it directly.
- Brief-rich, multiple customer types → pick the one whose journey this capability serves; the others go in a `Notes` line.
- Brief-thin → `[NEEDS-SME-CONFIRM: <best-guess>]` with a guess if any.
- No brief → skill should not have started; refer to refuse-early rules in SKILL.md.

### WHO `<want X>`

**Source**: The Customer Experience that contains the journey this capability participates in. The CE's goal stated as a customer desire.

- Always derivable when CE name follows `Ability to <verb> <object>` form — just rewrite as `want to <verb> <object>`.
- Mark `[NEEDS-SME-CONFIRM]` since phrasing matters and SMEs may sharpen it.

### THE `<capability name>`

**Source**: The confirmed name from the Object-Verb validation. Always fully derivable.

### IS `<type of thing>`

**Source**: Code layer + classification.

| Capability is implemented as | `IS` line |
|---|---|
| Web UI / SPA | `a {{web / mobile}} interface` |
| API endpoints (REST / GraphQL) | `a {{searchable / transactional}} API` |
| Background processor / worker | `a {{event-driven / scheduled}} processor` |
| Library / shared code | `a {{shared library / SDK}}` |
| Customer Touch Point (Web/Mobile) | `a {{customer-facing / partner-facing}} touch point` |

Always derivable to first approximation. SMEs may refine ("a searchable, business-truthful API" — the deck adds business adjectives that aren't in code).

### THAT `<does what>`

**Source**: Group the journey steps the capability participates in; summarise.

Example: capability `Provider Discovering` participates in journey steps "Search for available Provider," "Views list of all available Providers," "View Provider Search Results." → `THAT allows users to flexibly search for and browse Providers`.

Code-derivable; mark `[NEEDS-SME-CONFIRM]` to give the SME a chance to sharpen.

### UNLIKE `<alternative>`

**Source**: **None.** Always `[NEEDS-SME]`. This is competitive positioning — what does this capability beat or replace? Examples from the deck: `UNLIKE traditional location-based listings`, `UNLIKE the legacy location-db dumping-ground`.

The skill **never** guesses this. Always blank with `[NEEDS-SME]`.

### THE `<capability name>` **supports** `<unique benefit>`

**Source**: Distinctive features visible in code that aren't generic to the capability type.

Example: every search capability supports search. The `supports` line should name what makes *this* search special: `supports customised search results in our provider database`, `supports time-window filtering across multiple time zones`.

If code reveals a distinctive feature → fill with `[NEEDS-SME-CONFIRM: <feature>]`. If nothing distinctive jumps out → `[NEEDS-SME]`.

## Quality checks

After filling in the proposition, validate:

1. **Could a competitor's product fit this same proposition?** If yes, the proposition is too generic — the `supports` line probably needs work.
2. **Do the WHO and the THAT match?** "WHO want to find providers" + "THAT manages provider schedules" is a mismatch — those are two different capabilities.
3. **Is FOR an external customer or the engineering team?** Determines classification (business vs technology). If you wrote "FOR developers" for a customer-facing capability, you've misclassified.
4. **Does this proposition match any other capability in the model?** If yes — they are one capability. Merge ([PRINCIPLES.md](PRINCIPLES.md) §3, the unification rule).

## Anti-patterns

- Filling `FOR` with the company name: "FOR Acme Corp" — the company is not the customer. The customer is whoever Acme Corp serves.
- Filling `THE` with a service or codebase name: "THE booking-service" — that's the implementation, not the capability.
- Filling `UNLIKE` with technical alternatives: "UNLIKE writing raw SQL" — that's an internal trade-off, not customer positioning.
- Skipping `Does` / `Does Not` because the value proposition feels complete. Both are required; they bound the proposition.

# Naming Rules

A capability name describes **what the system does**. Systems do things. Names must take one of two shapes:

- **`Object Verb`** — `Provider Discovering`, `Store Asset Tracking`, `User Account Management`
- **`Verb`** — `Discovering`, `Routing`, `Authenticating` (only when the object is implicit and unambiguous from context; rare in practice)

Either form passes. Anything else fails.

## Validation procedure

Before accepting a candidate capability name, apply these checks **in order**. Reject on the first failure.

### 1. Reject noun-only names

A name is noun-only if it doesn't contain a verb or a gerund (-ing form).

- ❌ `Provider` (noun)
- ❌ `Store Information` (noun phrase)
- ❌ `Account` (noun)
- ❌ `Customer Data` (noun phrase)
- ❌ `Inventory` (noun)
- ✅ `Provider Discovering`
- ✅ `Store Information Management`
- ✅ `Account Provisioning`
- ✅ `Customer Data Curation`
- ✅ `Inventory Tracking`

If a candidate is noun-only, **don't reject silently** — rewrite it. Ask: *what does this system do with the noun?* Search the journey for the verbs that operate on it.

### 2. Reject project codenames

Codenames are not capabilities. They name systems, products, or codebases, not what the system *does*.

- ❌ `SIS`, `Snowflake`, `Prema`, `HARRI`, `ULTIPRO`
- ❌ `Auth Service`, `Provider API`, `Booking System`
- ❌ `v2 API`, `Legacy Module`

Project codenames typically appear in code as directory names, repo names, or service names. They are useful for finding code but not for naming capabilities. **Rewrite using the action the codenamed thing performs.**

- `SIS` → `Store Hierarchy Management` (or whatever it does)
- `Auth Service` → `Authenticating` or `User Account Management` (depending on what it actually does)

### 3. Reject implementation words

Names that describe *how* rather than *what* the capability does.

- ❌ `Provider Database` (storage is an implementation detail)
- ❌ `Provider Cache` (caching is an implementation detail)
- ❌ `Provider API` (API is an interface, not a capability)
- ❌ `Provider Queue` (queueing is an implementation detail)
- ✅ `Provider Discovering`
- ✅ `Provider Booking`
- ✅ `Provider Messaging`

The test: would a non-technical product manager use this word? "Provider Discovering" — yes. "Provider Cache" — no.

### 4. Require specificity in the verb

Generic verbs hide value propositions. Reject `Managing`, `Handling`, `Processing`, `Doing` without further qualification.

- ❌ `Provider Management` (what kind of management?)
- ❌ `Order Handling` (what kind of handling?)
- ❌ `Data Processing` (too generic)
- ✅ `Provider Onboarding`
- ✅ `Order Fulfilment`
- ✅ `Order Reconciliation`

There are exceptions — sometimes "Management" really is the right word (e.g., `User Account Management` is canonical in the deck). The rule of thumb: if `Management` is the verb, there should be a clear, single concept that "management" denotes for this object, and you should be able to articulate it in one sentence.

### 5. Singular concept

A capability name should describe **one** thing. If the name contains "and," it's probably two capabilities.

- ❌ `Provider Booking and Messaging` → split into `Provider Booking` + `Provider Messaging`
- ❌ `User Registration and Account Management` → split

### 6. Avoid product-line names

Product lines are groupings of Customer Experiences; not capabilities.

- ❌ `Provider Marketplace` (product line, not capability)
- ❌ `Store Management Platform` (product line, not capability)
- ✅ `Provider Listing`, `Provider Discovering`, `Provider Booking` (the capabilities inside that product line)

## Rewriting a failed name

When a candidate name fails, don't just discard it — use it as a hint:

1. Extract the noun(s) from the failed candidate.
2. Look at the journey steps the candidate was extracted from.
3. Identify the **verb** that connects the user's action to the noun.
4. Compose `Object Verb` or `Verb`.

Example: candidate `Provider` extracted from journey steps "Search for available Provider," "View Provider Search Results."
- Noun: Provider
- Verb in journey: Search → "Discovering" (more general than "Searching" because Search is one implementation)
- Result: `Provider Discovering`

Example: candidate `Store Information` extracted from "Update store address," "View store hierarchy," "Transfer store ownership."
- Noun: Store
- Verbs: Update, View, Transfer
- This is *not* one capability — split: `Store Asset Tracking`, `Store Hierarchy Management`, `Store Ownership Tracking`

## Why the rule matters

The naming rule is **not** stylistic. It is **load-bearing for boundary-setting.**

Noun-only names hide the value proposition. "Provider" doesn't force you to articulate *what about provider* the capability handles. So two teams can both think they own "Provider" while doing entirely different things with it. Renaming "Provider" → "Provider Discovering" + "Provider Booking" + "Provider Onboarding" forces three different value propositions, three different teams, three different seams.

The deck's `Object Verb` rule is the cheapest mechanism for surfacing decomposition opportunities. Take it seriously.

## When to ask the user

If after applying the rewrite procedure the name is still ambiguous or you don't know the right verb, ask the user — they're the SME for what the system does in their domain. Surface candidate names with `[NEEDS-SME-CONFIRM: <best-guess>]` rather than guessing silently.

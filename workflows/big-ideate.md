---
name: big-ideate
description: Plans an initiative too large for one session as a shared map of decision tickets on the issue tracker, then resolves them one per session until the way to the destination is clear. Use when an idea is too big or foggy for a single ideate session — when the open questions cannot yet all be listed, let alone answered.
argument-hint: "[loose idea | map key/URL] [ticket name]"
---

# Big Ideate: Multi-Session Decision Mapping

Charts an oversized, fog-wrapped idea as a **shared map** of **decision tickets** on the issue tracker, then works those tickets one per session until the way to the **destination** is clear and the standard discovery chain (`create-prd` → `create-stories`) can take over.

**Core principle**: Plan, don't do. Every ticket resolves a *decision*, not a slice of a build. The map is done when nothing is left to decide before someone goes and does the thing — and "doing the thing" is the job of the rest of the SDLC chain, not this workflow. The pull to just start building is the signal you have reached the edge of the map and it is time to hand off.

**Decision tickets are not stories.** `create-stories` produces execution slices with acceptance criteria; this workflow produces questions whose resolution is a decision. Keep them apart: never put a build task on the map, and never put an open decision in a story.

## When to use this skill

- The user has an initiative too large for one `ideate` session — a platform migration, a new product line, a system redesign — and the open questions cannot yet all be listed
- The user invokes with a loose idea and says "map this", "chart this", or "this is too big for one session"
- The user invokes with an existing map key or URL to resolve the next decision
- NOT for ideas one session can hold — run `ideate` → `create-prd` directly. Phase 3 enforces this: no fog means no map.

## Core Concepts

### The Map

The map is a single issue on the tracker, labelled `big-ideate:map` — the canonical artifact. Its tickets are child issues of the map. Tracker operations (create the map, create child tickets, wire blocking links, query the frontier, claim, resolve) are mapped per tool in the **Wayfinding Operations** section of `reference/tool-capabilities.md`. If no tracker is configured, use the local markdown fallback described there (`.agents/maps/`).

The map is an **index**, not a store. It lists the decisions made and points at the tickets that hold their detail. A decision lives in exactly one place — its ticket — so the map never restates it, only gists it and links. Open tickets are NOT listed in the map body; they are open child issues, found by query.

Map body template:

```markdown
## Destination

<what reaching the end of this map looks like — typically a PRD ready for
create-stories, a locked decision set, or a change made in place.
One or two lines; every session orients to it before choosing a ticket.>

## Notes

<domain; workflows every session should consult (default: ideate for
grilling tickets, create-prd for the destination artifact); standing
preferences for this effort>

## Decisions so far

<!-- the index — one line per closed ticket -->
- [<closed ticket title>](link) — <one-line gist of the answer>

## Not yet specified

<!-- in-scope fog you cannot ticket yet; graduates as the frontier advances -->

## Out of scope

<!-- work ruled beyond the destination; closed, never graduates -->
```

### Tickets

Each ticket is a **child issue** of the map; the tracker's issue id is its identity. Its body is one question, sized to one agent session:

```markdown
## Question

<the decision or investigation this ticket resolves>
```

Each ticket carries a `big-ideate:<type>` label — one of `research`, `prototype`, `grilling`, `task`:

| Type | Mode | Resolved by | Use when |
|------|------|-------------|----------|
| `research` | AFK | A research subagent or dedicated read-only pass over docs, third-party APIs, or the codebase | A fact outside the working directory blocks a decision |
| `prototype` | HITL | A cheap, rough, concrete artifact — an outline, a stub, spike code on a throwaway branch — linked from the ticket for the user to react to | "How should it look/behave" is the key question |
| `grilling` | HITL | Structured questioning conversation in the style of `ideate` Phases 1-2: sharpening questions, variations, stress-tests — one question at a time | The default case |
| `task` | HITL or AFK | Manual work that must happen before a decision can be made — provisioning access, signing up for a service, moving data so its shape can be seen | The discussion is blocked on work, not on a decision |

**HITL** (human in the loop) tickets resolve only through live exchange with the user. **AFK** tickets the agent drives alone. An agent that answers its own grilling questions has broken the model — those answers are the user's to give.

The answer is not part of the ticket body — it is recorded at resolution (Phase 9). Assets created while resolving (prototypes, research notes) are linked from the ticket, not pasted in.

### Blocking and the Frontier

Blocking uses the tracker's **native** dependency relationship (Blocks links in Jira) so the human sees what is takeable in the tracker's own UI without opening the map. A ticket is **unblocked** when every ticket blocking it is closed. The **frontier** is the set of open, unblocked, unclaimed children — the edge of the known.

A session **claims** a ticket by assigning it to the user driving the map, FIRST, before any work, so concurrent sessions skip it. The assignee IS the claim: an open, unassigned ticket is unclaimed.

### Fog of War

The map is deliberately incomplete: do not chart what you cannot yet see. Beyond the live tickets lies the fog — decisions you can tell are coming but cannot yet pin down, because they hang on questions still open. Write that dim view into **Not yet specified**, as loosely or fully as the view allows. Resolving a ticket clears the fog ahead of it; graduate whatever is now specifiable into fresh tickets and delete it from **Not yet specified**.

**Fog or ticket?** The test is whether you can state the question precisely now — NOT whether you can answer it now:

- **Ticket** when the question is already sharp, even if blocked
- **Not yet specified** when you cannot yet phrase it that sharply. Do not pre-slice fog into ticket-sized pieces — one patch may graduate into several tickets, or none

### Out of Scope

The destination fixes the scope. Work beyond it is not fog — it gets the map's **Out of scope** section: one line of gist plus why it is out, linking any closed ticket. When an existing ticket turns out to sit past the destination, close it and record it there. It stays out of **Decisions so far**, which records only the route actually walked. Out-of-scope work never graduates; it returns only if the destination is redrawn, and then as a fresh map.

### Refer by Name

Every map and ticket has a name — its title. In everything the human reads, refer to it by that name, never by a bare id. A wall of `PROJ-42, PROJ-43` is illegible; names read at a glance. The id and URL ride inside the name as its link, never stand in for it.

---

### Phase 1: INTAKE — Determine Mode

Parse the input:

| Input | Mode |
|-------|------|
| Loose idea, problem statement, initiative description | **Charting** — run Phases 2-6, then stop |
| Map key, URL, or `.agents/maps/` path (± a ticket name) | **Working** — skip to Phase 7 |

Resolve the tracker: check for Jira availability per `reference/tool-capabilities.md`. If unavailable, state that the map will live in `.agents/maps/` as local markdown and continue.

---

### Phase 2: DESTINATION — Name What This Map Is Finding Its Way To

Run an `ideate`-style questioning conversation (Phase 1 of that workflow: restate, then 3-5 sharpening questions, one at a time) to pin down the destination — the spec, decision, or change this effort is finding its way to. For pm-sdlc efforts the destination is typically "a PRD ready for `create-stories`" or "these N decisions locked so `create-prd` can run."

> **GATE:** Do NOT chart until the user confirms the destination in one or two lines. The destination fixes the scope; every ticket hangs off it.

---

### Phase 3: FRONTIER — Map the Open Decisions Breadth-First

Question again, **breadth-first** this time: fan out across the whole space rather than deep on any one thread. Surface the open decisions, the investigations they wait on, and the first steps takeable now. Do not answer anything — collect questions.

> **GATE:** If this surfaces no fog — the way to the destination is already clear and the whole journey fits one session — you do not need a map. Stop and recommend `ideate` → `create-prd` instead. Do NOT build ceremony around a small idea.

---

### Phase 4: CHART — Create the Map

Create the map issue (label `big-ideate:map`) with Destination and Notes filled in, Decisions-so-far empty, and the fog sketched into **Not yet specified**. Default the Notes to: grilling tickets use `ideate`-style questioning; the destination artifact is produced with `create-prd`.

---

### Phase 5: TICKET — Create and Wire the First Tickets

1. **Create** every ticket you can phrase sharply now as a child issue of the map, each with its `big-ideate:<type>` label. Everything you cannot phrase sharply stays in **Not yet specified**.
2. **Wire blocking in a second pass** — issues need ids before they can reference each other. Wiring sorts the tickets into the frontier and the blocked.
3. **Present the map to the user by name**: the destination, the frontier (what is takeable now), the blocked tail, and the fog.

---

### Phase 6: DISPATCH — Fire Research, Then Stop

For each `research` ticket on the frontier, dispatch a research subagent (or note it for a dedicated session if subagents are unavailable): claim the ticket, investigate, record findings per Phase 9. Research is the one type that may resolve in parallel with charting.

> **GATE:** Charting ends here. A charting session hand-resolves NOTHING — present the map and stop. Resolving decisions is the next session's work.

---

### Phase 7: LOAD — Orient on the Map

Load the map body only — the low-resolution view, not every ticket. Read Destination, Notes, Decisions-so-far. Zoom into closed tickets on demand when their detail bears on today's work.

---

### Phase 8: CLAIM — Choose and Claim One Ticket

1. If the user named a ticket, use it. Otherwise query the frontier and take the first ticket in order.
2. **Claim it before any work**: assign it to the user driving the map. Expect other sessions to be editing the tracker concurrently — an unassigned ticket is the only safe pick.

> **GATE:** One ticket per session (research tickets excepted). If the chosen ticket is HITL and the user is not actively responding, stop — a HITL ticket cannot be resolved AFK, and guessing the user's answers poisons the map.

---

### Phase 9: RESOLVE — Work the Ticket to a Decision

Work the ticket per its type (see Core Concepts). Zoom as needed: fetch related or closed tickets on demand; consult the workflows the map's Notes name. When in doubt, question `ideate`-style — one question at a time.

Record the resolution:

1. Post the answer as a **resolution comment** on the ticket
2. **Close** the ticket
3. **Append one line** to the map's Decisions-so-far: the ticket name (as a link) plus a one-line gist

---

### Phase 10: GRADUATE — Advance the Frontier

1. **Create newly surfaced tickets** (create, then wire blocking — same second-pass rule as Phase 5)
2. **Graduate fog** the answer has made specifiable: create the ticket, delete the patch from **Not yet specified** so it lives only as its ticket
3. **Rule out of scope** anything the answer revealed sits past the destination — close it, record it in **Out of scope**, keep it out of Decisions-so-far
4. **Update or delete tickets the decision invalidated**
5. **Check for arrival**: if the frontier is empty and no fog remains, the way is clear. Declare the map complete and hand off — run `create-prd` from Decisions-so-far (if the destination is a spec), then `create-stories`. The map's job is done.

---

## Failure Handling

| Failure | Action |
|---------|--------|
| Tracker unavailable mid-effort | Fall back to `.agents/maps/` per `reference/tool-capabilities.md`; tell the user the map moved |
| Chosen ticket already assigned | It is claimed — pick the next frontier ticket |
| HITL ticket, unresponsive user | Stop after Phase 8's gate; never self-answer |
| Resolution invalidates the destination | Stop and re-run Phase 2 with the user — a redrawn destination is a new scoping act, not a quiet edit |
| Frontier empty but fog remains | The fog is blocked on nothing — either graduate it (it was sharper than recorded) or take it to the user: what question would clear it? |

## Absolute Constraints

1. **NEVER resolve more than one ticket per session** — research tickets are the only exception
2. **NEVER answer the user's side of a HITL ticket** — grilling and prototype tickets resolve only through live exchange
3. **NEVER execute toward the destination** — produce decisions, not deliverables; the map's Notes may explicitly override this, but absent that, plan only (`task` tickets do work solely to unblock a decision)
4. **NEVER restate decision detail on the map** — the map is an index: gist plus link, detail lives in the ticket
5. **NEVER refer to a ticket by bare id in anything the user reads** — the name carries the link
6. **NEVER put execution stories on the map** — build slices belong to `create-stories` after the map completes
7. **NEVER work an unclaimed ticket** — claim by assignment first, before any other action
8. **NEVER chart what you cannot state sharply** — unspecifiable questions stay in Not yet specified
9. **Charting sessions resolve nothing** — chart, dispatch research, stop

## Integration Points

- **ideate**: supplies the questioning method — Phase 2's destination conversation and every `grilling` ticket run `ideate`-style sharpening (Phases 1-2 of that workflow: one question at a time, variations, stress-tests)
- **create-prd**: the usual destination artifact — when the map completes, Decisions-so-far is its input; the PRD is written once, informed by every resolved ticket
- **create-stories**: strictly downstream — execution tickets are created from the finished PRD, never from the map
- **prime-for-feature / plan-feature / ship-feature**: consume what the map hands off, unchanged; a completed map feeds the standard chain
- **Tracker operations**: the Wayfinding Operations section of `reference/tool-capabilities.md` maps capability language (create map, create ticket, wire blocking, query frontier, claim, resolve) to Jira MCP tools and the `.agents/maps/` markdown fallback. This file stays tool-agnostic.
- **retrospective**: after the effort ships, the map is retro input — Decisions-so-far is a record of every fork in the road

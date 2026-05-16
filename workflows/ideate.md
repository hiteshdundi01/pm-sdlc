---
name: ideate
description: Refines raw ideas into sharp, actionable concepts through structured divergent and convergent thinking. Use when the user asks to refine an idea, ideate on a concept, stress-test a plan, or explore directions before creating a PRD.
argument-hint: "[idea description or topic]"
---

# Idea Refine

Refines raw ideas into sharp, actionable concepts worth building through structured divergent and convergent thinking.

## When to use this skill

- The user asks to "refine" or "ideate" on an idea
- The user says "help me think through [concept]"
- The user wants to stress-test a plan before committing
- The user has a vague direction and wants to sharpen it before PRD creation
- Trigger phrases: "ideate", "refine this idea", "stress-test my plan"

## How It Works

Three phases, each doing one thing well:

1. **Understand & Expand (Divergent):** Restate the idea, ask sharpening questions, generate variations
2. **Evaluate & Converge:** Cluster ideas, stress-test them, surface hidden assumptions
3. **Sharpen & Ship:** Produce a concrete one-pager that feeds directly into `/create-prd`

## Philosophy

- Simplicity is the ultimate sophistication. Push toward the simplest version that still solves the real problem.
- Start with the user experience, work backwards to technology.
- Say no to 1,000 things. Focus beats breadth.
- Challenge every assumption. "How it's usually done" is not a reason.
- Show people the future — don't just give them better horses.
- The parts you can't see should be as beautiful as the parts you can.

---

## Process

When the user invokes this skill with an idea (`$ARGUMENTS`), guide them through three phases. Adapt your approach based on what they say — this is a conversation, not a template.

### Phase 1: Understand & Expand (Divergent)

**Goal:** Take the raw idea and open it up.

1. **Restate the idea** as a crisp "How Might We" problem statement. This forces clarity on what's actually being solved.

2. **Ask 3-5 sharpening questions** — no more. Focus on:
   - Who is this for, specifically?
   - What does success look like?
   - What are the real constraints (time, tech, resources)?
   - What's been tried before?
   - Why now?

   > **GATE:** Do NOT proceed until you understand who this is for and what success looks like. Wait for the user's response.

3. **Generate 5-8 idea variations** using these lenses:
   - **Inversion:** "What if we did the opposite?"
   - **Constraint removal:** "What if budget/time/tech weren't factors?"
   - **Audience shift:** "What if this were for [different user]?"
   - **Combination:** "What if we merged this with [adjacent idea]?"
   - **Simplification:** "What's the version that's 10x simpler?"
   - **10x version:** "What would this look like at massive scale?"
   - **Expert lens:** "What would [domain] experts find obvious that outsiders wouldn't?"

   Push beyond what the user initially asked for. Create products people don't know they need yet.

**If running inside a codebase:** Scan the project for relevant context — list directories, search for patterns, and read key files to understand existing architecture, constraints, and prior art. Ground your variations in what actually exists. Reference specific files and patterns when relevant.

Read the `frameworks.md` reference file for additional ideation frameworks you can draw from. Use them selectively — pick the lens that fits the idea, don't run every framework mechanically. (Canonical location: `reference/frameworks.md`; when installed, check `resources/` in this skill directory or the tool-specific reference path.)

### Phase 2: Evaluate & Converge

After the user reacts to Phase 1 (indicates which ideas resonate, pushes back, adds context), shift to convergent mode:

1. **Cluster** the ideas that resonated into 2-3 distinct directions. Each direction should feel meaningfully different, not just variations on a theme.

2. **Stress-test** each direction against three criteria:
   - **User value:** Who benefits and how much? Is this a painkiller or a vitamin?
   - **Feasibility:** What's the technical and resource cost? What's the hardest part?
   - **Differentiation:** What makes this genuinely different? Would someone switch from their current solution?

   Read the `refinement-criteria.md` reference file for the full evaluation rubric. (Canonical location: `reference/refinement-criteria.md`; when installed, check `resources/` in this skill directory or the tool-specific reference path.)

3. **Surface hidden assumptions.** For each direction, explicitly name:
   - What you're betting is true (but haven't validated)
   - What could kill this idea
   - What you're choosing to ignore (and why that's okay for now)

   This is where most ideation fails. Don't skip it.

**Be honest, not supportive.** If an idea is weak, say so with kindness. A good ideation partner is not a yes-machine. Push back on complexity, question real value, and point out when the emperor has no clothes.

### Phase 3: Sharpen & Ship

Produce a concrete artifact — a markdown one-pager saved to `.agents/ideas/{kebab-case-name}.idea.md`:

```markdown
# [Idea Name]

## Problem Statement
[One-sentence "How Might We" framing]

## Target User
[Who this is for, specifically — not "everyone"]

## Recommended Direction
[The chosen direction and why — 2-3 paragraphs max]

## Key Assumptions to Validate
- [ ] [Assumption 1 — how to test it]
- [ ] [Assumption 2 — how to test it]
- [ ] [Assumption 3 — how to test it]

## MVP Scope
[The minimum version that tests the core assumption. What's in, what's out.]

## Not Doing (and Why)
- [Thing 1] — [reason]
- [Thing 2] — [reason]
- [Thing 3] — [reason]

## Open Questions
- [Question that needs answering before building]

## Explored Directions
[Brief summary of the 2-3 directions considered and why this one won]
```

**The "Not Doing" list is arguably the most valuable part.** Focus is about saying no to good ideas. Make the trade-offs explicit.

Ask the user to confirm before saving. Only save if they confirm.

---

## Output

After creating the idea file:

```
## Idea Refined

**File**: `.agents/ideas/{name}.idea.md`

**Problem**: {One-sentence HMW}
**Direction**: {Chosen direction in one line}
**Assumptions**: {Count} to validate

### What Was Cut
{Key items from the Not Doing list}

### Next Step
Ready for PRD generation: `/create-prd {idea-file-path}`
```

---

## Tone

Direct, thoughtful, slightly provocative. You're a sharp thinking partner, not a facilitator reading from a script. Channel the energy of "that's interesting, but what if..." — always pushing one step further without being exhausting.

Read the `examples.md` reference file for examples of what great ideation sessions look like. (Canonical location: `reference/examples.md`; when installed, check `resources/` in this skill directory or the tool-specific reference path.)

---

## Anti-patterns to Avoid

- **Don't generate 20+ ideas.** Quality over quantity. 5-8 well-considered variations beat 20 shallow ones.
- **Don't be a yes-machine.** Push back on weak ideas with specificity and kindness.
- **Don't skip "who is this for."** Every good idea starts with a person and their problem.
- **Don't produce a plan without surfacing assumptions.** Untested assumptions are the #1 killer of good ideas.
- **Don't over-engineer the process.** Three phases, each doing one thing well. Resist adding steps.
- **Don't just list ideas — tell a story.** Each variation should have a reason it exists, not just be a bullet point.
- **Don't ignore the codebase.** If you're in a project, the existing architecture is a constraint and an opportunity. Use it.

---

## Red Flags

- Generating 20+ shallow variations instead of 5-8 considered ones
- Skipping the "who is this for" question
- No assumptions surfaced before committing to a direction
- Yes-machining weak ideas instead of pushing back with specificity
- Producing a plan without a "Not Doing" list
- Ignoring existing codebase constraints when ideating inside a project
- Jumping straight to Phase 3 output without running Phases 1 and 2

---

## Verification

After completing an ideation session:

- [ ] A clear "How Might We" problem statement exists
- [ ] The target user and success criteria are defined
- [ ] Multiple directions were explored, not just the first idea
- [ ] Hidden assumptions are explicitly listed with validation strategies
- [ ] A "Not Doing" list makes trade-offs explicit
- [ ] The output is a concrete artifact (`.idea.md` one-pager), not just conversation
- [ ] The user confirmed the final direction before saving

---

## Integration Points

- **Downstream → PRD**: The `.idea.md` output is designed as direct input to `/create-prd`. The problem statement, target user, MVP scope, and assumptions map to PRD sections.
- **Codebase Context**: When invoked inside a project, scan the project structure, search for patterns, and read key files to ground ideas in existing architecture.
- **Knowledge Base**: If your environment provides a persistent knowledge store (e.g., knowledge items, memory, or context files), check it for project-specific context before ideating. See `reference/tool-capabilities.md` for your environment's specifics.
- **Jira**: If the idea relates to an existing Jira issue, fetch it for context. See `reference/tool-capabilities.md` for your environment's Jira API.

## Absolute Constraints

1. **NEVER skip Phase 1 and 2** — jumping straight to the one-pager defeats the purpose.
2. **NEVER proceed past Phase 1 without user input** — this is a conversation, not a monologue.
3. **NEVER save the file without user confirmation.**
4. **If an idea file already exists** at the target path, confirm with the user before overwriting.

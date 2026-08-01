# Workflow Guide: How the SDLC Chain Works

This guide explains how pm-sdlc workflows connect, what each one expects as input, what it produces as output, and how to get the most out of the chain.

## The Full Lifecycle

```
┌─────────────────────────────────────────────────────────┐
│                    DISCOVERY                            │
│                                                         │
│   ideate ──→ create-prd ──→ create-stories              │
│   (idea)     (spec)         (tickets)                   │
└──────────────────────────────┬──────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────┐
│                    PLANNING                             │
│                                                         │
│   prime-for-feature ──→ plan-feature ⇄ critique-plan    │
│   (context)             (plan)         (audit)          │
└──────────────────────────────┬──────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────┐
│                    EXECUTION                            │
│                                                         │
│   implement-feature ──→ validate ──→ code-review        │
│   (code)                (checks)     (review)           │
└──────────────────────────────┬──────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────┐
│                    LEARNING                             │
│                                                         │
│   retrospective                                         │
│   (lessons → convention updates)                        │
└─────────────────────────────────────────────────────────┘

  create-global-rules runs standalone (once per project)
```

## Workflow-by-Workflow Breakdown

### 1. ideate

**Purpose**: Take a vague idea and turn it into something worth building.

**Input**: A raw idea, problem statement, or "help me think through X"

**Output**: `.agents/ideas/{name}.idea.md` — a one-pager with:
- HMW problem statement
- Target user
- Recommended direction
- Key assumptions to validate
- MVP scope
- "Not Doing" list (arguably the most valuable part)
- Explored directions that were rejected

**Key behaviors**:
- Generates 5-8 variations (not 20+ shallow ones)
- Explicitly pushes back on weak ideas
- Surfaces assumptions before committing to a direction
- Won't proceed past Phase 1 without user input

**Feeds into**: `create-prd`

**Typical duration**: 15-30 minutes of interactive conversation

---

### 2. create-prd

**Purpose**: Convert a refined idea or conversation into a formal spec.

**Input**: An `.idea.md` file, conversation context, or feature description

**Output**: `.agents/PRDs/{name}.prd.md` — a comprehensive PRD with:
- Executive summary and mission
- Target users and personas
- MVP scope (in/out)
- User stories
- Architecture and patterns
- Technology stack
- Success criteria
- Implementation phases
- Risks and mitigations

**Key behaviors**:
- Asks clarifying questions before generating
- Includes concrete examples, not abstract descriptions
- Implementation phases are actionable, not aspirational

**Feeds into**: `create-stories`

---

### 3. create-stories

**Purpose**: Break a PRD into implementable tickets.

**Input**: A `.prd.md` file + optional `--project` and `--epic` flags

**Output**: `.agents/stories/{name}.md` + (optionally) Jira issues

**Key behaviors**:
- Stories are small enough to complete in 1-2 days
- Each story has 3-5 testable acceptance criteria
- Dependencies between stories are explicit
- Can create Jira issues directly via MCP

**Feeds into**: `prime-for-feature` (pick a story to implement)

**Jira integration**: If the Atlassian MCP server is configured, this workflow creates issues, sets priority/labels, links them to epics, and creates dependency links between stories.

---

### 4. prime-for-feature

**Purpose**: Load all context needed before planning or implementing.

**Input**: Jira issue key, codebase, optional Confluence pages

**Output**: Context loaded into the agent's memory (not a file):
- Project purpose and tech stack
- Data model and key patterns
- Conventions and naming rules
- Current git state
- Task context from Jira
- AC reconciliation against PRD

**Key behaviors**:
- Discovers conventions from AGENTS.md, CLAUDE.md, CONTRIBUTING.md
- Maps the codebase structure and data model
- Reconciles Jira acceptance criteria against the PRD — proposes updates if they're out of sync

**Feeds into**: `plan-feature` and `critique-plan`

**Why this matters**: Without priming, plans are generic. With priming, plans are grounded in your actual code patterns, naming conventions, and architecture.

---

### 5. plan-feature

**Purpose**: Create a codebase-aware implementation plan.

**Input**: Feature description, PRD phase, Jira issue, or free-form text

**Output**: `.agents/plans/{name}.plan.md` — a detailed plan with:
- Summary and user story
- Patterns to follow (with `file:line` citations)
- Files to create/update
- Ordered task list with validation commands
- Acceptance criteria

**Key behaviors**:
- Explores the codebase BEFORE writing the plan
- Every pattern reference cites actual code
- Tasks are atomic and independently verifiable
- Never guesses validation commands — checks `package.json`/`Makefile`/etc.

**Feeds into**: `critique-plan` (for audit) then `implement-feature` (for execution)

**The critical rule**: Plan only, no code. This is the design phase.

---

### 6. critique-plan

**Purpose**: Audit a plan before implementation to catch issues that would derail one-pass execution.

**Input**: A `.plan.md` file (expects `prime-for-feature` to have already run)

**Output**: `.agents/reviews/plan-reviews/{name}.review.md` — an audit with:
- Anchors used (goal, constraints, patterns, minimum-viable sketch)
- Strengths (3 strongest things about the plan)
- Findings across 7 axes
- CUT / CHANGE / ADD worklist
- Overall verdict

**The 7 review axes**:
1. Scope Integrity — does every task trace to a requirement?
2. Necessity — could fewer files/tasks achieve the same result?
3. Pattern Fidelity — do cited patterns actually match the code?
4. Sequencing & Atomicity — can each task be validated independently?
5. Acceptance Criteria — are they testable from outside?
6. Risk Coverage — are mitigations real mechanisms, not vague intentions?
7. YAGNI / Speculative Generality — name a second concrete user today or cut it

**Key behaviors**:
- Diffs the plan against a "minimum-viable plan" it constructs
- Scans for rationalization phrases: "for testability" → name the test
- Won't manufacture problems — `fine` is a valid verdict
- Doesn't edit Jira — AC mismatches are findings, not edit triggers

**Feeds into**: Back to `plan-feature` (if revision needed) or `implement-feature` (if sound)

---

### 7. implement-feature

**Purpose**: Execute a plan with rigorous validation loops.

**Input**: A `.plan.md` file

**Output**: Code changes + `.agents/reports/{name}-report.md` + Jira updates

**Key behaviors**:
- Verifies assumptions before writing code
- Reads adjacent files to check integration
- Runs build/type-check after EVERY task
- Writes tests for all new code
- Has an E2E verification gate — workflows require passing tests before reporting done (with documented exceptions for libraries, CLIs, and docs repos)
- Archives completed plans to `.agents/plans/completed/`
- Transitions Jira issues and adds implementation comments

**Feeds into**: `validate` → `code-review`

---

### 8. validate

**Purpose**: Run the full quality pipeline — type check, lint, tests.

**Input**: Optional `--fix` flag and `--scope` path

**Output**: Structured pass/fail report with actionable details for failures

**Key behaviors**:
- Discovers the project's actual commands (never invents)
- Runs ALL checks even if early ones fail
- Read-only by default (`--fix` enables auto-fixing)
- Reports in a table format for quick scanning

**Feeds into**: `code-review` (as a pre-flight)

---

### 9. code-review

**Purpose**: Thorough 5-axis code review with isolated validation.

**Input**: PR number, file path, folder path, or unstaged changes

**Output**: `.agents/reviews/{scope}-review.md` + GitHub PR comment

**Key behaviors**:
- Records starting git state and verifies it's untouched at the end
- Fetches PR diff without checking out (read-only)
- Reviews tests FIRST — they reveal intent
- Runs validation in an isolated git worktree
- Checks git workflow compliance (merge commits, branch naming, commit hygiene)
- Supports plan conformance checking with `--plan` flag

**Feeds into**: `retrospective` (after merge)

---

### 10. retrospective

**Purpose**: Capture lessons learned and feed them back into conventions.

**Input**: Feature name, plan path, or `--sprint`

**Output**: `.agents/retros/{name}-retro.md` + convention updates

**Key behaviors**:
- Reviews actual artifacts, not impressions
- Identifies patterns across features (not just one-off observations)
- Does root cause analysis for problems
- Every retro produces at least one concrete action (or an explicit, evidence-based "nothing to change" with justification)
- Can apply convention updates (with user confirmation)

**Feeds into**: Improved future workflow runs via updated conventions

---

### 11. create-global-rules (standalone)

**Purpose**: Generate AGENTS.md from codebase analysis.

**Input**: The codebase itself

**Output**: `AGENTS.md` at project root

**Key behaviors**:
- Discovers everything from actual code (never invents patterns)
- Checks for existing conventions before creating new ones
- Asks before overwriting existing AGENTS.md

**When to use**: Once per project (or when the project's structure changes significantly)

---

### 12. ship-feature (orchestrator)

**Purpose**: Run the planning-to-shipped chain as one session, with implementation dispatched to a separate executor agent.

**Input**: Story file, Jira key, or feature description + optional `--executor` and `--model` flags

**Output**: Verified feature branch + every chain artifact (plan, plan critique, implementation report, validation results, code review)

**Key behaviors**:
- Executes `prime-for-feature` → `plan-feature` → `critique-plan` inline, with an automatic revise loop (max 2 cycles)
- Dispatches `implement-feature` to a headless executor CLI as a scoped work order
- Re-runs `validate` and `code-review --plan` itself — the executor's report is treated as claims, not evidence
- Bounded fix passes (max 2): the orchestrator applies review fixes directly, each traceable to a finding
- Merge ownership: after the ship decision, the executor re-validates and executes the merge; the orchestrator confirms it landed
- Two human gates: plan approval before dispatch, ship decision before merge

**Feeds into**: `retrospective`

**Why a separate executor**: The agent that wrote the code never reviews it, and no agent merges its own last change. Cross-agent review and cross-agent merge remove self-certification by construction.

---

### 13. big-ideate (multi-session discovery)

**Purpose**: Run Discovery across many sessions when an initiative is too large and foggy for one `ideate` conversation.

**Input**: A loose oversized idea (charting mode), or a map key/URL plus an optional ticket name (working mode)

**Output**: A decision map on the issue tracker — one parent issue labelled `big-ideate:map` with decision tickets as children (fallback: `.agents/maps/{name}/`). The finished map's "Decisions so far" index feeds `create-prd`.

**Key behaviors**:
- Names the **destination** first (usually "a PRD ready for create-stories") — it fixes the scope of everything else
- Charts breadth-first: sharp questions become tickets, dim ones stay in a "Not yet specified" fog section
- Tickets are typed: `research` (agent-driven), `grilling` and `prototype` (human-in-the-loop), `task` (unblocking work)
- Resolves exactly **one decision per session** (research excepted); claims tickets by assignment so parallel sessions don't collide
- Blocking uses native Jira Blocks links, so the frontier of takeable tickets is visible in the tracker UI
- Refuses to build a map when one session would do — no fog, no map
- Plans, never executes: the map produces decisions; the rest of the chain produces the deliverable

**Feeds into**: `create-prd` → `create-stories` once the frontier is empty and the fog is clear

**Why this exists**: `ideate` assumes one session can hold the whole conversation. Large initiatives can't list their open questions up front, let alone answer them — the map makes that incompleteness explicit and works it down decision by decision, across days or weeks, with a shared artifact any session can pick up.

---

## Common Workflows

### "I have an idea" → Ship it

```
ideate → create-prd → create-stories → prime-for-feature
→ plan-feature → critique-plan → implement-feature → validate → code-review
→ retrospective
```

### "This idea is too big for one session" → Map it

```
big-ideate (chart) → big-ideate (one decision per session, repeated)
→ create-prd → create-stories → prime-for-feature → ...
```

### "I have a Jira ticket" → Implement it

```
prime-for-feature → plan-feature → critique-plan
→ implement-feature → validate → code-review
```

### "Ship this story, orchestrated"

```
ship-feature .agents/stories/{story}.md --executor codex
(runs prime → plan ⇄ critique → dispatch → validate → code-review with two human gates)
```

### "Review this PR"

```
code-review [PR number]
```

### "Quick health check"

```
validate
```

### "New project setup"

```
create-global-rules
```

---

## Tips for Best Results

1. **Don't skip priming.** `prime-for-feature` is the difference between a generic plan and one grounded in your codebase.

2. **Always critique before implementing.** The 5-minute critique saves hours of rework.

3. **Use the full chain on the first feature.** After that, you'll know which steps to abbreviate for your context.

4. **Feed Jira keys through the chain.** When stories, plans, and implementations all reference the same Jira issue, the lifecycle stays traceable.

5. **Run retrospectives.** They're the feedback loop that makes everything else better over time.

6. **Start with `validate` when you pick up someone else's code.** Quick health check before you start changing things.

---
name: critique-plan
description: Audits an implementation plan for scope creep, bloat, speculative generality, and pattern drift. Outputs a CUT / CHANGE / ADD worklist. Use after `plan-feature` and before implementation. Assumes `prime-for-feature` has already loaded Jira issues, conventions, and codebase context.
---

# Plan Critique

Audit a plan to catch issues that would derail one-pass execution. Calibration matters more than finding fault — if the plan is mostly fine, say so.

Check if `prime-for-feature` has been run first. This skill expects Jira issues, convention files (`CLAUDE.md` / `AGENTS.md` / `ARCHITECTURE.md` / `.agents/`), tech stack, and key patterns to already be in context. If missing, ask the user to prime — do not silently re-fetch.

This skill does not edit Jira. AC reconciliation belongs to `prime-for-feature`.

## Use when

- The user asks to critique, review, audit, or sanity-check a plan.
- A `.plan.md` path is given and the user wants a second pass before coding.

## Process

### 1. Load

- Verify priming. If Jira / conventions / patterns are missing from context, stop and ask the user to prime.
- Read the plan (`view_file`). If no path given, list `.agents/plans/` and disambiguate.
- Sample 2-3 `file:line` citations from the plan's pattern table and view those exact ranges. This is the only fresh disk read; it is required. If a citation does not resolve, that is a `blocking` Pattern Fidelity finding.

### 2. Anchor + Sketch Minimum

Establish the bar for "right" (internally; do not re-fetch):

- **Goal** — one sentence from the Jira issue or PRD. Not from the plan's own framing.
- **Hard constraints** — explicit must / must-not from convention files and Jira ACs.
- **Established patterns** — what prime identified across the codebase.
- **Mode** — one-pass agentic / human review / both.
- **Minimum-viable plan** — 3-8 bullets describing the smallest set of changes that satisfies the constraints and ACs. No abstractions for "future flexibility". No new files unless required. No test seams without a current test depending on them. The actual plan will be diffed against this.

If any anchor is unsourceable, ask the user to re-prime rather than guessing.

### 3. Strengths

List the 3 strongest things about the plan. Brief. Forces honest calibration before reviewing.

### 4. Review — seven axes

For each: verdict (`fine` / `minor` / `blocking`) with task-number or line-range citations. If `fine`, one line and move on. Do not pad.

**1. Scope Integrity**
- Every task traces to a Jira AC, PRD requirement, or hard constraint?
- Anything in scope the requirements don't ask for? Distinguish load-bearing from speculative.
- Anything belonging to a different ticket?
- Any "must" / "must not" from conventions violated? Cite the file line.

**2. Necessity**
- Could fewer files be touched? Could any `CREATE` live in an existing file? Any `UPDATE` doing more than required? Any tasks mergeable without losing atomicity?
- **Diff against the minimum-viable plan from §2.** Every task without an equivalent in the minimum needs a load-bearing justification — removing it breaks an AC, violates a hard constraint, or breaks an established pattern. "Plausibly good engineering" does not count.
- **Rationalization scan.** Each occurrence of these phrases requires concrete grounding; ungrounded = `minor` minimum:
  - *"for testability"* → name the current test that needs the seam.
  - *"for flexibility" / "for future"* → name the second variant or caller that exists today.
  - *"for separation of concerns"* → name the concrete coupling problem prevented today.
  - *"for observability" / "for safety" / "for robustness"* → name the failure mode observed or AC requiring it.
- **Test bloat.** For each test file, name the unique behaviors covered. Tests that mostly assert mock interactions (e.g. "verify `X.method` called with `Y`") rather than observable behavior are flagged unless no observable seam exists.

**3. Pattern Fidelity**
- For each sampled citation: does the prescribed task actually mirror the cited code, or drift into a new pattern under the guise of following one?
- Cross-check against established patterns from §2: aligned, or one-off?

**4. Sequencing & Atomicity**
- Each task independently validatable with its `Validate` command? Hidden inter-task dependencies? Any task forcing later re-work? Any task too large to be atomic?

**5. Acceptance Criteria**
- Each criterion testable from outside (HTTP, exit code, file existence, type check) rather than by reading code? Criteria implied by requirements but missing? Duplicates or unfalsifiable ones?

**6. Risk Coverage**
- Each listed mitigation a real mechanism (test, code path, flag), not a vague intention?
- Missing risks: at most 2, only ones a competent reviewer would actually flag.

**7. YAGNI / Speculative Generality**

Apply the **concrete-user-today** test to:
- Abstractions / interfaces / base classes → name a second concrete impl today. Test doubles do not count.
- Configuration knobs / options / feature flags → name a second value used today.
- Adapter / wrapper / facade layers → name the concrete coupling problem prevented today.
- Generic types / type parameters → name a second concrete type using them today.
- Migration / dual-write / backward-compat shims → name an existing user of the old behavior.

No concrete user today = speculative = `minor` minimum, goes on CUT. **Exception:** if the plan names a different ticket adding the second user, it's load-bearing — note the dependency under Sequencing. Do not invent speculative findings; `fine` if none apply.

### 5. Write

Output to `.agents/reviews/plan-reviews/{plan-name}.review.md` with these sections:

- **Anchors Used** — goal, hard constraints, established patterns, execution mode, minimum-viable sketch.
- **Strongest Things** — the 3 from §3.
- **Findings by Axis** — 1 through 7, each with verdict and evidence (or `fine`).
- **CUT / CHANGE / ADD** — concrete worklist.
- **Overall Verdict** — one of: "Plan is sound, proceed" / "Sound with minor adjustments — apply CHANGE list, then proceed" / "Needs revision — apply CUT/CHANGE/ADD and re-run `plan-feature` on affected sections".

If a critique already exists at the path, confirm overwrite first.

### 6. Report

In chat: file path, one-line verdict, blocking/minor counts, strongest aspect, CUT/CHANGE/ADD item counts, next step.

## Constraints

- No plan rewriting. No format changes. No splitting into more files.
- No re-fetching primed context. Ask to re-prime if missing.
- No inventing the broader goal — source it from Jira / PRD / conventions or ask.
- No padding. Empty CUT/CHANGE/ADD lists are valid. Empty axes get a one-line `fine`.
- No manufacturing problems. Reasoning models love finding things to complain about; don't.
- No more than 2 invented missing risks. No invented YAGNI findings.
- No editing Jira. AC mismatches with the plan are Scope Integrity findings, not edit triggers.

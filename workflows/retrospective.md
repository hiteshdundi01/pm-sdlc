---
name: retrospective
description: Captures lessons learned after completing a feature, sprint, or incident. Produces actionable insights that update project conventions and improve future workflow runs. Use after implementation and code review are complete.
argument-hint: "[feature-name | plan-path | --sprint]"
---

# Retrospective: Capture and Apply Lessons Learned

After a feature ships or a sprint ends, this workflow reviews what happened, identifies patterns worth codifying, and produces actionable improvements that feed back into the project's conventions and future plans.

**Core Principle**: Learning that doesn't change behavior isn't learning. Every retrospective must produce at least one concrete action — a convention update, a workflow tweak, or a documented pattern.

## When to use this skill

- After `implement-feature` and `code-review` are complete for a feature
- At the end of a sprint or milestone
- After a production incident or unexpected bug
- When the user asks to "retro", "retrospective", "debrief", or "lessons learned"
- When patterns keep recurring across multiple features

## How to use it

**Input**: $ARGUMENTS

### Parse Input

| Input | Action |
|-------|--------|
| Feature name or plan path | Review the specific feature's artifacts |
| `--sprint` | Review all completed work since the last retrospective |
| Blank | Review the most recent completed feature |

---

### Phase 1: GATHER — Collect Evidence

Don't rely on memory or impressions. Review actual artifacts:

#### 1.1 Find Completed Work

```bash
# Check for implementation reports
ls .agents/reports/

# Check for completed plans
ls .agents/plans/completed/

# Check for reviews
ls .agents/reviews/completed/ .agents/reviews/plan-reviews/completed/

# Recent git history
git log --oneline --since="2 weeks ago" | head -20
```

#### 1.2 Read the Artifacts

For each completed feature in scope, read:

1. **The plan** (`.agents/plans/completed/*.plan.md`) — what was intended
2. **The implementation report** (`.agents/reports/*-report.md`) — what actually happened
3. **The plan critique** (`.agents/reviews/plan-reviews/*.review.md`) — what the audit found
4. **The code review** (`.agents/reviews/*.md`) — what the review found
5. **Git log** — the actual commit history

#### 1.3 Extract Key Data

From the artifacts, extract:

| Data Point | Source |
|-----------|--------|
| Planned tasks vs. completed tasks | Plan + Report |
| Deviations from plan | Report "Deviations" section |
| Issues found in review | Review "Issues Found" section |
| Plan critique findings | Plan review CUT/CHANGE/ADD |
| Test failures encountered | Report validation section |
| Files created vs. expected | Plan "Files to Change" vs. Report "Files Changed" |

---

### Phase 2: ANALYZE — Identify Patterns

Don't just list what happened. Find the **patterns** — things that keep recurring or that signal a systemic issue.

#### 2.1 What Went Well

Identify 2-4 things that worked effectively. Be specific:

- ❌ "Communication was good" (vague, not actionable)
- ✅ "The plan's `file:line` citations prevented 3 pattern mismatches that would have required rework" (specific, traceable)

#### 2.2 What Didn't Go Well

Identify 2-4 things that caused friction, rework, or surprises:

- ❌ "Testing was hard" (vague)
- ✅ "Integration tests required manual database setup that isn't documented — spent 45 minutes debugging connection issues" (specific, fixable)

#### 2.3 Pattern Detection

Look for recurring themes across features. Ask:

| Question | Signal |
|----------|--------|
| Did the plan's scope match reality? | If plans consistently over/under-scope, the planning workflow needs calibration |
| Were deviations mostly additions or removals? | Additions = underplanning. Removals = overplanning. |
| Did the same types of review findings recur? | Recurring findings = missing convention or pattern documentation |
| Were test failures in implementation or test code? | Implementation failures = plan didn't ground patterns well enough |
| Did critique findings get addressed? | Unaddressed critiques = critique isn't trusted or is too noisy |

#### 2.4 Root Cause (for problems)

For each issue identified, ask "why" until you reach something actionable:

```
Problem: Integration tests failed due to missing RLS policies
→ Why? The plan didn't include RLS setup in the task list
→ Why? The pattern table didn't reference the RLS setup pattern
→ Why? prime-for-feature didn't scan for RLS patterns
→ Action: Add RLS to the pattern checklist in prime-for-feature
```

Stop at the level where you can take a concrete action. Don't go deeper than necessary.

---

### Phase 3: RECOMMEND — Produce Actionable Improvements

Every retrospective must produce at least one of these:

#### 3.1 Convention Updates

If a pattern keeps recurring, codify it:

```markdown
### Convention Update: {description}

**File to update**: `AGENTS.md` / `CLAUDE.md` / `CONTRIBUTING.md`
**Section**: {section name}
**Change**: Add/modify the following:

> {The exact text to add or change}

**Rationale**: {Why this matters, with evidence from the retro}
```

#### 3.2 Workflow Improvements

If a workflow has a gap, document the fix:

```markdown
### Workflow Improvement: {workflow name}

**Issue**: {What's missing or broken}
**Proposed change**: {Specific addition or modification}
**Evidence**: {What happened that exposed this gap}
```

#### 3.3 Pattern Documentation

If you discovered a pattern worth sharing:

```markdown
### New Pattern: {pattern name}

**Where it applies**: {context}
**Example**: 
```
{code or process example}
```
**Anti-pattern**: {What to avoid}
```

#### 3.4 Checklist Items

If a step was missed that should be standard:

```markdown
### Checklist Addition: {workflow name}

**Add to phase**: {phase number and name}
**Check**: {What to verify}
**Rationale**: {Why this check matters}
```

---

### Phase 4: WRITE — Generate Retrospective Report

Create the report at: `.agents/retros/{feature-name}-retro.md`

```bash
mkdir -p .agents/retros
```

Use this template:

```markdown
# Retrospective: {Feature Name}

**Date**: {date}
**Scope**: {feature / sprint / incident}
**Artifacts Reviewed**: {list of files reviewed}

## Summary

{2-3 sentences: what was built, how it went, key takeaway}

## What Went Well

1. {Specific positive with evidence}
2. {Specific positive with evidence}

## What Didn't Go Well

1. {Specific issue with evidence}
   - **Root cause**: {why it happened}
   - **Impact**: {time lost, rework needed, risk introduced}
2. {Specific issue with evidence}
   - **Root cause**: {why}
   - **Impact**: {what}

## Patterns Detected

| Pattern | Frequency | Trend |
|---------|-----------|-------|
| {pattern} | {how often} | {improving / stable / worsening} |

## Metrics

| Metric | Planned | Actual |
|--------|---------|--------|
| Tasks | {N} | {N} |
| Files created | {N} | {N} |
| Files updated | {N} | {N} |
| Deviations | — | {N} |
| Review issues (Critical/High) | — | {N} |
| Review issues (Medium/Low) | — | {N} |

## Actions

### Must Do (before next feature)

| # | Action | Type | Target File/Workflow |
|---|--------|------|---------------------|
| 1 | {action} | Convention update | {file} |
| 2 | {action} | Workflow improvement | {workflow} |

### Should Do (within the sprint)

| # | Action | Type | Target |
|---|--------|------|--------|
| 1 | {action} | {type} | {target} |

### Consider

| # | Action | Type | Target |
|---|--------|------|--------|
| 1 | {action} | {type} | {target} |
```

---

### Phase 5: APPLY — Execute Must-Do Actions

> **GATE:** Ask the user before making any changes. Present the "Must Do" actions and get confirmation.

For each confirmed "Must Do" action:

1. **Convention updates** → Edit the target file (AGENTS.md, CLAUDE.md, etc.)
2. **Workflow improvements** → Note as a proposed change (don't modify workflow files in this pass — those changes should go through a PR)
3. **Pattern documentation** → Add to `.agents/rules/` or the project's convention file
4. **Checklist items** → Note for workflow PR

---

### Phase 6: OUTPUT — Report to User

```markdown
## Retrospective Complete

**Feature**: {name}
**Report**: `.agents/retros/{name}-retro.md`

### Key Findings

- **Went well**: {top positive}
- **Needs improvement**: {top issue}
- **Pattern detected**: {most important pattern}

### Actions Taken

- {N} convention updates applied
- {N} workflow improvements proposed
- {N} actions deferred to "Should Do"

### Next Steps

1. Review the full report at `.agents/retros/{name}-retro.md`
2. {Specific next action based on findings}
```

---

## Absolute Constraints

1. **NEVER produce a retrospective with zero actions.** If everything went perfectly, find one thing to improve anyway — there's always something.
2. **NEVER make vague observations.** Every finding must have specific evidence from artifacts.
3. **NEVER modify workflow files directly** — workflow improvements are proposed, not applied. They go through the contribution process.
4. **NEVER skip Phase 1.** Impressions without evidence lead to wrong conclusions.
5. **Ask before applying** any convention updates — the user decides what changes.

## Integration Points

- **implement-feature**: Consumes implementation reports and completed plans.
- **code-review**: Consumes review reports for finding patterns.
- **critique-plan**: Consumes plan reviews. Recurring critique findings signal convention gaps.
- **create-global-rules**: Convention updates from retros may trigger a re-run of `create-global-rules`.
- **prime-for-feature**: Pattern gaps found in retros improve future priming passes.

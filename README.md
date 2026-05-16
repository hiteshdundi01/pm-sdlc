# pm-sdlc

**Turn AI coding assistants into disciplined engineering partners.**

pm-sdlc is a framework of 11 structured workflows that guide AI assistants through the complete software development lifecycle — from ideation to code review to retrospective. No runtime, no dependencies, no build step. Just markdown files that make AI actually useful for serious engineering work.

## Why This Exists

AI coding assistants are powerful but undisciplined. Without structure, they:
- Generate plausible code that doesn't match your codebase patterns
- Say "LGTM" to everything instead of pushing back on weak ideas  
- Skip validation, invent APIs, and rubber-stamp reviews
- Build what sounds good instead of what's actually needed

pm-sdlc fixes this by giving AI assistants **opinionated, battle-tested workflows** with built-in quality gates, anti-sycophancy guards, and codebase grounding requirements.

## The Workflow Chain

Workflows are designed to be used in sequence. Each one's output feeds into the next:

```
  ideate ──→ create-prd ──→ create-stories
                                    │
                    prime-for-feature
                          │
                    plan-feature ⇄ critique-plan
                          │
                  implement-feature
                          │
                     validate ──→ code-review
                                      │
                                retrospective
```

`create-global-rules` runs standalone to bootstrap project conventions.

## Workflows

| # | Workflow | What It Does | Key Feature |
|---|----------|-------------|-------------|
| 1 | **ideate** | Refines raw ideas through divergent/convergent thinking | SCAMPER, HMW, JTBD frameworks; explicit "Not Doing" list |
| 2 | **create-prd** | Generates Product Requirements Documents | 15-section template with implementation phases |
| 3 | **create-stories** | Breaks PRDs into actionable stories | Direct Jira integration via MCP — creates issues, links dependencies |
| 4 | **prime-for-feature** | Loads codebase + task context | Reconciles Jira ACs against PRD, proposes updates |
| 5 | **plan-feature** | Creates implementation plans grounded in actual code | Every pattern reference requires `file:line` citation from real code |
| 6 | **critique-plan** | Audits plans for bloat and scope creep | Rationalization scanner: "for testability" → name the test |
| 7 | **implement-feature** | Executes plans with validation loops | Hard E2E gate — can't report done until tests actually pass |
| 8 | **code-review** | 5-axis PR review with isolated validation | Read-only safety via git worktrees; never touches your working tree |
| 9 | **create-global-rules** | Generates AGENTS.md from codebase analysis | Discover-first: every rule comes from actual code, not assumptions |
| 10 | **validate** | Runs linter, type checker, and tests | Auto-detects project toolchain; structured pass/fail report |
| 11 | **retrospective** | Captures lessons learned after shipping | Every retro produces at least one concrete convention update |

## Quick Start

### Option 1: Install Script

```bash
# Clone the framework
git clone https://github.com/hiteshdundi01/pm-sdlc.git
cd pm-sdlc

# Install into your project (interactive — picks your AI tool)
./install.sh /path/to/your/project
```

The install script will ask which tool you use and set up the right directory structure.

### Option 2: Manual Setup

<details>
<summary><b>Claude Code</b></summary>

```bash
# From your project root:
mkdir -p .claude/commands .claude/reference

# Copy workflows (exclude the README)
for f in /path/to/pm-sdlc/workflows/*.md; do
  [ "$(basename "$f")" = "README.md" ] && continue
  cp "$f" .claude/commands/
done

# Copy reference docs
cp /path/to/pm-sdlc/reference/*.md .claude/reference/

# Add to .gitignore
echo '.agents/' >> .gitignore
```

Then use workflows as slash commands: `/ideate`, `/plan-feature`, `/code-review`, etc.

</details>

<details>
<summary><b>Antigravity (Gemini)</b></summary>

```bash
# From your project root:
SKILL_DIR=".gemini/antigravity/skills/pm-sdlc"
mkdir -p "$SKILL_DIR/reference"

# Copy workflows as individual skill files
for f in /path/to/pm-sdlc/workflows/*.md; do
  name=$(basename "$f" .md)
  skill_path="$SKILL_DIR/$name"
  mkdir -p "$skill_path"
  cp "$f" "$skill_path/SKILL.md"
done

# Copy reference docs
cp /path/to/pm-sdlc/reference/*.md "$SKILL_DIR/reference/"

# Add to .gitignore
echo '.agents/' >> .gitignore
```

</details>

<details>
<summary><b>OpenAI Codex</b></summary>

```bash
# From your project root:
mkdir -p .agents/workflows .agents/reference

# Copy workflows (exclude the README)
for f in /path/to/pm-sdlc/workflows/*.md; do
  [ "$(basename "$f")" = "README.md" ] && continue
  cp "$f" .agents/workflows/
done

# Copy reference docs  
cp /path/to/pm-sdlc/reference/*.md .agents/reference/

# Copy AGENTS.md to project root
cp /path/to/pm-sdlc/AGENTS.md ./

# Add runtime artifacts to .gitignore
echo '.agents/plans/' >> .gitignore
echo '.agents/reviews/' >> .gitignore
echo '.agents/stories/' >> .gitignore
echo '.agents/ideas/' >> .gitignore
echo '.agents/PRDs/' >> .gitignore
echo '.agents/reports/' >> .gitignore
```

Reference workflows in your `AGENTS.md` or use them as context when prompting.

</details>

## What Makes This Different

### Anti-Sycophancy by Design

Most AI workflows produce "LGTM" responses. pm-sdlc workflows actively push back:

- **critique-plan** has a rationalization scanner that flags phrases like "for testability" and demands you name the actual test
- **code-review** lists anti-patterns like "It works, that's good enough" with concrete rebuttals
- **ideate** requires the AI to "push back on weak ideas with specificity and kindness"

### Codebase Grounding

Plans aren't generic — they're rooted in your actual code:

```markdown
### Patterns to Follow

### Error Handling
```typescript
// SOURCE: src/services/client-service.ts:45-52
try {
  const result = await db.query(sql);
  return { success: true, data: result };
} catch (error) {
  logger.error('Client query failed', { error: sanitize(error) });
  throw new ServiceError('CLIENT_QUERY_FAILED', error);
}
```
```

Every pattern reference in a plan must include a `file:line` citation from the actual codebase. No invented patterns.

### Validation Gates

Workflows don't trust that things work — they verify:

- `implement-feature` runs type checking, linting, and tests after **every single task**
- `code-review` runs validation in an **isolated git worktree** to avoid contaminating your work
- `create-stories` validates project and epic existence in Jira before creating issues

## Reference Documents

Workflows load these at runtime for domain-specific knowledge:

| Document | Purpose |
|----------|---------|
| **frameworks.md** | 7 ideation frameworks: SCAMPER, How Might We, First Principles, Jobs to Be Done, Constraint-Based, Pre-mortem, Analogous Inspiration |
| **refinement-criteria.md** | Evaluation rubric: User Value (painkiller vs vitamin), Feasibility, Differentiation + Assumption Audit framework |
| **review-standards.md** | 5-axis review (Correctness, Readability, Architecture, Security, Performance) + severity conventions + rationalization anti-patterns |
| **examples.md** | Real ideation session examples with analysis of what made them effective |
| **tool-capabilities.md** | Maps capability language to Claude Code, Antigravity, and Codex tool APIs |

## Jira Integration

Workflows that integrate with Jira (via Atlassian MCP):

- **create-stories** → Creates issues, sets priority/labels, links to epics, adds dependency links
- **prime-for-feature** → Fetches issues, reconciles acceptance criteria against PRD
- **implement-feature** → Transitions issues, adds implementation comments

Requires the [Atlassian MCP server](https://www.npmjs.com/package/@anthropic/atlassian-mcp-server) to be configured.

## Examples

The [`examples/`](examples/) directory contains realistic workflow outputs:

| Example | Workflow | What It Shows |
|---------|----------|---------------|
| [Ideation Session](examples/ideation-session.md) | `ideate` | HMW framing, variations, stress testing, "Not Doing" list |
| [Implementation Plan](examples/implementation-plan.md) | `plan-feature` | `file:line` citations, pattern table, ordered tasks |
| [Plan Critique](examples/plan-critique.md) | `critique-plan` | 7-axis audit, minimum-viable diff, CUT/CHANGE/ADD |
| [Code Review](examples/code-review-report.md) | `code-review` | 5-axis review, plan conformance, validation results |

## Documentation

| Document | Purpose |
|----------|---------|
| [Workflow Guide](docs/workflow-guide.md) | How each workflow connects — inputs, outputs, handoffs |
| [Best Practices](docs/best-practices.md) | Tips, common pitfalls, effectiveness metrics |
| [FAQ](docs/faq.md) | Common questions about installation, usage, and troubleshooting |

## Project Structure

```
pm-sdlc/
├── workflows/              # 11 canonical workflow definitions
│   ├── ideate.md
│   ├── create-prd.md
│   ├── create-stories.md
│   ├── prime-for-feature.md
│   ├── plan-feature.md
│   ├── critique-plan.md
│   ├── implement-feature.md
│   ├── code-review.md
│   ├── create-global-rules.md
│   ├── validate.md
│   └── retrospective.md
├── reference/              # Supporting documents loaded by workflows
│   ├── frameworks.md
│   ├── refinement-criteria.md
│   ├── review-standards.md
│   ├── examples.md
│   └── tool-capabilities.md
├── examples/               # Real-world workflow output examples
├── docs/                   # Extended documentation
│   ├── workflow-guide.md
│   ├── best-practices.md
│   └── faq.md
├── setup/                  # Per-tool installation guides
│   ├── claude-code/
│   ├── antigravity/
│   └── codex/
├── .github/workflows/      # CI: markdown lint, link check, install test, workflow check
├── scripts/                # CI scripts
│   └── check-workflows.sh  # Validates workflow structure and tool-agnostic compliance
├── install.sh              # One-command setup for any project
├── AGENTS.md               # For Codex/generic AI agents
├── CLAUDE.md               # For Claude Code (project rules)
├── CODEBASE-GUIDE.md       # Architecture guide for contributors
├── CONTRIBUTING.md         # How to contribute
├── CHANGELOG.md            # Version history
└── LICENSE                 # MIT
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). The short version:

1. Fork and branch from `main`
2. Follow the [workflow file conventions](CONTRIBUTING.md#workflow-file-structure)
3. Test against a real codebase
4. Open a PR with a clear description

## License

MIT — see [LICENSE](LICENSE).

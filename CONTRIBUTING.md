# Contributing to pm-sdlc

Thank you for your interest in improving the AI-powered SDLC framework. This document explains how to contribute effectively.

## How to Contribute

### Reporting Issues

- **Bug reports**: Describe the workflow, the input you provided, the expected behavior, and the actual behavior. Include the AI tool you're using (Claude Code, Codex, Antigravity).
- **Enhancement requests**: Describe the problem you're trying to solve, not just the solution you want. Reference specific workflows if applicable.
- **New workflow proposals**: Open a discussion first. Explain the gap in the current lifecycle and how the new workflow fits between existing ones.

### Pull Requests

1. Fork the repo and create a branch from `main`
2. Make your changes following the conventions below
3. Test your workflow changes against a real codebase (see [Testing](#testing-workflows))
4. Update the CHANGELOG.md under `[Unreleased]`
5. Open a PR with a clear description of what changed and why

## Conventions

### Workflow File Structure

Every workflow file follows this pattern:

```markdown
---
name: workflow-name
description: One-line description of when to use this workflow.
argument-hint: <required-arg> [--optional-flag]
---

# Workflow Title

{Brief description of purpose and philosophy}

## When to use this skill
{Bullet list of trigger conditions}

## How to use it

### Phase N: NAME — Description
{Ordered phases with clear gates between them}

## Absolute Constraints
{Non-negotiable rules — things the workflow must NEVER do}

## Integration Points
{How this workflow connects to other workflows and external tools}
```

### Writing Principles

- **Discover, don't invent.** Workflows should ground themselves in actual codebase analysis, not assumed patterns.
- **Gate, don't hope.** Each phase should have explicit conditions that must be met before proceeding.
- **Anti-sycophancy by default.** Workflows should push back on weak inputs, not rubber-stamp them.
- **Tool-agnostic content.** Write workflows for AI assistants in general. Tool-specific details go in `setup/`.

### File Naming

- Workflow files: `kebab-case.md`
- Reference documents: `kebab-case.md`
- Setup guides: `README.md` within tool-specific directories

### Reference Documents

Reference documents live in `reference/` and are loaded by workflows at runtime. They should be:
- Scannable (tables, bullet lists, clear headings)
- Actionable (tell the AI what to *do*, not what something *is*)
- Self-contained (no dependencies on other reference docs)

### Commit Messages

Use conventional commits:

```
feat: add retrospective workflow
fix: correct file path in critique-plan reference loading
docs: update README quick start section
refactor: simplify code-review worktree setup
```

## Testing Workflows

There's no automated test suite (yet). To validate a workflow change:

1. **Pick a real codebase** — don't test against toy projects
2. **Run the workflow end-to-end** with your AI tool of choice
3. **Check the output** against the workflow's documented structure and constraints
4. **Verify integration** — does the output work as input to the next workflow in the chain?

### Workflow Chain

Test changes in context of the full lifecycle:

```
ideate → create-prd → create-stories → prime-for-feature → plan-feature → critique-plan → implement-feature → code-review
```

If you change `plan-feature`, verify that its output still works as input to both `critique-plan` and `implement-feature`.

## Architecture Decisions

### Why YAML Frontmatter?

The YAML frontmatter (`name`, `description`, `argument-hint`) was originally for Claude Code's slash-command system, but it serves as useful metadata for any tool. Other tools can ignore it or parse it for their own purposes.

### Why `.agents/` for Runtime Artifacts?

Workflows generate artifacts (plans, reviews, stories, reports) that are project-specific and should not be committed. The `.agents/` directory is gitignored by convention. This keeps workflow outputs close to the code they describe without polluting version control.

### Why No Templating Engine?

The workflows are pure markdown — no Jinja, no Handlebars, no variable interpolation. This is intentional. AI assistants read markdown natively and adapt based on context. Templating engines add complexity without adding value for this use case.

## Code of Conduct

Be constructive, be specific, be kind. The same principles that make a good code review make a good contribution.

## License

By contributing, you agree that your contributions will be licensed under the [MIT License](LICENSE).

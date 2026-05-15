# pm-sdlc Project Rules

> These rules govern contributions to the pm-sdlc framework itself. For using the framework in your own projects, see the [setup guides](setup/).

## Project Overview

pm-sdlc is a collection of structured AI workflows and reference documents that implement a complete software development lifecycle. The workflows are tool-agnostic markdown files consumed by AI coding assistants.

## Tech Stack

| Technology | Purpose |
|-----------|---------|
| Markdown | Workflow definitions, reference docs, all content |
| YAML frontmatter | Workflow metadata (name, description, argument-hint) |
| Mermaid | Diagrams in documentation |
| Shell (bash) | Install script and setup automation |

## Directory Structure

```
workflows/          # Canonical workflow definitions (source of truth)
reference/          # Supporting reference documents loaded by workflows
setup/              # Tool-specific installation guides and scripts
  claude-code/      # Claude Code setup
  antigravity/      # Antigravity (Gemini) setup
  codex/            # OpenAI Codex setup
docs/               # Extended documentation
.agents/            # Runtime artifacts (gitignored)
```

## Commands

```bash
# Install into a project
./install.sh

# Validate markdown (if markdownlint is installed)
npx markdownlint-cli2 "**/*.md" "#node_modules"
```

## Conventions

### Workflow Files

- Every workflow MUST have YAML frontmatter with `name` and `description`
- Every workflow MUST have "When to use this skill" and "Absolute Constraints" sections
- Phases are numbered and named: `### Phase N: NAME — Description`
- Gates between phases are marked with `> **GATE:**` blockquotes
- File references use `file:line` format: `src/utils.ts:15-30`

### Reference Documents

- Live in `reference/`, not inline in workflows
- Are self-contained — no cross-references between reference docs
- Use tables for structured data, bullet lists for conventions

### Writing Style

- Imperative mood for instructions ("Read the file", not "You should read the file")
- Concrete over abstract ("Check `package.json` scripts" not "Verify build configuration")
- Anti-patterns explicitly named and explained
- No filler phrases ("Note that", "It should be noted", "Please be aware")

### Git Workflow

- Branch from `main`
- Branch names: `feat/`, `fix/`, `docs/`, `refactor/` prefixes
- Conventional commit messages
- Rebase before merge (linear history)
- No merge commits in feature branches

## Hard Rules

1. **NEVER add tool-specific logic to workflow files** — tool integration goes in `setup/`
2. **NEVER reference absolute paths** — all paths are relative to project root
3. **NEVER add dependencies** — this is a pure-markdown framework with one shell script
4. **NEVER merge without reviewing** the workflow chain integration (does the output of one workflow still work as input to the next?)
5. **Preserve all existing YAML frontmatter** when editing workflow files

---
name: create-global-rules
description: Generates an AGENTS.md file by analyzing the codebase for project type, tech stack, directory structure, patterns, and conventions. Use when the user asks to create global rules, generate an AGENTS.md, bootstrap project context, or set up agent guidance for a repository.
---

# Create Global Rules from Codebase Analysis

Analyzes a codebase end-to-end and produces an `AGENTS.md` file at the project root — the canonical context document that gives Antigravity (and any other coding agent) everything it needs to work effectively in the repository.

**Core Principle**: DISCOVER FIRST — every rule, pattern, and convention in the output must come from actual codebase analysis, not assumptions. If something can't be verified, omit it.

## When to use this skill

- The user asks to "create global rules", "generate AGENTS.md", or "bootstrap project context".
- The user opens a new project and asks for agent setup or guidance initialization.
- The user says "create something like CLAUDE.md" or references project-level agent instructions.
- A workspace has no `AGENTS.md` and the user wants one generated from the codebase.

## How to use it

### Phase 1: DISCOVER — Identify Project Type & Configuration

#### 1.1 Detect Project Type

List the workspace root and scan for type indicators:

| Type | Indicators |
|------|------------|
| Web App (Full-stack) | Separate `client`/`server` dirs, API routes, frontend + backend code |
| Web App (Frontend) | React/Vue/Svelte, no server code |
| API/Backend | Express/Fastify/Hono/etc, no frontend |
| Library/Package | `main`/`exports` in `package.json`, publishable config |
| CLI Tool | `bin` in `package.json`, command-line interface |
| Monorepo | Multiple packages, workspace config (`pnpm-workspace.yaml`, `lerna.json`, `turbo.json`) |
| Rust Project | `Cargo.toml`, `src/main.rs` or `src/lib.rs` |
| Python Project | `pyproject.toml`, `setup.py`, `requirements.txt` |
| Multi-language | Mix of the above |
| Script/Automation | Standalone scripts, task-focused, no package structure |

#### 1.2 Analyze Configuration

Read root configuration files to extract tech stack and project metadata:

- `package.json` → dependencies, scripts, type, workspaces
- `tsconfig.json` / `tsconfig.*.json` → TypeScript settings, path aliases
- `Cargo.toml` → Rust dependencies, features, workspace members
- `pyproject.toml` / `setup.py` → Python dependencies, build system
- `vite.config.*` / `next.config.*` / `webpack.config.*` → Build tool
- `docker-compose.yml` / `Dockerfile` → Containerization
- `*.config.js/ts` → Linting, formatting, testing tool configs
- `.env.example` / `.env.local` → Environment variables

#### 1.3 Map Directory Structure

List the directory tree recursively (1–2 levels deep) to understand the codebase layout:

- Where does source code live?
- Where are tests? (co-located, separate `tests/` dir, `__tests__/`)
- Is there shared/common code?
- Where are database schemas/migrations?
- Where is configuration vs. application code?

### Phase 2: ANALYZE — Extract Patterns & Conventions

#### 2.1 Extract Tech Stack

From manifests and config files, build a complete technology inventory:

- **Runtime/Language**: Node.js, Bun, Deno, Rust, Python, browser-only
- **Framework(s)**: Express, Next.js, Vite, Actix, FastAPI, etc.
- **Database**: PostgreSQL, SQLite, MongoDB, Drizzle/Prisma/SQLx ORM
- **Testing**: Vitest, Jest, pytest, Cargo test
- **Build tools**: TSC, Vite, esbuild, Cargo
- **Linting/Formatting**: ESLint, Prettier, Clippy, Ruff

#### 2.2 Identify Code Patterns

Study 3-5 representative source files to extract patterns:

- **Naming**: How are files named? (`kebab-case.ts`, `PascalCase.tsx`, `snake_case.rs`). How are functions, classes, types, and variables named?
- **File structure**: How is code organized within files? (imports → types → implementation → exports)
- **Error handling**: Custom error classes? Result types? Try/catch patterns?
- **Type definitions**: Where do types/interfaces live? Inline, co-located, or centralized?
- **API patterns**: REST routes, middleware, request/response shapes
- **State management**: How is application state managed?

#### 2.3 Identify Test Patterns

Look at 2-3 existing test files to understand:

- Test file naming convention (`*.test.ts`, `*.spec.ts`, `*_test.rs`)
- Test structure (describe/it, test functions, #[test])
- Assertion style
- Mocking/fixture patterns
- Test runner configuration

#### 2.4 Extract Commands

Read `package.json` scripts, `Makefile`, `Cargo.toml`, `justfile`, or equivalent to identify:

- Dev server command
- Build command
- Test command (unit, integration, e2e)
- Lint/format command
- Any custom scripts (migrations, seeding, etc.)

#### 2.5 Identify Key Files

Locate and note files that are critical to understanding the project:

- Entry points (`src/main.ts`, `src/index.ts`, `src/main.rs`, `app.py`)
- Core configuration
- Database schema/migrations
- Shared utilities and types
- Domain/business logic entry points
- CI/CD configuration

### Phase 3: GENERATE — Write AGENTS.md

#### 3.1 Check for Existing File

Before writing, check if an `AGENTS.md` already exists at the workspace root:

- **If it exists**: Ask the user whether to overwrite or merge. Do NOT overwrite without confirmation.
- **If it does not exist**: Proceed with creation.

#### 3.2 Check for Template

Look for a template file at `.agents/AGENTS-template.md` in the workspace. If found, use it as the structural starting point and fill in discovered values. If not found, use the built-in template structure below.

#### 3.3 Write the File

Create `AGENTS.md` at the workspace root.

**Adapt to the project:**
- Remove sections that don't apply (e.g., no "Database" section if there's no DB)
- Add sections specific to this project type (e.g., "Component Patterns" for frontends, "API Endpoints" for backends)
- Keep it concise and scannable — focus on what's actionable

**Required sections:**

1. **Project Overview** — What is this and what does it do? (1 paragraph max)
2. **Tech Stack** — Table of technologies and their purposes
3. **Commands** — Code block with dev, build, test, lint commands
4. **Architecture** — Directory tree with descriptions + data flow explanation
5. **Code Patterns** — Naming, file organization, error handling conventions
6. **Testing** — How to run tests, where they live, what patterns to follow
7. **Key Files** — Table of important files and their purposes

**Optional sections (add only if relevant):**

- **Validation** — Pre-commit commands
- **API Patterns** — Route conventions, middleware, auth (for backends)
- **Component Patterns** — Component structure, props, styling (for frontends)
- **Database Patterns** — Migration workflow, ORM usage, schema conventions
- **On-Demand Context** — Links to deeper reference docs
- **Notes** — Gotchas, constraints, special instructions

**Style rules:**
- Use tables for structured data (tech stack, key files)
- Use code blocks for commands and directory trees
- Use bullet lists for conventions and patterns
- Keep each section to 5-15 lines
- Use horizontal rules (`---`) between major sections

### Phase 4: OUTPUT — Report to User

After creating the file, provide a concise summary:

```
## Global Rules Created

**File**: `AGENTS.md`

### Project Type
{Detected project type}

### Tech Stack Summary
{Key technologies in a quick list}

### Structure
{Brief structure overview — 2-3 sentences}

### Next Steps
1. Review the generated `AGENTS.md`
2. Add any project-specific notes or constraints
3. Remove any sections that don't apply
4. Optionally create reference docs for deeper context and link them in the "On-Demand Context" section
```

## Absolute Constraints

1. **NEVER invent patterns** — every convention documented must come from actual codebase files. If you can't find a pattern, leave the section out rather than guessing.
2. **NEVER guess commands** — always check `package.json`, `Makefile`, `Cargo.toml`, or equivalent for actual commands. If a command doesn't exist, don't list it.
3. **NEVER overwrite without asking** — if `AGENTS.md` already exists, confirm with the user first.
4. **Keep it scannable** — the output should be useful at a glance. No walls of text.
5. **Focus on the actionable** — rules should tell an agent what to DO, not describe the project's history.

## Integration Points

- **Knowledge Base**: If your environment provides a persistent knowledge store (e.g., knowledge items, memory, or context files), check it for existing project-specific context (startup scripts, service architecture, known gotchas) and incorporate relevant details. See `reference/tool-capabilities.md` for your environment's specifics.
- **Existing Convention Files**: If `CONTRIBUTING.md`, `ARCHITECTURE.md`, or similar docs exist, reference them in the "On-Demand Context" section rather than duplicating their content.
- **Workspace Skills**: If `.agents/skills/` exists with workspace-specific skills, mention them in AGENTS.md so agents know to check there.
- **PRDs**: If `.agents/PRDs/` exists, mention it as context for understanding project direction.

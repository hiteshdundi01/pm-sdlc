---
name: prime-for-feature
description: Primes the agent with a comprehensive understanding of the current codebase and feature context by analyzing project structure, key files, conventions, and optionally fetching Jira issues or Confluence pages. Use this skill when starting a new complex task, beginning feature work, or when explicitly instructed to prime the context.
---

# Prime for Feature: Load Project & Task Context

This skill instructs the agent to build a comprehensive, workspace-aware understanding of the codebase and the specific feature or task at hand. It combines structural analysis, convention discovery, and external task context from Atlassian tools into a single priming pass.

## When to use this skill

- When you first start working on a major new feature or a complex task in **any** project.
- When the user explicitly asks you to "prime for feature", "prime the codebase", or load project context.
- When you need to understand the project conventions, architecture, and current state before proceeding with implementation.
- When the user provides Jira issue keys or Confluence page IDs to establish task context.

## How to use it

### Step 0: Load External Context (If provided)

If the user provides Jira issue keys (e.g., `ANP0-5`) or Confluence page IDs:

1. Call `mcp_atlassian-mcp-server_getAccessibleAtlassianResources` to get the `cloudId`.
2. **If Jira issues are provided:**
   - For each issue key, call `mcp_atlassian-mcp-server_getJiraIssue` with `responseContentFormat: "markdown"` to fetch the issue summary, description, acceptance criteria, comments, and any other relevant context.
   - Check for linked issues (parent epics, blockers, related stories) to understand dependencies.
   - Use this context to inform your understanding of what work is expected.
3. **If Confluence page IDs are provided:**
   - For each page ID, call `mcp_atlassian-mcp-server_getConfluencePage` with `contentFormat: "markdown"` to fetch the page content.
   - Use this context as additional background for understanding the project requirements or architecture.

### Step 1: Discover Project Conventions

1. Scan the workspace root for convention and guidance files. Check for any of the following (order of priority):
   - `CLAUDE.md`, `AGENTS.md`, `CODEBASE-GUIDE.md`, `CONTRIBUTING.md`, `ARCHITECTURE.md`
   - `.agents/` directory for workspace-specific skills or instructions
   - `docs/` or `documentation/` directories for architectural docs
2. Read the most relevant convention files to understand established patterns, naming conventions, and architectural decisions.

### Step 2: Analyze the Codebase Structure

1. List the top-level project directory to map the project layout.
2. Read `package.json`, `Cargo.toml`, `pyproject.toml`, or equivalent manifest files to understand:
   - The tech stack and dependencies
   - Available scripts and commands
   - Monorepo structure (workspaces, packages)
3. Study the relevant feature slices (e.g., `src/features/`, `src/app/`, `packages/`, or main source directories) to map out the application structure.
4. Identify the data model by scanning for schema files, migration directories, or ORM model definitions.

### Step 3: Understand Current State

1. Check recent commits by running `git log --oneline -10` to understand the current state of the working branch.
2. Run `git status` to identify any in-progress work.
3. Check for existing Knowledge Items (KIs) in the Antigravity knowledge base that relate to this project.

### Step 4: Reconcile Jira ACs Against the PRD (If Jira context was loaded)

If Step 0 loaded one or more Jira issues **and** the project has a PRD (typically found in `.agents/`, `.agents/PRDs/`, or a `prd.md` / `*_prd.md` file):

1. **Locate the PRD** — scan the workspace for the authoritative PRD file. If multiple candidates exist, prefer the one scoped to the current feature or phase.
2. **Extract PRD requirements** — identify the specific functional requirements, acceptance criteria, constraints, and scope boundaries defined in the PRD that map to each loaded Jira issue.
3. **Diff against Jira ACs** — for each Jira issue, compare its current acceptance criteria against the PRD requirements:
   - **Missing ACs**: Requirements in the PRD that have no corresponding AC on the Jira issue.
   - **Stale ACs**: ACs on the Jira issue that contradict or no longer align with the PRD (e.g., scope was trimmed, approach changed).
   - **Scope drift**: ACs that go beyond what the PRD specifies (gold-plating or scope creep).
4. **Propose updates** — if any gaps are found, present the user with a clear summary:
   - Which issue(s) need AC updates.
   - The specific ACs to add, remove, or revise, with rationale tied to PRD sections.
   - Ask the user for confirmation before making any changes.
5. **Apply updates (on confirmation)** — if the user approves, call `mcp_atlassian-mcp-server_editJiraIssue` to update the issue description with the revised acceptance criteria. Preserve all other description content; only modify the AC section.

## Output

Produce a scannable summary for the user of what you learned:

- **Project Purpose**: One sentence
- **Tech Stack**:
  - Frontend: framework, UI library, state management
  - Backend: framework, database, validation
  - Infrastructure: containerization, CI/CD, deployment
- **Data Model**: Core entities and relationships
- **Key Patterns**: Database access, API design, state management, error handling, routing, validation
- **Conventions**: Naming, file organization, testing approach
- **Current State**: Recent commits, current branch, any in-progress work
- **Task Context** *(if Jira/Confluence was loaded)*: Summary of the assigned work, acceptance criteria, and dependencies
- **AC Reconciliation** *(if Jira + PRD were both loaded)*: Summary of any gaps found between the PRD and current Jira ACs, with proposed updates (or confirmation that ACs are aligned)

Format the output using bullet points and keep it concise.

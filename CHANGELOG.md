# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-05-15

### Added

- **11 interconnected SDLC workflows** covering the full product development lifecycle:
  - `ideate` — Divergent/convergent idea refinement with SCAMPER, HMW, JTBD frameworks
  - `create-prd` — Generate comprehensive Product Requirements Documents
  - `create-stories` — PRD → Jira stories with full MCP integration
  - `prime-for-feature` — Load codebase + Jira/Confluence context with AC reconciliation
  - `plan-feature` — Codebase-aware implementation planning with `file:line` citations
  - `critique-plan` — Audit plans for scope creep, YAGNI, and rationalization anti-patterns
  - `implement-feature` — Execute plans with validation loops and E2E gates
  - `code-review` — 5-axis PR review with isolated worktree validation
  - `create-global-rules` — Generate AGENTS.md from codebase analysis
  - `validate` — Run linter, type checker, and tests with structured reporting
  - `retrospective` — Capture lessons learned and feed back into project conventions
- **Reference documents**: ideation frameworks, refinement criteria, review standards, real session examples
- **Tool-agnostic structure** with setup support for Claude Code, OpenAI Codex, and Antigravity
- **Install script** (`install.sh`) for one-command project setup
- **Real-world examples**: ideation session, implementation plan, plan critique, code review report
- **Documentation**: workflow guide, best practices, FAQ
- Open-source packaging: README, LICENSE (MIT), CONTRIBUTING guide

## [0.1.0] - 2026-05-14

### Added

- Initial workflow definitions under `.claude/commands/`
- Framework and reference document drafts

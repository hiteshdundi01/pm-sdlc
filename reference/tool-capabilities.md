# Tool Capabilities Reference

Workflows describe **capabilities** (what to do), not **tool names** (how to do it). This reference maps capability language to each AI tool's specific APIs.

## File Operations

| Capability | Claude Code | Antigravity (Gemini) | OpenAI Codex |
|-----------|-------------|---------------------|--------------|
| Read a file | `View` tool or `cat` | `view_file` | `cat` / built-in file read |
| Search files for patterns | `Grep` / `rg` / `grep` | `grep_search` | `grep` / `rg` |
| List directory contents | `ls` / `Bash` | `list_dir` | `ls` / built-in listing |
| Create a file | `Write` tool | `write_to_file` | Built-in file creation |
| Edit a file | `Edit` tool | `replace_file_content` / `multi_replace_file_content` | Built-in file edit |
| Run a shell command | `Bash` tool | `run_command` | Sandbox shell |

## Jira / Atlassian Operations

Requires the Atlassian MCP server. Tool name prefixes vary by environment:

| Capability | MCP Tool (typical) | Notes |
|-----------|-------------------|-------|
| Get cloud ID | `getAccessibleAtlassianResources` | Required for all Jira calls |
| Get a Jira issue | `getJiraIssue` | Use `responseContentFormat: "markdown"` |
| Create a Jira issue | `createJiraIssue` | Requires cloudId, projectKey, issueTypeName, summary |
| Edit a Jira issue | `editJiraIssue` | Update fields on existing issue |
| Search issues (JQL) | `searchJiraIssuesUsingJql` | For querying issues by filter |
| Get issue transitions | `getTransitionsForJiraIssue` | Returns available status transitions |
| Transition an issue | `transitionJiraIssue` | Use numeric transition ID, not status name |
| Add a comment | `addCommentToJiraIssue` | Use `contentFormat: "markdown"` |
| Link two issues | `createIssueLink` | e.g., Blocks, Relates |
| Get link types | `getIssueLinkTypes` | To discover available link types |
| Get project issue types | `getJiraProjectIssueTypesMetadata` | Story, Task, Bug, etc. |
| Search (Rovo) | `search` | Natural language search across Jira + Confluence |

**MCP tool name formats by environment:**

| Environment | Format | Example |
|-------------|--------|---------|
| Claude Code | `mcp__atlassian__toolName` | `mcp__atlassian__createJiraIssue` |
| Antigravity | `mcp_atlassian-mcp-server_toolName` | `mcp_atlassian-mcp-server_createJiraIssue` |
| Codex | Varies by configuration | Check available tools at runtime |

Workflows should describe the **operation** (e.g., "create a Jira issue") and let the agent resolve the correct tool name for its environment.

## Confluence Operations

| Capability | MCP Tool (typical) |
|-----------|-------------------|
| Get a Confluence page | `getConfluencePage` |
| Search Confluence | `search` (Rovo search covers both Jira and Confluence) |

## Git / GitHub Operations

These are standard CLI tools available in all environments:

| Capability | Command |
|-----------|---------|
| Check current branch | `git rev-parse --abbrev-ref HEAD` |
| View recent commits | `git log --oneline -N` |
| Check working tree state | `git status --porcelain` |
| Create a branch | `git checkout -b branch-name` |
| View PR diff | `gh pr diff {number}` |
| View PR metadata | `gh pr view {number} --json ...` |
| Create a PR | `gh pr create` |

## Executor Dispatch

Used by `ship-feature`. The orchestrator dispatches an implementation work order to a headless executor agent running as a shell command. Workflows say "dispatch the work order to the executor"; this table resolves the command.

| Capability | Codex CLI | Claude Code (as executor) |
|-----------|-----------|---------------------------|
| Check availability | `codex --version` | `claude --version` |
| Dispatch work order | `codex exec --sandbox workspace-write --json "<work order>"` | `claude -p "<work order>" --permission-mode acceptEdits` |
| Select model | `-m <model>` (e.g., `-m gpt-5-codex`) | `--model <model>` |
| Parse progress | `--json` emits JSONL events on stdout (commands run, files changed, agent messages) | `--output-format stream-json` emits JSONL events |
| Detect completion | Process exit; nonzero exit = failed run | Process exit; nonzero exit = failed run |

**Sandbox rules:**

- `workspace-write` (Codex) or default permissions (Claude Code) is the ceiling for dispatched work.
- Never dispatch with `--sandbox danger-full-access`, `--dangerously-skip-permissions`, or equivalent.
- The executor works only inside the project directory on the branch named in the work order.

**Model selection:** any model the executor CLI exposes is valid — the orchestrator passes the user's `--model` value through unchanged. Verify unfamiliar model names against the CLI's documentation rather than guessing.

**Work order delivery:** pass the work order as the command's prompt argument. For long work orders, write the text to a temp file and pipe it (e.g., `codex exec --sandbox workspace-write "$(cat /tmp/work-order.txt)"`).

**Merge orders:** merge dispatch uses the same command shape as implementation dispatch. If the merge must push to a remote, enable network access for that run only — Codex sandboxes block network by default in `workspace-write` (config key `sandbox_workspace_write.network_access`, settable per-run with `-c`). Local-only repositories need no network. The merge order forbids code edits; the executor aborts on conflicts.

**Timeouts:** wrap dispatch in a timeout appropriate to plan size (e.g., `timeout 30m codex exec ...`). A hung executor is a failed dispatch, not a reason to wait indefinitely.

## Wayfinding Operations

Used by `big-ideate`. The workflow describes map and ticket operations as capabilities; this table resolves them. Jira (via the Atlassian MCP server) is the primary tracker. If Jira is unavailable, use the local markdown fallback — do not silently skip mapping.

| Capability | Jira (Atlassian MCP) | Local Markdown Fallback (`.agents/maps/{map-name}/`) |
|-----------|----------------------|------------------------------------------------------|
| Create the map | `createJiraIssue` (Task or Epic), label `big-ideate:map`, body = map template | Create `map.md`, body = map template |
| Create a ticket | `createJiraIssue` with the map as parent/epic, label `big-ideate:<type>` | Create `tickets/{NNN}-{slug}.md` with frontmatter: `type`, `status: open`, `assignee:`, `blocked-by: []` |
| Wire blocking | `createIssueLink` with the Blocks link type (`getIssueLinkTypes` to confirm the name) | List blocker filenames in the ticket's `blocked-by` frontmatter |
| Claim a ticket | `editJiraIssue` — set assignee | Set `assignee` in frontmatter |
| Query the frontier | `searchJiraIssuesUsingJql`: `parent = {MAP-KEY} AND statusCategory != Done AND assignee IS EMPTY ORDER BY created ASC`, then drop candidates whose inward Blocks links (from `getJiraIssue`) include an unresolved issue | List `tickets/*.md` where `status: open`, `assignee` empty, and every `blocked-by` entry has `status: closed` |
| Zoom a ticket | `getJiraIssue` with `responseContentFormat: "markdown"` | Read the ticket file |
| Record a resolution | `addCommentToJiraIssue` (the resolution comment), then `transitionJiraIssue` to Done (`getTransitionsForJiraIssue` for the id) | Append a `## Resolution` section, set `status: closed` |
| Update the map body | `editJiraIssue` on the map issue | Edit `map.md` |

**Naming rule:** wherever a ticket appears in text the user reads (map body, session narration), render it as its title wrapping its link — `[Choose the sync engine](url)` in Jira, `[Choose the sync engine](tickets/003-sync-engine.md)` locally — never a bare key or filename.

**Concurrency rule:** the assignee field is the claim. Check it immediately before starting work, not from a stale earlier query — another session may have claimed the ticket in between.

**Fallback file layout:**

```text
.agents/maps/{map-name}/
├── map.md              # Destination, Notes, Decisions so far, Not yet specified, Out of scope
└── tickets/
    ├── 001-{slug}.md   # frontmatter: type, status, assignee, blocked-by
    └── 002-{slug}.md
```

## Detecting Available Capabilities

Workflows should not assume any specific tools are available. Instead:

1. **File operations**: Every AI coding assistant can read, write, and search files. Use capability language ("read the file", "search for patterns matching X", "create the file at path Y").

2. **Jira/Atlassian**: Check if Jira tools are available before attempting to use them. If unavailable, skip Jira integration gracefully and output instructions for manual setup.

3. **Git/GitHub**: Standard CLI tools (`git`, `gh`) are generally available. If `gh` is missing, provide manual GitHub instructions.

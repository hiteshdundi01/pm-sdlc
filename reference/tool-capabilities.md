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

## Detecting Available Capabilities

Workflows should not assume any specific tools are available. Instead:

1. **File operations**: Every AI coding assistant can read, write, and search files. Use capability language ("read the file", "search for patterns matching X", "create the file at path Y").

2. **Jira/Atlassian**: Check if Jira tools are available before attempting to use them. If unavailable, skip Jira integration gracefully and output instructions for manual setup.

3. **Git/GitHub**: Standard CLI tools (`git`, `gh`) are generally available. If `gh` is missing, provide manual GitHub instructions.

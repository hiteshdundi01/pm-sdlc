# Frequently Asked Questions

## General

### What is pm-sdlc?

pm-sdlc is a collection of structured markdown workflows that guide AI coding assistants through the complete software development lifecycle. It's not a library, framework, or CLI tool — it's a set of prompts and reference documents that make AI assistants more disciplined and effective.

### Is this just prompt engineering?

It's structured prompt engineering with three key differences:
1. **Workflows are sequenced** — each one's output feeds into the next
2. **Quality gates are built in** — workflows define conditions that must be met before proceeding
3. **Codebase grounding is required** — plans must cite actual code, not invented patterns

### Do I need to use all 12 workflows?

No. Use what's relevant:
- **Quick feature work**: `prime-for-feature` → `plan-feature` → `implement-feature`
- **PR review**: `code-review` standalone
- **New project**: `create-global-rules` standalone
- **Orchestrated run**: `ship-feature` drives planning through review for you, with two approval gates
- **Full lifecycle**: Use the complete chain

### Which AI tools are supported?

- **Claude Code** — workflows install as slash commands
- **Antigravity (Gemini)** — workflows install as skills
- **OpenAI Codex** — workflows install as referenced docs with AGENTS.md

The workflows are tool-agnostic markdown. Any AI assistant that can read files can use them.

---

## Installation

### How do I install this?

```bash
git clone https://github.com/hiteshdundi01/pm-sdlc.git
cd pm-sdlc
./install.sh /path/to/your/project
```

The script asks which tool you use and sets up the right structure.

### Can I install for multiple tools at once?

Yes. Use `./install.sh /path/to/project --tool all` to set up Claude Code, Antigravity, and Codex simultaneously.

### What does the install script actually do?

It copies workflow files and reference docs to the right location for your AI tool, creates the `.agents/` runtime directory, and updates your `.gitignore`. It doesn't install any packages, modify your code, or require any runtime dependencies.

### Can I customize the workflows?

Absolutely. The installed files are just markdown — edit them to match your team's process. Common customizations:
- Adjusting severity levels in `code-review`
- Adding team-specific sections to `create-prd`
- Customizing the plan template in `plan-feature`

---

## Workflows

### What's the `.agents/` directory?

It's where workflows store their outputs (plans, reviews, stories, reports). It's gitignored by default — these are working documents, not source code.

### Why do plans need `file:line` citations?

Because AI assistants confidently invent patterns that don't exist. Requiring citations from real code forces the plan to be grounded in what your codebase actually does, not what the AI thinks it should do.

### What if I don't use Jira?

The Jira integration is optional. Workflows that mention Jira (`create-stories`, `prime-for-feature`, `implement-feature`) work fine without it — they just skip the Jira-specific steps.

### How does the code review stay read-only?

The `code-review` workflow uses git worktrees for validation. It creates a temporary worktree, runs checks there, and deletes it when done. Your working tree is never modified. It even records your starting git state and verifies it's unchanged at the end.

### What's the "rationalization scan" in critique-plan?

It's a check for common phrases that sound reasonable but often hide unnecessary complexity:
- "for testability" → name the test that needs this seam
- "for flexibility" → name the second variant that exists today
- "for separation of concerns" → name the coupling problem prevented today

If the justification is real, the phrase survives. If it's vague, it gets flagged.

---

## Troubleshooting

### The AI isn't following the workflow phases

Make sure the workflow file is being loaded correctly. For Claude Code, check that the file is in `.claude/commands/`. For Antigravity, check `.gemini/antigravity/skills/`. The AI needs to read the file, not just know its name.

### Plans are too generic / don't reference my code

Run `prime-for-feature` before `plan-feature`. Without priming, the AI doesn't know your codebase patterns and falls back to generic advice.

### Code review is modifying my working tree

The workflow explicitly prohibits this. If it's happening, the AI isn't following the constraints. Point it to the "Hard Constraint — Repo State Safety" section in the workflow file.

### Install script fails

- Make sure the target directory exists
- Make sure you have write permissions
- Check that `bash` is available (the script requires bash 4+)

---

## Contributing

### How do I add a new workflow?

See [CONTRIBUTING.md](../CONTRIBUTING.md). The short version:
1. Create `workflows/your-workflow.md` following the standard structure
2. Add setup instructions in each `setup/*/README.md`
3. Update `install.sh` to include the new file
4. Test the full chain with a real codebase
5. Open a PR

### Can I submit my workflow outputs as examples?

Yes! We'd love real-world examples. Anonymize any project-specific details and submit to the `examples/` directory.

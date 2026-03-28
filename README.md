# ai-coding

Personal AI coding workspace.
Git-tracked, symlinked into `~/.cursor/` for global availability across all projects.

## Quick Start

```bash
# One-time setup: symlink everything into ~/.cursor/
./scripts/install-global.sh

# Verify (dry run):
./scripts/install-global.sh --dry-run

# After adding new agents, skills, or references:
./scripts/install-global.sh
```

Restart Cursor after running the install script.

## What This Does

The install script creates symlinks from this directory into `~/.cursor/` so that rules, skills, agents, and reference files are available in every Cursor project.

It does **not** modify, overwrite, or replace any Cursor core files or directories.
All additions are individual symlinks placed alongside Cursor's existing files.

### Symlink Map

| Source (git-tracked) | Destination (global) | Method |
|---|---|---|
| `.cursor/rules/` | `~/.cursor/rules` | Directory symlink |
| `.cursor/skills/*/` | `~/.cursor/skills-cursor/*/` | Per-skill symlink (preserves Cursor meta-skills) |
| `.cursor/agents/*.md` | `~/.cursor/agents/*.md` | Per-file symlink (preserves existing agents) |
| `.cursor/references/` | `~/.cursor/references` | Directory symlink |
| `.cursor/projects/` | `~/.cursor/review-projects` | Directory symlink (avoids `~/.cursor/projects/` which is Cursor-internal) |

### What Is NOT Touched

These Cursor-managed paths are never modified:

- `~/.cursor/projects/` -- Cursor's workspace index
- `~/.cursor/extensions/` -- installed extensions
- `~/.cursor/mcp.json` -- MCP server config
- `~/.cursor/plans/` -- Cursor plan files
- `~/.cursor/chats/` -- conversation history
- `~/.cursor/skills-cursor/create-rule/`, `create-skill/`, `shell/`, etc. -- Cursor meta-skills

The install script uses per-file/per-directory symlinks specifically to avoid replacing directories that contain Cursor's own files.

## Directory Structure

```
ai-coding/
├── README.md                                   ← You are here
├── scripts/
│   └── install-global.sh                       # Symlinks everything into ~/.cursor/
├── plans/                                       # Saved plans (not Cursor config)
└── .cursor/
    ├── rules/                                   # Global Cursor rules
    │   ├── code-review.mdc                      # Triggers the code-review skill
    │   └── planning.mdc                         # Persist plans to plans/ directory
    ├── skills/
    │   └── code-review/                         # PR review orchestrator skill
    │       ├── SKILL.md                         # Orchestrator: gathers context, dispatches agents
    │       └── findings-format.md               # Shared severity/confidence definitions
    ├── agents/                                  # Reviewer subagents (parallel execution)
    │   ├── review-architecture.md               # Architecture & correctness (model: inherit)
    │   ├── review-react-typescript.md           # React/TS patterns (model: inherit)
    │   ├── review-security.md                   # Security (model: fast)
    │   ├── review-performance.md                # Performance (model: fast)
    │   └── review-testing.md                    # Testing & coverage (model: fast)
    ├── references/                              # Shared review checklists
    │   ├── engineering-principles.md            # DRY, KISS, YAGNI, SOLID
    │   ├── react-typescript.md                  # React/TS patterns, hooks, testing
    │   ├── security-review.md                   # Security checklist
    │   └── performance-review.md                # Performance checklist
    └── projects/                                # Project-specific review config
        └── (empty -- add per-project configs here)
```

## How Code Review Works

The code-review skill orchestrates a multi-agent PR review:

1. **Gather context** -- parse PR, fetch metadata via `gh`
2. **Triage** -- classify changed files and decide which reviewers to dispatch
3. **Dispatch** -- launch up to 5 reviewer subagents in parallel (Cursor's native Task tool)
4. **Consolidate** -- deduplicate findings across reviewers, rank by severity
5. **Report** -- produce a unified review with attributed findings

Each reviewer agent runs in its own context window with `readonly: true` (cannot modify code).
Architecture and React/TS reviewers use `model: inherit` for deep reasoning.
Security, performance, and testing reviewers use `model: fast` for speed.

Trigger with: "review this PR", "code review", or provide a GitHub PR URL.

## Adding New Content

### New rule

Add a `.mdc` file to `.cursor/rules/`.
Set `alwaysApply: true` in frontmatter if it should load on every conversation.
Re-run `install-global.sh` (rules directory is already symlinked, so new files appear automatically).

### New skill

Create a directory under `.cursor/skills/<name>/` with a `SKILL.md`.
Re-run `install-global.sh` to create the symlink in `~/.cursor/skills-cursor/`.

### New agent

Add a `.md` file to `.cursor/agents/` with YAML frontmatter (`name`, `description`, `model`, `readonly`).
Re-run `install-global.sh` to create the symlink in `~/.cursor/agents/`.

### New project config

Create a directory under `.cursor/projects/<repo-name>/` with `checklist.md` and/or `architecture-guide.md`.
The `review-projects` symlink covers the whole directory, so new projects appear automatically.

### New reference

Add a `.md` file to `.cursor/references/`.
The directory symlink covers it automatically.

## Design Principles

- **Git-tracked source of truth**: everything lives in this repo
- **Symlinks, not copies**: `install-global.sh` creates symlinks so edits propagate immediately
- **No Cursor core conflicts**: per-file symlinks into shared directories (agents, skills-cursor); directory symlinks only where the target doesn't exist yet; `~/.cursor/projects/` is explicitly avoided
- **Idempotent install**: `install-global.sh` is safe to re-run; it skips existing correct symlinks
- **Extensible**: adding new rules, skills, agents, references, or project configs follows the same pattern

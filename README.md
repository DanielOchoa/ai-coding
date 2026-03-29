# ai-coding

Personal AI coding workspace — one repo for all AI dev tooling.

Includes a **Claude Code plugin marketplace** (dev orchestrator with parallel stack-aware agents) and **Cursor tooling** (code review orchestrator with parallel reviewer agents). Claude Code ignores `.cursor/`; Cursor ignores `.claude-plugin/` and `plugins/`. Both coexist cleanly.

## Claude Code Plugin — Dev Orchestrator

A streamlined 4-phase development workflow that parallelizes stack-aware agents and biases toward action.

### Install

```bash
# From GitHub (anyone):
/plugin marketplace add DanielOchoa/ai-coding

# Local:
/plugin marketplace add /Users/danielochoa/Documents/projects/ai-coding

# Then install the plugin:
/plugin install dev@danielochoa-tools
```

After marketplace install, commands become namespaced: `/dev:dev`, `/dev:scout`, `/dev:verify`.

### Commands

| Command | Purpose |
|---------|---------|
| `/dev:dev [description]` | Full 4-phase workflow: Context → Plan → Build → Verify + Ship |
| `/dev:scout [area]` | Quick codebase exploration with stack detection |
| `/dev:verify [scope]` | Post-implementation quality check + docs + commit |

### Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| stack-detective | sonnet | Fast project detection, reads CLAUDE.md, returns structured context |
| rails-specialist | sonnet | Rails 8 code tracing — MVC, ActiveRecord, Turbo/Stimulus |
| astro-specialist | sonnet | Astro 5.x code tracing — content collections, components, SSG |
| tailwind-ui | sonnet | Tailwind CSS + frontend patterns, design system analysis |
| implementation-planner | **opus** | One decisive blueprint — files, order, tests, risks |
| bug-hunter | sonnet | Post-impl review — logic errors, edge cases (confidence >= 80) |
| convention-enforcer | sonnet | CLAUDE.md compliance checking against the diff |

### How `/dev:dev` Works

1. **Context** (~10s, parallel) — stack-detective + specialist + tailwind-ui (conditional)
2. **Plan** (~30s) — implementation-planner (opus) produces one decisive blueprint
3. **Build** (variable) — main session implements the plan, runs tests
4. **Verify + Ship** (~20s) — bug-hunter + convention-enforcer, then docs-updater + git-commit-author

### Design Principles

- **Generic agents, runtime context**: Agents have stack-level expertise but zero business-specific knowledge. All project context comes from reading CLAUDE.md at runtime. Safe for a public repo.
- **Opus for the planner, sonnet for the rest**: Maximum reasoning quality where it matters most.
- **Reference existing agents**: docs-updater and git-commit-author are invoked from `~/.claude/agents/` — updates propagate automatically.
- **4 phases, not 7**: No discovery phase, no 3-option architecture menus, no serial blocking questions.

---

## Cursor Tooling — Code Review Orchestrator

Symlinked into `~/.cursor/` for global availability across all projects.

### Quick Start

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
├── .claude-plugin/
│   └── marketplace.json                        # Plugin marketplace manifest
├── plugins/
│   └── dev/                                    # Dev orchestrator plugin
│       ├── .claude-plugin/
│       │   └── plugin.json                     # Plugin manifest
│       ├── commands/                            # Slash commands (/dev:dev, /dev:scout, /dev:verify)
│       │   ├── dev.md
│       │   ├── scout.md
│       │   └── verify.md
│       └── agents/                              # Stack-aware agents
│           ├── stack-detective.md               # Project stack detection (sonnet)
│           ├── rails-specialist.md              # Rails 8 code tracing (sonnet)
│           ├── astro-specialist.md              # Astro 5.x code tracing (sonnet)
│           ├── tailwind-ui.md                   # Tailwind/UI patterns (sonnet)
│           ├── implementation-planner.md        # Decisive blueprint (opus)
│           ├── bug-hunter.md                    # Correctness review (sonnet)
│           └── convention-enforcer.md           # CLAUDE.md compliance (sonnet)
├── scripts/
│   └── install-global.sh                       # Symlinks .cursor/ into ~/.cursor/
├── plans/                                       # Saved plans (not Cursor config)
└── .cursor/                                    # Cursor tooling (untouched by Claude Code)
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

### New Claude Code plugin

Create a directory under `plugins/<name>/` with `.claude-plugin/plugin.json`, `commands/`, and/or `agents/`.
Add an entry to `.claude-plugin/marketplace.json` under `plugins[]`.
After pushing, anyone can install with `/plugin install <name>@danielochoa-tools`.

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

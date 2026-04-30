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
/plugin marketplace add <path-to-repo>/ai-coding

# Then install the plugin:
/plugin install dev@ai-coding
```

After marketplace install, commands become namespaced: `/dev:run`, `/dev:scout`, `/dev:verify`.

### Commands

| Command | Purpose |
|---------|---------|
| `/dev:run [description]` | Full 4-phase workflow: Context → Plan → Build → Verify + Ship |
| `/dev:scout [area]` | Quick codebase exploration with stack detection |
| `/dev:verify [scope]` | Post-implementation quality check + docs + commit |

### Agents

| Agent | Model | Purpose |
|-------|-------|---------|
| stack-detective | sonnet | Fast project detection, reads CLAUDE.md, returns structured context |
| rails-specialist | sonnet | Rails 8 code tracing — MVC, ActiveRecord, Turbo/Stimulus |
| astro-specialist | sonnet | Astro 5.x code tracing — content collections, components, SSG |
| code-tracer | sonnet | Generic code path tracer — adapts to any stack as specialist fallback |
| tailwind-ui | sonnet | Tailwind CSS + frontend patterns, design system analysis |
| implementation-planner | **opus** | One decisive blueprint — files, order, tests, risks |
| bug-hunter | **opus** | Post-impl review — logic errors, edge cases (confidence >= 80) |
| convention-enforcer | sonnet | CLAUDE.md compliance checking against the diff |

### How `/dev:run` Works

1. **Context** (~10s, parallel) — stack-detective + specialist + tailwind-ui (conditional)
2. **Plan** (~30s) — implementation-planner (opus) produces one decisive blueprint
3. **Build** (variable) — main session implements the plan, runs tests
4. **Verify + Ship** (~20s) — bug-hunter + convention-enforcer, then docs-updater + git-commit-author

### Design Principles

- **Generic agents, runtime context**: Agents have stack-level expertise but zero business-specific knowledge. All project context comes from reading CLAUDE.md at runtime. Safe for a public repo.
- **Opus where reasoning matters**: Planner and bug-hunter run on opus; the rest run on sonnet for speed.
- **Reference existing agents**: docs-updater and git-commit-author are invoked from `~/.claude/agents/` — updates propagate automatically.
- **4 phases, not 7**: No discovery phase, no 3-option architecture menus, no serial blocking questions.

### Future Work

Potential improvements to explore once the current orchestrator-worker pattern has been stress-tested across more projects.

| Idea | What | Why |
|------|------|-----|
| **Agent Teams for Phase 3** | Use Claude Code's experimental [Agent Teams](https://code.claude.com/docs/en/agent-teams) (`CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1`) during the Build phase. Teammates get their own context windows, a shared task list, and peer-to-peer messaging. | Enables true parallel implementation across multiple files instead of sequential single-session builds. |
| **Hierarchical decomposition** | Spawn "feature leads" that further decompose into sub-specialists, instead of flat orchestrator → workers. | Keeps each agent's context window clean as task complexity grows beyond 5+ parallel concerns. |
| **Competing hypotheses debugging** | Replace single bug-hunter with a team of 3 agents testing different theories and actively disproving each other. | Single-reviewer debugging anchors on the first plausible explanation. Adversarial investigation finds root causes faster. |
| **Git worktrees per agent** | Give each Build-phase agent its own worktree so they can edit files in parallel without conflicts, then merge. | Unlocks parallel file editing — currently blocked by single-session Phase 3. |
| **Reuse agents as teammate types** | Existing agent definitions (rails-specialist, code-tracer, etc.) can be referenced directly as Agent Team teammate types — no rewrite needed. | Smooth migration path: same agents, different coordination model. |
| **Autonomy-first / YOLO mode** | A `/dev:run --auto` flag (or sibling `/dev:auto` command) that runs the full pipeline without the plan-approval gate, auto-applies bug-hunter fixes above a confidence threshold, and stops only at pre-commit. Pairs with running Claude in a sandboxed devcontainer with `--dangerously-skip-permissions`. | Unlocks unattended runs (overnight jobs, batch refactors, container/cloud sandboxes). The current flow's hard stop at plan approval is the right default *only* when a human is at the keyboard. |
| **Specialist breadth** | First-class specialists for Next.js, Python (Django/FastAPI), and Go — currently only Rails and Astro have dedicated tracers; everything else falls through to the generic `code-tracer`. | The generic tracer is a reasonable fallback, but stack-aware specialists produce sharper traces (knows where to look first, recognizes idioms). Diminishing returns past the top ~5 stacks. |
| **Continuous verify (delta mode)** | A long-running `/dev:verify --watch` that re-runs bug-hunter + convention-enforcer against each new commit or save during Phase 3, instead of one terminal pass. | Catches issues while the context is fresh and the diff is small. Currently all verification is end-of-build, so problems get bundled and lose their causal trail. |
| **Product manager agent (opt-in)** | A `pm-agent` that turns vague task descriptions into concrete acceptance criteria and a "definition of done" before the planner sees the task. Either an opt-in `/dev:pm` command or an automatic Phase 0 that short-circuits when the task is already concrete. | The planner is built to be decisive — it works best with a sharp task. Fuzzy asks ("improve onboarding") force the planner to pick a target out of thin air. A PM pass upstream raises plan quality without diluting the planner's job. **Tradeoff:** must not become a questionnaire; should produce a one-paragraph spec, not a discovery phase. |

References: [The Code Agent Orchestra (Addy Osmani)](https://addyosmani.com/blog/code-agent-orchestra/), [Claude Code Agent Teams docs](https://code.claude.com/docs/en/agent-teams), [Conductor vs. Swarm Architecture Guide](https://agixtech.com/conductor-vs-swarm-multi-agent-ai-orchestration/)

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
│       ├── commands/                            # Slash commands (/dev:run, /dev:scout, /dev:verify)
│       │   ├── run.md
│       │   ├── scout.md
│       │   └── verify.md
│       └── agents/                              # Stack-aware agents
│           ├── stack-detective.md               # Project stack detection (sonnet)
│           ├── rails-specialist.md              # Rails 8 code tracing (sonnet)
│           ├── astro-specialist.md              # Astro 5.x code tracing (sonnet)
│           ├── code-tracer.md                   # Generic code path tracer (sonnet)
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
After pushing, anyone can install with `/plugin install <name>@ai-coding`.

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

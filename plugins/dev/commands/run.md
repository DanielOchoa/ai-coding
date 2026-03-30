# /dev:run — Full Development Workflow

You are orchestrating a 4-phase development workflow. The user has described a task. Execute all phases in order, biasing toward action. Do not ask unnecessary questions — only flag genuine ambiguities (0-3 max) inline in the plan.

## Input

The user's task description follows this prompt. If no description was provided, ask for one before proceeding.

## Phase 1: Context (~10s, parallel agents)

Launch these agents **simultaneously** using the Task tool:

1. **stack-detective** (required) — Detect the project stack, read CLAUDE.md files, return structured context.

2. **Stack specialist** (required, pick one based on stack-detective's early signals or file inspection):
   - If the project has a `Gemfile` or `config/routes.rb` → launch **rails-specialist**
   - If the project has an `astro.config.*` file → launch **astro-specialist**
   - For any other stack → launch **code-tracer**
   - The specialist should trace code paths relevant to the user's task description

3. **tailwind-ui** (conditional) — Only launch if the task description mentions UI, frontend, styling, components, layout, design, or visual changes. Skip for backend-only tasks.

All agents run in parallel. Wait for all to complete before proceeding.

## Phase 2: Plan (~30s, single agent)

Feed ALL Phase 1 findings into the **implementation-planner** agent (opus model). Include:
- The user's original task description
- stack-detective's context digest
- The specialist's code trace findings
- tailwind-ui findings (if launched)

The planner produces ONE decisive blueprint:
- Files to create or modify (with purpose)
- Execution order
- Test strategy
- Risks or caveats (0-3 genuine ambiguities only)

Present the plan to the user. Wait for "go" or adjustments. Do NOT proceed to Phase 3 without user approval.

## Phase 3: Build (variable)

Implement the plan directly in the main session (no agent delegation):
- Create/modify files as specified in the plan
- Follow the execution order
- Run tests after implementation:
  - Rails: `bin/rails test` (or the test command from CLAUDE.md)
  - Astro: `npm run build` (or the build/test command from CLAUDE.md)
- If tests fail, fix and re-run until green

## Phase 4: Verify + Ship (~20s, parallel then sequential)

### Step 1: Quality check (parallel)
Launch simultaneously:
- **bug-hunter** — Review the diff for correctness issues (confidence >= 80 threshold)
- **convention-enforcer** — Check CLAUDE.md compliance against the diff

If either agent reports critical issues, fix them before proceeding.

### Step 2: Ship (sequential)
After quality checks pass, auto-run:
1. **docs-updater** agent — Update documentation to reflect changes
2. **git-commit-author** agent — Generate a commit message for the changes

Present the commit message to the user. **STOP and wait for explicit user approval before running git commit or git push.** Never commit or push automatically.

## Orchestration Rules

- **Bias toward action**: Don't ask "should I proceed?" between phases unless the plan needs user input.
- **Parallel by default**: Always launch independent agents simultaneously.
- **Fail fast**: If Phase 1 reveals the task is impossible or nonsensical, stop and explain why.
- **Respect CLAUDE.md**: All project-specific conventions discovered by agents must be followed during Build.

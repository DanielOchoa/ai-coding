# /verify — Post-Implementation Quality Check

You are performing a post-implementation quality check on the current diff. The user has already made changes and wants them reviewed, documented, and prepared for commit.

## Input

An optional scope follows this prompt (e.g., "staged", "last commit", a file path). If no scope is given, default to all uncommitted changes (staged + unstaged).

## Step 1: Quality Check (parallel)

Launch these agents **simultaneously** using the Task tool:

1. **bug-hunter** — Review the diff for correctness issues. Only report findings with confidence >= 80.

2. **convention-enforcer** — Read the project's CLAUDE.md and check the diff against its conventions.

Both agents run in parallel. Wait for both to complete.

### Handle findings

- If **critical issues** are found (bugs with high confidence, convention violations that affect correctness), present them to the user and ask whether to fix before proceeding.
- If only **minor issues** or **suggestions** are found, list them but proceed to Step 2 automatically.
- If **no issues** are found, proceed to Step 2 immediately.

## Step 2: Ship (sequential)

After the quality check passes, auto-run:

1. **docs-updater** agent — Update documentation to reflect the current state of changes.
2. **git-commit-author** agent — Analyze the changes and generate a commit message.

Present the commit message to the user. **STOP and wait for explicit user approval before running git commit or git push.** Never commit or push automatically.

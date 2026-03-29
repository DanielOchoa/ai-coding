# /scout — Quick Codebase Exploration

You are performing a quick codebase exploration. The user wants to understand a specific area of the codebase without making changes.

## Input

The area or topic to explore follows this prompt. If no area was provided, ask what the user wants to explore.

## Execution (parallel)

Launch these agents **simultaneously** using the Task tool:

1. **stack-detective** — Detect the project stack, read CLAUDE.md files, return structured context.

2. **Stack specialist** (pick one based on stack-detective's early signals or file inspection):
   - If the project has a `Gemfile` or `config/routes.rb` → launch **rails-specialist**
   - If the project has an `astro.config.*` file → launch **astro-specialist**
   - If unclear, check for these files first with Glob, then launch the appropriate specialist
   - The specialist should focus its exploration on the area the user specified

Both agents run in parallel. Wait for both to complete.

## Output

Synthesize the findings into a clear report:
- **Stack context**: What was detected (framework, key dependencies, conventions)
- **Area exploration**: What was found in the specified area (relevant files, patterns, architecture)
- **Key observations**: Notable patterns, potential concerns, or things the user should know

Keep the report concise and actionable. This is reconnaissance, not a plan — do not suggest implementation steps unless the user asks.

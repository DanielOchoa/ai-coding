# Findings Format

Standard format used by all reviewer subagents. The orchestrator (SKILL.md) uses this to consolidate findings across reviewers.

## Severity Levels

- **Critical** -- Must fix before merge. Bugs, security vulnerabilities, data loss risk, architecture violations, breaking changes. Requires High confidence.
- **Improvement** -- Suggestions for better code quality, performance, maintainability, or coverage. Medium or Low confidence findings that would otherwise be Critical are downgraded here.
- **Nitpick** -- Formatting, naming, minor style issues. Optional.

## Confidence Levels

- **High** -- The reviewer is certain this is a real issue based on the code.
- **Medium** -- Likely an issue but depends on context not visible in the diff.
- **Low** -- Possible concern; reviewer is flagging for human judgment.

Critical severity requires High confidence. If confidence is Medium or Low, the finding must be downgraded to Improvement.

## Finding Structure

Each finding includes:

```
- **[file:line]** [Description]. **Why**: [Impact]. **Suggestion**: [Fix]. **Confidence**: [High/Medium/Low]
```

Nitpicks omit the "Why" field:

```
- **[file:line]** [Description]. **Suggestion**: [Fix].
```

Praise entries:

```
- **[file:line]** [What's done well and why].
```

## Per-Reviewer Output

Each reviewer returns:

```markdown
## Findings: [Reviewer Name]

### Critical
[findings or "None."]

### Improvement
[findings or "None."]

### Nitpick
[findings or "None."]

### Praise
[findings or "None."]

### Summary
[2-3 sentence assessment from this reviewer's perspective]
```

## Consolidation Rules

The orchestrator merges findings from all reviewers:

1. **Deduplicate**: If two reviewers flag the same file:line, keep the higher-severity finding and note both reviewers.
2. **Rank**: Critical first, then Improvement, then Nitpick.
3. **Attribute**: Each finding shows which reviewer produced it (e.g., `[Architecture]`, `[Security]`).
4. **Praise**: Merge all praise entries into a single Strengths section.
5. **Summaries**: Synthesize reviewer summaries into the report's Summary section.

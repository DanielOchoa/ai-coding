# Engineering Principles

Universal code review principles. Apply to every changed file regardless of language, framework, or project.

---

## DRY (Don't Repeat Yourself)

Flag duplicated logic that should be extracted into a shared function, hook, or constant.
Look for copy-pasted blocks, near-identical components, and repeated conditionals.

## KISS (Keep It Simple)

Flag unnecessary abstraction, indirection, or cleverness.
If a simpler approach achieves the same result, suggest it.
Wrapper functions that add no value, over-engineered generics, and deep inheritance are common violations.

## YAGNI (You Aren't Gonna Need It)

Flag speculative features, premature generalization, and unused abstractions.
Code should solve the current problem, not hypothetical future ones.
If a parameter, config option, or abstraction layer has exactly one consumer, it's likely premature.

## SOLID

- **Single Responsibility** — each module/component should have one reason to change. Flag god-components or files doing too many things.
- **Open/Closed** — extend behavior without modifying existing code. Flag changes that require editing multiple unrelated files to add a single feature.
- **Liskov Substitution** — subtypes must be substitutable for their base types.
- **Interface Segregation** — don't force consumers to depend on interfaces they don't use.
- **Dependency Inversion** — depend on abstractions, not concretions. Flag tight coupling to specific implementations.

## Readability

Code should read like well-written prose. Prefer explicit over implicit. Naming should convey intent.
Flag single-letter variables (outside trivial loops), boolean parameters without named arguments, and magic numbers/strings.

## No Premature Optimization

Measure first, optimize second. Flag micro-optimizations that sacrifice readability without evidence of a performance problem.

## Beyond the Checklist

Don't limit yourself to the items above. If you see an issue, name it. If you see a better way, suggest it.

- Are there better approaches? Different solutions, tradeoffs?
- What patterns emerge? Repeated code suggesting a missing abstraction?
- What might break? Edge cases, race conditions, failure modes?
- How will this age? Easy to understand in 6 months? Easy to change?
- What's missing? Observability, logging, type safety?
- What assumptions are being made? Are they documented and valid?

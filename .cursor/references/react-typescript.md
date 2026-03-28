# React & TypeScript Patterns

Generic review checks for React and TypeScript projects. Apply when the project uses React/TypeScript (detected from `package.json` or file extensions).

---

## TypeScript

- No `any` — use `unknown`. Flag `as any` casts and untyped function params.
- Prefer explicit typing over inference when the type isn't obvious.
- Follow strict mode patterns (`noUncheckedIndexedAccess` catches `arr[i]` returning `undefined`).
- Prefer explicit props destructuring over `React.FC<Props>` (breaks generic inference).
- Flag barrel files (`index.ts` re-exports) in app code — they cause bundle bloat and circular deps. Use direct imports.

## React Components

**Design:**

- Components should be "dumb" — render props and call event handlers. Extract business logic into pure functions.
- Flag components over ~300 lines — split into smaller, focused components.
- Flag components defined inside other components — causes remount every render. Move outside.
- Prop drilling past 2-3 levels — use composition or context.
- Colocate state close to where it's used.

**Hooks:**

- Hooks over utility files for logic that participates in the render lifecycle.
- Flag `eslint-disable react-hooks/exhaustive-deps` — hides stale closure bugs. Refactor the logic instead.
- `useMemo`/`useCallback` need clear justification — don't apply by default.

## useEffect Anti-Patterns

Most common issue in React reviews. Flag these:

**Derived state in effects** — compute during render instead:

```typescript
// Bad: extra render cycle, sync bugs
useEffect(() => {
  setFullName(first + ' ' + last);
}, [first, last]);
// Good: derived value computed inline
const fullName = first + ' ' + last;
```

**Event-response logic in effects** — move to the event handler:

```typescript
// Bad: effect reacts to state change caused by event
useEffect(() => {
  if (item.isInCart) showNotification('Added!');
}, [item]);
// Good: logic lives in the handler that caused the change
function handleAdd() {
  addToCart(item);
  showNotification('Added!');
}
```

**Missing cleanup** — subscriptions, timers, or listeners without cleanup cause memory leaks.

## State Mutations

Flag direct mutation of arrays/objects then calling the setter — React won't re-render:

```typescript
// Bad: mutates in place, no re-render
items.push(newItem);
setItems(items);
// Good: immutable update
setItems([...items, newItem]);
```

## Common Pitfalls

- **Controlled inputs** — flag `useState(undefined)` for form inputs. Use empty string `''` as initial value to avoid uncontrolled-to-controlled warnings.
- **Conditional hooks** — flag any hook call inside a condition, loop, or early return. Breaks Rules of Hooks.
- **Dynamic list keys** — flag `key={index}` on lists that can reorder, filter, or insert. Causes state corruption. Use a stable unique ID.

## Accessibility

- Do interactive elements have accessible labels? (`aria-label`, `aria-labelledby`)
- Is keyboard navigation supported? (`tabIndex`, `onKeyDown` where needed)
- Are form inputs associated with labels?

## Testing

- Accessible queries (`byRole`, `byLabelText`, `byText`) over `data-testid`.
- No "should..." in test names — assert behavior definitively (e.g., "renders the submit button" not "should render the submit button").
- Single assertion per test. Multiple assertions indicate the test verifies more than one behavior.
- Don't test implementation details. Tests that assert on internal state or specific DOM structure break when details change.
- Mocks should match real interfaces — assertions directly against mocks are a code smell.
- User interactions tested (click, type, submit).
- Async flows tested with `waitFor` / `findBy` queries.

# Performance Review

Performance checklist for the `review-performance` subagent. Covers algorithmic complexity, database/I/O, network, memory, rendering, and observability.

---

## Checklist

### Algorithmic Complexity

- What is the time and space complexity of the hot paths?
- Are there O(n^2) or worse loops where O(n log n) or O(n) is achievable?
- Are unnecessary iterations happening? (double loops, repeated array scans)
- Is the data structure appropriate? (array vs map vs set vs tree)

### Database & I/O

- Are queries fetching more data than needed? Check for `SELECT *` or over-fetching in APIs.
- Are N+1 query patterns present? (loading a list, then querying per item)
- Are indexes likely to be used? Check WHERE / JOIN / ORDER BY columns.
- Are expensive queries cached when results are stable?
- Is pagination applied to large result sets?

### Network & APIs

- Are requests batched where possible?
- Is response payload minimized? (field selection, compression)
- Are requests parallelized when independent? (`Promise.all`, concurrent fetches)
- Is caching applied at the right layer? (CDN, HTTP cache headers, in-memory)

### Memory

- Are there object or listener leaks? (event listeners, subscriptions not cleaned up)
- Are large objects held in memory longer than needed?
- Are streams or lazy evaluation used for large data sets?

### Rendering (Frontend)

- Are components re-rendering unnecessarily? Check for unstable object/function references passed as props.
- Are expensive calculations in the render path memoized with genuine dependencies?
- Is the critical rendering path kept lean? (blocking scripts, large bundles)
- Are images lazy-loaded where appropriate?
- Are lists virtualized if they can be long? (`react-window`, `react-virtual`)

### Observability

- Are slow paths instrumented? (timing, metrics, tracing)
- Will we know if this degrades in production?


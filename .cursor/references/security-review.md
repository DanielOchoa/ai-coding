# Security Review

Security checklist for the `review-security` subagent. Covers authentication, injection, secrets, data exposure, dependencies, transport, CSRF, and logging.

---

## Checklist

### Authentication & Authorization

- Are protected routes/endpoints verified for authentication?
- Is authorization checked at the right layer? (not just UI, also server-side)
- Are permission checks correct? Could a lower-privileged user access restricted data?
- Are session tokens generated securely and rotated appropriately?

### Input Validation & Injection

- Is user input validated and sanitized before use?
- Is there SQL injection risk? (raw query strings with user data)
- Is there XSS risk? (unsanitized HTML rendering, `dangerouslySetInnerHTML`)
- Is there command injection risk? (shell commands built from user input)
- Are file upload paths sanitized? (path traversal attacks)

### Secrets & Credentials

- Are secrets hardcoded in source? (API keys, tokens, passwords)
- Are environment variables used correctly and not leaked to clients?
- Are secrets excluded from logs and error messages?

### Data Exposure

- Is sensitive data returned only to authorized requestors?
- Are error messages minimal? (no stack traces or internal detail in production responses)
- Is PII handled according to data policies?
- Are responses paginated to avoid bulk data extraction?

### Dependencies

- Are new dependencies introduced? Check for known CVEs.
- Are dependencies pinned to specific versions?
- Are any dependencies from unverified sources?

### Transport & Storage

- Is data in transit over HTTPS/TLS?
- Is sensitive data at rest encrypted?
- Are cookies `HttpOnly`, `Secure`, and `SameSite` where appropriate?

### CSRF & Request Forgery

- Are state-mutating endpoints protected against CSRF?
- Are CORS policies appropriately restrictive?

### Logging & Audit

- Are security-sensitive actions logged? (login, permission change, data export)
- Are logs structured enough to support incident investigation?


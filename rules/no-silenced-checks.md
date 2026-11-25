# Don't silence checks

When a lint rule, type check, audit or hook flags something, fix what it found. Don't add an ignore comment (`eslint-disable`, `@ts-expect-error`, `unused-methods-ignore` and the like), a baseline entry, or a config exclusion to make it pass unless I ask for that. If the check itself seems wrong, tell me, with what you saw, and let me decide.

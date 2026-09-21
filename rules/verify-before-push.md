# Verify before push

Every change is verified working before it is pushed, and the verification is shown before the push, not alongside it. The order is edit → verify → show the result → commit → push.

- **Verify means run the real check**: the test suite, the script against a scratch target, a dry run against the real target, a build. Read the output. A syntax check alone is not verification of behaviour.
- **Prose-only changes** (docs, rules, skills) get a read-through against the thing they describe, so a documented command or path actually exists.
- **When a check cannot be run** (for example the environment refuses it, or it needs something only I can do), say so explicitly and push only if I have agreed to that.

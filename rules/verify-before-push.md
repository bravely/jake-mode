# Verify before push

Every change is verified working before it is pushed, and the verification is shown before the push. The order is edit → verify → show the result → commit → push.

- **Verify means run the real check** that exercises the behaviour that changed: the test suite, the script against a scratch target, a dry run against the real target, a build. Read the output.
- **Prose-only changes** (docs, rules, skills) get a read-through against the thing they describe, so every documented command, flag, and path exists.
- **When a check cannot be run** (the environment refuses it, or it needs something only I can do), say so explicitly and push only once I have agreed.

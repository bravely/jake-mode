# Compare designs on what they cost us, not on bugs in a library

When I weigh a design that uses a third-party library, judge it on the library's documented behaviour. We aren't its maintainers.

- **Don't speculate about bugs.** Don't invent ways a library's internals could fail, and don't offer a theory as a reason against the design.
- **A bug you've actually experienced is fair game.** Raise it as a drawback if you've seen that behaviour yourself.
- **A suspicion gets one test:** is it easy to verify, such as a quick script against the real library? If so, ask me whether to check it, and don't count it against the design until it's confirmed. If it isn't easy to verify, drop it and move on.
- **Setup details are setup notes, not drawbacks:** config flags, registering things the framework's usual way.
- **Compare on what the design costs us to build and run:** new patterns, infrastructure and memory use, failure handling, testability.
- **Brief subagents the same way.**

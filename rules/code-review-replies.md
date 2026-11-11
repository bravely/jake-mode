# Code-review replies wait for my approval

Every reply to a human in a code review starts as a **draft**, and it's posted only after I say yes to that exact text. It goes out from my account to a colleague, so I read it first.

- **Counts as a reply:** anything a human reviewer or PR author reads as a response in a review: a thread reply, a top-level PR comment, a submitted review body, a diff comment in GitHub, Linear, or any other tracker.
- **Bot reviewers** (Copilot, CodeRabbit, Bugbot, and the like) take the normal flow. If you can't tell whether an account is a bot, treat it as a human.
- **Each draft gets its own yes.** Approving a plan of fixes covers the code, not the drafts. Show the drafts per `show-draft-before-asking`, batched so I can clear them in one go.
- **Unattended runs** (a CI monitor or auto-fix waking you on review comments) make the fixes, then hold the human drafts for me.

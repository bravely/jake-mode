---
name: address-pr-comments
description: Work through the unresolved review comments on a pull request — classify each by Conventional Comments intent, decide what (if anything) it asks you to change, implement changes test-first via /tdd, and reply on each thread. Use when the user wants to address PR feedback, respond to review comments, work through code-review threads, or "handle the review".
---

# Address PR Comments

Work through a pull request's **unresolved** review threads, one at a time, honouring the
reviewer's intent. Code changes go through `/tdd`. You reply on each thread; you do **not**
resolve threads — the reviewer does that.

**Two hard rules:**
- **Every reply you post is from you (the agent), not the user.** Sign each reply so the
  reviewer knows a coding agent answered — e.g. open with `🤖 (agent reply on the author's
  behalf)`. Never write in the first person as if you were the PR author.
- **If a reviewer asks for a human** — explicitly requests the author, says "can a person
  look at this", escalates, or expresses they want to talk to someone rather than an agent —
  **stop and notify the user immediately.** Do not reply to that thread on your own; surface
  it to the user right away and let them take it.

**The core discipline — answer before you patch.** A question is not a license to refactor.
The reliable failure mode here is treating the review as a checklist and producing a plausible
diff per comment instead of understanding the concern behind it. Mechanical directives ("rename
X", "use `File.write`") are safe to just do. **Questions and design prods are not** — for those,
*investigate and answer in prose first* (enumerate the call sites, name what's actually used),
and let any code change follow from that answer. Treat the smallest change — deleting, inlining —
as a first-class option: when a reviewer questions whether something should *exist*, responding
with *more* structure almost always misses the point. Litmus test before every edit: **"Am I
about to change code in response to a question I haven't actually answered yet?"** If yes, stop
and answer it.

The tracker is GitHub via `gh`. Before replying, read whatever the project keeps as its
glossary and decision record (a `CONTEXT.md`, ADRs, `docs/`) so replies and code use the
project's language and respect documented decisions.

## Process

### 1. Re-fetch the unresolved threads (always fresh)

Every time this skill runs, re-pull the live state — comments may have been added or
resolved since last time. Do not trust earlier context.

```
scripts/unresolved-threads.sh [PR_NUMBER]
```

The path is relative to this skill's directory (the base directory the harness reports
when the skill loads).

Omit `PR_NUMBER` to use the PR for the current branch. The script returns each unresolved
thread with its `path`, `line`, `thread_id`, `reply_to` (the comment id to reply to), the
comment bodies, and two triage flags: `last_comment_by` and `awaiting_reviewer`. Also skim
the PR's review summaries (`gh pr view --json reviews`) for top-level `CHANGES_REQUESTED`
notes not attached to a line.

If there are zero unresolved threads, say so and stop.

### 2. Classify each thread by intent

**First, drop the threads that aren't yours to act on.** `unresolved ≠ unaddressed` — a
thread stays open until the *reviewer* clicks resolve, which often lags well behind the fix.

- **`awaiting_reviewer: true`** (you, the PR author, already replied last) → the ball is in
  the reviewer's court, not yours. Don't re-reply, don't re-change. List it as "addressed,
  awaiting reviewer" and move on — unless the reviewer added a *new* ask after your reply.
- **Request for a human** (see the hard rule above) → notify the user immediately and
  exclude it from your auto-reply set; they'll handle it.

For the threads that remain (last word is the reviewer's, no human requested), classify each.

Read each through the **Conventional Comments** lens — use the label and decoration if
present, infer the intent if not. The label→action mapping and the full question decision
tree live in [CONVENTIONAL-COMMENTS.md](CONVENTIONAL-COMMENTS.md). Read it. Sort each into
one of three modes, because they want different responses:

- **Directive** ("rename X to Y", "use `File.write`") → just do it.
- **Question** ("do we need X?", "what else uses this?", "shouldn't it handle Z?") →
  **investigate and answer in prose first**; a change follows only from the answer. Then run
  the question decision tree: clarity vs. issue? does it imply a change? if it's a concept a
  mid-level dev would already know, just **reply with the explanation** (no code change); if
  not, the *code* failed to communicate — fix the code (preferably) or docs (less so).
- **Design prod** (a question whose real aim is to make you reconsider the shape) → engage
  with the design, propose a direction, and confirm in step 4 before building.

### 3. Look across the threads — why, and what they add up to

Before planning fixes, step back from the individual comments and ask:

- **Why is the reviewer raising this?** Read for the underlying concern, not just the
  literal ask. A reviewer pointing at one line often means the whole approach there worries
  them. Address the concern, not only the symptom.
- **Are two comments related?** Separate threads can be two symptoms of one cause. If
  several comments circle the same code, name the shared root and fix it once.
- **Do the issues together suggest a different design?** When the feedback clusters around
  a seam — the same abstraction leaking, the same edge case recurring — the right response
  may be to reshape the design rather than patch each spot. If so, surface that to the user
  as an option in step 4 with your reasoning; don't quietly do a large redesign, and don't
  quietly apply N local patches when one structural change is clearly what's being asked.

### 4. Present the plan, grouped into commits

Show the user a numbered list: each thread, its inferred intent, and your proposed
response (change / reply-only / no-op). Call out any cross-thread root cause or design
change you found in step 3. Group threads that touch related code into one logical commit;
keep unrelated changes in separate commits, unless they're trivial. Get approval before
writing code.

### 5. Implement changes via /tdd

For every thread that warrants a code change, drive it through the `tdd` skill
(`/tdd`, or `/mattpocock-skills:tdd` when only the plugin provides it; red → green →
refactor). Address one logical group at a time. Don't batch all tests up
front. `nitpick:`/`suggestion:` items marked non-blocking are optional — confirm with the
user whether to include them.

After drafting each change, re-read the reviewer's **original** words and ask: does this
actually satisfy what they were worried about? "Made the comment go away" is not the metric;
the concern being gone is. And if a reviewer says you misunderstood, **re-derive from their
words — don't re-patch your wrong answer.** Restate the concern in your own terms and reason
from scratch; tweaking the previous attempt keeps you in the wrong frame.

### 6. Commit per logical group

One focused commit per related group of threads; separate commits for unrelated work
(minor tweaks may ride along). Reference the threads in the commit body. **Stop and confirm
with the user before pushing.**

### 7. Reply on each thread (reply only — never resolve)

For every thread, post a reply with the first comment's `reply_to` id. Each reply must be
clearly **from you, the agent** — lead with `🤖 (agent reply on the author's behalf)` and
never write as if you were the author. Skip any thread that asked for a human (already
escalated to the user in step 2).

```
gh api --method POST /repos/{owner}/{repo}/pulls/{PR}/comments/{reply_to}/replies \
  -f body="🤖 (agent reply on the author's behalf) ..."
```

- **Changed it** → say what changed and the commit SHA.
- **Trivial question** (concept a mid-level dev would know) → reply with the explanation.
- **Won't change** (e.g. a `thought:` you're declining) → reply with the brief rationale.

Leave resolving to the reviewer.

### 8. Report

Summarise: threads changed (with commits), threads replied-to, and any threads escalated to
the user (human requested). Note anything still open or awaiting the user's push.

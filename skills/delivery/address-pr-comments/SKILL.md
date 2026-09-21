---
name: address-pr-comments
description: Work through a pull request's unresolved review threads, honouring the reviewer's intent, and reply on each. Use when asked to address a PR's review comments, or when a CI monitor event reports new review comments.
---

# Address PR comments

Work a pull request's **unresolved** review threads one at a time, honouring the
reviewer's intent. Code changes go through the `tdd` skill (`/tdd`, or
`/mattpocock-skills:tdd` when only the plugin provides it). You reply on each
thread; resolving is the reviewer's, and stays theirs.

**Two hard rules.**

- **Every reply is from you, the agent.** Open each with the signature
  `🤖 (agent reply on the author's behalf)` so the reviewer knows a coding agent
  answered. Never write in the first person as if you were the PR author.
- **A reviewer who asks for a human gets one.** If they request the author, ask
  for a person, escalate, or say they would rather talk to someone than an agent:
  stop, surface that thread to the user immediately, and leave it to them.

**Answer first.** A question is not a licence to refactor. Directives ("rename
X", "use `File.write`") are safe to just do. Questions and design prods get an
answer in prose before any edit: enumerate the call sites, name what is actually
used, and let a change follow from the answer, if one follows at all. The
smallest change (deleting, inlining) is a first-class option; a reviewer doubting
whether something should *exist* is answered with less structure, not more.
Litmus test before every edit: "am I about to change code in response to a
question I have not actually answered yet?"

The tracker is GitHub via `gh`. Before replying, read whatever the project keeps
as its glossary and decision record (a `CONTEXT.md`, ADRs, `docs/`) so replies
and code use the project's language and respect documented decisions.

## Process

### 1. Fetch the unresolved threads, fresh

Every run re-pulls the live state; comments get added and resolved between runs.

```
scripts/unresolved-threads.sh [PR_NUMBER]
```

The path is relative to this skill's directory (the base directory the harness
reports when the skill loads). Omit `PR_NUMBER` to use the current branch's PR.
Each thread comes with `path`, `line`, `thread_id`, `reply_to` (the comment id
to reply to), the comment bodies, and two triage flags: `last_comment_by` and
`awaiting_reviewer`. Also skim `gh pr view --json reviews` for top-level
`CHANGES_REQUESTED` notes not attached to a line.

Done when every unresolved thread is in hand. Zero threads: say so and stop.

### 2. Classify each thread by intent

`unresolved ≠ unaddressed`: a thread stays open until the *reviewer* clicks
resolve, which often lags the fix. Drop first:

- **`awaiting_reviewer: true`** (you replied last): the ball is in the
  reviewer's court. List it as "addressed, awaiting reviewer" and leave it,
  unless the reviewer added a *new* ask after your reply.
- **Human requested** (hard rule above): surface to the user now and exclude it
  from your reply set.

Read each remaining thread through the Conventional Comments lens, using the
label and decoration when present and inferring the intent when not. The
label → action table and the question decision tree are in
[CONVENTIONAL-COMMENTS.md](CONVENTIONAL-COMMENTS.md); read it. Sort each thread
into one mode:

- **Directive** ("rename X to Y", "use `File.write`"): do it.
- **Question** ("do we need X?", "what else uses this?", "shouldn't it handle
  Z?"): answer first, then run the decision tree. A concept a mid-level
  developer already knows gets a reply with the explanation and no code change;
  otherwise the *code* failed to communicate, so fix the code (preferred) or the
  docs (less so).
- **Design prod** (a question whose real aim is to make you reconsider the
  shape): engage with the design, propose a direction, and confirm in step 4
  before building.

Done when every remaining thread carries exactly one mode.

### 3. Look across the threads

Before planning fixes, read for what the comments add up to:

- **Why is the reviewer raising this?** One line pointed at often means the
  whole approach there worries them. Address the concern, not only the symptom.
- **Are two comments one cause?** Several comments circling the same code get
  one shared root, fixed once.
- **Do they suggest a different design?** Feedback clustering around a seam
  (the same abstraction leaking, the same edge case recurring) may want a
  reshape rather than N local patches. Surface that to the user as an option in
  step 4, with your reasoning, and let them choose between the reshape and the
  patches.

Done when each thread is tied to a root cause, shared or its own.

### 4. Present the plan, grouped into commits

A numbered list: each thread, its mode, and your proposed response (change /
reply-only / no-op), plus any cross-thread root cause or design option from
step 3. Group threads touching related code into one logical commit; unrelated
changes get separate commits unless trivial.

Done when the user has approved the plan.

### 5. Implement via /tdd

Each change goes through `/tdd` (red → green → refactor), one logical group at
a time, with that group's tests written as it is reached. Non-blocking
`nitpick:`/`suggestion:` items are optional: confirm with the user whether to
include them.

After drafting each change, re-read the reviewer's **original** words. The bar
is the concern being gone; the comment going away is a side effect. If a
reviewer says you misunderstood, re-derive from their words: restate the
concern in your own terms and reason from scratch, since tweaking the previous
attempt keeps you in the wrong frame.

Done when every change satisfies the reviewer's original words, with tests
green.

### 6. Commit per logical group

One focused commit per related group of threads, separate commits for unrelated
work (minor tweaks may ride along), the threads referenced in the commit body.

Done when the user has confirmed the push.

### 7. Reply on each thread

For every thread in your reply set, post a reply to its first comment's
`reply_to` id, opening with the signature:

```
gh api --method POST /repos/{owner}/{repo}/pulls/{PR}/comments/{reply_to}/replies \
  -f body="🤖 (agent reply on the author's behalf) ..."
```

- **Changed it**: what changed and the commit SHA.
- **Trivial question**: the explanation.
- **Won't change** (a `thought:` you are declining): the brief rationale.

Resolving stays with the reviewer. Done when every thread in the reply set has
a reply.

### 8. Report

Threads changed (with commits), threads replied to, and threads escalated to
the user. Note anything still open or awaiting the user's push.

---
name: pr-review-guide
description: Write or refresh the review guide in a pull request's body — the change's thesis, the order to read it in, and where to look hard. Use when opening a pull request, after pushing commits to a branch whose PR is already open, or when asked for a reading order through a set of changes.
---

# PR review guide

A reviewer opening a big PR lands on an alphabetised file list that hides the shape of the change. The guide replaces that with a **tour**: a route through the diff that builds understanding in the order the reviewer needs it, plus the two things the diff can't say for itself — why this change exists, and where it is most likely to be wrong.

Refreshing an existing guide runs these same steps against the current diff.

## 1. Gate

Most PRs don't need a tour. Decide from the diff itself, never from the branch name or commit subjects — branch names go stale, and a branch can carry a commit closing a different issue than the one it's named for.

```
base=$(gh pr view --json baseRefName -q .baseRefName 2>/dev/null \
  || gh repo view --json defaultBranchRef -q .defaultBranchRef.name)
git diff --stat "origin/$base"...HEAD
git diff --stat "origin/$base"...HEAD -- ':(exclude)*.lock'
```

The second count is the **significant** one. Widen the exclusion when the repo carries other generated trees — vendored dependencies, snapshot fixtures, compiled assets.

Read the state fresh each run rather than trusting an earlier reading: another session or a merge can move `HEAD` and the base mid-task, and a guide written against a diff that no longer exists is worse than none.

- **Skip** when the change fits in one pass: under 5 significant files and under ~200 significant lines.
- **Guide anyway** when a small diff crosses layers (schema + API + UI), or introduces an abstraction that other code now calls. Span beats size.
- **Downshift** when the bulk is one mechanical operation repeated. A 40-file rename needs one sentence naming the operation and the file where real behaviour changed — not a tour.

Completion: either a written decision to skip (say so in one line to the user and stop here) or a file-and-line count you read off the `--stat`. On a refresh, a guide that already exists stays even if the current diff would gate out — reviewers may already be working from it.

## 2. Name the thesis

What is this PR *for*? Read the linked issue (`gh issue view`), the commit messages, and any existing PR body before falling back to inferring it from the diff.

Completion: one or two sentences that land for someone who has read no code, naming what changes for the user or the system. "Adds `FooSupervisor` and updates 6 callers" is a file list, not a thesis. If the PR does two unrelated things, say that outright — it is the single most useful sentence a guide can carry.

## 3. Route the tour

Order for comprehension, not for git's alphabet.

- **Open where the intent is clearest** — the new type, schema, interface, or test that states what the change is trying to do. This is rarely the biggest file and rarely the entrypoint.
- **Then follow the dependency order**: the implementation that satisfies it, then the callers that consume it.
- **Batch the mechanical tail** into one stop: "the remaining 14 files are the same call-site update."
- **Clean commits are the spine, not the whole tour.** When `git log --oneline "origin/$base"..HEAD` shows coherent, well-named commits, the order is already encoded — take it, then hang the stops off it rather than replacing files with commit hashes. A reviewer still needs to know which file inside the commit to open.

Each stop gets a path (plus symbol or line number where it helps) and one line on the question that stop answers. Cap the tour at about seven stops; past that, batch harder rather than listing more.

Completion: every significant file from step 1 is reachable from some stop, individually or inside a batch.

## 4. Mark the hot spots

Where does careful attention actually pay? Name the places that want a second opinion — drawn from what you know if the change is yours, and from what the commit messages, code comments, and linked issues admit to if it isn't:

- Logic that is load-bearing and subtly breakable — concurrency, migrations, money, time zones, auth.
- Judgement calls with a live alternative that was rejected.
- Unverified ground: untested paths, external services, behaviour asserted but not run.
- Hunks that look mechanical but aren't — the one file in a rename sweep where behaviour also moved.
- Findings buried in prose. A spec-level problem confessed in a commit message merges as a footnote unless the guide surfaces it as a decision the reviewer has to make.

Then collect what the diff doesn't show: constraints from outside the repo, approaches ruled out, checks run out-of-band and their results.

Completion: the honest list, carrying the change's weakest point — plus, when the work isn't yours, a plain statement of which claims you read rather than reproduced. A hot-spot section with nothing uncomfortable in it isn't doing its job.

## 5. Write it into the PR body

The guide is fenced by sentinel markers so refreshes are a section swap:

```markdown
<!-- review-guide -->
## Review guide

**The point:** …

**Read in this order:**
1. `path/to/file.ex` — what this stop answers
2. …

**Look hard at:** …

**What the diff doesn't show:** …
<!-- /review-guide -->
```

Drop the last section when it's empty rather than padding it.

For a PR that doesn't exist yet, include the fenced section in the body you pass to `gh pr create --body-file`. For one that does:

1. `gh pr view --json body -q .body > <scratchpad>/body.md`
2. Replace the text between the markers, or append the fenced section if they're absent.
3. `gh pr edit --body-file <scratchpad>/body.md`

Completion: re-read the body with `gh pr view` and confirm every line outside the markers is byte-identical to what you started with.

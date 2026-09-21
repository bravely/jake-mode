# Conventional Comments → expected action

[Conventional Comments](https://conventionalcomments.org/) format: `<label> [decoration]: <subject>`.
When a reviewer uses a label, it signals their intent and how strongly they expect a change.
When no label is present, infer the intent from the wording and apply the same mapping.

## Labels

| Label         | Reviewer's intent                          | Default expectation |
|---------------|--------------------------------------------|---------------------|
| `praise:`     | Highlighting something good                 | No action. A brief thanks is fine. |
| `nitpick:`    | Trivial, preference-level                    | Optional. Usually non-blocking — confirm with user before doing. |
| `suggestion:` | Proposes a specific improvement              | Apply it, unless you have a reasoned objection — then reply with it. |
| `issue:`      | A real problem with the code                 | Address it. Treat as required. |
| `todo:`       | Small, necessary change                      | Do it. |
| `question:`   | Wants information                            | Run the decision tree below. |
| `thought:`    | A non-blocking idea, not a request           | Usually no change; reply acknowledging or declining with rationale. |
| `chore:`      | A process task (changelog, rebase, etc.)     | Do the task. |
| `note:`       | FYI, draws attention                         | No change expected; acknowledge if useful. |

## Decorations override the default

- **(blocking)** — must be resolved before merge. Treat as required regardless of label.
- **(non-blocking)** — should not block merge. Safe to defer; confirm with user.
- **(if-minor)** — address only if the fix is genuinely small; otherwise reply explaining why you're deferring.

When label and decoration disagree (e.g. `issue: (non-blocking)`), the decoration wins on
*urgency*; the label still tells you *what kind* of response to give.

## Question decision tree

A `question:` (or any interrogative comment) is ambiguous — resolve it in this order.

**Before any of the steps below: answer the question first.** A question is not a license to
refactor. Investigate — for "do we need X / what else uses this / shouldn't it handle Z",
literally enumerate the call sites and state what you found. The answer is usually the whole
insight, and it's sitting in the code already ("after the refactor, only `Issue.eligible?`
and the GitHub adapter touch these" *was* the fix). Only after you've answered do you decide
whether a change follows. And keep the smallest change in view: when a reviewer questions
whether something should *exist*, "what would deleting/inlining this look like?" ranks equal
with "where should I move it?" — adding a module or abstraction in response to a doubt is a
smell. If you're reaching for *more* structure to answer a "do we need this?", you've likely
missed the point.

1. **Clarity vs. issue.** Is the reviewer asking to understand something, or using a
   question to point out a problem ("is this null-safe?" usually means "this isn't null-safe")?
   A leading/rhetorical question is really an `issue:` — handle it as one.

2. **Does the question imply a code change?** Independently of step 1, decide whether
   answering it honestly requires changing the code.
   - **Yes** → treat as `issue:`/`todo:`. Make the change via `/tdd`, then reply pointing to it.
   - **No** → it's the commenter not yet understanding a concept. Go to step 3.

3. **Would a typical mid-level developer already understand this?**
   - **Yes** → no code or doc change. **Reply with a clear explanation.** The reviewer
     learning a concept isn't a reason to bloat the code.
   - **No** → the *code* failed to communicate. Make it clearer:
     - **Preferred:** improve the code itself — better names, a clearer structure, a deeper
       module that hides the confusing detail behind a simple interface.
     - **Less preferred:** add or improve documentation / a comment, when the clarity
       genuinely can't live in the code.
     Then reply describing the change.

The bar in step 3 is deliberately high: only reach for docs when restructuring the code
can't carry the meaning, and only conclude "no change" when the confusion is the reader's
to resolve, not the code's.

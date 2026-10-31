---
name: "todoist-inbox-management"
description: "Governs how Claude handles all Todoist task creation and changes for Jake. Use this skill any time Jake asks to add something to his to-do list or Todoist inbox, mentions a task in passing that might belong in his inbox, or when wrapping up a conversation where tasks have been collected on a running list. Also use any time Jake asks to complete, reschedule, or otherwise update an existing Todoist task, especially a recurring one. Also use when deciding how to frame a task title, whether to ask clarifying questions before adding a task, or when determining whether context should accompany a task. This skill should always be active in the background — treat it as the standing protocol for all task-capture and task-change behavior.\n"
metadata:
  reach: all
---

# Todoist Inbox Management

This skill defines the complete protocol for how Claude captures tasks into Jake's
Todoist inbox. It covers: when to use Todoist directly vs. a running list, how to
frame task titles, when to ask clarifying questions, and what context to include.
It also covers how to complete and reschedule existing tasks without breaking
recurrence (see Step 8).

---

## Step 1: Try Todoist First

Whenever Jake asks to add something to his to-do list or Todoist inbox, attempt to
use the Todoist MCP connector immediately.

If the call **succeeds**: confirm the task was added and move on.

If the call **fails** (permission error, connector unavailable, etc.): do not
assume the cause. Acknowledge the failure and explain that it's either because
we're in conversation mode (where the Todoist MCP is unavailable) or because
there's a problem with the Todoist connection itself. Ask Jake to confirm which.

- If **conversation mode** is confirmed: pivot to the running list (see Step 2).
- If it's a **connection issue**: acknowledge it, troubleshoot if possible, or
  suggest retrying. Do not fall back to the running list unless Jake confirms
  we're in conversation mode or the issue can't be resolved.

---

## Step 2: Maintain a Running List (Conversation Mode Fallback)

If Todoist is unavailable, maintain a numbered running list inline in the
conversation. Format:

```
1. **[Task title]** — [Context note]
2. **[Task title]** — [Context note]
```

- Keep the list visible and up to date as new items are added throughout the
  conversation.
- Apply all the same task-framing rules (see Step 3) to running list items as
  you would to direct Todoist additions.

---

## Step 3: Frame Every Task as a Next Physical Action (GTD)

Before adding any task — whether to Todoist or the running list — make sure the
title describes a **concrete next physical action**: the very next thing Jake
would physically do to move this forward.

**Bad**: "iOS shortcut for Claude"
**Good**: "Review Claude iOS URL scheme docs to determine if conversation mode
parameter is supported"

### When the next action is unclear

If the best next action is ambiguous, **steer toward the discovery action** that
will clarify what to do — rather than assuming. Typically this means the task
becomes: "Research / review [X] to determine [Y]."

Where possible, include a direct link to the relevant documentation or resource
in the task description so Jake doesn't have to go find it again.

### When to ask clarifying questions

This applies only when Jake has already asked for the task. If you're
considering an unprompted offer and the next action is unclear, don't ask, and
don't offer (see Step 6).

If the task is too vague to determine the next physical action, ask Jake one
focused question to nail it down before adding it. Don't ask multiple questions
at once. Examples of when to ask:

- "What would doing this look like in practice — is there a specific thing to
  open, read, or write first?"
- "Is the next step to research this, or do you already know what to do?"

---

## Step 4: No Metadata Unless Jake Prompts It

Do **not** ask about or assign:
- Due dates
- Priority levels
- Labels
- Project assignment

These are determined during inbox processing. Jake will handle them then.

Only add metadata if Jake explicitly suggests it (e.g. "add this as p1" or
"put it in the Job Search project").

---

## Step 5: Include Context in the Task Description

Every task should carry enough context in its description for Jake to mentally
reconstruct the situation when he encounters it during inbox processing — which
may be hours or days later.

Good context includes:
- What conversation or situation prompted this task
- What the goal or outcome is
- Any relevant links, docs, or resources
- What was uncertain or unresolved at the time

Keep it concise — this is a reminder, not a full brief.

---

## Step 6: When to Offer Capture (Unprompted)

This section covers tasks Jake has **not** asked you to add. Silence is the
default. Offering is the exception, and the bar is high.

### The gate

Only offer when all three are true:

1. **Jake has landed on a direction.** He said he'll do it, chose between
   options, or agreed with something you proposed. Interest, curiosity,
   venting, and thinking out loud do not count.
2. **The exchange has moved past the question.** If Jake asked a question,
   answer it and stop. No offer in that turn, and none in a turn that answers a
   follow-up. Wait for him to respond in a way that shows he's decided.
3. **The next physical action is already obvious** from what's been said. If
   you'd need to interview him to write the title, you're too early.

### Never offer

- In any turn that answers a question Jake asked.
- While he's still comparing options or exploring an idea.
- For something he mentioned as background, context, or an aside.
- More than once per topic. Declined or ignored means dropped.
- For anything that takes under two minutes and needs no computer. Say "that's
  a two-minute thing, do it now" instead.

When it's a close call, stay quiet. Jake asks when he wants something captured,
and a missed offer costs him nothing.

### How to offer

Show the proposed title and description, then wait for approval before writing
anything to Todoist:

> "Want this in your inbox?
> **[Title]** — [Description]"

---

## Step 7: End-of-Conversation Reminder

When the conversation is winding down — look for signals like "thanks", "that's
all", "I think we're done", or a natural stopping point — and a running list has
been built up, remind Jake:

> "We've got [N] items on the running list. Want me to add them to your Todoist
> inbox now that we're out of conversation mode?"

If Jake confirms, add them all to Todoist using the Todoist connector, applying
the task titles and descriptions from the running list. Do not re-ask about
metadata.

---

## Step 8: Changing Existing Tasks (Protect Recurrence)

This applies everywhere Claude touches an existing task: weekly reviews, ad hoc
requests, scheduled tasks.

Before changing any task's date, check whether it recurs. The task's `recurring`
field holds the repeat pattern, or `false`.

- **To move a date**: use `reschedule-tasks`. Never use `update-tasks` with a
  `dueString` on a recurring task. That call replaces the whole due value and
  sets `recurring` to `false` (tested 2026-10-05).
- **To complete**: use `complete-tasks`. On a recurring task it rolls the due
  date to the next occurrence and keeps the repeat.
- **After either**: re-fetch the task and confirm `recurring` still holds the
  same pattern. If it doesn't, tell Jake immediately and offer to restore it.
- **To change the repeat pattern itself**: only when Jake asks. Then
  `update-tasks` with the new recurring `dueString` is correct.

---

## Quick Reference

| Situation | Action |
|---|---|
| Asked to add a task, Todoist works | Add directly, confirm |
| Asked to add a task, Todoist fails | Ask Jake to confirm: conversation mode or connection issue? |
| Task title is vague | Ask one clarifying question before adding |
| Next action is uncertain | Steer toward research/discovery task; include relevant link |
| Jake asked a question | Answer it. No capture offer this turn. |
| Jake is still exploring or comparing options | Stay quiet |
| Jake landed on a direction + next action is obvious | Offer once, show title and description, wait for approval |
| Under 2 min, no computer needed | Tell him to just do it now |
| Close call | Stay quiet |
| Metadata (due date, priority, etc.) | Never add unless Jake suggests it |
| Conversation winding down + running list exists | Remind Jake and offer to add items to Todoist |
| Move a task's date | `reschedule-tasks`, never `update-tasks` + `dueString` on a recurring task |
| Complete a task | `complete-tasks` |
| After moving or completing a recurring task | Re-fetch, confirm it still recurs, flag it if not |

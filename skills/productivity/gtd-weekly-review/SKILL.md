---
name: gtd-weekly-review
description: Guides the user through a complete GTD weekly review, one phase at a time, with full Todoist integration for surfacing, processing, and updating tasks along the way. Trigger this skill whenever the user says anything like "let's do my weekly review", "start my GTD review", "time for my weekly review", "walk me through my weekly review", "I want to do a weekly review", or similar. Also trigger if the user says they want to review their task system, projects list, or do a system review.
metadata:
  reach: all
---

# GTD Weekly Review

This skill guides the user through a complete GTD weekly review, phase by phase, using Todoist as the task system. Work through each phase in order. After finishing each phase, briefly note what was done, then ask if the user is ready to move on. Never skip ahead without confirmation.

Pull Todoist data at the start of each relevant phase — don't front-load everything at once.

---

## Before you begin

Pull the user's actual Todoist label names using the find-labels tool before starting the review. Don't assume label names — in particular, confirm the exact name of the Waiting For label (it may be `waitingfor`, `Waiting For`, or something else entirely) and use that exact name throughout.

- **Context labels**: Home, Office, Errands
- **Waiting For**: a Todoist label named `waitingfor`
- **Someday/Maybe**: a dedicated Todoist project
- **Next actions**: "Option A" — one next action per project is manually surfaced into the **Todo** project, which functions as a flat Next Actions list, not a true project. Don't treat Todo as a project during the projects review — it's the equivalent of a GTD Next Actions list. Review other projects and ensure each has one task surfaced in Todo.
- **Inbox**: the default Todoist Inbox

## What you can do in Todoist

- **Read**: pull tasks by project, label, or date range
- **Surface**: present tasks clearly, grouped logically
- **Add tasks**: when the user dictates something to capture
- **Reschedule**: when the user tells you to move a due date
- **Complete tasks**: when the user marks something done

Batch confirm changes where possible ("I'll reschedule those 3 and mark the 4th complete — confirm?") to avoid asking after every single action. Always confirm before executing.

## Phrasing tasks as next physical actions

Whenever you add or rename a task, phrase it as a specific next physical action — the literal first thing someone would do to make progress. Vague tasks like "Clean up office" or "Deal with HSA" aren't actionable; "Clear desk surface in office" or "Read Avidia HSA letter to understand balance" are.

If you can infer a reasonable first action from context, use it. If you genuinely can't tell what the first physical action is, ask before adding the task. Don't add vague tasks and plan to clean them up later.

## Flagging stale items

Flag as stale when:
- A project has no incomplete tasks (possibly abandoned or quietly finished)
- A project's tasks are all undated (no surfaced next action)
- A task outside of Someday/Maybe has no due date (surface it and let the user decide)

Don't flag tasks inside Someday/Maybe as stale — that's normal for that project.

---

## Phase 1: Collect

**Goal**: get everything out of the user's head and physical environment into the system.

Open with: "Let's start the weekly review. First: do a quick physical sweep — desk, pockets, notebooks, any loose paper or sticky notes. Anything that needs to go into your system? Tell me and I'll add it to your Inbox, or say 'done' when you're clear."

After physical sweep:
- Ask: "Any other capture points? Email inbox, browser tabs, Slack, voice memos?"
- Add anything dictated as tasks to the Todoist Inbox.

Then process the Todoist Inbox:
- Pull all tasks currently in the Inbox.
- If empty: note it and move on.
- If not empty: present tasks in batches of 3-5 and help triage each:
  - **Do it** (under 2 min — user handles it, you mark complete)
  - **Defer it** (schedule it or move to a project)
  - **Delegate it** (add the Waiting For label; optionally set a follow-up date)
  - **Someday/Maybe** (move to Someday/Maybe project)
  - **Delete it** (mark complete, or note that the user should delete it)

When triaging, don't suggest creating a new project for a task unless the user explicitly asks for one. If a task seems related to an existing project, you can ask — but default to keeping it as a standalone task or filing it into something that already exists.

Work through the full Inbox before moving on.

---

## Phase 2: Past Week Review

**Goal**: catch anything that fell through from the past 7 days.

Before pulling calendar data, prompt the user to open their Obsidian daily notes for the past week and scan through them for anything that needs capturing. Wait for them to confirm they've done that, or capture anything they dictate.

Then pull last week's calendar events from Google Calendar (the 7 days prior to today). Present them as a scannable list — event name, date, and day of week, grouped by day. Insert a visual week separator (e.g. "── Week of [Sunday date] ──") whenever the list crosses into a new week. Weeks start on Sunday, so the label should always use the date of that week's Sunday — e.g. events on May 5-8 fall in the "Week of May 3", not "Week of Apr 28". Then ask: "Looking at these — did anything come up that generated a task or follow-up you haven't captured yet?"

Capture whatever the user dictates. Add directly to a project if they specify one, otherwise add to the Inbox.

---

## Phase 3: Upcoming Calendar

**Goal**: prepare for what's coming in the next two weeks.

Pull the next 14 days of calendar events from Google Calendar. Present them the same way — event name, date, and day of week, grouped by day, with a week separator whenever the list crosses into a new week starting Sunday. Then ask: "Anything coming up that needs prep work, a decision, or a task added?"

Capture whatever the user dictates.

---

## Phase 4: Waiting For

**Goal**: ensure nothing is stuck or forgotten.

Pull all tasks with the Waiting For label. Present them clearly:

```
Waiting For (N items):
1. [Task] — due: [date or "no date"]
2. ...
```

For each, ask: still waiting, got a response, or need to follow up?
- **Still waiting**: keep as-is, or reschedule for a follow-up nudge
- **Got a response**: mark complete; capture any resulting next action
- **Follow up needed**: reschedule or add a follow-up task

---

## Phase 5: Projects Review

**Goal**: make sure every active project has a clear next action.

Pull all projects, excluding Inbox, Someday/Maybe, and Todo (which is the Next Actions list, not a true project).

For each project, check whether it has a task currently surfaced in Todo as its active next action. Flag a project if:
- It has no tasks at all (possibly done or abandoned)
- None of its tasks appear in Todo (no next action surfaced)

When a project is missing a next action in Todo, help the user pick one from the project's task list and move it to Todo.

Let the user move quickly through ones they're confident about ("looks fine" = skip). For flagged projects, ask:
- Is it done? (close/archive it)
- Does it need a next action? (add one)
- Do any tasks need rescheduling or reorganizing?

Work through projects one at a time. Don't dump the full list at once.

---

## Phase 6: Someday/Maybe Review

**Goal**: keep the list current — prune what's no longer relevant, activate what's ready.

Pull all tasks in the Someday/Maybe project. Present the full list so the user can scan it. They don't need to go item-by-item — let them call out what they want to act on.

Options for each item:
- **Still relevant**: leave it
- **Activate it**: move to an active project and help add a next action
- **Drop it**: mark complete

---

## Phase 7: Next Actions Sweep

**Goal**: surface anything overdue or unscheduled that needs a decision.

Pull:
1. Overdue tasks (excluding Someday/Maybe)
2. Undated tasks outside Someday/Maybe

**Overdue tasks**: present and resolve these directly -- there are usually few of them and each one needs a concrete decision (reschedule, complete, or move to Someday/Maybe).

**Undated tasks**: there may be a lot of these, and going item-by-item in conversation is slow and shallow. Instead, do a review pass yourself first:
- Look for tasks that appear stale (old IDs, vague content, no clear owner or context)
- Flag anything that seems like it might be done, abandoned, or needs clarification
- Ask any specific questions that would help the user decide (e.g. "Is the Move Office project still active, or has it stalled?")
- Point out clusters of tasks that might be candidates for pruning or consolidation

After sharing your observations, tell the user: "Take a few minutes to go through the rest of the undated tasks in Todoist directly -- you'll move faster there than in conversation. Come back when you're done and we'll move on." Wait for them to confirm before proceeding.

This keeps the review honest without turning it into an exhausting item-by-item verbal drill.

---

## Phase 8: Get Creative

**Goal**: surface anything bigger that isn't captured in the system yet.

This phase requires active engagement — don't just ask the questions once and move on. Push back, dig deeper, and brainstorm collaboratively. People tend to undersell what's on their mind here, especially after the effort of the earlier phases.

Start with:
- "Anything on your mind that doesn't fit into your current projects?"
- "Any projects you've been meaning to start but haven't?"
- "Anything to add to Someday/Maybe while it's fresh?"

When the user mentions something new, don't just capture it and move on. Ask follow-up questions like:
- "What else would need to happen for that to be complete?"
- "What's the second thing you'd do after the first task?"
- "Are there other dimensions to this you haven't mentioned?"

When a new project gets created during this phase, actively brainstorm what belongs in it. Propose 3-5 plausible tasks based on what the user described, let them react, and capture what sticks. Don't wait for them to enumerate everything themselves.

Keep pushing until the user explicitly signals they're done — a short answer isn't a cue to wrap up, it's a cue to ask a follow-up.

---

## Phase 9: Wrap Up

Before summarizing, do a second Inbox pass — tasks captured during phases 2-8 land in the Inbox and won't have been triaged yet. Pull the Inbox and process any new items the same way as Phase 1.

Then summarize the review:
- Inbox items processed
- Projects reviewed, and how many had issues flagged or resolved
- Waiting For items cleared or updated
- New tasks or projects added

Close with: "System's clean. Weekly review done."

---

## Tone and pacing

- Keep it efficient and direct. The user doesn't need encouragement — they need clarity and forward motion.
- If the user says "skip" or "looks fine," move on immediately, no fuss.
- If they're getting stuck on a single item, nudge: act on it now, park it in Someday/Maybe, or defer it — but don't linger.
- For phases 2 and 3, pull calendar events from Google Calendar before asking the user for input.

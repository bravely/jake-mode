---
name: "weekly-retro"
description: "Runs a short weekly retrospective as a conversation, then writes it up as a dated note that feeds the next weekly review. Trigger whenever the user says anything like \"let's do my retro\", \"weekly retro\", \"time for my retrospective\", \"run my retro\", or \"let's look back at last week\". Also trigger when a scheduled task fires the weekly retro. Do not trigger for the GTD weekly review, which is a separate skill and a separate session."
metadata:
  reach: all
---

# Weekly Retro

A reflective session run on Thursdays. It is deliberately separate from the GTD weekly review, which happens on a later day and inherits this session's decision.

Four questions, in order. Then a written note.

This session is not a task-capture session. See "What not to do" below, because that constraint is the reason this skill exists.

---

## Philosophy

This governs the tone of every question. Read it before starting and hold it throughout.

This is not about the user making mistakes, doing things better, or being stupid. It is about finding where systems and processes are broken. People will consistently fail. That is expected, and it is not a sign the person did a bad job. It is a sign the system needs to change.

In practice this means:

- When something did not happen, the question is what made not doing it the path of least resistance, not why the user lacked discipline.
- If the user starts assigning fault to themselves, redirect to the system. "What would have had to be true for that to happen on its own?" is usually the right follow-up.
- A week where nothing broke is still worth examining. Friction that did not stop the user is exactly the improvement that otherwise gets left on the table.
- Never offer reassurance in place of analysis. The user is not looking to feel better about the week, they are looking for the thing to change.

---

## Emotions are clues

This is the core method and it overrides any instinct to keep things moving.

Emotions point at the structural issues worth working on. If the retro only covers "this could have gone better" without processing the feeling behind it, it produces surface-level sweeping and misses the structural problem in the user's approach. The value of the session is in following the emotional thread until something structural surfaces.

So:

- Stop on emotional words. Shame, dread, nervous, frustrated, proud, "felt weird", "I don't know". Each one is a thread to pull, not a detail to log.
- Never assume you understand the emotion. Do not name what the feeling is about or offer your own interpretation of it. Ask the user to explain what the feeling actually is and what it is about, in their words. A plausible-sounding guess is worse than a question, because it steers them toward your version.
- Keep pulling. After they explain, ask what is underneath it. Stay with it until a structural issue surfaces, something about how they approach things rather than what happened this week.
- When the user says something will sound weird, or hedges, or trails off, slow down further. That is usually where the real thing is.
- Do not tidy answers into summaries mid-thread. A summary signals the thread is closed. Only reflect back when it helps the user see the shape of what they said, and then ask whether it is right.
- Watch for repetition across retros. The same feeling or failure mode showing up in more than one week is a signal it is structural, not situational. Check the retro log in memory for this.
- Do not hurry toward the one change. The one change comes out of the threads; it is not the goal the threads are in service of. Let the user say when a thread is done.

---

## Before you begin

Find last week's one change. Check, in this order:

1. Memory, where the most recent retro's one change should be recorded.
2. Past conversations, searching for the previous retro session.
3. If the user has the vault open, the previous dated retro note.

If none of those turn up a prior change, say so plainly and skip question 1. Do not invent one or guess from context.

Do not pull Todoist or calendar data at the start. This session runs on the user's recollection, not on system state. Pulling data turns it into a review, which is the failure mode this session exists to avoid. If a specific fact is genuinely needed to answer a question, pull just that.

Open with something like: "Retro time. Last week's one change was [X]. How did that go?" If there is no prior change, open with question 2 instead and say why.

---

## The four questions

Ask one at a time. Wait for the answer. Follow every emotional and mental thread in the answer before moving to the next question.

### 1. How did I do against last week's one change?

Skip if there is no prior change on record.

Looking for a straight answer: it held, it partly held, or it did not. If it did not hold, the interesting part is what displaced it, not that it failed. If the user expresses any feeling about how it went, pull on that before moving on.

If the change held, ask whether it should continue as a standing thing or whether it is now automatic enough to stop tracking.

### 2. What went well?

This goes before the hard question deliberately. Question 3 runs long, and if it comes first this one gets skipped.

Push past the first answer. "Nothing much" is not an answer, it is fatigue. Ask what got done that would not have got done a month ago, or what was easier this week than usual.

Where something went well, ask why. A thing that worked is a system that worked, and it is worth knowing which one.

### 3. What got hard, slow, or didn't happen?

The phrasing covers three distinct cases on purpose: things that went badly, things that dragged, and things that never started at all. All three have the same underlying cause more often than not.

This is where the philosophy and the emotional method do the most work. Ask how it felt, have the user explain the feeling, then look at where the friction sat:

- What was the state of things right before the moment it stalled?
- Was the next step actually clear, or did it require a decision first?
- Did it depend on something that was not ready?

Let this run as long as it needs. It is the question with the most in it.

### 4. What is the one thing I'm doing about it?

One. Not two, not a list. The whole point is that it stays in the user's head all week without effort.

Push on vagueness. "Be more consistent" is not a change. "Do X before Y" is. If the user offers several, ask which one, if it worked, would make the others matter less.

Prefer a change that addresses a structural issue surfaced in question 3 over one that patches a surface symptom.

If the chosen change needs a task, or a setting altered, or something built, note it for the writeup rather than acting on it here.

---

## Writing the note

Produce a dated note the user can save into their Obsidian vault. If vault access is available, offer to write it directly. If not, output it in the conversation so it can be copied later. The conversation does not depend on the vault, only the persistence does.

The note is edited prose, not a transcript. Do not reproduce the back and forth. Write it so that someone reading it cold understands what the week was like and why this particular change was chosen. Aim for something a person reads in two minutes.

Structure:

```
# Weekly Retro, [date]

## Last week's change
How it went, in a sentence or two. Omit this section on the first ever retro.

## What went well
Prose, not bullets. What worked and, where it is known, why.

## What got hard, slow, or didn't happen
The substantive section. Name the friction, the feeling behind it in the
user's own terms, and the structural issue it pointed to.

## The one change
State it plainly, in one line, at the top of this section. Then a short paragraph
on why this one and not the alternatives that came up.

## For the review
Anything the weekly review should act on. Pruning candidates, tasks that need
rephrasing, projects that came up as stalled or no longer wanted. Bullets are
fine here. This section exists to make the next session faster.
```

After writing, record the one change and any structural issues surfaced in memory so the next retro can find them without depending on the vault.

---

## What not to do

The weekly review had become pure list mechanics, so thoughts about why a week went the way it did had nowhere to live. They either got dropped or got converted into tasks, and those tasks fed the overwhelm that made the whole system harder to work. This session is the place those thoughts live now.

So:

- Do not turn insights into a pile of Todoist tasks. The one change is the commitment. Everything else goes in the "For the review" section as a note, not as a task.
- Do not add tasks during this session unless the user explicitly asks. If something clearly needs capturing, say so and let them decide.
- Do not go through lists, projects, or the inbox. That is the weekly review's job, on a different day.
- Do not propose a second change, even a small one, even when the user seems willing.
- Do not interpret the user's feelings for them.
- Do not rush to close a thread or to reach the one change.

---

## Tone and pacing

- Direct, no encouragement, no affirmations. Do not open with praise or validate the user's framing before responding to it.
- Short turns. Long responses stall the conversation. Short does not mean hurried: a short turn that asks one good question about a feeling beats a long one that summarizes and moves on.
- One question per turn.
- Depth over speed. There is no time target. Follow threads until the user says they are done with them.
- If the user is tired and wants to wrap up, follow their lead. They decide when to stop, not the clock.

---

## Meta retro

If the user asks for a retro on the retro, keep it separate from the retro content. The meta retro is about the process and how the session was run. Material that improves the week's retro itself belongs to the retro, not the meta retro. If a meta retro produces a standing change to how retros run, update this skill.

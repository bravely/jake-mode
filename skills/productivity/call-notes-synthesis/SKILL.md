---
name: call-notes-synthesis
description: Turns raw, real-time notes from a voice or video call that could not be recorded into a clean, organized note in the user's own shorthand style, actively chasing down gaps and ambiguities first so information is retained while memory is still fresh. Trigger whenever the user says anything like "synthesize my call notes", "process my notes from a call", "clean up my meeting notes", "I just got off a call, here are my notes", "turn my raw notes into a proper note", "help me write up this call", or pastes raw notes from a meeting/appointment/call and asks for help organizing them. Works for any unrecorded call: work meetings, recruiter screens, 1:1s, medical or therapy appointments, school or service calls, personal calls.
metadata:
  reach: all
---

# Call Notes Synthesis

This skill turns messy, in-the-moment notes from an unrecorded call into a clean note the user can actually use months later. The value is in catching what the raw notes lost: abandoned thoughts, floating references, unexplained terms, and buried follow-ups, while the user still remembers the call. Speed matters. Run this close to the call.

Work in order. The defining move is the clarification pass in Step 3: collect every gap and ambiguity first, ask them all at once, then synthesize. Never synthesize before the user has answered the clarification list.

---

## Core principles

These hold across every step. They are the point of the skill, not decoration.

- **Never invent content.** If something is missing or unclear, ask the user or flag it. Do not infer what the therapist "probably meant" or smooth a fragment into a plausible sentence. A confident-sounding reconstruction that is wrong is worse than a flagged gap.
- **Preserve high-value material verbatim.** Some things lose their worth the moment they are paraphrased. Keep these exactly as written, in quotes or a set-off block:
  - Direct quotes and scripts (e.g. a clinician's exact limit-setting phrasing, a recruiter's exact comp range wording).
  - Named frameworks, programs, acronyms, and their expansions (e.g. HALT = Hungry/Angry/Lonely/Tired).
  - Numbers, scores, scales, measurements, dates, durations (e.g. "68 on aggressive", "0-1-2 scale, 2 is bad", "20 minutes").
  - Proper nouns and specific resources mentioned or being sent.
- **Keep the user's voice, but consolidate hard.** Output stays in their bullet/shorthand style. Do not expand terse bullets into prose, and do not add an executive summary unless asked. Actively compress: merge elaborative child bullets into their parent, combine redundant points, tighten wording. Aim for the densest note that loses no specific fact and keeps every verbatim-preserve item intact. Shorter wins as long as specificity survives.
- **Read indentation as meaning.** The user uses bullet depth to imply relationships: a child bullet elaborates, supports, specifies, or answers its parent. Before flagging anything as unclear, resolve it by reading up and down the hierarchy. The answer to a parent bullet's ambiguity is often sitting in its own children.
- **No em dashes** in any output. Use commas, parentheses, or separate sentences. This is a standing user preference and applies to the synthesized note too.
- **Batch the questions.** One numbered clarification list, not a drip of one-at-a-time questions. The user rips through it in a single pass.

---

## Step 1: Intake

Get the raw notes. The user will usually paste them. If they point to a file and file access is available, read it; otherwise ask them to paste.

Then capture the light header metadata, inferring what you can from the notes and asking only for what is genuinely missing:
- **Date** of the call (default to today if the notes were just taken and the user confirms).
- **Who** was on the call (person and/or role, e.g. "Wren's play therapist").
- **Call type** (work meeting, recruiter screen, appointment, etc.), which also tells you how to group the content later.

Do not over-collect. A header is three short fields, not a form.

---

## Step 2: First-pass analysis (silent)

Read the full notes once and build your clarification list. You are hunting for five things. Use the examples as a pattern, not a checklist limited to these cases.

**First resolve, then ask.** For every candidate gap, try to settle it from the bullet's own children or parent and from surrounding context before it becomes a question. Only items that still block a faithful writeup after that pass go on the list. The user also types occasional nervous-tic fragments, a short run of repeated letters like `Fffff`. These are noise, not content. Drop them silently and never ask about them.

1. **Abandoned or trailing-off thoughts.** A real sentence that cuts off mid-idea. Example: `This is helpful to know because these`, where the reason is missing, though check the child bullets first, the reason is often there. Distinguish these from tic fragments, which you drop without asking.
2. **Floating references with no subject.** A bullet that states something but never says who or what it is about. Example: `Creative kids` sitting alone, where it is unclear whether this is an observation about the user's child specifically or a general point the other person made.
3. **Unexplained terms, acronyms, and programs.** Anything a reader in three months would not decode. Example: `"PEACE" as an outlet`, or `Child/Parent rel therapy`. Ask what it stands for or what it is.
4. **Ambiguous attribution or pronouns.** Who said it, who it refers to, what it contrasts with. Example: `She's gonna send us a milestone thing`, where "she" needs pinning down, or `Some kids are very independent` where it is unclear what point this was supporting.
5. **Compressed shorthand that will not survive time.** A number or phrase that made sense live but is missing its anchor. Example: `Borderline on it- 68`, which needs "68 on what measure, out of what range".

While you do this, also tag, but do not yet ask about:
- **Follow-ups and to-dos** buried in the notes (things being sent, things the user agreed to do, things to schedule). These feed Step 5.
- **Verbatim-preserve items** (quotes, frameworks, numbers) so you keep them intact during synthesis.

---

## Step 3: One clarification pass

Present every gap and ambiguity that survived Step 2 as a single numbered list. Aim for the shortest list possible. If it runs long, re-check whether structure or context already answers some, and fold multi-part questions about the same bullet into one numbered item. Quote the exact fragment from their notes so they know what you are pointing at. Keep each question short and answerable in a phrase.

Format:

```
Before I write this up, here's everything that's unclear from your notes. Answer as many as you can in one pass:

1. "Fffff" — what was this bullet meant to capture?
2. "Creative kids" — is this about Wren specifically, or a general point the therapist made?
3. "PEACE" — what does this stand for / what is it?
4. ...
```

The user answers in one go. If they cannot recall a given item, that item is handled per the unfillable rule below. Do not re-ask or push on items they have already passed on.

---

## Step 4: Synthesize the note

Write the clean note in the user's shorthand style. Structure:

1. **Light header** at the top:
   ```
   ## [Call title]
   *[Date] · [Who] · [Call type]*
   ```
2. **Organized, consolidated body.** Group related bullets under clear subheadings drawn from the actual content. Groupings vary by call, so derive them each time rather than forcing a fixed set. Within each group, consolidate: collapse a parent and its elaborative children into one dense bullet where that reads tighter, merge redundant points, and fold in clarification answers so each bullet stands on its own. Preserve nesting only where it carries real structure (a genuine sub-list, an ordered sequence). Keep everything terse, never prose.
3. **Verbatim blocks** for the preserve-items. Keep quotes, scripts, frameworks, and scores exactly as given. If a framework has a sequence (e.g. a three-step script), keep it as an ordered list in the original wording.
4. **Unfillable fragments.** For anything the user could not recall, keep the original text verbatim and append an `[unclear]` marker so it is visible but not silently dropped. Example: `Creative kids [unclear]`.
5. **Follow-ups section** closing the action cluster, listing every to-do, thing being sent, or item to schedule that surfaced. Phrase each as a concrete next physical action starting with a verb.

   ```
   ### Follow-ups
   - [ ] Set up recurring 20-min "special playtime" on the shared calendar, labeled "Mom/Wren 1:1"
   - [ ] Watch for the 5-6yo milestone doc the therapist is sending, save to Obsidian
   ```

Order the sections by topical affinity so related ones sit adjacent. Keep understanding-oriented sections together (observations, things to watch, assessment data) and action-oriented sections together (recommendations, tools or scripts, follow-ups). Do not strand the Follow-ups section at the far end of the note past unrelated sections; it belongs right after the recommendation and action content that produced it.

Present the finished note as a copy-pasteable markdown block so the user can drop it straight into Obsidian. If file access to their vault is available, offer to write it there instead.

---

## Step 5: Offer follow-ups as Todoist tasks

After the note is delivered, offer to add the follow-ups to the Todoist inbox. The user has opted into this for call notes, so offer it every time follow-ups exist, but still follow their standing task-capture rules (see the todoist-inbox-management skill):

- Frame each task as the most specific first physical action, starting with a verb, with enough context in the title or description to route it during inbox review without reconstructing why it mattered.
- Show the proposed task (title and description) and wait for approval before adding anything.
- Add only the ones the user approves.

Do not add tasks silently and do not assume all follow-ups should become tasks. Some live fine in the note's Follow-ups section without entering Todoist.

---

## Tone and pacing

- Direct and efficient. No preamble, no validation, no encouraging sign-offs.
- The clarification list is the heaviest lift for the user. Make it fast to answer: exact fragment quoted, one crisp question, no essay.
- If the user passes on an item, move on without comment.
- Do not pad the synthesized note. A shorter note that is fully decoded beats a longer one that reintroduces ambiguity.

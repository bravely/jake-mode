---
name: availability
description: Availability for scheduling - turn the user's calendars into bookable ranges and draft the reply. Use when someone has asked the user for times or days that work, when proposing slots for a call, interview, or meeting, or when the user asks what is open before committing to something.
metadata:
  reach: all
---

# Availability

Turn the user's calendars into a short set of ranges they can paste into a reply.

The output is **ranges, not slots**: a window of hours and the days it applies to, rather than a handful of specific start times. Discrete times make the user look more constrained than they are and invite another round of back-and-forth.

## Standing window

Default bookable hours: **9:00 to 15:00 local**, any day with nothing binding in it.

This is the one line to edit as the user's schedule changes. Anything the user says in the current conversation overrides it.

## Steps

### 1. Pin the ask

Establish from the request itself:

- **Who** is asking, and what the meeting is.
- **How long** it runs.
- **Which days** they asked about. "This week and next" anchors to the sender's message date, not to today.

Read the actual message. A summary of it, including one written earlier by you, drops the constraints that matter.

### 2. Read the calendars

Read every calendar the user has across the asked-about window, not just the primary one. Shared and family calendars are where the real conflicts hide.

Take the timezone from the calendar rather than from memory. Calendar listings report an IANA zone per calendar, and the offset label (MDT vs MST, BST vs GMT) depends on the date, so a remembered abbreviation is wrong for part of the year.

### 3. Classify every entry as binding

An entry is **binding** if it occupies the user during those hours. Work through every entry in the window and place each one:

- **Binding**: the user is committed. Subtract it.
- **Not binding**: it sits on a shared calendar but belongs to someone else. Ignore it.
- **Unknown**: you cannot tell from the entry. Ask.

A shared calendar holds both kinds. Another person's appointment can still bind the user, because someone has to drive, or cover childcare, or be home for it. Whose calendar it lives on does not settle the question. Only the user does.

Collect all the unknowns and ask about them in one message, as a short list, before drafting anything.

**Done when every entry in the window is marked binding or not binding, with none left unknown.** The draft is the visible payoff and it is tempting to guess the last one or two to reach it. A guess here is the error that survives all the way to the recipient: it either books the user over a real commitment, or hides a day that was free.

### 4. Build the ranges

Subtract the binding entries from the standing window, day by day.

- An entry ending before the window opens, or starting after it closes, takes nothing. Note it and move on.
- An entry inside the window splits the day. Offer the larger part, or both if both are usable.
- A day with no usable remainder is out. Name it explicitly rather than omitting it, so the recipient does not propose it.
- When several days come out identical, state the window once and list the days beneath it. Five repeated lines read as more constraint than one window and five dates.

### 5. Draft the reply

Write the times in the user's own timezone, named in full: "9:00am to 3:00pm Mountain". Keep them there even when you know the recipient's zone. Converting reads as a claim about where the user lives, and it moves the conversion burden onto the user, so a slot landing at 7:00am their time gets caught only after the invite arrives.

The message carries:

- The window and the days it covers.
- Any day inside the asked-about range that is out, by name.
- One line inviting them to take any hour inside it.

### 6. Hand it over

Create it as a draft where the user will send it from, and tell them where it is. The user sends it.

Alongside the draft, show them:

- Which days you offered and which you dropped, with the entry that dropped each one. This is what lets them catch a misclassification before it goes out.
- What the window converts to in the recipient's zone, so they can see how it lands on the other end. Keep that conversion out of the message itself.

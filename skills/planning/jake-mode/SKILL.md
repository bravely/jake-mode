---
name: jake-mode
description: Jake's router for engineering work. Matches the task to a playbook and runs its steps in order. Use for /jake-mode.
disable-model-invocation: true
metadata:
  experimental: true
---

# Jake mode

A router: it matches the task to a playbook, then runs that playbook's steps in order.

## Files

Paths here are relative to this file's folder. Resolve them against this file's absolute path.

- `playbooks/<name>.md` holds each playbook: a plain list of steps ending in a **Reply:** line.
- `design/` holds the reference files that playbook steps read by path. They are part of this skill, not skills of their own, so the Skill tool never loads them.

Playbook steps call other skills (`grilling`, `domain-modeling`, `codebase-design`, `tdd`) by name with the Skill tool. Each of those is model-invocable, so the call works from inside this skill.

## Running a playbook

1. Match the task to a playbook from the list below, and open its file.
2. Copy its steps word for word into the session's task list before starting the first one.
3. Run the steps in order. Each step ends when its own completion criterion holds.
4. A step that says **stop** is a checkpoint. End the turn there and wait for Jake's explicit approval before the next step. Everywhere else, keep going.
5. Finish with the playbook's **Reply:** line.

When no playbook fits, say so in one line and do the task without one.

## Playbooks

- **Implement** (`playbooks/implement.md`): starting or carrying a ticket from the tracker through design, phasing and stacked PRs.

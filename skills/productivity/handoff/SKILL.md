---
name: handoff
description: Compact the current conversation into a handoff document for another agent to pick up. Use only when the user asks for it by name, optionally saying what the next session will be used for.
license: MIT
metadata:
  reach: all
  upstream: mattpocock/skills skills/productivity/handoff at 6f7f783, MIT, see licenses/mattpocock-skills-LICENSE
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS (`$TMPDIR`, else `/tmp`; `%TEMP%` on Windows) - not the current workspace. In a chat with no access to the user's filesystem, give the document as a downloadable file or, failing that, in the reply.

Include a "suggested skills" section in the document, naming which skills the next agent should call the Skill tool for.

Do not duplicate content already captured in other artifacts (specs, plans, ADRs, issues, commits, diffs). Reference them by path or URL instead.

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.

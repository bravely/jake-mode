# jake-mode

Every skill and global rule of my own, and how each one reaches the places Claude runs. Machine setup, including the Claude Code settings and Declared plugins, belongs to [dotfiles](https://github.com/bravely/dotfiles), which has its own `GLOSSARY.md`.

## Skills

**Promoted skill**:
A skill of my own that has proven itself. Like every skill of my own, it lives in this repo under `skills/`.
_Avoid_: Stable skill, global skill

**Experimental skill**:
A skill of my own that is still being tried out, which a metadata field on the skill says. It lives beside the Promoted skills and reaches the same places they do; it becomes a Promoted skill when that field comes off.
_Avoid_: Draft skill, local skill

**Reach**:
Where a skill of mine can be used. A skill with reach `all` is carried by the Account plugin, so it works in chat, on mobile, and in every kind of Claude Code session. A skill with reach `code` works only in Claude Code sessions, local or cloud. A skill is `code` unless its metadata field says otherwise.
_Avoid_: Scope, surface (a surface is one place Claude runs, not a setting of the skill)

**Account plugin**:
The plugin this repo serves to each of my Claude accounts, carrying every skill with reach `all`.
_Avoid_: Plugin skill (dotfiles' term for a skill someone else wrote that arrives through a Declared plugin)

**Wiring**:
Making a skill or rule visible to Claude Code by linking it from where it lives into the harness's own directories.
_Avoid_: Installing (that is what happens to a plugin)

## Inboxes

**Work account**:
My Solace Gmail account.
_Avoid_: Work email, Solace inbox

**Personal account**:
My own-domain Gmail account, kept apart from the work account.
_Avoid_: Home email, personal inbox

**Gmail inbox**:
The mail sitting in the `INBOX` label of one of my Gmail accounts, waiting for a decision. Email triage works through it.
_Avoid_: Inbox, on its own

**Todoist Inbox**:
The default Todoist project, where captured tasks wait to be processed.
_Avoid_: Inbox, on its own

**Stream**:
The unit email triage decides about: the mail one sender sends to one recipient (me directly, or a group I'm in), narrowed to one kind of mail when that sender sends several kinds. Each stream gets two decisions, one for its backlog and one for its future mail.
_Avoid_: Subtype

**Backlog**:
A stream's mail already sitting in the Gmail inbox. Its decision is to archive it, leave it, or mark it as spam, separately from what happens to the stream's future mail.

**Category**:
Related streams presented together so they can share one decision, such as every account-security notice. Each stream in it still gets its own filter.
_Avoid_: Bucket, type

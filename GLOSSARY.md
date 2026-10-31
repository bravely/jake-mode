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
Where a skill of mine can be used. A skill with reach `all` is uploaded to my Claude account, so it works in chat, on mobile, and in every kind of Claude Code session. A skill with reach `code` works only in Claude Code sessions, local or cloud. A skill is `code` unless its metadata field says otherwise.
_Avoid_: Scope, surface (a surface is one place Claude runs, not a setting of the skill)

**Wiring**:
Making a skill or rule visible to Claude Code by linking it from where it lives into the harness's own directories.
_Avoid_: Installing (that is what happens to a plugin)

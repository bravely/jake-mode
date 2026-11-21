---
status: accepted
---

# Skills reach my Claude accounts as a plugin from this repo, not by hand upload

This supersedes ADR 0001's choice of hand upload. A skill with reach `all` now reaches
chat, mobile and every Claude Code session through the **Account plugin**. This repo is a
plugin marketplace whose one plugin, `jake-mode`, lives in `plugins/jake-mode/` and holds
one symlink per `all` skill. Each of my Claude accounts, personal and
work, adds the marketplace once and installs the plugin. ADR 0001 rejected this route because
attaching a custom marketplace to a personal claude.ai account was undocumented. It is now
documented, and a throwaway test repo on 2026-11-21 showed it working end to end.

## What the test showed

- **Chat:** both accounts accept a marketplace added by URL. After adding the marketplace,
  you have to search it for the plugin and install it; adding it installs nothing.
- **Skill names and front matter:** chat lists the skills under their plain names. claude.ai
  accepted the front matter my skills already use (`metadata.reach`, a quoted
  `description`).
- **Symlinked skills:** a plugin whose `skills/<name>` is a symlink to a folder outside the
  plugin works. claude.ai stores a real copy, and Claude Code's synced copy is a plain file.
- **What claude.ai refuses or reads:** it skips any plugin with a top-level `bin/`, and it
  loads every `SKILL.md` anywhere in the plugin's folder, listed or not. A name that clashes
  with a hand-uploaded skill, and a `CLAUDE.md`, did not block a plugin.
- **Claude Code and cloud sessions:** Claude Code downloads the account's plugins on one
  start and loads them on the next, as `jake-mode:<name>`. This does not touch
  `~/.claude/settings.json`, so dotfiles does not revert it. Cloud sessions get them too,
  so `bin/cloud-setup` installs nothing for this.
- **No nested plugins:** claude.ai skipped a plugin that had another
  `.claude-plugin/plugin.json` below it.
- **Updates are not automatic:** claude.ai did not pull a push on its own, even with
  **Sync automatically** switched on. The repo has no webhook, and claude.ai offered no way
  to make one. **Check for updates** pulled it at once.

## Considered Options

- **Keep the hand upload (ADR 0001)**: rejected. Each change meant zips, an upload per skill
  per account, and a label gate. The plugin needs one click per account per merge.
- **The repo root as the plugin, listing the `all` skills in `plugin.json`**: tried first and
  merged, then dropped. claude.ai refused it: "claude.ai-hosted plugins may not ship bin/
  executables", and jake-mode's `bin/` holds its scripts. A second test showed claude.ai also
  reads every `SKILL.md` anywhere in a plugin's folder, whether listed or not, so a root plugin
  would carry the `code` skills to chat too. Renaming `bin/` would also have meant editing
  every cloud environment's setup script.
- **Moving the `all` skills into the plugin folder**: rejected. Symlinks work: claude.ai
  follows them and stores real copies, which chat and Claude Code both load, and the skills
  keep their place in the category layout.
- **Installing the marketplace directly in Claude Code as well, or forcing updates with a
  SessionStart hook**: rejected. Both apply the update no sooner than the account sync's next
  start does. A direct install would also be a second copy that takes precedence over the
  synced one.
- **A separate plugin for the work account without the personal skills**: rejected. A second
  plugin doubles the upkeep, and the work org's policy allows the whole one.

## Consequences

- The links repeat what `metadata.reach` says, so `bin/account-plugin` fails CI when they
  disagree, and `--write` rebuilds them.
- No `version` is set, so every commit on `main` is a release. After a merge that changes an
  `all` skill, each account needs **Check for updates**, and the CI summary says when.
- `plugins/jake-mode/` may hold only its manifest and the links, a linked skill folder may
  hold no symlink and no nested skill or plugin, and the plugin must be the only one in the
  repo. Because claude.ai follows the links, the check looks at every folder they lead to,
  and CI checks each pull request as it would merge.
- Rules still cannot travel in a plugin, so they and `code` skills keep reaching sessions
  through `bin/link` and `bin/cloud-setup`, as ADR 0001 describes.
- The front-matter limits from ADR 0001 still apply to `all` skills.

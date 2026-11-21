---
status: accepted
---

# Skills reach my Claude accounts as a plugin from this repo, not by hand upload

This supersedes ADR 0001's choice of hand upload. A skill with reach `all` now reaches
chat, mobile and every Claude Code session through the **Account plugin**. This repo is a
plugin marketplace whose one plugin, `jake-mode`, is rooted at the repo and lists each `all`
skill's directory in `.claude-plugin/plugin.json`. Each of my Claude accounts, personal and
work, adds the marketplace once and installs the plugin. ADR 0001 rejected this route because
attaching a custom marketplace to a personal claude.ai account was undocumented. It is now
documented, and a throwaway test repo on 2026-11-21 showed it working end to end.

## What the test showed

- **Chat:** both accounts accept a marketplace added by URL. After adding the marketplace,
  you have to search it for the plugin and install it; adding it installs nothing.
- **Skill names and front matter:** chat lists the skills under their plain names. claude.ai
  accepted the front matter my skills already use (`metadata.reach`, a quoted
  `description`).
- **Nested skills:** a skill nested under `skills/<category>/` works when `plugin.json`
  lists its directory.
- **Claude Code and cloud sessions:** Claude Code downloads the account's plugins on one
  start and loads them on the next, as `jake-mode:<name>`. This does not touch
  `~/.claude/settings.json`, so dotfiles does not revert it. Cloud sessions get them too,
  so `bin/cloud-setup` installs nothing for this.
- **No nested plugins:** claude.ai skipped a root plugin that had another
  `.claude-plugin/plugin.json` below it.
- **Updates are not automatic:** claude.ai did not pull a push on its own, even with
  **Sync automatically** switched on. The repo has no webhook, and claude.ai offered no way
  to make one. **Check for updates** pulled it at once.

## Considered Options

- **Keep the hand upload (ADR 0001)**: rejected. Each change meant zips, an upload per skill
  per account, and a label gate. The plugin needs one click per account per merge.
- **A subfolder plugin of symlinks to the `all` skills**: rejected. claude.ai's handling of
  symlinks is undocumented, and the explicit list in `plugin.json` needs nothing to move.
- **Installing the marketplace directly in Claude Code as well, or forcing updates with a
  SessionStart hook**: rejected. Both apply the update no sooner than the account sync's next
  start does. A direct install would also be a second copy that takes precedence over the
  synced one.
- **A separate plugin for the work account without the personal skills**: rejected. A second
  plugin doubles the upkeep, and the work org's policy allows the whole one.

## Consequences

- `plugin.json` repeats what `metadata.reach` says, so `bin/account-plugin` fails CI when
  they disagree, and `--write` regenerates the list.
- No `version` is set, so every commit on `main` is a release. After a merge that changes an
  `all` skill, each account needs **Check for updates**, and the CI summary says when.
- Nothing may add a `.claude-plugin/plugin.json` below the root. CI fails if one appears.
- Rules still cannot travel in a plugin, so they and `code` skills keep reaching sessions
  through `bin/link` and `bin/cloud-setup`, as ADR 0001 describes.
- The front-matter limits from ADR 0001 still apply to `all` skills.

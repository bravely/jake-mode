# jake-mode

A portable library of agent skills and global rules, wired into whatever
harness is in front of Jake. `README.md` has the layout, the categories and
the attribution rules for ported skills; read it before adding or moving a
skill.

`bin/link-skills` and `bin/link-rules` write symlinks into `~/.claude/` that
every Claude Code session on this machine follows. Sessions in this repo
usually run in a worktree under `.claude/worktrees/`, and a link into a
worktree dies with it.

## Wiring is post-merge, from the main checkout

- On a branch, the only touch on `~/.claude/` is `--dry-run`. The scripts
  refuse a real run from a worktree.
- The PR body and any handoff state wiring as a post-merge step with the
  exact command: `bin/link-skills && bin/link-rules`. Any completion
  criterion that needs `~/.claude/` touched ("resolves in a fresh session",
  "ends up all symlinks") is scoped post-merge too, and left explicitly
  undone on the branch.
- Before trusting an entry in `~/.claude/skills/` or `~/.claude/rules/`, run
  `readlink` on it to see where the link points; another session may have
  wired from its own worktree.

The wiring contract is `skills/meta/wire-skills/SKILL.md`; read it before
changing `bin/`.

## Anything worth remembering goes in the repo

This repository *is* the record of how sessions should behave, so a lesson,
convention or preference learned here lands in `CLAUDE.md`, `rules/` or a
skill, where it is versioned and visible to everyone who clones it. A memory
file lives on one machine and explains nothing to the next reader, so a
session in this repo writes one only when Jake asks for it by name.

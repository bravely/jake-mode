# jake-mode

This repository's scripts write outside it: `bin/link-skills` and
`bin/link-rules` create symlinks in `~/.claude/` that every Claude Code
session on this machine follows. A link that points at the wrong checkout
breaks silently for every future session.

## Wiring happens from the main checkout, after merge

Sessions in this repo usually run in a worktree under `.claude/worktrees/`.
Links into a worktree die when it is removed, so:

- Work on a branch validates with `--dry-run` only. The scripts refuse a real
  run from a worktree; do not work around that with `--target` or by copying
  files into `~/.claude/` by hand.
- Wiring is a post-merge step from `~/dev/jake-mode`. Say so in the PR body
  and in any handoff, with the exact command (`bin/link-skills && bin/link-rules`).
- "Confirm the skill resolves in a fresh session" is a post-merge check too.
  Leave it explicitly undone on the branch rather than satisfying it early.

Before trusting the state of `~/.claude/skills/` or `~/.claude/rules/`,
`readlink` the entries. Another session may have linked from its own worktree.

## Handoffs about this repo

A handoff that says "run X for real" names the checkout to run it from. A
completion criterion that can only be met by touching `~/.claude/` (for
example "ends up all symlinks") is scoped to after merge, or it will be
satisfied on the branch.

The wiring contract itself lives in `skills/meta/wire-skills/SKILL.md`; read
it before changing `bin/`.

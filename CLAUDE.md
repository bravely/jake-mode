# jake-mode

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
- `readlink` entries in `~/.claude/skills/` and `~/.claude/rules/` before
  trusting them; another session may have wired from its own worktree.

The wiring contract is `skills/meta/wire-skills/SKILL.md`; read it before
changing `bin/`.

---
name: claude-rc
description: Keep a Remote Control server running for a repo on this Mac with the claude-rc command, so sessions in it can be started from the Claude mobile app or claude.ai/code. Use when asked to make a repo reachable from the phone or remotely, to set up, check, restart or remove a repo's Remote Control server, or when remote sessions in a repo fail to start.
metadata:
  experimental: true
---

# claude-rc

`claude-rc` comes from the dotfiles (`~/.local/bin/claude-rc`). It keeps one
`claude remote-control` server per repo running as a LaunchAgent, restarted
if it dies and after every Claude update. Its `--help` is the full reference;
this skill covers what a session needs around it.

## Before running it

- **macOS only.** In a cloud session or on Linux there is nothing to set up:
  say so and stop.
- **`command -v claude-rc` finds nothing:** the dotfiles haven't been applied
  since the command landed. Ask the user to run `chezmoi apply`, then retry.
- **Only on request.** Each server lets the account start sessions in that
  repo in auto permission mode. Never set one up because a repo looks like it
  could use one.

## Commands

```bash
claude-rc ensure [DIR]           # set up, update or load the repo's server; no-op if current
claude-rc status                 # every server and the updater, and what is wrong with each
claude-rc restart [DIR | --all]  # restart one server, or all of them
claude-rc remove [DIR]           # stop it and delete its LaunchAgent, even if the repo is gone
```

DIR defaults to the current directory. From a worktree it resolves to the
main checkout, so run it from wherever the session is. Every command exits 1
when it couldn't do what was asked, so the exit status is the answer: read
the output, don't assume.

If the permission check refuses the command (it writes LaunchAgents and
calls `launchctl`), give the user the exact command to run themselves rather
than working around it.

## When `ensure` refuses

A server has no terminal to answer prompts, so `ensure` checks first and
names what is missing. Only the user can do these; relay the step and stop.

| `ensure` says | The user does |
|:--|:--|
| claude is not logged in | Run `claude`, then `/login`. |
| hasn't been trusted yet | Run `claude` in the repo and accept the folder-trust prompt. |
| Remote Control hasn't been enabled | Once per Mac: run `claude remote-control` in a terminal, answer `y`, wait for Ready, Ctrl+C. Then wait a few minutes before `ensure`. |

That terminal run keeps the folder registered for a few minutes after it
stops. A server started meanwhile logs "already served by a terminal `claude
remote-control`" and launchd retries it every minute until it clears, so
`ensure` reporting "loaded but failing" straight after the consent step is
expected. Check `status` again in a few minutes before treating it as broken.

Never answer these prompts by editing `~/.claude.json`. Answering them is the
user's consent, not a setting.

## When remote sessions fail

1. `claude-rc status`. It names a server that isn't loaded, isn't running,
   last exited nonzero, or whose repo is gone, and says whether the updater
   is installed.
2. Read the server's log, `~/Library/Logs/claude-rc-<path>.log`, which
   `status` names.
3. `claude-rc restart DIR` for one server. After a Claude update with the
   updater missing, `claude-rc restart --all`, then `claude-rc ensure` to
   reinstall the updater.

A grayed-out entry for the repo in the Claude app is a previous server
start: each start registers a new environment. The live one isn't grayed
out. Nothing needs cleaning up.

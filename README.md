# jake-mode

A portable library of agent skills, kept in its own repository and wired into
whatever coding agent is in front of me.

Most skills here are ported from [`cursor/plugins`](https://github.com/cursor/plugins),
which is MIT licensed. They were the valuable part of a week-long Cursor trial.
The editor was not. The point of this repository is to keep the former without
depending on the latter. The rest are my own, kept here so they travel with
the ported ones.

## How it works

Skills live under `skills/`, grouped into categories. A harness scans only the
top level of its own skills directory, so the library reaches a harness by
symlink, one link per skill. Global rules, the always-on instructions Claude
Code loads from `~/.claude/rules/`, live in `rules/` and reach it the same
way, one link per file. One command makes both sets of links:

```bash
bin/link
```

That flattens `skills/<category>/<skill-name>/` into `~/.claude/skills/<skill-name>`
and links `rules/<name>.md` into `~/.claude/rules/<name>.md`. The repository
organizes its entries however it likes, and the links flatten them at the
boundary.

Run it with `--help` for the other options, or read
[`skills/meta/wire-skills/SKILL.md`](skills/meta/wire-skills/SKILL.md) for the
reasoning and the troubleshooting order. Run it from the main checkout, not a
worktree; it refuses otherwise, since links into a worktree die with it.

## Reach: where a skill can be used

Every skill says where it can be used through `metadata.reach` in its front
matter:

```yaml
---
name: some-skill
description: ...
metadata:
  reach: all          # or code, the default when absent
  experimental: true  # optional: still being tried out
---
```

- **`code`** skills are for Claude Code only. `bin/link` wires them on a Mac,
  and `bin/cloud-setup` wires them in cloud sessions.
- **`all`** skills are uploaded by hand to my Claude account, which delivers
  them to chat, mobile and every Claude Code session, local or cloud.
  `bin/link` deliberately does **not** link them, because the account sync
  already puts them in every session and a link would list them twice.
  `bin/link --include-all` links them anyway, so an edit can be tried locally
  before it is uploaded.

Custom fields go under `metadata` because claude.ai rejects an upload whose
front matter has any other key it does not know. The only top-level keys an
`all` skill may use are `name`, `description`, `license`, `compatibility`,
`metadata` and `allowed-tools`.

claude.ai has no upload API, so the upload is by hand, and CI keeps it from
being forgotten. The `claude-account-upload` check runs on every pull
request. When the pull request changes an `all` skill, the run summary lists
what to upload or delete at claude.ai (Customize > Skills), and the run's
`claude-account-upload` artifact holds the zips. The check fails until the
pull request has the `claude-account-synced` label. Add the label once the
account matches, or add it to skip syncing on purpose. A later push that
changes an `all` skill again removes the label. To build the zips locally,
run `bin/claude-account-upload`; add `--base main` to get only what a branch
changed.

## Cloud sessions

A Claude Code cloud session (claude.ai/code) runs in a fresh VM that never
sees this machine's `~/.claude`. `all` skills reach it through the account.
`code` skills and the rules reach it through each cloud environment's
**setup script**, which clones this repository and runs `bin/cloud-setup`.
That script wires everything into the VM's `~/.claude` the way `bin/link`
does here. It also installs a SessionStart hook that pulls and wires again
at the start of every session, because the setup script's result is cached
for up to about a week.

Every environment needs this as its setup script (the environment's
settings in claude.ai/code):

```bash
[ -d ~/dev/jake-mode ] || git clone --depth 1 https://github.com/bravely/jake-mode.git ~/dev/jake-mode
~/dev/jake-mode/bin/cloud-setup
```

To check an environment, start a session in it, then:

1. `/skills` lists the `code` skills, such as `wire-skills`.
2. `/context` lists the rules under Memory files, as `/root/.claude/rules/...`.
3. `cat ~/.claude/settings.json` shows the SessionStart hook running
   `bin/cloud-setup --refresh`.

An environment without the setup script still gets the `all` skills, but no
rules and no `code` skills.

## Why not just live in `~/.claude/skills`

Two reasons.

That directory belongs to one harness. Putting the library there couples it to
Claude Code, which defeats the purpose.

It is also shared territory, holding skills installed by other tools and
authored by other people. Versioning it wholesale means committing files I do
not own.

## Layout

| Path | Holds |
|:-----|:------|
| `skills/principles/` | The shared vocabulary of reasoning that other skills cite |
| `skills/planning/` | The multi-phase plan skeleton and its playbooks |
| `skills/verification/` | Proving a claim, driving a real app, generating per-project verify skills |
| `skills/delivery/` | Stacked execution, and the pull-request lifecycle (review guides, addressing review) |
| `skills/hygiene/` | Cleanup passes |
| `skills/meta/` | Skills about this library itself |
| `rules/` | Global rules, one concern per file |
| `bin/` | Wiring (`link`, `cloud-setup`) and the account upload (`claude-account-upload`) |
| `.github/workflows/` | The `claude-account-upload` check |
| `licenses/` | Upstream license texts |
| `GLOSSARY.md` | The terms this library uses for its own skills: Promoted, Experimental, Reach, Wiring |
| `docs/adr/` | Decisions about how skills and rules reach each place Claude runs |

Categories are for humans reading the repository. They disappear at the symlink
boundary, so skill names must be unique across the whole library.

The port lands one category at a time; see the tracking issue for what is in
flight. Directories appear as their phases complete.

## Conventions

**Generated verification skills are not library content.** The verification
skill generator writes a project-local verify skill and feature map describing
one specific codebase. Those get committed in that project's repository,
because the maintenance loop's job is keeping them synchronized with code that
changes. The library ships the generator. The project owns the output.

**Cross-skill references go by name, not path.** A skill names which principle
governs and lets the harness resolve it.

## License and attribution

Original content is MIT licensed; see [`LICENSE`](LICENSE). Ported skills keep
their upstream terms, recorded in [`NOTICE.md`](NOTICE.md) with the license
texts in [`licenses/`](licenses/).

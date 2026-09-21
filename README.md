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
symlink, one link per skill:

```bash
bin/link-skills
```

That flattens `skills/<category>/<skill-name>/` into `~/.claude/skills/<skill-name>`,
a symlink the harness follows. The repository organizes skills however it
likes, and the links flatten them at the boundary.

Global rules, the always-on instructions Claude Code loads from
`~/.claude/rules/`, live in `rules/` and are linked the same way:

```bash
bin/link-rules
```

Run either script with `--help` for the other options, or read
[`skills/meta/wire-skills/SKILL.md`](skills/meta/wire-skills/SKILL.md) for the
reasoning and the troubleshooting order. Run them from the main checkout, not
a worktree; they refuse otherwise, since links into a worktree die with it.

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
| `bin/` | Wiring |
| `licenses/` | Upstream license texts |

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

---
name: wire-skills
description: "Wire this library into a coding agent by symlinking each skill and each global rule into the harness's directories. Use when a skill or rule from the library is not showing up, after adding or renaming one, or when setting the library up on a new machine or a second harness."
---

# Wire the library into a harness

This library lives in its own repository and reaches a harness by symlink, one
link per skill and one per rule. This skill is how you create and repair those
links.

## Why links, and not the skills directory itself

A harness scans only the **top level** of its skills directory. A skill nested
in a category folder is invisible to it. So the library cannot simply be cloned
into that directory as-is without giving up its internal organization.

A name in that directory can be a symlink to a directory anywhere on disk, and
the harness follows it. That is the whole mechanism. The repository organizes
skills by category, and the links flatten them at the boundary. The library
stays harness-independent, and the same repository can feed several harnesses
at once.

Keeping the repository out of the harness directory matters for a second
reason. That directory is shared territory, often holding skills installed by
other tools and authored by other people. Versioning it wholesale means
committing files you do not own.

## Wire it

From the root of the **main checkout**, never a worktree: a link into a
worktree dies when the worktree is removed, so the script refuses to run for
real from one (dry runs are fine).

```bash
bin/link --dry-run
```

Run it for real once the dry run lists only links and adoptions you expect,
with no `conflict:`, `worktree:` or `dangling:` line:

```bash
bin/link
```

One run wires both kinds of entry. Skills: every directory under `skills/`
that contains a `SKILL.md`, linked under the directory name into
`~/.claude/skills/`. Rules: every `.md` under `rules/`, linked into
`~/.claude/rules/`, which Claude Code loads into every session, following
symlinks. One link per rule rather than linking the directory itself, so
machine-local rules this repository knows nothing about can sit alongside
ours.

Re-running is safe; it only touches entries it owns, and it checks every kind
before it touches either. A plain copy already sitting in a target with
identical content is adopted, swapped for a link without `--force`, since
nothing is lost.

Point a kind at a different harness with its target flag:

```bash
bin/link --skills-target ~/.config/some-other-agent/skills --skip rules
```

`--skip` leaves a kind alone entirely, for a harness that has no notion of
it. Set `JAKE_MODE_SKILLS_TARGET` or `JAKE_MODE_RULES_TARGET` instead when a
machine's default target is never the `~/.claude` one, so you do not have to
pass the flag on every run.

After renaming or removing a skill or rule, clear the stale link:

```bash
bin/link --prune
```

## When a skill or rule does not show up

Work through these in order.

1. **The link is missing or stale.** Run `bin/link --dry-run` and see
   whether it reports the entry as already current.

2. **Something else owns the name.** The script refuses to clobber an entry it
   did not create and says why: `conflict:` (another tool's link or file
   under the same name), `worktree:` (a link into a git worktree, wired from
   the wrong checkout; it dies when that worktree is removed), or
   `dangling:` (the target is already gone). For the last two, `--force` from
   the main checkout is the repair. For a real conflict, rename yours, or
   pass `--force` if you are sure you want the library's version to win.

3. **The front matter is malformed.** A skill without valid YAML front matter
   carrying `name` and `description` never registers. The `name` must match
   the directory name.

4. **The harness needs a restart.** Two behaviors are worth knowing apart.
   Edits to an existing `SKILL.md` are picked up inside a running session. But
   creating a **top-level skills directory that did not exist when the session
   started** is not watched until the harness restarts. If you just created the
   target directory, restart before you debug anything else. Rules load at
   session start, full stop: a new or edited rule needs a fresh session.

5. **It is a Cowork session.** Cowork skips symlinked rules that point outside
   the working directory, by design. The rules from this library are absent
   there and nothing in the wiring can change that.

## Adding to the library

A skill: create `skills/<category>/<skill-name>/SKILL.md`, then run
`bin/link`. Categories are for humans reading the repository; they
disappear at the boundary, so skill names must be unique across the whole
library. The script fails loudly if two collide rather than silently linking
one of them.

A rule: create `rules/<name>.md`, then run `bin/link`. Keep each rule to
one concern so it can be dropped or overridden on its own.

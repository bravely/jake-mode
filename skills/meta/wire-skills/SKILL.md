---
name: wire-skills
description: "Wire this skill library into a coding agent by symlinking each skill into the harness's skills directory. Use when a skill in the library is not showing up, after adding or renaming a skill, or when setting the library up on a new machine or a second harness."
---

# Wire the skill library into a harness

This library lives in its own repository and reaches a harness by symlink, one
link per skill. This skill is how you create and repair those links.

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

From the repository root:

```bash
bin/link-skills --dry-run
```

Read what it plans to do, then run it for real:

```bash
bin/link-skills
```

It links every directory under `skills/` that contains a `SKILL.md`, using the
directory name as the skill name. Re-running is safe; it only touches entries
it owns.

Point it at a different harness with `--target`:

```bash
bin/link-skills --target ~/.config/some-other-agent/skills
```

Set `JAKE_MODE_TARGET` instead when a machine's default target is never
`~/.claude/skills`, so you do not have to pass `--target` on every run.

After renaming or removing a skill, clear the stale link:

```bash
bin/link-skills --prune
```

## When a skill does not show up

Work through these in order.

1. **The link is missing or stale.** Run `bin/link-skills --dry-run` and see
   whether it reports the skill as already current.

2. **Something else owns the name.** The script refuses to clobber an entry it
   did not create and prints the conflict. Another tool may have installed a
   skill under the same name. Rename yours, or pass `--force` if you are sure
   you want the library's version to win.

3. **The front matter is malformed.** A skill without valid YAML front matter
   carrying `name` and `description` never registers. The `name` must match
   the directory name.

4. **The harness needs a restart.** Two behaviors are worth knowing apart.
   Edits to an existing `SKILL.md` are picked up inside a running session. But
   creating a **top-level skills directory that did not exist when the session
   started** is not watched until the harness restarts. If you just created the
   target directory, restart before you debug anything else.

## Adding a skill to the library

Create `skills/<category>/<skill-name>/SKILL.md`, then run `bin/link-skills`.
Categories are for humans reading the repository; they disappear at the
boundary, so skill names must be unique across the whole library. The script
fails loudly if two collide rather than silently linking one of them.

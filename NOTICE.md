# Attribution

Skills in this library are ported from [`cursor/plugins`](https://github.com/cursor/plugins),
which publishes each plugin under its own MIT license, and from
[`mattpocock/skills`](https://github.com/mattpocock/skills), also MIT licensed. The ports keep the
upstream license terms. Where a skill is derived from upstream work, its
provenance is recorded here and in the skill's own front matter.

## Upstream sources

| Upstream plugin | Copyright | License text |
|:----------------|:----------|:-------------|
| `pstack` | 2026 Lauren Tan | [`licenses/pstack-LICENSE`](licenses/pstack-LICENSE) |
| `cursor-team-kit` | 2026 Cursor | [`licenses/cursor-team-kit-LICENSE`](licenses/cursor-team-kit-LICENSE) |
| `mattpocock/skills` | 2026 Matt Pocock | [`licenses/mattpocock-skills-LICENSE`](licenses/mattpocock-skills-LICENSE) |

## What came from where

| This library | Upstream path |
|:-------------|:--------------|
| `skills/principles/` | `pstack/skills/principle-*` |
| `skills/planning/` | `pstack/skills/poteto-mode/` (plan skeleton, playbooks, `check-plan.mjs`) |
| `skills/verification/verify-this/` | `cursor-team-kit/skills/verify-this/` |
| `skills/verification/control-cli/` | `cursor-team-kit/skills/control-cli/` |
| `skills/verification/create-verification-skill/` | `pstack/skills/create-verification-skill/` |
| `skills/verification/maintain-verification-skill/` | `pstack/skills/maintain-verification-skill/` |
| `skills/delivery/` (stacking skills) | `pstack/skills/poteto-mode/playbooks/` |
| `skills/hygiene/deslop/` | `cursor-team-kit/skills/deslop/` |
| `skills/planning/jake-mode/` | Router and playbook shape from `pstack/skills/poteto-mode/`; two-shape sketch from `pstack/skills/architect/`; plan file from `pstack/skills/poteto-mode/playbooks/multi-phase-plan.md` |
| `skills/engineering/grilling/` | `mattpocock/skills` `skills/productivity/grilling/` |
| `skills/engineering/domain-modeling/` | `mattpocock/skills` `skills/engineering/domain-modeling/` |
| `skills/engineering/codebase-design/` | `mattpocock/skills` `skills/engineering/codebase-design/` |
| `skills/engineering/tdd/` | `mattpocock/skills` `skills/engineering/tdd/` |

The table describes the intended destination of each port. Rows land as their
phases complete; see the port tracking issue. Each vendored `mattpocock/skills`
skill records the upstream commit it was copied from in its front matter, as
`metadata.upstream`; bravely/jake-mode#47 tracks keeping those copies in step.

Original content in this repository, including `bin/`, `rules/`,
`skills/meta/`, `skills/delivery/address-pr-comments/` and
`skills/delivery/pr-review-guide/`, is licensed under [`LICENSE`](LICENSE).

# Branch naming

When creating a git branch for new work, choose the name by where the work came from:

- **Linear issue**: use the git branch name Linear gives the issue, exactly as Linear spells it: `<username>/<team>-<number>-<title-slug>`, e.g. `jakedemarest-mays/phy-1994-hello-my-name-is-update-physician-xp-advocate-card-to-use`. Read it from the issue (the Linear MCP's `get_issue` returns it as `gitBranchName`) rather than building it by hand, since Linear truncates the slug and lowercases the key.
- **GitHub issue**: name the branch `<issue-number>-<kebab-case-issue-title>`, e.g. issue #42 "Add CSV export" → `42-add-csv-export`. Fetch the real title first (e.g. `gh issue view <n>`) rather than guessing it.
- **Work requested directly** (no issue in play): use a short "good enough" kebab-case descriptor of the change, e.g. `fix-csv-quoting`.
- **When unsure of a good name** for a GitHub issue or direct work (ambiguous scope, multiple plausible descriptors, or the work doesn't reduce to one clear phrase): stop and ask me for the branch name before creating it. A Linear issue never needs this, since Linear's name is the answer.

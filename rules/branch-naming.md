# Branch naming

Name the branch with the git branch name Linear gives the issue, exactly as Linear spells it: `<username>/<team>-<number>-<title-slug>`, e.g. `jakedemarest-mays/phy-1994-hello-my-name-is-update-physician-xp-advocate-card-to-use`. Read it from the issue (the Linear MCP's `get_issue` returns it as `gitBranchName`) rather than building it by hand, since Linear truncates the slug and lowercases the key.

- **Work requested directly** (no issue in play): a short kebab-case descriptor of the change under the same username prefix, e.g. `jakedemarest-mays/fix-csv-quoting`.

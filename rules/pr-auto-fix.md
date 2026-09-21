# PR auto-fix

After opening a pull request from a desktop-app session, immediately turn on the CI monitor's auto-fix for it (`mcp__ccd_pr__set_monitor` with `auto_fix: true`, `address_comments: true`, and the PR URL) in the same turn as `gh pr create`. Don't ask — this is a standing default. If the auto-mode classifier prompts for approval anyway, that's expected; if I say the prompting is annoying, stop doing this rather than negotiating.

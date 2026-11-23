# Reaching Todoist

A session reaches my Todoist one of two ways, and which it has depends on where it runs. Try both before saying Todoist is unavailable.

- **Connector first.** When the session has Todoist connector tools, use them.
- **Otherwise the `td` CLI.** With no connector, check `command -v td`. When it is there, use it. The `todoist-cli` skill has the commands, and `td <command> --help` covers a machine where that skill is missing. A cloud session loads this rule but has no `td`.
- **Neither:** say so plainly, then follow the running list in `todoist-inbox-management`.
- **The route changes the tool, not the protocol.** `todoist-inbox-management` still decides what gets captured, how a task is worded, and how a recurring task is moved, whichever route carries it.

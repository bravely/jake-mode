# Name by the domain; let the code's shape say what it does

- **Name values by what they hold** (`statementIds`, not `ids`), and predicates by the question they answer (`isVoidable`, `hasPaymentActivity`).
- **Match the shape to the dependency.** Independent work over a list is a transform (`Promise.all(items.map(...))`, `.flat()`, a set difference); a loop that pushes into an accumulator implies each step depends on the last.
- **When a transform gets clever, extract a named pure helper.** A plain loop inside a well-named function beats a `reduce` that takes a minute to read.

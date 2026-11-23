# File links across repos

When a session has more than one repo or folder open, a relative file link resolves against the start folder: the one the session opened in, which stays the same when the shell `cd`s elsewhere. `README.md:70` written about another repo opens the start folder's `README.md`.

- **Every link opens the file its sentence is about.** A file outside the start folder takes the absolute path you read it at as its href.
- **The link text names the repo** when more than one open repo has a file of that name: `[jake-mode README.md:70](…)`.

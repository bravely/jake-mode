# Shared by bin/link-skills and bin/link-rules. Not executable on its own.
#
# Flatten one kind of repository entry into a harness directory, one symlink
# per entry, touching only entries this repository owns.
#
# The calling script sets, before calling link_entries:
#   PROG        its own name, for messages
#   WHAT        plural noun for usage text ("skills")
#   SOURCE_DIR  repository directory the entries live under
#   ENV_VAR     environment variable that overrides the default target
#   TARGET      the target directory (already resolved from $ENV_VAR)
#   entries     array of absolute source paths, one per link
#   entry_live  function: exit 0 if the path it is given is still an entry,
#               used by --prune to tell a stale link from a current one

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DRY_RUN=0
PRUNE=0
FORCE=0

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      -t|--target)  TARGET="${2:?--target needs a directory}"; shift 2 ;;
      -n|--dry-run) DRY_RUN=1; shift ;;
      --prune)      PRUNE=1; shift ;;
      -f|--force)   FORCE=1; shift ;;
      -h|--help)    usage; exit 0 ;;
      *) printf '%s: unknown option: %s\n\n' "$PROG" "$1" >&2; usage >&2; exit 2 ;;
    esac
  done
}

usage() {
  cat <<USAGE
Usage: bin/$PROG [options]

Link every entry in ${SOURCE_DIR#"$REPO_ROOT/"}/ into a harness $WHAT directory.

Options:
  -t, --target DIR   Harness $WHAT directory (default: ${TARGET/#$HOME/~},
                     override with \$$ENV_VAR)
  -n, --dry-run      Print what would change, touch nothing
      --prune        Remove links into this repo whose entry no longer exists
  -f, --force        Replace a conflicting entry that this repo does not own
  -h, --help         Show this message

Exit status is 1 if any entry could not be linked.
USAGE
}

link_entries() {
  if [ "${#entries[@]}" -eq 0 ]; then
    echo "$PROG: no $WHAT found under $SOURCE_DIR" >&2
    exit 1
  fi

  if [ "$DRY_RUN" -eq 0 ] && in_worktree; then
    local main_root; main_root="$(cd "$(dirname "$(git -C "$REPO_ROOT" rev-parse --git-common-dir)")" && pwd)"
    printf '%s: this checkout is a git worktree; links into it break when it is removed.\n' "$PROG" >&2
    printf 'Run from the main checkout instead: %s\n' "$main_root" >&2
    exit 1
  fi

  # Two entries with the same name would collide at the flat boundary.
  local dupes
  dupes="$(for e in "${entries[@]}"; do basename "$e"; done | sort | uniq -d)"
  if [ -n "$dupes" ]; then
    echo "$PROG: duplicate names, these collide when flattened:" >&2
    printf '%s\n' "$dupes" | sed 's/^/  /' >&2
    exit 1
  fi

  if [ ! -d "$TARGET" ]; then
    say "create $TARGET"
    [ "$DRY_RUN" -eq 1 ] || mkdir -p "$TARGET"
  fi

  local linked=0 current=0 failed=0 src name dest

  for src in "${entries[@]}"; do
    name="$(basename "$src")"
    dest="$TARGET/$name"

    if [ -L "$dest" ]; then
      if [ "$(link_target "$dest")" = "$src" ]; then
        current=$((current + 1))
        continue
      fi
      if [ "$FORCE" -eq 0 ]; then
        printf 'conflict: %s is a link to %s, not ours (use --force)\n' "$dest" "$(link_target "$dest")" >&2
        failed=$((failed + 1))
        continue
      fi
      say "replace link $name"
      [ "$DRY_RUN" -eq 1 ] || rm "$dest"
    elif [ -e "$dest" ]; then
      if same_content "$dest" "$src"; then
        say "adopt $name (identical copy, replacing it with a link)"
      elif [ "$FORCE" -eq 0 ]; then
        printf 'conflict: %s already exists and is not a symlink (use --force)\n' "$dest" >&2
        failed=$((failed + 1))
        continue
      else
        say "replace $name"
      fi
      [ "$DRY_RUN" -eq 1 ] || rm -rf "$dest"
    fi

    say "link $name -> $src"
    [ "$DRY_RUN" -eq 1 ] || ln -s "$src" "$dest"
    linked=$((linked + 1))
  done

  local pruned=0 resolved
  if [ "$PRUNE" -eq 1 ]; then
    for dest in "$TARGET"/*; do
      [ -L "$dest" ] || continue
      resolved="$(link_target "$dest")"
      case "$resolved" in
        "$SOURCE_DIR"/*) ;;
        *) continue ;;
      esac
      entry_live "$resolved" && continue
      say "prune $(basename "$dest") (was $resolved)"
      [ "$DRY_RUN" -eq 1 ] || rm "$dest"
      pruned=$((pruned + 1))
    done
  fi

  printf '\n%s: %d linked, %d already current, %d pruned, %d failed  (target %s)\n' \
    "$([ "$DRY_RUN" -eq 1 ] && echo 'dry run' || echo 'done')" \
    "$linked" "$current" "$pruned" "$failed" "$TARGET"

  [ "$failed" -eq 0 ]
}

# Is this checkout a git worktree? Links into a worktree die with it, so the
# real run belongs in the main checkout.
in_worktree() {
  local common; common="$(git -C "$REPO_ROOT" rev-parse --git-common-dir 2>/dev/null)" || return 1
  [ "$(git -C "$REPO_ROOT" rev-parse --git-dir)" != "$common" ]
}

say() { [ "$DRY_RUN" -eq 1 ] && printf 'would %s\n' "$*" || printf '%s\n' "$*"; }

# Absolute path a symlink points at. Links this script writes are always
# absolute, which is what the prune and ownership checks rely on.
link_target() {
  local raw; raw="$(readlink "$1")"
  case "$raw" in
    /*) printf '%s\n' "$raw" ;;
    *)  printf '%s/%s\n' "$(cd "$(dirname "$1")" && pwd)" "$raw" ;;
  esac
}

# A plain file or directory in the target whose content already matches
# ours can be swapped for a link without --force: nothing is lost.
same_content() {
  if [ -d "$1" ] && [ -d "$2" ]; then diff -rq "$1" "$2" >/dev/null 2>&1
  elif [ -f "$1" ] && [ -f "$2" ]; then cmp -s "$1" "$2"
  else return 1
  fi
}

# Shared by bin/link-skills and bin/link-rules. Not executable on its own.
#
# Flatten one kind of repository entry into a harness directory, one symlink
# per entry, touching only entries this repository owns.
#
# The calling script sets these before calling any function here. The
# first five are read by parse_args and usage as well as link_entries; the
# last two only by link_entries.
#   PROG        its own name, for messages
#   WHAT        plural noun for usage text ("skills")
#   SOURCE_DIR  repository directory the entries live under
#   ENV_VAR     environment variable that overrides the default target
#   TARGET      the target directory (already resolved from $ENV_VAR)
#   entries     array of absolute source paths, one per link
#   entry_live  function: exit 0 if the path it is given is still an entry,
#               used by --prune to tell a stale link from a current one

set -euo pipefail

# The checkout this file lives in, found from this file's own path (so the
# working directory and the calling script play no part). Every link points
# under it: skills/ for link-skills, rules/ for link-rules. That is why a
# worktree checkout must not run for real.
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Command-line switches. parse_args sets them; link_entries and say read
# them. All off by default: a bare run links what is missing and stops at
# anything it does not own.
DRY_RUN=0   # --dry-run: print every action as "would ...", touch nothing
PRUNE=0     # --prune: also remove our own links whose entry no longer exists
FORCE=0     # --force: replace entries this repo does not own

# Read the command-line options into TARGET, DRY_RUN, PRUNE and FORCE.
# Takes the caller's "$@". Exits 0 after printing --help, 2 on an unknown
# option; anything else returns normally with the globals updated.
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

# Print the help text for the calling script, built from PROG, WHAT,
# SOURCE_DIR, TARGET and ENV_VAR so the two scripts share one template.
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

# The main loop: make TARGET hold one link per element of entries.
#
# For each entry, the destination TARGET/<basename> ends up as a link to it,
# unless the destination is owned by something else, in which case it is
# left alone and reported (see the conflict, worktree and dangling messages).
# --force overrides that. With --prune, a link into SOURCE_DIR is removed
# when its target is no longer an entry (the skill or rule was renamed or
# deleted; entry_live decides). Every action is printed through say, so
# --dry-run shows the full plan.
#
# Exits 1 before touching anything when entries is empty, two entries share
# a basename, or this is a real run from a worktree. Otherwise prints a
# summary line and returns 0 only if nothing failed.
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

  local linked=0 current=0 failed=0 src name dest resolved problem

  for src in "${entries[@]}"; do
    name="$(basename "$src")"
    dest="$TARGET/$name"

    if [ -L "$dest" ]; then
      resolved="$(link_target "$dest")"
      if [ ! -e "$resolved" ]; then
        problem="dangling: $dest points at $resolved, which no longer exists"
      elif into_worktree "$resolved"; then
        problem="worktree: $dest links into a git worktree ($resolved) and dies with it; relink from the main checkout"
      elif [ "$resolved" = "$src" ]; then
        current=$((current + 1))
        continue
      else
        problem="conflict: $dest is a link to $resolved, not ours"
      fi
      if [ "$FORCE" -eq 0 ]; then
        printf '%s (use --force)\n' "$problem" >&2
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

  local pruned=0
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

# Is this checkout a git worktree? Returns 0 if so. Links into a worktree
# die with it, so link_entries refuses a real run when this is true.
in_worktree() { into_worktree "$REPO_ROOT"; }

# Does the given path live inside a git worktree, of any repository?
# Returns 0 if so, 1 for a main checkout or a path outside any repository.
# A file's directory is what gets asked. The test: in a main checkout
# --git-dir and --git-common-dir are the same directory; in a worktree they
# differ. Both are forced absolute, since from a subdirectory git prints
# one relative and the other not.
into_worktree() {
  local dir="$1" git_dir common
  [ -d "$dir" ] || dir="$(dirname "$dir")"
  { read -r git_dir && read -r common; } < <(
    git -C "$dir" rev-parse --path-format=absolute --git-dir --git-common-dir 2>/dev/null
  ) || return 1
  [ -n "$common" ] && [ "$git_dir" != "$common" ]
}

# Report an action, prefixed with "would" under --dry-run. Every change
# link_entries makes goes through here first, so the dry run is the plan.
say() { [ "$DRY_RUN" -eq 1 ] && printf 'would %s\n' "$*" || printf '%s\n' "$*"; }

# Print the absolute path the given symlink points at, resolving a relative
# target against the link's own directory. Links this library writes are
# always absolute, which is what the ownership and prune checks compare on.
link_target() {
  local raw; raw="$(readlink "$1")"
  case "$raw" in
    /*) printf '%s\n' "$raw" ;;
    *)  printf '%s/%s\n' "$(cd "$(dirname "$1")" && pwd)" "$raw" ;;
  esac
}

# Are the two given paths a pair of files, or a pair of directories, with
# identical content? Returns 0 if so, 1 otherwise (including a file paired
# with a directory). Content only: permissions and executable bits are not
# compared, and symlinks inside a directory are followed rather than
# compared as links. A plain copy in the target that matches ours can be
# swapped for a link without --force, since nothing is lost.
same_content() {
  if [ -d "$1" ] && [ -d "$2" ]; then diff -rq "$1" "$2" >/dev/null 2>&1
  elif [ -f "$1" ] && [ -f "$2" ]; then cmp -s "$1" "$2"
  else return 1
  fi
}

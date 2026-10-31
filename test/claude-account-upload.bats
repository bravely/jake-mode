#!/usr/bin/env bats
#
# Tests for bin/claude-account-upload's --base plan, run against a
# throwaway repository holding a copy of bin/. Run with `bats test/`.

setup() {
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO"
  cp -R "$BATS_TEST_DIRNAME/../bin" "$REPO/bin"
  cd "$REPO" || return 1
  git init -q -b main
  git config user.name test
  git config user.email test@example.com
  skill kept all
  git add -A
  git commit -qm base
  git switch -q -c work
}

# Write skills/test/<name>/SKILL.md with the given reach.
skill() {
  mkdir -p "skills/test/$1"
  printf -- '---\nname: %s\ndescription: A test skill.\nmetadata:\n  reach: %s\n---\nBody\n' \
    "$1" "$2" > "skills/test/$1/SKILL.md"
}

upload() { bin/claude-account-upload --base main --out "$BATS_TEST_TMPDIR/out"; }

actions() { cat "$BATS_TEST_TMPDIR/out/actions"; }

@test "an unchanged skill needs nothing" {
  run upload
  [ "$status" -eq 0 ]
  [ "$(actions)" = "" ]
}

@test "a committed new all skill is an upload" {
  skill fresh all
  git add -A
  git commit -qm fresh
  run upload
  [ "$status" -eq 0 ]
  [ "$(actions)" = "upload fresh" ]
}

@test "an uncommitted new all skill is an upload" {
  skill fresh all
  run upload
  [ "$status" -eq 0 ]
  [ "$(actions)" = "upload fresh" ]
  [ -f "$BATS_TEST_TMPDIR/out/fresh.zip" ]
}

@test "an uncommitted edit to an all skill is an upload" {
  printf 'More\n' >> skills/test/kept/SKILL.md
  run upload
  [ "$status" -eq 0 ]
  [ "$(actions)" = "upload kept" ]
}

@test "an uncommitted new file in an all skill is an upload" {
  printf 'notes\n' > skills/test/kept/notes.md
  run upload
  [ "$status" -eq 0 ]
  [ "$(actions)" = "upload kept" ]
}

@test "an uncommitted new code skill needs nothing" {
  skill local code
  run upload
  [ "$status" -eq 0 ]
  [ "$(actions)" = "" ]
}

@test "an ignored file in an all skill needs nothing" {
  printf '.DS_Store\n' > .gitignore
  git add .gitignore
  git commit -qm ignore
  : > skills/test/kept/.DS_Store
  run upload
  [ "$status" -eq 0 ]
  [ "$(actions)" = "" ]
}

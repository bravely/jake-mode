#!/usr/bin/env bats
#
# Tests for bin/account-plugin, run against a throwaway repository holding
# a copy of bin/. Run with `bats test/`.

setup() {
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/.claude-plugin"
  cp -R "$BATS_TEST_DIRNAME/../bin" "$REPO/bin"
  cd "$REPO" || return 1
  git init -q -b main
  git config user.name test
  git config user.email test@example.com
  skill kept all
  skill local code
  printf '{"name": "jake-mode", "skills": ["./skills/test/kept"]}\n' > .claude-plugin/plugin.json
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

check() { bin/account-plugin --base main; }

@test "an unchanged repository passes and needs nothing" {
  run check
  [ "$status" -eq 0 ]
  [[ "$output" == *"need nothing"* ]]
}

@test "a new all skill missing from plugin.json fails" {
  skill fresh all
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"does not list ./skills/test/fresh"* ]]
}

@test "--write adds a new all skill to plugin.json" {
  skill fresh all
  run bin/account-plugin --write --base main
  [ "$status" -eq 0 ]
  grep -q '"./skills/test/fresh"' .claude-plugin/plugin.json
  [[ "$output" == *'- `fresh`'* ]]
  [[ "$output" == *"Check for updates"* ]]
}

@test "a listed skill that became code fails" {
  skill kept code
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"lists ./skills/test/kept, which is not a skill with reach all"* ]]
}

@test "--write never lists a code skill" {
  run bin/account-plugin --write
  [ "$status" -eq 0 ]
  ! grep -q local .claude-plugin/plugin.json
}

@test "a plugin nested below the root fails" {
  mkdir -p plugins/other/.claude-plugin
  printf '{"name": "other"}\n' > plugins/other/.claude-plugin/plugin.json
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugins/other/.claude-plugin/plugin.json: a plugin inside"* ]]
}

@test "an edit to an all skill asks for a Check for updates" {
  printf 'More\n' >> skills/test/kept/SKILL.md
  run check
  [ "$status" -eq 0 ]
  [[ "$output" == *'- `kept`'* ]]
}

@test "an all skill removed since the base asks for a Check for updates" {
  rm -r skills/test/kept
  bin/account-plugin --write
  run check
  [ "$status" -eq 0 ]
  [[ "$output" == *'- `kept`'* ]]
}

@test "an edit to a code skill needs nothing" {
  printf 'More\n' >> skills/test/local/SKILL.md
  run check
  [ "$status" -eq 0 ]
  [[ "$output" == *"need nothing"* ]]
}

@test "an ignored file in an all skill needs nothing" {
  printf '.DS_Store\n' > .gitignore
  git add .gitignore
  git commit -qm ignore
  : > skills/test/kept/.DS_Store
  run check
  [ "$status" -eq 0 ]
  [[ "$output" == *"need nothing"* ]]
}

@test "an all skill with a key claude.ai rejects fails" {
  printf -- '---\nname: kept\ndescription: A test skill.\nwhen_to_use: never\nmetadata:\n  reach: all\n---\n' \
    > skills/test/kept/SKILL.md
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *'rejects the front matter key "when_to_use"'* ]]
}

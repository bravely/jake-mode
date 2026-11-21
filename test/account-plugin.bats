#!/usr/bin/env bats
#
# Tests for bin/account-plugin, run against a throwaway repository holding
# a copy of bin/. Run with `bats test/`.

setup() {
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/plugins/jake-mode/.claude-plugin" "$REPO/plugins/jake-mode/skills"
  cp -R "$BATS_TEST_DIRNAME/../bin" "$REPO/bin"
  cd "$REPO" || return 1
  git init -q -b main
  git config user.name test
  git config user.email test@example.com
  skill kept all
  skill local code
  printf '{"name": "jake-mode"}\n' > plugins/jake-mode/.claude-plugin/plugin.json
  ln -s ../../../skills/test/kept plugins/jake-mode/skills/kept
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

@test "a new all skill without a link fails" {
  skill fresh all
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugins/jake-mode/skills/fresh should link to ../../../skills/test/fresh"* ]]
}

@test "--write links a new all skill" {
  skill fresh all
  run bin/account-plugin --write --base main
  [ "$status" -eq 0 ]
  [ "$(readlink plugins/jake-mode/skills/fresh)" = ../../../skills/test/fresh ]
  [ -f plugins/jake-mode/skills/fresh/SKILL.md ]
  [[ "$output" == *'- `fresh`'* ]]
  [[ "$output" == *"Check for updates"* ]]
}

@test "a linked skill that became code fails" {
  skill kept code
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugins/jake-mode/skills/kept -> ../../../skills/test/kept is not a link to a skill with reach all"* ]]
}

@test "--write never links a code skill" {
  run bin/account-plugin --write
  [ "$status" -eq 0 ]
  [ ! -e plugins/jake-mode/skills/local ]
}

@test "a copied skill in place of a link fails" {
  rm plugins/jake-mode/skills/kept
  cp -R skills/test/kept plugins/jake-mode/skills/kept
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugins/jake-mode/skills/kept -> (not a link)"* ]]
}

@test "a bin folder in the plugin fails" {
  mkdir plugins/jake-mode/bin
  : > plugins/jake-mode/bin/tool
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugins/jake-mode/bin: the Account plugin may hold only"* ]]
}

@test "a second plugin anywhere in the repository fails" {
  mkdir -p .claude-plugin
  printf '{"name": "root"}\n' > .claude-plugin/plugin.json
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *".claude-plugin/plugin.json: the Account plugin must be the only plugin"* ]]
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

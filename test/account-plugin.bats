#!/usr/bin/env bats
#
# Tests for bin/account-plugin, run against a throwaway repository holding
# a copy of bin/. Run with `bats test/`.

setup() {
  REPO="$BATS_TEST_TMPDIR/repo"
  mkdir -p "$REPO/plugins/jake-mode/.claude-plugin" "$REPO/plugins/jake-mode/skills" "$REPO/.claude-plugin"
  cp -R "$BATS_TEST_DIRNAME/../bin" "$REPO/bin"
  cd "$REPO" || return 1
  git init -q -b main
  git config user.name test
  git config user.email test@example.com
  skill kept all
  skill local code
  printf '{"name": "jake-mode"}\n' > plugins/jake-mode/.claude-plugin/plugin.json
  ln -s ../../../skills/test/kept plugins/jake-mode/skills/kept
  printf '{"name": "jake-mode", "plugins": [{"name": "jake-mode", "source": "./plugins/jake-mode"}]}\n' \
    > .claude-plugin/marketplace.json
  git add -A
  git commit -qm base
  git switch -q -c work
}

# Write skills/<category>/<name>/SKILL.md with the given reach. The
# category is the third argument, test by default.
skill() {
  mkdir -p "skills/${3:-test}/$1"
  printf -- '---\nname: %s\ndescription: A test skill.\nmetadata:\n  reach: %s\n---\nBody\n' \
    "$1" "$2" > "skills/${3:-test}/$1/SKILL.md"
}

# Write the front matter given on stdin as skills/test/kept/SKILL.md.
kept_frontmatter() {
  { printf -- '---\n'; cat; printf -- '---\nBody\n'; } > skills/test/kept/SKILL.md
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
  [[ "$output" == *'- the skill `fresh`'* ]]
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
  [[ "$output" == *"plugins/jake-mode/bin/tool: the Account plugin may hold only"* ]]
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
  [[ "$output" == *'- the skill `kept`'* ]]
}

@test "an all skill removed since the base asks for a Check for updates" {
  rm -r skills/test/kept
  bin/account-plugin --write
  run check
  [ "$status" -eq 0 ]
  [[ "$output" == *'- the skill `kept`'* ]]
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

@test "all skills in several categories pass once linked" {
  skill zeta all meta
  skill alpha all delivery
  run bin/account-plugin --write
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "a nested skill inside an all skill fails" {
  mkdir -p skills/test/kept/examples/demo
  printf -- '---\nname: demo\ndescription: Nested.\n---\n' > skills/test/kept/examples/demo/SKILL.md
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"skills/test/kept/examples/demo/SKILL.md: claude.ai would publish this nested skill"* ]]
}

@test "a symlink inside an all skill fails" {
  mkdir rules
  ln -s ../../../rules skills/test/kept/rules
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"skills/test/kept/rules: a symlink inside a skill with reach all"* ]]
}

@test "anything in the plugin folder besides the manifest and links fails" {
  mkdir -p plugins/jake-mode/.claude-plugin/extra plugins/jake-mode/..hidden
  : > plugins/jake-mode/.claude-plugin/extra/SKILL.md
  : > plugins/jake-mode/..hidden/SKILL.md
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugins/jake-mode/.claude-plugin/extra/SKILL.md: the Account plugin may hold only"* ]]
  [[ "$output" == *"plugins/jake-mode/..hidden/SKILL.md: the Account plugin may hold only"* ]]
}

@test "an ignored file in the plugin folder or a worktree does not fail" {
  printf '.DS_Store\n.claude/\n' > .gitignore
  git add .gitignore
  git commit -qm ignore
  : > plugins/jake-mode/.DS_Store
  : > plugins/jake-mode/skills/.DS_Store
  mkdir -p .claude/worktrees/x/plugins/jake-mode/.claude-plugin
  cp plugins/jake-mode/.claude-plugin/plugin.json .claude/worktrees/x/plugins/jake-mode/.claude-plugin/
  run check
  [ "$status" -eq 0 ]
  run bin/account-plugin --write
  [ "$status" -eq 0 ]
  [ -f plugins/jake-mode/skills/.DS_Store ]
}

@test "a description with XML tags fails" {
  kept_frontmatter <<'EOF'
name: kept
description: Use <thinking> tags.
metadata:
  reach: all
EOF
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"description contains < or >"* ]]
}

@test "a folded description over 1024 characters fails" {
  { printf 'name: kept\ndescription: >-\n  '; printf 'x%.0s' $(seq 1 1100); printf '\nmetadata:\n  reach: all\n'; } | kept_frontmatter
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"description is 1100 characters"* ]]
}

@test "an empty folded description fails" {
  printf 'name: kept\ndescription: >\nmetadata:\n  reach: all\n' | kept_frontmatter
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"skills/test/kept: no description"* ]]
}

@test "a quoted or spaced key claude.ai rejects fails" {
  printf 'name: kept\ndescription: Ok.\n"argument-hint": foo\nwhen_to_use : never\nmetadata:\n  reach: all\n' | kept_frontmatter
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *'rejects the front matter key "argument-hint"'* ]]
  [[ "$output" == *'rejects the front matter key "when_to_use"'* ]]
}

@test "a plugin.json that is not JSON or sets a version fails" {
  printf '{ "name": "jake-mode",' > plugins/jake-mode/.claude-plugin/plugin.json
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugin.json is not valid JSON"* ]]
  printf '{"name": "jake-mode", "version": "1.0.0"}\n' > plugins/jake-mode/.claude-plugin/plugin.json
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugin.json sets a version"* ]]
}

@test "a marketplace pointing elsewhere fails" {
  printf '{"plugins": [{"name": "jake-mode", "source": "./plugins/jake-mod"}]}\n' > .claude-plugin/marketplace.json
  run check
  [ "$status" -eq 1 ]
  [[ "$output" == *'the jake-mode source is "./plugins/jake-mod"'* ]]
}

@test "a manifest change asks for a Check for updates" {
  printf '{"name": "jake-mode", "description": "changed"}\n' > plugins/jake-mode/.claude-plugin/plugin.json
  run check
  [ "$status" -eq 0 ]
  [[ "$output" == *'- `plugins/jake-mode`'* ]]
}

@test "--write refuses to replace a copy that is not a link" {
  rm plugins/jake-mode/skills/kept
  cp -R skills/test/kept plugins/jake-mode/skills/kept
  printf 'edited\n' >> plugins/jake-mode/skills/kept/SKILL.md
  run bin/account-plugin --write
  [ "$status" -eq 1 ]
  [[ "$output" == *"plugins/jake-mode/skills/kept is not a symlink"* ]]
  grep -q edited plugins/jake-mode/skills/kept/SKILL.md
}

@test "two all skills with the same name fail and --write touches nothing" {
  skill dup all one
  skill dup all two
  run bin/account-plugin --write
  [ "$status" -eq 1 ]
  [[ "$output" == *"more than one skill with reach all is named: dup"* ]]
  [ ! -e plugins/jake-mode/skills/dup ]
  [ ! -e skills/one/dup/dup ]
  run check
  [[ "$output" == *"more than one skill with reach all is named dup"* ]]
}

@test "a --base that is not a commit fails" {
  run bin/account-plugin --base nosuchref
  [ "$status" -eq 2 ]
  [[ "$output" == *"--base nosuchref is not a commit"* ]]
}

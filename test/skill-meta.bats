#!/usr/bin/env bats
#
# Tests for bin/lib/skill-meta.sh, the front matter reader that bin/link
# and bin/claude-account-upload share. Run with `bats test/`.

setup() {
  # shellcheck source=../bin/lib/skill-meta.sh
  . "$BATS_TEST_DIRNAME/../bin/lib/skill-meta.sh"
  SKILL_DIR="$BATS_TEST_TMPDIR/some-skill"
  mkdir -p "$SKILL_DIR"
  SKILL="$SKILL_DIR/SKILL.md"
}

# Write stdin to the skill's SKILL.md.
skill() { cat > "$SKILL"; }

# --- skill_frontmatter

@test "frontmatter: prints the lines between the fences" {
  skill <<'EOF'
---
name: some-skill
description: Does a thing.
---
Body
EOF
  run skill_frontmatter "$SKILL"
  [ "$status" -eq 0 ]
  [ "$output" = "name: some-skill
description: Does a thing." ]
}

@test "frontmatter: prints nothing when line 1 is not a fence" {
  skill <<'EOF'
# Some skill
---
name: some-skill
---
EOF
  run skill_frontmatter "$SKILL"
  [ "$output" = "" ]
}

@test "frontmatter: stops at the first closing fence" {
  skill <<'EOF'
---
name: some-skill
---
Body
---
metadata:
  reach: all
EOF
  run skill_frontmatter "$SKILL"
  [ "$output" = "name: some-skill" ]
}

# --- skill_file_metadata

@test "metadata: reads a key from the block map" {
  skill <<'EOF'
---
name: some-skill
metadata:
  reach: all
  experimental: true
---
EOF
  run skill_file_metadata "$SKILL" experimental
  [ "$output" = "true" ]
}

@test "metadata: strips double and single quotes" {
  skill <<'EOF'
---
metadata:
  reach: "all"
  experimental: 'true'
---
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "all" ]
  run skill_file_metadata "$SKILL" experimental
  [ "$output" = "true" ]
}

@test "metadata: strips a trailing comment" {
  skill <<'EOF'
---
metadata:
  reach: all   # uploaded by hand
---
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "all" ]
}

@test "metadata: prints nothing for an absent key" {
  skill <<'EOF'
---
metadata:
  experimental: true
---
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "" ]
}

@test "metadata: a key is not matched by a longer key it prefixes" {
  skill <<'EOF'
---
metadata:
  reachable: all
---
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "" ]
}

@test "metadata: a top-level key after the map ends it" {
  skill <<'EOF'
---
metadata:
  experimental: true
license: MIT
  reach: all
---
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "" ]
}

@test "metadata: a comment at column 0 does not end the map" {
  skill <<'EOF'
---
metadata:
# where the skill can be used
  reach: all
---
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "all" ]
}

@test "metadata: a key inside a nested map is not read as a metadata key" {
  skill <<'EOF'
---
metadata:
  upstream:
    reach: all
  experimental: true
---
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "" ]
  run skill_file_metadata "$SKILL" experimental
  [ "$output" = "true" ]
}

@test "metadata: a metadata map in the body is ignored" {
  skill <<'EOF'
---
name: some-skill
---
metadata:
  reach: all
EOF
  run skill_file_metadata "$SKILL" reach
  [ "$output" = "" ]
}

# --- skill_reach and skill_file_reach

@test "reach: defaults to code" {
  skill <<'EOF'
---
name: some-skill
---
EOF
  run skill_reach "$SKILL_DIR"
  [ "$output" = "code" ]
}

@test "reach: reads all" {
  skill <<'EOF'
---
metadata:
  reach: all
---
EOF
  run skill_reach "$SKILL_DIR"
  [ "$output" = "all" ]
  run skill_file_reach "$SKILL"
  [ "$output" = "all" ]
}

@test "reach: prints an unknown value as written" {
  skill <<'EOF'
---
metadata:
  reach: everywhere
---
EOF
  run skill_reach "$SKILL_DIR"
  [ "$output" = "everywhere" ]
}

# shellcheck shell=bash
# Read the marks a skill carries in its SKILL.md front matter. Sourced, not
# run: bin/link and bin/account-upload both need the same answer to "what
# is this skill's reach?", so the parsing lives here once.
#
# Custom marks live under the `metadata:` map, because claude.ai rejects an
# upload whose front matter has any other top-level key it does not know
# (it accepts only name, description, license, compatibility, metadata and
# allowed-tools). The map must be block style, one `key: value` per
# indented line:
#
#   metadata:
#     reach: all
#     experimental: true
#
# bin/account-upload rejects the inline `metadata: {...}` form, so
# the plain line-by-line reading below never has to understand it.
#
# The marks:
#   reach         all  -> uploaded to the Claude account by hand, reaching chat,
#                         mobile and every Claude Code session through it.
#                 code -> wired by bin/link, Claude Code only. The default.
#   experimental  true while the skill is still being tried out. Nothing
#                 reads it; it is for the person reading the skill.

# Print the front matter of the given SKILL.md: the lines between the
# opening `---` on line 1 and the next `---`. Prints nothing when line 1 is
# not `---`.
skill_frontmatter() {
  awk 'NR == 1 { if ($0 !~ /^---[[:space:]]*$/) exit; next }
       /^---[[:space:]]*$/ { exit }
       { print }' "$1"
}

# Print the value of one key under the front matter's `metadata:` map, for
# the skill directory given first and the key given second. Quotes and a
# trailing comment are stripped. Prints nothing when the key is absent.
skill_metadata() { skill_file_metadata "$1/SKILL.md" "$2"; }

# The same, given the SKILL.md file itself rather than its directory, so a
# copy taken from another commit can be read too.
skill_file_metadata() {
  skill_frontmatter "$1" | awk -v key="$2" '
    /^metadata:[[:space:]]*$/ { inmeta = 1; next }
    /^[^[:space:]#]/          { inmeta = 0; next }
    inmeta && $0 ~ "^[[:space:]]+" key ":" {
      v = $0
      sub("^[[:space:]]+" key ":[[:space:]]*", "", v)
      sub(/[[:space:]]+#.*$/, "", v)
      sub(/[[:space:]]+$/, "", v)
      gsub(/^["\047]|["\047]$/, "", v)
      print v
      exit
    }'
}

# Print the reach of the given skill directory: its `metadata.reach`, or
# `code` when it has none. An unknown value is printed as-is so that the
# check in bin/account-upload can name it; everything else treats any value
# but `all` as code.
skill_reach() { skill_file_reach "$1/SKILL.md"; }

# The same, given the SKILL.md file itself.
skill_file_reach() {
  local reach; reach="$(skill_file_metadata "$1" reach)"
  printf '%s\n' "${reach:-code}"
}

# The top-level keys claude.ai accepts in an uploaded skill's front matter.
# Anything else fails the upload. Read by bin/account-upload.
# shellcheck disable=SC2034
ACCOUNT_FRONTMATTER_KEYS="name description license compatibility metadata allowed-tools"

#!/usr/bin/env bash
# Fetch the UNRESOLVED review threads on a pull request as JSON.
#
# Usage: unresolved-threads.sh [PR_NUMBER]
#   PR_NUMBER  optional; defaults to the PR for the current branch.
#
# Each element of the output array is one unresolved thread:
#   thread_id          GraphQL node id of the thread
#   outdated           true if the thread's diff hunk is outdated
#   path,line          location of the comment
#   reply_to           REST comment id to reply to (first comment in the thread)
#   last_comment_by    login of the most recent commenter
#   awaiting_reviewer  true if the PR author already replied last — i.e. the thread
#                      is addressed and waiting on the reviewer to resolve, NOT on you.
#                      Skip these unless there's a new reviewer ask. (unresolved != unaddressed)
#   comments           [{author, url, body}, ...] in order
#
# Reply to a thread with:
#   gh api --method POST \
#     /repos/{owner}/{repo}/pulls/{PR}/comments/{reply_to}/replies -f body="..."
set -euo pipefail

pr="${1:-$(gh pr view --json number --jq .number)}"
read -r owner repo < <(gh repo view --json owner,name --jq '"\(.owner.login) \(.name)"')

gh api graphql \
  -F owner="$owner" -F repo="$repo" -F pr="$pr" \
  -f query='
    query($owner:String!, $repo:String!, $pr:Int!) {
      repository(owner:$owner, name:$repo) {
        pullRequest(number:$pr) {
          author { login }
          reviewThreads(first:100) {
            nodes {
              id
              isResolved
              isOutdated
              path
              line
              comments(first:50) {
                nodes {
                  databaseId
                  author { login }
                  body
                  url
                  diffHunk
                }
              }
            }
          }
        }
      }
    }' \
  --jq '
    .data.repository.pullRequest as $pr
    | ($pr.author.login) as $author
    | $pr.reviewThreads.nodes
    | map(select(.isResolved == false))
    | map({
        thread_id:         .id,
        outdated:          .isOutdated,
        path:              .path,
        line:              .line,
        reply_to:          .comments.nodes[0].databaseId,
        last_comment_by:   .comments.nodes[-1].author.login,
        awaiting_reviewer: (.comments.nodes[-1].author.login == $author),
        comments:          [.comments.nodes[] | {author: .author.login, url: .url, body: .body}]
      })'

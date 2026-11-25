---
name: email-triage
description: "Gmail inbox triage for the user's work or personal account: go stream by stream, deciding filter, archive, unsubscribe, task, spam, or leave alone, then create the approved filters in one batch. Use when the user asks to clean up, triage, process or review their email or Gmail inbox."
metadata:
  reach: all
  experimental: true
---

# Email triage

A run works through one account's **Gmail inbox** (the mail in its `INBOX` label) one **stream** at a time. A stream is all the mail from one sender address or, when that sender sends several kinds of mail, one of those kinds. One decision covers a whole stream. The Todoist Inbox is a different inbox; this skill only adds tasks to it.

## Accounts and routes

Each run covers one account: the one the user names, or ask which. The account and the surface decide how mail is read and how filters are made.

| Account | Read, label, archive, spam | Filters |
|---|---|---|
| Work, `jake.demarest-mays@solace.health`, any surface | Gmail connector | Windmill; the Todoist task when no Windmill connection is in the session |
| Personal, `jake@demarest-mays.com`, in Claude Code | `gws` | `gws` |
| Personal, outside Claude Code | Gmail connector | Todoist task |

Before the first stream, confirm the route:

- **Gmail connector**: check that inbox mail is addressed to the account you are triaging. A connector signed in to the other account means stop and say so.
- **`gws`**: `gws auth status` must show credentials, and `gws gmail users settings filters list --params '{"userId":"me"}'` must succeed. If either fails, say the personal account can't be reached on this machine and stop. Setting `gws` up is the user's job.
- **Windmill**: the deployed script `u/JakeDemarestMays/gmail_filter_and_archive` in workspace `engineering`, called with `google: "$res:u/JakeDemarestMays/unencumbered_solace_google"`.

With `gws`, list with `gws gmail users messages list`, read with `gws gmail +read`, change labels with `gws gmail users messages batchModify`, and create filters with `gws gmail users settings filters create`. Use `--help` on each one for its flags. Archive means removing `INBOX`; spam means adding `SPAM` and removing `INBOX`.

## Running it

1. **Size the streams.** List the Gmail inbox, group it by sender, and work largest stream first.
2. **Decide each stream.** Open its mail before describing it: at least the newest message, and one of each kind when the sender's mail is mixed. Give a one-sentence gist, the rule that matches, and a recommendation. Act only on the user's yes for that stream.
3. **Keep the running filter list.** A yes to filtering adds the stream's filter to the list after its dry run (see Filters). That stream's mail stays where it is until the batch.
4. **Finish** when every stream has a decision or the user says stop. Either way, run the batch, then give a short summary: streams decided, mail archived, unsubscribes, tasks, and filters created.

### The batch

Show the whole filter list: each query, its label, whether it keeps mail in the inbox, and its dry-run match count. On one approval of that list:

- **Windmill or `gws`**: create each filter and apply its action to the mail already in the Gmail inbox that matches it.
- **Todoist task**: add one Todoist Inbox task for the user to create the filters, with every query and action in its description.

## Rules

Check the rules in this order. The first one that matches decides the stream.

1. **Spam or impersonation**: mark as spam.
2. **Money and security alerts** (bank and card alerts, fraud, sign-ins): these always stay in the inbox. Bank alerts get nothing. Google security alerts get a filter that adds the `Security` label and keeps them in the inbox. A recurring Todoist task, outside this skill, covers the daily check of that label.
3. **People and communities the user follows** (Hachyderm, Patreon, Stack Exchange, newsletters they chose): leave alone.
4. **Needs action later**: add a Todoist Inbox task, then archive the stream. `todoist-inbox-management` decides how the task is worded, and the `todoist-access` rule decides how Todoist is reached.
5. **Senders with mixed mail**: start with a narrow filter (exact address plus a subject term) and widen it in later runs. Mail with codes, redemption steps or other unique details stays in the inbox.
6. **Statements and billing that need nothing from the user** (card statements, receipts, eNotice-ready emails): filter, label `Statements`.
7. **Promos and newsletters**: when you suspect the user rarely engages with a sender, ask. To drop a sender, unsubscribe first, with the user's yes on each sender: open its unsubscribe link in the browser pane, then archive the stream with the `Unsubscribed` label added. A sender whose mail is back in the Gmail inbox, newer than its `Unsubscribed` mail, didn't take the unsubscribe: filter it, label `Promos`.
8. **One-off notices already handled**: archive with no filter when the mail is read. Unread mail stays in the inbox, since the user hasn't seen it.

## Filters

A filter skips the inbox, adds the label named for its rule, and leaves mail unread, because read and unread is how rule 8 tells what the user has seen. The `Security` filter is the exception: it keeps mail in the inbox.

Every filter goes through a dry run before it joins the list:

- **Query**: exact sender addresses, never whole domains, plus a subject term when the sender's mail is mixed.
- **Count**: how many Gmail inbox messages match. With Windmill, run the script with `dry_run: true`; its output holds counts only.
- **Breadth**: check the subjects of the matching mail through the account's reading route (the Gmail connector or `gws`), never through Windmill output, which is logged. A query that catches mail another rule would keep is too broad: narrow it before it joins the list.

In the batch, the Windmill script takes `filter_query`, `label_name`, `skip_inbox` (false only for `Security`), `mark_read: false` and `dry_run: false`.

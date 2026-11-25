---
name: email-triage
description: "Gmail inbox triage for the user's work or personal account: go stream by stream, deciding what happens to the mail already there and to future mail (archive, filter, unsubscribe, task, spam, or leave alone), then create the approved filters in one batch. Use when the user asks to clean up, triage, process or review their email or Gmail inbox."
metadata:
  reach: all
  experimental: true
---

# Email triage

A run works through one account's **Gmail inbox** (the mail in its `INBOX` label) one **stream** at a time. A stream is the mail one sender sends to one recipient (the user directly, or a group they're in), narrowed to one kind of mail when that sender sends several kinds. Every stream gets two decisions:

- **Backlog**, the mail already in the inbox: archive it, leave it, or mark it as spam.
- **Future mail**: filter it out of the inbox, filter it but keep it in the inbox, fix it at the source, or no filter.

Related streams can be presented together as a **category** (every account-security notice, say) for one shared decision. Each stream in a category still gets its own filter. The Todoist Inbox is a different inbox; this skill only adds tasks to it.

## Accounts and routes

Each run covers one account: the one the user names, or ask which. The account and the surface decide how mail is read and how filters are made.

| Account | Read, label, archive, spam | Filters |
|---|---|---|
| Work, any surface | Gmail connector | Windmill; the Todoist task when no Windmill connection is in the session |
| Personal, in Claude Code | `gws` | `gws` |
| Personal, outside Claude Code | Gmail connector | Todoist task |

The work account is `jake.demarest-mays@solace.health`, and its mail also arrives addressed to the alias `jakedemarest-mays@solace.health`. The personal account is `jake@demarest-mays.com`. Mail sent to the user's other addresses lands there too, so whatever is in that Gmail inbox counts as mail to the user directly, whichever address it was sent to. When that address changes the decision (a storage warning for it, a recovery-email copy of another account's alert), name it.

Before the first stream, confirm the route:

- **Gmail connector**: check that inbox mail is addressed to the account you are triaging or one of its aliases. A connector signed in to the other account means stop and say so.
- **`gws`**: `gws auth status` must show credentials, and `gws gmail users settings filters list --params '{"userId":"me"}'` must succeed. If either fails, say the personal account can't be reached on this machine and stop. Listing filters works without permission to create them, so also check that the `scopes` in `gws auth status` include `gmail.settings.basic`. If only that is missing, say so before starting: the run can go on, but its filters wait until the user signs in with it. Setting `gws` up is the user's job.
- **Windmill**: workspace `engineering`, Google resource `$res:u/JakeDemarestMays/unencumbered_solace_google`. The deployed script `u/JakeDemarestMays/gmail_filter_and_archive` creates filters, and retries Gmail's rate limits itself.

With `gws`, list with `gws gmail users messages list`, read with `gws gmail +read`, change labels with `gws gmail users messages batchModify`, and create filters with `gws gmail users settings filters create`. Use `--help` on each one for its flags. Archive means removing `INBOX`; spam means adding `SPAM` and removing `INBOX`.

## Preferences in memory

What the user has settled in earlier runs (a stream's two decisions, an answer to one of the standing questions) lives in memory, so a run never asks the same thing twice.

- **In chat and on mobile**: the Claude account's own memory holds the preferences for the Gmail account it triages. At the end of a run, list every preference settled during it and ask the user to tell Claude to remember them.
- **In Claude Code**: the session's auto memory holds them. Triage runs start from `~/dev/jake-mode`, so they all share one memory; a session started anywhere else says its preferences may be missing. Save each preference to memory as soon as it's settled.

A settled preference becomes the recommendation for its stream, and its standing question isn't asked again. Acting on it still takes the user's yes, which can cover a whole category at once.

## Running it

1. **Confirm the route, read the preferences, and list the existing filters** (see Filters).
2. **Take inventory.** Split the Gmail inbox by recipient first: mail to the user directly, and mail to each group. A group rewrites the From line to its own address, so grouping by sender alone merges everything sent to it into one stream. The user picks which part to start on. Within a part, group by sender, then by kind of mail, and work largest stream first.
   - `search_threads` may stop returning a page token, so take inventory with repeated searches that each leave out the streams already found (`-from:… -subject:…`) until nothing new turns up. Later searches also leave out streams already decided this run.
   - When Gmail's per-minute limit cuts a read off, wait a minute and retry.
   - Take inventory through the reading route only. Windmill output is logged, so it never carries mail content.
3. **Decide each stream or category.** Open its mail before describing it: at least the newest message, and one of each kind when the mail is mixed. Pull out any message that needs the user (an access request, a bounce to a dead address, a new app connected to an account, a notice from a team they've left) as a **follow-up** before deciding the rest. Give a one-sentence gist, the rule that matches, and a recommendation for the backlog and for future mail. Act only on the user's yes.
4. **Act on the backlog right away**, except where the stream is being filtered: the batch archives that mail along with creating its filter.
5. **Keep the running filter list.** A yes to filtering adds the stream's filter to the list once its dry run passes (see Filters).
6. **Finish** when every stream has a decision or the user says stop. Either way, run the batch, then give a short summary: streams decided, mail archived, unsubscribes, tasks, filters created, and the follow-ups noticed. Offer each follow-up as a Todoist Inbox task, added only on the user's yes, worded and captured as `todoist-inbox-management` says and reached as the `todoist-access` rule says. Then record the run's settled preferences (see Preferences in memory).

### The batch

Show the whole filter list in the reply itself. For each filter, give the exact query, its label if it has one, whether it skips the inbox, and what it matches: the dry-run count, the all-mail count, and the matching subjects grouped by kind. Then name the same sender's mail it leaves alone. Leave patient details out of the subjects. Mark a query that matches no mail at all as untested.

Propose filters freely, but create one only after the user approves its exact query and action. A yes to a stream in step 3 puts its filter on the list; it doesn't approve creating it. If a filter changes after approval, show the new version and ask again. A run with nobody to ask ends with the proposed list. On one approval of that list:

- **Windmill or `gws`**: create each filter and archive the mail already in the Gmail inbox that matches it. Mail that reached the inbox is mail the filter would have caught.
- **Todoist task**: add one Todoist Inbox task for the user to create the filters, with every query and action in its description.

## Standing questions

Ask each once, when its case first comes up, and record the answer as a preference.

- **Whose mail is this?** For mail sent to a group: is handling it the user's job, or someone else's? Mail that's someone else's job gets no forwarding.
- **Does the user work from the tool's own inbox?** For a tool's notifications (an issue tracker, say): if they handle it in the tool itself, filter its mail.
- **Is the user a real customer?** For the company's own product emails: if not, they're test mail, and can be filtered.
- **Does the user engage with this sender?** Ask when you suspect they rarely read a promo or newsletter sender.

## Rules

Check the rules in this order. The first one that matches gives the default for both decisions.

1. **Spam or impersonation.** Backlog: spam. Future: nothing.
2. **Alerts about the user's own accounts** (bank and card alerts, fraud, sign-ins, devices, passwords). Future: never filtered out of the inbox. Security notices (sign-ins, devices, passwords) get a filter that adds the `Security` label and keeps them in the inbox; on the work account, only Google's do. Bank and card alerts get no filter. Backlog: group the alerts about the same event, ask about each, and archive the ones the user says to.
3. **Group mail that isn't the user's job.** Backlog: archive. Future: filter by kind into labels under the group's label. That covers alerts for shared team accounts and mail from outside senders (a `to:<group> -from:<company domain>` filter into an "inbound external" label).
4. **People and communities the user follows** (Hachyderm, Patreon, Stack Exchange, newsletters they chose). Leave alone.
5. **Needs action later.** Add a Todoist Inbox task, then archive the backlog. Future: nothing.
6. **A tool the user works in directly.** Backlog: archive. Future: filter.
7. **The company's own product emails, as test mail.** Backlog: archive. Future: filter.
8. **Senders with mixed mail.** Filter narrowly (exact address plus a subject term) and widen it in later runs. Protected mail stays in the inbox (see Filters).
9. **Promos and newsletters.** Fix it at the source: unsubscribe (see below), then archive the backlog. Future: no filter unless the unsubscribe didn't take.
10. **Routine notices that need nothing** (calendar invites and replies, benefits and HR, document shares and mentions, bounces once you've checked who bounced). Backlog: archive. Future: no filter. This is the most common outcome.
11. **Anything else.** Give the gist, and archive on the user's yes, read or unread.

### Patient data

Group mail can carry patient details, such as messages or insurance-card photos from patients. Say that patient data is there, never quote it, and never forward it unless the user asks.

### Fixing it at the source

A filter hides mail; fixing the source stops it. Before filtering a stream that comes from a subscription or a membership, look for the fix:

- **What you can do**: unsubscribe through the sender's unsubscribe link, opened in the browser pane after the user's yes on that sender, then archive the backlog with the `Unsubscribed` label added. A sender whose mail is back in the Gmail inbox, newer than its `Unsubscribed` mail, didn't take the unsubscribe: filter it.
- **What only the user can do** (leave a team, change a tool's notification settings): suggest it as a follow-up, and filter the stream in the meantime.

A meantime filter matches the source as it is today, so it stops matching once the source changes. A filter for one team's alerts names that team (`subject:"assigned to the alpha team"`), never the whole tool (`from:alerts.example.com`), because after the user moves to another team, the new team's mail has to reach them.

## Filters

A filter skips the inbox and leaves mail unread, except where rule 2 keeps mail in the inbox.

- **Existing filters**: the live list (`gws gmail users settings filters list`) is the reference, so keep no copy of it. A stream that an existing filter already handles gets no new filter. When an existing filter is wrong or too narrow, propose replacing it. Where the route can't list filters, say in the batch that this check was skipped.
- **Protected mail**: a filter on mail to the user directly never takes these out of the inbox: codes, redemption steps or other unique details; security or fraud alerts; account changes (a cancellation, a declined payment, a changed setting); and personal mail or support replies.
- **Label**: on the personal account a filter adds a label only when the user has named one for that mail, and `Security` is the only one so far. On the work account every filter adds one, named for the source, nested under the group's label for group mail (`Team/Acme`, or `Acme` for mail to the user directly). Use an existing label before creating a new one, so a second stream from the same source lands where the first one did.
- **Query**: exact sender addresses by default. A whole domain is fine when the breadth check shows every address on it gets the same decision. Group mail needs `to:<group>` plus subject or body terms, since its From line is the group's own address.
- **Dry run**: count the Gmail inbox mail the query matches. With Windmill, run the script with `dry_run: true`; its output holds counts only.
- **Breadth check**: check the subjects of the matching mail, across all mail rather than just the inbox, through the reading route (the Gmail connector or `gws`), never through Windmill output. A query that catches protected mail, or mail another rule would keep, is too broad: narrow it before it joins the list.

In the batch, the Windmill script takes `filter_query`, `label_name`, `skip_inbox` (false only for security alerts), `mark_read: false` and `dry_run: false`.

To replace a filter on the work account, create the new one first, then delete the old one with the draft script `u/JakeDemarestMays/gmail_filter_delete`, run as a Windmill test run. It deletes only a filter whose query matches exactly, and only when exactly one does. Run it with `dry_run: true` first.

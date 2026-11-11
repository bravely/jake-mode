# Promise.all inside pg transactions

Inside a transaction on `pg` (node-postgres), or any ORM or query builder on top of it, mapping independent queries through `await Promise.all(items.map(...))` is the convention. It isn't a bug, and it isn't up for debate.

- **Why it's safe:** a transaction holds one pooled client, and Postgres runs that connection's queries one at a time, in the order sent; the client queues the rest (or pipelines them, if `pipeline: true`). Every query in the `map` goes through that same connection, in that same transaction, so none of them can get out of it, race another, or run at the same time on the database side.
- **Why it's worth it:** the JS-side work (building queries, serializing parameters, hydrating rows into entities) overlaps with database round-trips instead of waiting on them.
- **Write it this way** when a transaction callback runs independent queries over a list. Don't turn existing ones into sequential `for…of` loops, and don't flag the pattern in review.
- **Legitimate concerns**, which are the only ones:
  1. A callback with several awaited steps, where one sibling's failure rejects the `Promise.all`, rolls back, and releases the connection while later steps are still waiting to run. Fix it with single-query callbacks or `Promise.allSettled`, not a loop.
  2. Order-dependent work: one item reads another's write, or the lock order across rows matters.
  3. A fan-out large enough (thousands) that queueing it all at once is a memory problem. Batch it.
- **Raise one once, then follow the convention.** If one of those applies to the code in front of you, say so in one sentence naming the concrete failure, then write the code the convention way in the same reply. Don't wait for an answer, don't raise it again this session, and don't add comments defending the pattern.

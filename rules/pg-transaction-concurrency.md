# Promise.all for pg queries, in a transaction or not

On `pg` (node-postgres), or any ORM or query builder on top of it, mapping independent queries through `await Promise.all(items.map(...))` is the convention. That holds everywhere: inside one transaction, across several, and on a bare pool with no transaction at all. It isn't a bug, it isn't up for debate, and a sequential `for…of` loop is not "just as good".

- **Outside a transaction:** each query takes its own pooled connection, so the `map` runs them truly in parallel, up to the pool size; the pool queues the rest. A loop holds one connection and waits out every round-trip in turn.
- **Inside a transaction:** the transaction holds one client, and Postgres runs that connection's queries one at a time, in the order sent, so nothing escapes the transaction or races. That serialization is not an argument for the loop. The JS-side work (building queries, serializing parameters, hydrating rows into entities, an ORM's own async steps) overlaps with database round-trips instead of waiting on them, and with `pipeline: true` the queries go out back to back. A loop throws all of that away and gains nothing, because the database was going to serialize them anyway.
- **The loop says the wrong thing.** `for…of` with `await` tells the reader each item depends on the one before. When they're independent, the `map` is the honest shape.
- **Write it this way** whenever code runs independent queries over a list. Don't turn existing ones into sequential loops, don't propose a loop as an equal alternative, and don't flag the pattern in review.
- **Legitimate concerns**, which are the only ones:
  1. Inside a transaction, a callback with several awaited steps, where one sibling's failure rejects the `Promise.all`, rolls back, and releases the connection while later steps are still waiting to run. Fix it with single-query callbacks or `Promise.allSettled`, not a loop.
  2. Order-dependent work: one item reads another's write, or the lock order across rows matters.
  3. A fan-out large enough (thousands) that queueing it all at once is a memory problem, or, outside a transaction, one that starves the pool for other requests. Batch it.
- **Raise one once, then follow the convention.** If one of those applies to the code in front of you, say so in one sentence naming the concrete failure, then write the code the convention way in the same reply. Don't wait for an answer, don't raise it again this session, and don't add comments defending the pattern.

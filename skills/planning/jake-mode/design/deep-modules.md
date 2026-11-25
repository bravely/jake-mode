# Deep-modules design

Design a system of deep modules for one ticket. The **interface** is the deliverable. The internals are a plan that shows the interface can be built.

The target is the fewest modules, each with a small, powerful interface whose intent a reader sees at a glance, and which combine cleanly. A caller gets the ticket's job done without learning a dozen modules with five or six functions each.

**Input:** the scope file (the ticket's traced call path and its test seams), the ticket, and the glossary terms settled in grilling.
**Output:** the checkpoint below, and once Jake approves it, the approved design.

## Vocabulary

Call the Skill tool for `codebase-design` and use its terms exactly: **module**, **interface**, **implementation**, **depth**, **seam**, **adapter**, **leverage**, **locality**. Use the glossary terms for the domain. Its `DEEPENING.md` covers dependency categories and testing across a seam, and applies here.

## Procedure

1. **Take the scope as given.** The scope file's traced call path sets the boundary of the design. Existing code is input to the design, nothing more, so greenfield work runs the same procedure.
2. **Design the top-level interface first.** When the change crosses a function boundary, sketch two different shapes: types, signatures, and where each module's seam sits. Pick the one where each piece of state has one owner, each task has one way to do it, and callers need to know least. When those criteria don't separate the two, carry both to the checkpoint for Jake to choose. A split like a REST resource's lookup-by-id (which returns the not-found) apart from its update (which takes the found resource) is fine.
3. **Run the three checks on every interface.** When a check fails, merge or reshape the module.
   - Can you say what the module is for in one sentence, without saying how it works?
   - Can the ticket's main use case be done in one or two calls?
   - Does the caller stay free of the internals, such as call order or state setup?
4. **Sketch the private plan** for each module.
5. **Recurse.** Each module's private plan is a new design problem, with that module's internals as the boundary and the parent module as the caller. Apply the same checks at every layer. Stop when a piece is simple enough to write directly (a single function with no hidden state), or when it reaches an existing module that already passes the checks.
6. **Present the checkpoint and stop.**

A ticket that repeats one change across many modules (audit logging on every update across five resources, say) gets its shared shape designed once, as its own step, and then applied everywhere. One design, not one per module.

## Checkpoint

- The top-level modules, each with its one-sentence purpose and its function signatures, including the error union in each return type.
- One line on the shape that lost in step 2 and why. When the criteria didn't separate the two shapes, both shapes in full instead, for Jake to choose.
- The call sequence for the ticket's main use case.
- One level deeper, one line per piece by default. Expand a piece when any of these holds:
  - It adds a module or changes an existing module's interface.
  - It has side effects or is hard to undo: jobs, analytics events, external calls, schema changes.
  - You can't tell which of two designs for it is better. Lay both out for Jake to choose.
- The test seams from the scope file.
- The main test cases for each public function, including every error tag.
- Partial-failure points: every public function with more than one irreversible side effect, marked with where it can partially fail and the options. Jake decides, because the strategy is a business decision. Example: the card is charged, then the inventory reservation fails because another order took the last unit.
- Scope escalation: when the right change sits outside the traced call path, both the local fix and the root-cause fix. The scope widens only when Jake chooses the root-cause fix.
- Flags on existing modules (see Existing code), and a short "noticed in passing" list.

## Errors

- Expected errors are values: a plain hand-rolled TypeScript discriminated union such as `{ ok: true, value } | { ok: false, error }`, with each error carrying a type tag like `not-found` or `invalid-state`. The compiler then makes every caller handle them.
- Throw only for panics: bugs, broken invariants, the database being down. This is Go's error-versus-panic split.
- Define errors out of existence where you can: deleting something already gone just succeeds. Handle an error inside the module when the caller can't act on it, like retrying a flaky call. Expose only the errors a caller would act on differently, named for the caller's world.
- In NestJS, the controller unwraps the result and maps each tag to an HTTP status in one place. Nest's exception filters keep turning thrown panics into 500s. Framework conventions stay as they are.

## Dependency injection, classes, and namespace modules

This style is a bias, not a rule. Lean this way, and follow without arguing when Jake or the surrounding code goes the other way.

- A thing is injectable only when it **directly** holds state or calls an I/O provider itself. Calling other modules that do I/O doesn't make a thing injectable.
- Push I/O up and logic down. Internals take plain data and return plain data or decisions ("here's the price, and here's the event to send"). Only the thin top layer of a module calls the repository or the queue.
- A class is for injectable things. Everything else is pure functions grouped in a file module and imported as a namespace (`import * as orders from "./orders"`). Name functions for how they read through the namespace: `orders.total(cart)`, not `orders.calculateOrderTotal(cart)`.
- Internal sub-pieces are plain functions or classes that the public module imports, not Nest providers. Only public modules are exported from Nest modules, so the DI graph matches the module seams.
- Passing an I/O dependency in as an argument is fine and often good: `processOrder(order, paymentGateway)`.
- Each module takes only what it calls directly. When its dependency list grows long, ask whether one object should collect them so they're easier to pass around, and whether the module is doing too much.

## Testing

- Test through the interface only, so the internals can be reshaped without breaking tests.
- Test pure modules with plain unit tests and no mocks: data in, data out, error cases included.
- Test injectable classes against real dependencies where practical, such as a real test database. Fake only true outside services, such as a payment API.

## Generality

- Make each interface somewhat general-purpose. The test: if the next likely ticket in this area came along, would the interface still make sense without a new special-case function?
- Every parameter, option and function has a current caller that uses it.

## Existing code

- **Flag, don't reshape.** An existing module that fails the checks gets flagged, so Jake can decide whether to fix it in this work or later. Flag it only when its weakness directly makes the current change worse or harder. Everything else goes on the "noticed in passing" list.
- **Wrap legacy code at the seam.** Where new code meets legacy code that throws, or that is injectable without holding state or doing I/O itself, the new code wraps it. The wrapper sorts each exception the old code can throw: a broken invariant propagates as a panic, unwrapped, and an expected case becomes a union error.
- **Create a module only when it hides something.** With nothing to hide, put the code in the nearest existing module that owns the concept.

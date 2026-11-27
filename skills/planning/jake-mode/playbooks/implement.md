### Implement

**Carry one ticket from the tracker to a stack of reviewable PRs.** You own the design and the plan. Jake approves the design before any code is written.

The steps hand work to each other through three files: the scope file, the design file and the plan file. Put them wherever the work's repo keeps nothing committed, and name each path in your reply when you write it. A later session picks the ticket up from those files.

1. **Scope the ticket.** Fetch the ticket from the tracker and state its title. Trace the ticket's actual call path through the code, from its entry point (controller, job, CLI command) through every module it reaches. The traced path is the scope. The ticket's wording only points at where to start. Note the test seams: where the ticket's behaviour will be tested, preferring seams that already exist, at the highest seam the code offers, and as few of them as possible. Post nothing to the tracker. Write the scope file: the ticket, every module on the call path with its file paths, and the test seams. Done when every module the call path reaches is listed and every test seam is named.

2. **Grill with docs.** Find the glossaries first, in this order, which replaces the file structure section of `domain-modeling`:
   1. At the repo's top level, look for `GLOSSARY-MAP.md`, then `GLOSSARY.md`. If one is there, use it. A map points to each context's glossary, so nothing else needs searching.
   2. Only if neither exists, start from each file in the scope and walk up the folders to the repo root, collecting every `GLOSSARY.md` on the way. The closer file wins on conflicts.

   Then call the Skill tool for `grilling` and for `domain-modeling`, and grill the ticket and the scope against those glossaries. New terms go in the nearest glossary in a folder the developer's team owns, created only when the first term is resolved. Where a rule requires approval of each glossary change (the Solace shared repos), collect the new terms and show them in one batch at the end of this step for approval. Elsewhere, write each term as it settles. Done when the grilling frontier is empty and Jake confirms shared understanding. The glossary terms in play are this step's output.

3. **Design, then stop.** Read `design/deep-modules.md` and follow it. Its input is the scope file, the ticket, and the glossary terms from step 2. It ends by presenting the checkpoint. **Stop** there until Jake approves. When Jake asks for changes, revise and present the checkpoint again. On approval, write the approved design to the design file. Done when Jake has approved and the design file holds the design exactly as approved.

4. **Phase the approved design.** Every phase compiles, passes its tests, and is safe to merge and deploy alone, even if nothing uses it yet. Order the phases by "make the change easy, then make the easy change": prep refactors that don't change behaviour, then new or deepened modules alongside the old ones, then callers switched over, then cleanup. Skip any step the ticket doesn't need. The approved interfaces are the natural seams between phases. Choose the approach with two questions:
   1. Could users notice the change in behaviour, or does it carry real risk (money, data, external side effects)? Then put the new path behind a feature flag, switch callers, and clean up, whatever the size.
   2. Is it behaviour-preserving (an optimization or an interface reshape)? If every caller can move in one reviewable PR, migrate the callers and delete the old interface in one go. If it's too big for one PR, phase it, but without a flag.

   Write the plan file. Open it with what changes, the phases in landing order, and the dependency graph: which phase stacks on which, and the files each may touch. Then one section per phase, with checkboxes for what it depends on, the files it edits, the one change it builds, the result you see, and its verification. Done when every part of the approved design lands in exactly one phase.

5. **Implement phase by phase.** In a worktree with no `.jj` folder, run `jj git init --colocate` first. Each phase gets its own bookmark, stacked on the previous phase. Phase 1's bookmark is the branch name the tracker gives the ticket, exactly as spelled (Linear's `gitBranchName`). Later phases are `<that name>-<n>-<short-slug>`. Write each phase test-first through the `tdd` skill. Its seams are the ones approved at the checkpoint, so they count as agreed. Run the typecheck and single test files as you go, and the full suite at the end of each phase. Verify a phase before starting the next. Push each bookmark with `jj git push --bookmark <name>`, and open one PR per phase, based on the previous phase's branch. Done when every phase in the plan file has its boxes checked and its PR open.

**Reply:** the ticket, the paths of the scope, design and plan files, each phase with its bookmark, PR and verification result, and anything the checkpoint left open.

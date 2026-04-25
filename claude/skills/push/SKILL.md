---
name: push
description: Push the current branch after running the `pre-push` skill and getting explicit user confirmation. Detects force-pushes from the pre-push output and warns the user before asking. Never pushes without confirmation.
---

# push

Run `pre-push`, confirm with the user, then push.

## Steps

1. **Run the `pre-push` skill first.** Follow its instructions in this same conversation. It will sign unsigned commits, run tests/lint, draft or check the PR title/body, and run a sub-agent code review.

2. **Determine the push command and whether it's a force-push.**

   - If the branch has an upstream (`git rev-parse --symbolic-full-name @{u}` succeeds): a force-push is needed when commits would be dropped (`git log HEAD..@{u}` non-empty) or when histories diverged. In that case use `git push --force-with-lease` (safer than `--force`). Otherwise plain `git push`.
   - If the branch has no upstream: use `git push -u origin <branch>`. Not a force-push.

   `pre-push` already reports the push type in Mode A; reuse that classification rather than recomputing.

3. **Ask the user to confirm.** Show:

   - The exact command that will run.
   - The push type (fast-forward / first push / **force-push**).
   - A one-line summary of what `pre-push` found (test/lint failures and any blocking review issues, if any).

   If it's a force-push, lead with a clear warning — call out that remote commits will be overwritten and anyone else with the branch checked out will need to recover. If `pre-push` flagged failing tests, lint errors, or blocking review issues, mention them in the same prompt so the user decides with full context.

   Stop and wait. Do not push.

4. **Push only after the user confirms.** If they say no or want to fix something first, do not push. If they confirm, run the command from step 2 and report the result.

## Notes

- Never push without explicit user confirmation in this turn — a prior approval in the conversation does not carry over.
- Never use `--force` (without lease) or `--no-verify` unless the user explicitly asks.
- Never push to `main`/`master` with `--force-with-lease` without an extra-explicit confirmation that calls out the branch name.

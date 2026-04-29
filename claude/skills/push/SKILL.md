---
name: push
description: Push the current branch after running the `pre-push` skill. Pushes automatically if pre-push checks all pass; aborts if they don't.
---

# push

Run `pre-push`, then push if its checks all passed.

## Steps

1. **Run the `pre-push` skill first.** Follow its instructions in this same conversation. It will sign unsigned commits, run tests/lint, draft or check the PR title/body, and run a sub-agent code review.

2. **Decide whether to push.**

   - If `pre-push` reported failing tests, lint errors, or blocking review issues: **do not push.** Report the failures to the user and stop.
   - Otherwise: proceed.

3. **Determine the push command.**

   - If the branch has an upstream (`git rev-parse --symbolic-full-name @{u}` succeeds): a force-push is needed when commits would be dropped (`git log HEAD..@{u}` non-empty) or when histories diverged. In that case use `git push --force-with-lease` (safer than `--force`). Otherwise plain `git push`.
   - If the branch has no upstream: use `git push -u origin <branch>`.

   `pre-push` already reports the push type in Mode A; reuse that classification rather than recomputing.

4. **Push.** Run the command and report the result.

## Notes

- Never use `--force` (without lease) or `--no-verify` unless the user explicitly asks.
- Never force-push to `main`/`master` without explicit user confirmation that calls out the branch name.

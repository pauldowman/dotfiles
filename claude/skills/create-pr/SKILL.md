---
name: create-pr
description: Create a draft GitHub PR using `gh pr create --draft`. Use when the user wants to open a draft pull request for review before marking it ready. First runs the `pre-push` skill to draft the title/body and code-review the diff, then creates the draft PR with that title and body.
---

# create-pr

Create a draft GitHub PR with a title and a short description so the user can review it on GitHub and mark it ready when appropriate. Always run `pre-push` first so the new PR's diff gets a code review before submission.

## Steps

1. **Run the `pre-push` skill first.** Follow its instructions in this same conversation. It will:
   - Detect that no PR exists yet (Mode B).
   - Draft a proposed title and body.
   - Run a sub-agent code review of `<default-base>...HEAD`.

   If `pre-push` reports that a PR already exists for this branch, stop — `create-pr` is for new PRs. Tell the user to push and update the existing PR via `gh pr edit` instead.

   If the sub-agent surfaces blocking issues, surface them to the user and ask whether to proceed before creating the draft PR. The user may want to fix issues first.

2. **Create the draft PR.** Use the title and body from `pre-push`. Pass the body via a heredoc to preserve formatting:

   ```
   gh pr create --draft --title "the title" --body "$(cat <<'EOF'
   One-line summary.

   - bullet
   - bullet
   EOF
   )"
   ```

   `gh pr create` will push the branch if it has no upstream.

3. **Move the issue to "In Review".** If there's a related GitHub issue, change it's project status to "In Review". It may exist in multiple GitHub projects, if so, change it's status in all of them.

4. **Print the PR URL.** `gh pr create --draft` outputs the URL of the created PR — surface that URL in the final message so the user can click it.

## Notes

- The PR is created as a draft. The user marks it ready for review themselves when appropriate.
- Do not push separately beforehand — let `gh pr create` handle it.
- If there are uncommitted changes, mention them before running the command rather than silently including/excluding them.

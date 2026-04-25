---
name: create-pr
description: Open a pre-filled GitHub PR form in the browser using `gh pr create --web`. Use when the user wants to create a pull request but finish editing/submitting it themselves. First runs the `pre-push` skill to draft the title/body and code-review the diff, then opens the browser form pre-filled with that title and body.
---

# create-pr

Open the GitHub PR creation form in the browser, pre-filled with a title and a short description, so the user can review and click submit themselves. Always run `pre-push` first so the new PR's diff gets a code review before submission.

## Steps

1. **Run the `pre-push` skill first.** Follow its instructions in this same conversation. It will:
   - Detect that no PR exists yet (Mode B).
   - Draft a proposed title and body.
   - Run a sub-agent code review of `<default-base>...HEAD`.

   If `pre-push` reports that a PR already exists for this branch, stop — `create-pr` is for new PRs. Tell the user to push and update the existing PR via `gh pr edit` instead.

   If the sub-agent surfaces blocking issues, surface them to the user and ask whether to proceed before opening the browser form. The user may want to fix issues first.

2. **Open the pre-filled form.** Use the title and body from `pre-push`. Pass the body via a heredoc to preserve formatting:

   ```
   gh pr create --web --title "the title" --body "$(cat <<'EOF'
   One-line summary.

   - bullet
   - bullet
   EOF
   )"
   ```

   `gh pr create --web` will push the branch if it has no upstream.

3. **Print the PR URL.** `gh pr create --web` outputs a line like `Opening https://github.com/owner/repo/compare/...` — surface that URL in the final message so the user can click it.

## Notes

- Do not submit the PR. The user finishes editing in the browser and clicks submit.
- Do not push separately beforehand — let `gh pr create` handle it.
- If there are uncommitted changes, mention them before running the command rather than silently including/excluding them.

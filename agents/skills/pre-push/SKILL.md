---
name: pre-push
description: Pre-push check for the current branch. Detects whether a PR already exists for the branch — if yes, fetches its title/body and suggests edits if out of date; if no, drafts a proposed title/body for a new PR against the repo's default branch.
---

# pre-push

Run before `git push` (or before creating a new PR) to make sure the PR description matches the work.

Never run `git push`, `gh pr edit`, or `gh pr create` from this skill — only suggest.

## Step 1 — Gather state

Run in parallel:

- `git rev-parse --abbrev-ref HEAD` — current branch.
- `gh pr view --json number,title,body,headRefName,baseRefName,url` — current PR for the branch (errors with non-zero exit if none exists; that's fine, treat it as "no PR").
- `gh repo view --json defaultBranchRef -q .defaultBranchRef.name` — default branch (fallback to `main`).

Decide which mode applies:

- **Mode A — Updating an existing PR**: `gh pr view` returned a PR. Use the PR's `baseRefName` as the base, and compare against `origin/<branch>`.
- **Mode B — New PR**: no PR exists. Use the repo's default branch as the base. There is no "remote version" to compare against; review the whole branch.

If the working tree has uncommitted changes, mention it before going further — those won't be in the push or the PR.

## Step 2 — Classify and pick the diff

**Mode A (existing PR):** with `<remote> = origin/<branch>`:

- `git log --oneline <remote>..HEAD` — commits that would be added.
- `git log --oneline HEAD..<remote>` — commits that would be dropped (non-empty ⇒ force-push).
- Diff: `git diff <remote>..HEAD` (net effective change vs what's published).
- Push type:
  - _Fast-forward_: nothing dropped, only new commits on top.
  - _Force-push / rebase / amend_: commits dropped, or histories diverged.
- If the diff is empty and no commits would change, stop — nothing to push.

**Mode B (new PR):** with `<base> = origin/<default-branch>`:

- `git log --oneline <base>..HEAD` — every commit that will be in the PR.
- Diff: `git diff <base>...HEAD` (three-dot — changes on HEAD's side since the merge base).
- If the diff is empty, stop — there's nothing to PR.

## Step 3 — Title and body

**Mode A:** Read the existing PR's title and body. Compare against the new state (added commits' subjects, the net diff). Flag:

- New behavior present in the diff but not mentioned in the body.
- Items in the body that no longer apply (reverted, removed, replaced).
- Title no longer summarizes the work.

If the existing title/body still fit, say so — don't invent edits. When suggesting edits, show the proposed new title and body verbatim so the user can paste them into `gh pr edit`.

**Mode B:** No existing description to compare against. Draft a proposed title and body for the new PR:

- **Title**: short (under ~70 chars), imperative. If a single commit, its subject is usually fine.
- **Body**: 1–2 sentence summary, then a short bulleted list if there's more than one logical piece. Skip boilerplate like "Test plan" unless the user asks.

Output the proposed title and body verbatim so they can be reused (e.g. by `create-pr`).

## Step 4 — Summarize

1. Mode and push type (e.g. "Mode A · fast-forward · 3 commits, 5 files" or "Mode B · new PR vs `main` · 7 commits, 12 files").
2. Title/body status: OK, suggested edits (Mode A), or proposed title/body (Mode B).

Don't push. Don't edit or create the PR. The caller (user or `create-pr`) acts on the output.

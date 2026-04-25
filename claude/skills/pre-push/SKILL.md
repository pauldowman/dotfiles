---
name: pre-push
description: Pre-push check for the current branch. Detects whether a PR already exists for the branch — if yes, fetches its title/body and suggests edits if out of date; if no, drafts a proposed title/body for a new PR against the repo's default branch. Runs tests and linting appropriate for the changes, then runs a sub-agent code review on the appropriate diff (local-vs-remote for an update, base-vs-HEAD for a new PR).
---

# pre-push

Run before `git push` (or before creating a new PR) to make sure the PR description matches the work and the changes get a fresh review.

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
- Diff to review: `git diff <remote>..HEAD` (net effective change vs what's published).
- Push type:
  - _Fast-forward_: nothing dropped, only new commits on top.
  - _Force-push / rebase / amend_: commits dropped, or histories diverged.
- If the diff is empty and no commits would change, stop — nothing to push.

**Mode B (new PR):** with `<base> = origin/<default-branch>`:

- `git log --oneline <base>..HEAD` — every commit that will be in the PR.
- Diff to review: `git diff <base>...HEAD` (three-dot — changes on HEAD's side since the merge base).
- If the diff is empty, stop — there's nothing to PR.

## Step 3 — Sign unsigned commits in the unpushed range

Sign only the commits that haven't been pushed yet — never rewrite history that's already on the remote.

Determine the base as the remote tip of the current branch:

```sh
base=$(git rev-parse --symbolic-full-name @{u} 2>/dev/null) \
  || base=origin/<default-branch>   # fall back if the branch was never pushed
```

Check for unsigned commits with `git log --format='%G?' <base>..HEAD`. If any line is `N` or `B`, run `git sign-since <base>`. This rebases only the unpushed range and re-signs each commit, so HEAD's SHA changes (but no force-push is required since nothing already on the remote is rewritten).

After signing, refresh anything you cached from Step 2 that referenced commit SHAs (the ranges and diff commands still work because they use refs, not SHAs).

If everything is already signed, say so and continue.

## Step 4 — Title and body

**Mode A:** Read the existing PR's title and body. Compare against the new state (added commits' subjects, the net diff). Flag:

- New behavior present in the diff but not mentioned in the body.
- Items in the body that no longer apply (reverted, removed, replaced).
- Title no longer summarizes the work.

If the existing title/body still fit, say so — don't invent edits. When suggesting edits, show the proposed new title and body verbatim so the user can paste them into `gh pr edit`.

**Mode B:** No existing description to compare against. Draft a proposed title and body for the new PR:

- **Title**: short (under ~70 chars), imperative. If a single commit, its subject is usually fine.
- **Body**: 1–2 sentence summary, then a short bulleted list if there's more than one logical piece. Skip boilerplate like "Test plan" unless the user asks.

Output the proposed title and body verbatim so they can be reused (e.g. by `create-pr`).

## Step 5 — Run tests and linting

Run tests and linting before the review. Bias toward being thorough — when in doubt, run the broader suite rather than narrowing to changed files. Run independent commands in parallel.

Report each command and its result. If something fails, include the failing output (trimmed) so the user can act. Continue to Step 6 even on failure — the review still adds value — but surface failures prominently in the summary.

If the repo genuinely has no tests or linters configured, state that plainly and move on.

## Step 6 — Sub-agent code review

Use the Agent tool (general-purpose subagent). The prompt must be self-contained — the sub-agent has none of this conversation's context.

Tell it:

- The base branch and the head branch.
- Mode and push type (Mode A fast-forward / Mode A force-push / Mode B new PR).
- The current or proposed PR title and body.
- The exact diff command to run from this repo (Mode A: `git diff <remote>..HEAD`; Mode B: `git diff <base>...HEAD`).

Ask for: correctness issues, likely regressions, anything inconsistent with the PR description, and — for force-pushes — anything that looks like an unintentional change picked up during a rebase. Cap the review at ~300 words.

## Step 7 — Summarize

In this order, blocking issues first:

1. Mode and push type (e.g. "Mode A · fast-forward · 3 commits, 5 files" or "Mode B · new PR vs `main` · 7 commits, 12 files").
2. Test and lint results — list each command run with pass/fail. Failures go to the top of the summary.
3. Title/body status: OK, suggested edits (Mode A), or proposed title/body (Mode B).
4. Sub-agent review summary.

Don't push. Don't edit or create the PR. The caller (user or `create-pr`) acts on the output.

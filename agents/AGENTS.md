# Planning

If the user indicates that a plan should be created or followed, then when making code changes all agents must follow the planning-execution model using agent-planning/{ID}.md files.

Directory Structure

All plans live under:
agent-planning/
├── {ID}.md # One per change / feature / fix
└── ...

Where {ID} is an integer that increments followed by a short human-readable slug, e.g. 02-cool-feature, so the file is agent-planning/02-cool-feature.md. Use a leading zero so that plans sort correctly.

# Workflow Rules

## 1. Working with a plan

When working with a plan, the agent must create or update an agent-planning/{ID}.md file with the following format:

```
---
status: draft
---

# {ID}

## Objective
Explain the goal of the change in one or two sentences.

## Context
Summarize relevant technical context, constraints, or links.

## Steps
Break the work down into **discrete, ordered steps**.

## Notes
- Optional discussion of assumptions, alternatives, dependencies, or TODOs.

```

The `status` front matter field must be one of:

- `draft`: the plan is being written or edited and is not yet confirmed by the user.
- `ready`: the user has confirmed the plan.
- `implementing`: steps are being executed.
- `implemented`: all steps are done, skipped, or otherwise resolved.

Keep the status up to date as the plan moves through these stages. Only the user can move a plan from `draft` to `ready`, either by editing it or by explicitly confirming the plan.

## 2. Each step is a "vertical slice" of functionality or a refactor

When breaking down work into steps organize them into a series of changes that each include end-to-end changes even if the changes are trivial, so that the app remains working with tests passing after each step.

For example, when adding a new page one step might be to add an empty page and routes, then the next step might add the first component to the page with hard-coded values, then another step might replace the hard-coded values with API calls.

Or, a step can be a refactor. Do not combine refactoring with adding functionality, do the refactor first as a separate step.

Each step needs to be a coherent change to commit to the repo without leaving the repo in a broken state.

## 3. Use the "tidy first" approach

- Separate all changes into two distinct types:
  1. STRUCTURAL CHANGES: Rearranging code without changing behavior (renaming, extracting methods, moving code)
  2. BEHAVIORAL CHANGES: Adding or modifying actual functionality
- Never mix structural and behavioral changes in the same commit
- Always make structural changes first, as a separate step, if both are needed

## 4. Each step includes tests

If a step adds new behavior or changes behavior then add or change tests as part of that step to ensure that the new behavior is covered.

ALWAYS INCLUDE TESTS WITHIN EACH STEP. There should not be a separate step for tests.

Describe which specific scenarios will be tested as part of the step description.

Or, if tests aren't warranted (for example there's no need to test something that is just declarative or config) then say so in the plan.

## 5. Review the plan

After creating a plan, have another agent review the plan by using the `cross-agent-review` skill. If it's not available use a sub-agent.

## 6. Stop after creating the plan

After creating the plan, stop for the user to edit and confirm the plan.

## 7. Execute one step at a time

When implementing a plan:

- Implement the plan on a new branch.
- Only implement a plan with status `ready` (or `implementing` when resuming). Set the status to `implementing` before starting the first step.
- Always refer to the current step from the Steps section.
- Before executing each step, read the step and confirm its scope.
- Only modify code corresponding to that single step.
- Run tests to ensure that the change hasn't broken anything.
- Have a sub-agent review the change.
- Commit the changes to the git repo after each step after tests are passing.
- After executing, always update the plan to mark the step as done, skipped, or blocked with a brief note.
- Do not skip steps or combine multiple steps in a single execution.
- Implement all steps in the plan, do not stop until all steps are finished and the plan is complete.
- When all steps are finished, set the status to `implemented`.

## 8. Review each change

Each change should be reviewed by another agent before committing. The sub-agent should review it for the following:

1. Ensure that it matches what was planned, or if it deviates from the plan that it's an improvement from what was planned.
2. Review it for correctness.
3. Ensure it's as clean and simple as possible, while still achieving the goals.

## 9. Commit the change

Each change should be committed after it has been reviewed by the sub-agent. Committing after each step allows the changes to be reviewed more easily, with each step corresponding to a commit.

Commit messages should be terse and one single line.

# Coding style

## Prefer code that's self-documenting and easily readable rather than comments

- Assume the reader can read code, and avoid redundant comments unless the code might be confusing.
- Avoid unnecessary comments. Comments should explain _why_, but not _what_, unless it's not obvious. Prefer refactoring code into functions with sensible names to make it readable.

## Tests

- Always write unit tests for all changes.
- Never delete or skip failing tests to solve the problem, always try to fix them, and alert the user if there's a good reason why the test is no longer applicable or doesn't add confidence.
- Add or update end-to-end or integration tests for main functionality, but typically just one case for a feature. Use unit tests for combinations of different input and edge cases.

## Review the whole feature

After the plan is implemented the full implementation must be reviewed with the /cross-agent-review skill. Even though each commit has already been reviewed, the full branch must be reviewed as a whole.

# Rules for git

- When committing, keep the commit message succinct, and do not co-sign.
- When pushing branches use the `push` skill
- When creating PRs use the `create-pr` skill
- **Never push unsigned commits**. Commits are not signed by default, but there is a `sign-since` git alias, which the `push` skill describes.
- If signing fails stop and ask the user to fix it by reconnecting the SSH session. Never work around it.

# Rules for conversations

- Do not flatter me. Always question my assumptions, they may be incorrect, and don't hesitate to tell me when I'm confused.
- When printing names of files within the project always use the complete path from the project root, optionally with a colon and line number at the end, e.g. dir/subdir/file.rs:42

# Rules for markdown files

- Don't insert line breaks just to keep the page width smaller. I will resize the window if it's too wide.

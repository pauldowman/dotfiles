# Planning

If the user indicates that a plan should be created or followed, then when making code changes all agents must follow the planning-execution model using agent-planning/plan-{ID}.md files.

Directory Structure

All plans live under:
agent-planning/
  ├── {ID}.md      # One per change / feature / fix
  └── ...

Where {ID} is a short human-readable identifier, starting with an integer that increments, e.g. 02-add-view-page.

# Workflow Rules

## 1. Working with a plan

When working with a plan, the agent must create or update a plan-{ID}.md file with the following format:

```
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

## 2. Each step is a "vertical slice" of functionality or a refactor

When breaking down work into steps organize them into a series of changes that each include end-to-end changes even if the changes are trivial, so that the app remains working with tests passing after each step.

For example, when adding a new page one step might be to add an empty page and routes, then the next step might add the first component to the page with hard-coded values, then another step might replace the hard-coded values with API calls.

Or, a step can be a refactor. Do not combine refactoring with adding functionality, do the refactor first as a separate step.

Each step needs to be a coherent change that the user will commit to the repo without leaving the repo in a broken state.

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

## 5. Review the plan

After creating a plan, have a sub-agent review the plan, to ensure that it's the best way to achieve the goal and that it follows the principles in this document.

## 6. Stop after creating the plan

After creating the plan, stop for the user to edit and confirm the plan.

## 7. Execute one step at a time

When implementing a plan:
- Always refer to the current step from the Steps section.
- Before executing, read the step and confirm its scope.
- Only modify code corresponding to that single step.
- Run tests to ensure that the change hasn't broken anything.
- Have a sub-agent review the change.
- If executing multiple steps you can commit the changes to the git repo. But **DO NOT push the branch** and **DO NOT change any branch other than the current branch**.
    - Commit messages should be terse and one single line
- After executing, always update the plan to mark the step as done, skipped, or blocked with a brief note.
- Do not skip steps or combine multiple steps in a single execution.

## 8. Review each change

Each change should be reviewed by a sub-agent before committing. The sub-agent should review it for the following:
1. Ensure that it matches what was planned, or if it deviates from the plan that it's an improvement from what was planned.
2. Review it for correctness.
3. Ensure it's as clean and simple as possible, while still achieving the goals.

## 9. Commit the change

Each change should be committed after it has been reviewed by the sub-agent. The user will then review and may request changes, in which case the commit can be amended. Committing after each step allows the changes to be reviewed more easily, with each step corresponding to a commit.

# Coding style

## Prefer code that's self-documenting and easily readable rather than comments.

- Assume the reader can read code, and avoid redundant comments unless the code might be confusing. 
- Avoid unnecessary comments. Comments should explain _why_, but not _what_, unless it's not obvious. Prefer refactoring code into functions with sensible names to make it readable.
- Always write unit tests for all changes.
- Never delete or skip failing tests to solve the problem, always try to fix them, and alert the user if there's a good reason why the test is no longer applicable or doesn't add confidence.
- Add or update end-to-end tests for main functionality, but typically just one case for a feature. Use unit tests for combinations of different input and edge cases.

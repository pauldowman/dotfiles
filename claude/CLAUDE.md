# Planning

If the user indicates that a plan should be created or followed, then when making code changes all agents must follow the planning-execution model using agent-planning/plan-{ID}.md files.

Directory Structure

All plans live under:
agent-planning/
  ├── plan-{ID}.md      # One per change / feature / fix
  └── ...

Where {ID} is a short human-readable identifier, starting with an integer that increments, e.g. 02-add-view-page.

# Workflow Rules

## 1. Working with a plan

When working with a plan, the agent must create or update a plan-{ID}.md file with the following format:

```
# Plan {ID}

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

## 5. Stop after creating the plan

After creating the plan, stop for the user to edit and confirm the plan. The user will begin a new execution for each step.

## 6. Execute one step at a time

When implementing a plan:
- Always refer to the current step from the Steps section.
- Before executing, read the step and confirm its scope.
- Only modify code corresponding to that single step.
- Run tests to ensure that the change hasn't broken anything
- After executing, always update the plan to mark the step as done, skipped, or blocked with a brief note.
- Stop and allow the user to check the change.
- Never commit the changes to the git repo. The user will do that manually.
- Do not skip steps or combine multiple steps in a single execution.

# Coding style

## Prefer code that's self-documenting and easily readable rather than comments.

Assume the reader can read code, and avoid redundant comments unless the code might be confusing. Comments explaining _why_ are useful, but comments that just duplicate the code are not.

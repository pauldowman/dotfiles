# Coding style

These rules apply to build code, not to prototypes.

## Prefer code that's self-documenting and easily readable rather than comments

- Assume the reader can read code, and avoid redundant comments unless the code might be confusing.
- Avoid unnecessary comments. Comments should explain _why_, but not _what_, unless it's not obvious. Prefer refactoring code into functions with sensible names to make it readable.

## Tests

- Always write unit tests for all changes.
- For bug fixes and for logic whose interface is settled, write the failing test first and watch it fail.
- Take expected values from an independent source (a literal, a worked example, the spec), never recomputed the way the code computes them. Mock only at system boundaries, and verify through the interface under test rather than a side channel.
- Never delete or skip failing tests to solve the problem, always try to fix them, and alert the user if there's a good reason why the test is no longer applicable or doesn't add confidence.
- Add or update end-to-end or integration tests for main functionality, but typically just one case for a feature. Use unit tests for combinations of different input and edge cases.
- Write tests as if the code had always been built this way. When a change removes or replaces behaviour, don't add tests asserting the old behaviour is gone (an old field is absent, an old argument is refused, an old name no longer appears); update the existing tests to describe the new behaviour. A test belongs only if it checks something the current design requires, such as a bug's regression test or a rule the current interface enforces. Comments and docs follow the same rule: describe the end state, not the change ("no longer", "now", "instead of"), except in ADRs and changelogs, which record history.

# Rules for git

- When committing, keep the commit message succinct, and do not co-sign or add text to PR messages about being authored by you.
- When pushing branches use the `pd-push` skill
- When creating PRs use the `pd-create-pr` skill

# Rules for conversations

- Do not flatter me. Always question my assumptions, they may be incorrect, and don't hesitate to tell me when I'm confused.
- When printing names of files within the project always use the complete path from the project root, optionally with a colon and line number at the end, e.g. dir/subdir/file.rs:42

# Rules for markdown files and html docs

- Don't insert line breaks just to keep the page width smaller. I will resize the window if it's too wide.
- When I ask for a temporary markdown or html file, put it in `$TEMP_DOCS_DIR`. Do not use cloud artifacts unless specifically asked to.
- Markdown should avoid creating something that looks like an html tag without a closing tag. Use `{...}` instead of `<...>` to represent variables.

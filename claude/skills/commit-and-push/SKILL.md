---
name: commit-and-push
description: Create a commit, push and good message
---

1. Run `git status`.
2. Stage the changes.
3. Bump the project's version: if it's a web project, bump the version in `package.json` based on the changes.
4. Create a commit following the **Conventional Commits** convention, **written in English** (see below). Don't use `Co-Authored-By: Claude` or `git commit --amend`.
5. Push to the current branch.

## Commit message convention

Format: `type(scope): description`

- **type** (required, lowercase) — one of:
  - `feat` — a new feature or capability
  - `fix` — a bug fix
  - `docs` — documentation only (README, comments, CLAUDE.md, skill prose)
  - `refactor` — code change that neither fixes a bug nor adds a feature
  - `chore` — tooling, config, deps, housekeeping
  - `style` — formatting/whitespace only, no logic change
  - `test` — adding or fixing tests
  - `perf` — a performance improvement
- **scope** (optional but preferred) — the area touched, in parentheses: the
  package, module, skill, or file (e.g. `feat(project-hub)`, `chore(zed)`).
- **description** (required) — imperative mood ("add", not "added"/"adds"),
  lowercase first letter, no trailing period, aim for ≤ 50 chars.
- **body** (optional) — after a blank line, explain the *why* when it isn't
  obvious from the subject. Wrap at ~72 chars.
- Group unrelated changes into **separate commits** rather than one mixed
  commit; pick the type/scope that fits each.

Examples:

```
feat(mcp-integrations): discover tools via search instead of an inventory
fix(install): use portable pwsh path and correct profile target
docs(claude): clarify Executor account defaults
chore(zed): dock terminal to the right
```

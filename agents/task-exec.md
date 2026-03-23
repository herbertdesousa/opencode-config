---
name: task-exec
description: Execute exactly one planned task and update workflow tracking. Use only when the user message contains the exact token `#task-exec` plus a single selector value (task number, task id, or task text). Never run this skill for multiple tasks in one call.
---

# Task Exec

## Trigger Gate

Run this skill only when the user includes `#task-exec`.

If the token is not present, do not run this workflow.

## Command Format

`#task-exec <seletor>`

Selector can be:

- numeric task number (1-based position)
- explicit task id (for example `T-3`)
- task title text

## Scope Rule (Hard Constraint)

Execute only the selected task. Do not execute, reorder, or advance any other task.

## Workflow

1. If `.ai/setup/project-structure.md` exists, read it and use it as guidance.
2. Read `.ai/feature/<task name>/tasks.yml`, `prd.md`, and `progress.md`.
3. If workflow files are missing, create minimal versions and continue (do not require `#repo-init`).
4. Resolve selector to one task:
   - if numeric, match list position first
   - otherwise, match id or title
5. If zero matches, report and stop.
6. If multiple matches, ask user to disambiguate and stop.
7. Set selected task status to `in_progress`.
8. Identify existing related tests and avoid redundant scenarios already covered.
9. Execute TDD cycle for this task only:
   - write/update tests first (expected to fail)
   - implement minimal code to pass tests
   - refactor safely keeping tests green
10. Choose test level by behavior:

- integration tests for important DB-backed behavior
- if DB is not central, keep integration tests lean (happy path + sad path)
- unit tests for business logic/calculations in application code

11. Implement only what is required for that task and its acceptance criteria.
12. Update selected task to `done` or `blocked`.
13. Append execution log to `progress.md` with date, task id, changes, validation, next action.
14. If contract changed (DTO/API/event/schema), append to `changes/contracts.md`.

## Rules

- Never mark other tasks as done.
- Never silently skip acceptance criteria.
- Keep changes minimal and directly tied to the selected task.
- Always report what validation commands were executed and their result.
- Maintain non-duplicative tests: add new tests only when they increase behavioral coverage.

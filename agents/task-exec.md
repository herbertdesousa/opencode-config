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
2. Read `.ai/feature/<task name>/tasks.yml`, `prd.md`, optional `questions.yml`, and optional matching file under `.ai/feature/<task name>/tasks-planning/`.
3. Treat `prd.md`, `tasks.yml`, `questions.yml`, and `tasks-planning/*.md` as read-only inputs. Never create, rewrite, or update them from this workflow.
4. Resolve selector to one task:
    - if numeric, match list position first
    - otherwise, match id or title
5. If a matching file exists in `.ai/feature/<task name>/tasks-planning/` for the selected task number, task id, or another unambiguous selector mapping, use it as authoritative technical refinement for execution together with `prd.md` and `tasks.yml`.
6. If zero matches, report and stop.
7. If multiple matches, ask user to disambiguate and stop.
8. Identify existing related tests and avoid redundant scenarios already covered.
9. Execute TDD cycle for this task only:
    - write/update tests first (expected to fail)
    - implement minimal code to pass tests
    - refactor safely keeping tests green
10. Choose test level by behavior:

- integration tests for important DB-backed behavior
- if DB is not central, keep integration tests lean (happy path + sad path)
- unit tests for business logic/calculations in application code

11. When `tasks-planning/*.md` exists for the selected task, honor its technical constraints, edge cases, sequencing, and validation expectations unless they conflict with newer explicit user instructions.
12. Implement only what is required for that task and its acceptance criteria.

## Rules

- Never modify `prd.md`, `tasks.yml`, or `questions.yml`.
- Never modify `tasks-planning/*.md`.
- Never mark other tasks as done.
- Never silently skip acceptance criteria.
- If `tasks-planning/*.md` exists for the selected task, do not ignore its edge cases or technical notes without explicit justification.
- Keep changes minimal and directly tied to the selected task.
- Always report what validation commands were executed and their result.
- Maintain non-duplicative tests: add new tests only when they increase behavioral coverage.

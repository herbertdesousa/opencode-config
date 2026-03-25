---
name: prd-plan
description: Build or update PRD and task breakdown from business context. Use only when the user message contains the exact token `#prd-plan` followed by context text. This skill creates planning artifacts that are ready for later execution by `#task-exec`.
---

# PRD Plan

## Trigger Gate

Run this skill only when the user includes `#prd-plan`.

If the token is not present, do not run this workflow.

## Command Format

`#prd-plan <contexto geral>`

Use everything after `#prd-plan` as planning context.

If context is missing after `#prd-plan`, ask for the context text.

## Goal

Produce a planning-only package from business context that is ready for later execution.

This skill must analyze the requested change, define scope, and write the planning artifacts that `#task-exec` can consume.

## Hard Constraint: Planning Only

This skill is for planning, not execution.

- Do not write production code.
- Do not write or modify tests.
- Do not run implementation tasks.
- Do not behave like `#task-exec`.

Allowed work:

- inspect the repository
- read relevant files
- analyze business and technical context
- define scope and task slicing
- write PRD, task list, contracts notes, and progress notes

## Planning Workspace

Follow the same workflow structure used by `bug.md` and `task-exec.md` so the output is executable later.

All planning artifacts must be written under:

`.ai/feature/<task-name>/`

Use a short, filesystem-safe kebab-case task name derived from the planning context.

Required files:

- `.ai/feature/<task-name>/prd.md`
- `.ai/feature/<task-name>/tasks.yml`
- `.ai/feature/<task-name>/progress.md`
- `.ai/feature/<task-name>/changes/contracts.md` when contracts are affected

Conditional file:

- `.ai/feature/<task-name>/questions.yml` when planning reveals questions that block, narrow, or materially reshape the refinement

## `questions.yml` Contract

When planning uncovers missing business decisions, assumptions that are too risky, or ambiguities that materially change scope, create `.ai/feature/<task-name>/questions.yml`.

Use a structure like:

```yml
questions:
  - id: Q01
    title: Short question title
    criticality: P0
    question: >-
      Direct question for the stakeholder.
    context: >-
      Why this matters, what part of the design it changes, and what risk exists if unanswered.
    answer: Optional stakeholder answer
```

Rules for `questions.yml`:

- Use stable ids like `Q01`, `Q02`, `Q03`.
- Use `criticality` with `P0`, `P1`, or `P2`.
- Keep each question decision-oriented, not open-ended discovery fluff.
- Always explain the planning impact in `context`.
- Add `answer` only when the stakeholder has already provided one.
- Prefer a short, high-signal list of questions that actually affect the plan.
- If no material questions exist, do not create `questions.yml`.
- If `questions.yml` already exists, treat it as planning input and preserve answered items while updating unresolved or newly discovered ones.

## Workflow

1. If `.ai/setup/project-structure.md` exists, read it and use it as guidance.
2. Derive `<task-name>` from the business context.
3. Ensure `.ai/feature/<task-name>/` exists.
4. If `.ai/feature/<task-name>/questions.yml` already exists, read it before rebuilding the plan and treat all answered questions as authoritative planning input for this run.
5. Reset workflow context before planning by overwriting these files from zero:
   - `.ai/feature/<task-name>/prd.md`
   - `.ai/feature/<task-name>/tasks.yml`
   - `.ai/feature/<task-name>/progress.md`
   - `.ai/feature/<task-name>/changes/contracts.md`
6. Start `progress.md` immediately so planning progress is visible while you work.
7. Normalize the request context:
   - problema de negocio
   - objetivo
   - usuarios ou fluxos afetados
   - restricoes, dependencias, ou contexto operacional
8. Identify planning questions that are still open after reading the user context and any existing `questions.yml` answers.
9. Build or refresh `.ai/feature/<task-name>/questions.yml` when those questions materially affect scope, sequencing, acceptance criteria, contracts, rollout, or operational design.
10. Build `prd.md` from scratch with:
   - problema de negocio
   - objetivo
   - escopo e nao-escopo
   - criterios de aceite
   - riscos e dependencias
   - estrategia de testes (TDD) por criterio de aceite
11. When answered questions exist, reorganize the refinement around those answers instead of keeping the previous assumption-based shape.
12. Build `tasks.yml` from scratch with context-oriented tasks that are PR-oriented:
   - `id`
   - `title`
   - `status: todo`
   - `repositories`
   - `pr_scope`
   - `acceptance_criteria`
   - `dependencies`
   - `test_strategy`
13. If DTO, API, event, schema, or other contracts are affected, write the expected impact in `changes/contracts.md`.
14. Append planning decision summary to `progress.md`, including which questions were answered, which remain open, and how they changed the plan.
15. Make the result clearly executable by `#task-exec`, including a recommended next command such as `#task-exec 1` when the plan is actionable.
16. If unresolved P0 questions remain, mark the planning result as partially blocked and direct the user to answer `questions.yml` before expecting final refinement quality.

## Task Slicing Rules (PR-Oriented)

- Organize tasks by delivery context, where each task should preferably map to one PR.
- Keep in the same task everything that belongs to the same context or flow, even if it touches multiple files.
- Prefer one repository per task so `1 task = 1 PR` stays practical.
- If the context impacts multiple repositories, split into coordinated tasks by repository while preserving the same context name or purpose.
- Split into more tasks only when scope becomes too large or risky for one PR, or when contexts are clearly independent.
- Every task must explicitly list the target repositories in `repositories`.
- Prefer 3-6 high-signal tasks over many micro-tasks.

## Test Planning Rules (TDD)

- Plan test-first execution for every task: tests first, then implementation.
- Define the minimum test set that proves behavior without redundant overlap with existing coverage.
- Prefer integration tests for important DB-backed flows, transactions, persistence rules, or query behavior.
- If DB integration is not central, create only a lean integration slice with happy path and sad path validation.
- Prefer unit tests for business logic and calculations when behavior does not depend on DB internals.
- Map each acceptance criterion to explicit tests in `prd.md` or `tasks.yml`.

## `progress.md` Requirements

`progress.md` is the live planning status file.

Write it so a human can open the file at any moment and understand:

- current planning status
- what has already been analyzed
- what remains open
- why the proposed plan was chosen
- what command should be run next

Update `progress.md` in stages. At minimum include:

1. planning status (`not_started`, `in_progress`, `planned`, or `blocked`)
2. current step
3. findings so far
4. open questions or risks
5. selected approach
6. planning decision summary
7. recommended next command such as `#task-exec 1`
8. reference to `questions.yml` when present, including answered vs open questions

## Output Contract

- Planning artifacts are ready for later execution by `#task-exec`.
- The output is written under `.ai/feature/<task-name>/...`.
- `tasks.yml` is structured so a single selector can be resolved by `#task-exec`.
- `progress.md` clearly shows the planning progress and final recommendation.
- `questions.yml` is created when material open questions exist and reused as input on later `#prd-plan` runs.

## Rules

- Do not execute implementation tasks.
- Do not mark tasks as done in this phase.
- Rebuild PRD, tasks, progress, and contracts from scratch for each run, but do reuse stakeholder answers from `questions.yml` when present.
- Keep the plan pragmatic, reviewable, and directly tied to business value.
- Be aware of performance, reliability, observability, accessibility, maintainability, privacy, and security.

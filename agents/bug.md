---
name: bug
description: Triage and structure bug-fix work for fast resolution. Use only when the user message contains the exact token `#bug` followed by bug context. This skill analyzes the bug, builds PRD/tasks from the bug context (equivalent to running `#prd-plan`), and prepares execution-ready tasks for `#task-exec`.
---

# Bug

## Trigger Gate

Run this skill only when the user includes `#bug`.

If the token is not present, do not run this workflow.

## Command Format

`#bug <complete bug context>`

Use everything after `#bug` as bug context: symptoms, logs, stacktrace, expected vs actual behavior, scope, environment, frequency, and impact.

## Goal

Produce a planning-only bug investigation package that is ready for later execution.

This skill must analyze the bug, define the fix strategy, and write the planning artifacts. It must not implement the fix.

## Hard Constraint: Planning Only

This skill is for planning, not execution.

- Do not write production code.
- Do not write or modify tests.
- Do not run implementation tasks.
- Do not partially fix the bug.
- Do not behave like `#task-exec`.

Allowed work:

- inspect the repository
- read relevant files
- analyze evidence
- form hypotheses
- define scope
- write PRD, task list, contracts notes, and progress notes

## Planning Workspace

All bug-planning artifacts must be written under:

`.ai/feature/<task-name>/`

Use a short, filesystem-safe kebab-case task name derived from the bug context.

Required files:

- `.ai/feature/<task-name>/prd.md`
- `.ai/feature/<task-name>/tasks.yml`
- `.ai/feature/<task-name>/progress.md`
- `.ai/feature/<task-name>/changes/contracts.md` when contracts are affected

Do not write the planning output anywhere else unless the repository has an explicit local override that instructs otherwise.

## Workflow

1. If `project/ai/agents/bug.md` exists at repository root, read and follow it first.
2. If `.ai/setup/project-structure.md` exists, read it and use it as guidance.
3. Derive `<task-name>` from the bug context.
4. Ensure `.ai/feature/<task-name>/` exists.
5. Reset workflow context before analysis by overwriting these files from zero:
   - `.ai/feature/<task-name>/prd.md`
   - `.ai/feature/<task-name>/tasks.yml`
   - `.ai/feature/<task-name>/progress.md`
   - `.ai/feature/<task-name>/changes/contracts.md`
6. Start `progress.md` immediately so planning progress is visible while you work.
7. Normalize the bug statement:
   - expected behavior
   - actual behavior
   - impact and severity
   - affected users or flows
   - reproducibility (always, intermittent, unknown)
8. Triage with evidence only:
   - inspect the most relevant code paths
   - collect the strongest evidence first (errors, logs, failing flow, recent changes)
   - narrow the likely layer (API, service, domain logic, persistence, integration, infra/config)
9. Build a hypothesis list and prioritize by probability x impact x verification cost.
10. Convert the investigation into planning artifacts:
   - write `prd.md` from scratch with bug context, scope, root-cause hypothesis, acceptance criteria, risks, and validation strategy
   - write `tasks.yml` from scratch with the minimum set of implementation tasks needed to fix and validate the bug
   - if one task is enough, create only one task
   - include `test_strategy` for each task, but do not implement the tests in this skill
11. Update `progress.md` throughout the workflow so someone can check planning status at any time.
12. If the bug involves DTO, API, schema, or contract behavior, write the impact in `changes/contracts.md`.

## `progress.md` Requirements

`progress.md` is not a final dump. It is the live status file for the planning process.

Write it so a human can open the file at any moment and understand:

- current planning status
- what has already been analyzed
- what remains open
- current leading hypothesis
- why the proposed plan was chosen
- what command should be run next

Update `progress.md` in stages. At minimum include:

1. planning status (`not_started`, `in_progress`, `planned`, or `blocked`)
2. current step
3. findings so far
4. discarded hypotheses
5. open questions or risks
6. selected approach
7. recommended next command such as `#task-exec 1`

## Performance Rules

- Prefer targeted search (`rg`, focused file reads) over broad scanning.
- Prefer the smallest evidence set that supports a solid plan.
- Prefer the smallest fix strategy that satisfies acceptance criteria.
- Stop early on disproven hypotheses and record them to avoid repeated work.

## Output Contract

- Planning artifacts are ready for later execution by `#task-exec`.
- The output is written under `.ai/feature/<task-name>/...`.
- `progress.md` clearly shows the planning progress and final recommendation.
- Include a clear recommended selector for the next command, for example `#task-exec 1` or `#task-exec T-2`.

## Rules

- This skill must never implement the bug fix.
- This skill must never create or edit production code or tests as part of execution.
- If bug context is missing after `#bug`, ask for complete context.
- Keep analysis pragmatic and directly tied to bug resolution.
- Be a senior engineer with years of experience, balancing quality and simplicity.
- Never reuse previous PRD, tasks, progress, or contracts context for this command.
- Be aware of performance, reliability, observability, accessibility, maintainability, privacy, and security.

## Reference Sources

Use these sources only when they materially improve the quality of the plan. Be pragmatic.

- Refactoring / clean code: https://refactoring.guru
- Architecture & design: https://martinfowler.com
- Microservices: https://microservices.io
- API design: https://google.aip.dev
- Security: https://owasp.org
- 12-factor apps: https://12factor.net
- System design fundamentals: https://systemdesign.one
- System design fundamentals: https://bytebytego.com

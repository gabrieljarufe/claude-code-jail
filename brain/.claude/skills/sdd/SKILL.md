---
name: sdd
description: Spec-Driven Development workflow for non-trivial features, new projects, or when the operator explicitly asks for a plan, spec, or formal approval flow. Provides a light mode (plan only) and a full mode (specs + plan + tasks) with explicit checkpoint protocol. Skip this skill for bug fixes, small refactors, or one-off scripts.
---

# SDD — Spec-Driven Development

## When to Invoke

Use this skill when:
- The operator requests a plan, spec, or SDD flow explicitly.
- Starting a new project.
- Building a feature that spans multiple tasks or more than ~1h of focused work.
- Requirements are ambiguous and need resolution before code is written.

**Skip this skill** for bug fixes, small refactors, one-off scripts, or exploratory questions — proceed directly.

## Two Modes — Pick the Smallest That Fits

### Light Mode (default)

For a single feature that fits in one focused session:

1. Write a short `plans/YYYYMMDD-<slug>.md` — scope, uncertainties, ordered task list.
2. **CHECKPOINT** — present to operator. Do not proceed without approval.
3. Execute task by task. TDD when the stack supports it. Commit after each task.
4. Update plan status to `completed` and summarize.

No specs. The plan is the spec.

### Full Mode

For new projects, large initiatives, or when the operator requires formal specs:

1. **RESEARCH** — read relevant files and gather context. Invoke the `research` skill if unfamiliar tech is involved.
2. **SPEC** — create only the spec types that add value, inside `<project>/.claude/specs/`:
   - `spec-<slug>.md` — WHAT, WHY, FOR WHOM (business + product merged)
   - `stack.md` — language, frameworks, infra (one per project, grows over time)
   - `architecture.md` — cumulative ADR log, created only when the first real decision appears
3. **PLAN** — synthesize `plans/YYYYMMDD-<slug>.md` from the specs.
4. **CHECKPOINT** — present the plan, highlight **assumed premises** and **points of uncertainty**.
5. **EXECUTE** — generate `tasks/<feature>/NNN-<slug>.md` files, work in order, commit per task.
6. **ORGANIZE** — update plan/task statuses, archive completed tasks, extract reusable patterns as skills or references.

## Checkpoint Protocol

Mandatory at:
- After plan synthesis, before generating tasks.
- When scope changes mid-execution.
- When a blocker needs a decision — do not guess.
- After all tasks complete — final review.

Format:

```
⏸️ CHECKPOINT — Awaiting approval
Plan: plans/YYYYMMDD-<slug>.md
Scope: ...
Assumed premises: ...
Points of uncertainty: ...
Approve? (yes / adjust / cancel)
```

**Never assume approval. Silence is not approval.**

## Spec Rejection = Spec Gap

If the operator rejects a plan, the first question is: *"What did I not write in the specs that led me here?"*
Plan rejection signals a spec gap, not an agent failure. Enrich the relevant spec, then re-synthesize the plan.

## Templates

All templates live in `/workspace/.claude/templates/`:
- `spec.md` — unified spec (light or full)
- `stack.md` — stack summary
- `architecture.md` — cumulative ADRs
- `plan.md` — synthesis document
- `task.md` — atomic execution unit

## Status Values

| Artifact | Values |
|----------|--------|
| Plan | `draft` \| `approved` \| `executing` \| `completed` |
| Task | `pending` \| `in-progress` \| `done` \| `blocked` |
| Spec | `draft` \| `approved` \| `archived` |

## Commit Convention

Conventional Commits: `feat`, `fix`, `test`, `refactor`, `docs`, `chore` with optional scope.
Commit after each completed task. One logical step per commit — respect natural precedence (fix a file before gitignoring it).

## After Each Completed Task

- Update task status to `done`.
- Commit (including the task status file).
- If a reusable pattern emerged, add a skill or reference.

## After a Completed Plan

- Mark the plan `completed`.
- Move finished task files into `tasks/<feature>/done/`.
- Summarize outcomes to the operator.

# Self-Organization Rules

## After Every Completed Task

1. Update the task file status to `done`.
2. If the task revealed a reusable pattern → create a skill in `.claude/skills/`.
3. If the task required research → ensure a reference file exists in `.claude/references/`.
4. Commit all changes including organizational files.

## After Every Completed Plan

1. Update the plan file status to `completed`.
2. Update all task files to `done`.
3. Archive completed tasks (move to `tasks/<feature-name>/done/`).
4. Present a final summary to the operator.

## After Every Completed Spec

Specs are business/product/stack/architecture documents — they do not "complete" like tasks.
Instead, update their status to `archived` when the initiative they describe is fully shipped.

## Skill Creation Criteria

Create a skill when:
- You've solved the same type of problem 2+ times.
- You've found an efficient workflow for a specific stack or tool.
- You've built a useful code pattern that applies across projects.

Skill files must be self-contained — another session should be able to follow the skill without additional context.

## Workspace Hygiene

- No orphaned files: every file belongs to a project or the agent system.
- No stale tasks: review pending tasks at the start of each session.
- No duplicate references: merge overlapping research notes.
- Keep `CLAUDE.md` files under 200 lines. Split into rules/ if growing.

## Session Start Protocol

At the beginning of every new session:
1. Read this workspace's `CLAUDE.md`.
2. Check `plans/` for any approved but incomplete plans.
3. Check `tasks/` for any `in-progress` or `pending` tasks.
4. Report to the operator: "Here's where we left off: [summary]".
5. Wait for instructions before acting.

## Session End Protocol

Before ending a session:
1. Commit all pending changes.
2. Update any in-progress task files with current status.
3. Note any blockers or next steps in the relevant task file.
4. Summarize what was accomplished and what remains.

## Directory Reference

```
.claude/
├── specs/
│   ├── business/      ← business requirements (what & why)
│   ├── stack/         ← technology choices (with what)
│   ├── product/       ← user-facing features (for whom)
│   └── architecture/  ← ADRs, cumulative design decisions
├── plans/             ← technical synthesis docs (agent reads specs → writes plan)
├── tasks/
│   └── <feature>/     ← atomic execution units, generated from plan
│       ├── 001-slug.md
│       └── done/
├── skills/            ← reusable patterns learned across projects
└── references/        ← research notes and findings
```

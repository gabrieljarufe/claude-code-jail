# Autonomous Development Agent

You run inside a Docker container (`claude-jail`) with full control of its environment.
The operator communicates in Brazilian Portuguese — respond in PT-BR.
Code, commits, and system files stay in English.

## Identity

Semi-autonomous agent for software development, research, and POCs.
Persistent Linux environment with Docker-in-Docker.

## Infrastructure

### Credential Persistence

Home credentials survive container rebuilds via the `home-data` volume mounted at `/root/persist/`.
The entrypoint bootstraps symlinks before the Docker daemon starts:

```
/root/persist/
  ├── .claude.json  → /root/.claude.json  (auth token)
  ├── .gitconfig    → /root/.gitconfig
  └── .ssh/         → /root/.ssh
```

After a full rebuild, only `claude login` and `git config` need to run again.

### Never Commit Credentials

Files in `/root/persist/` are excluded from version control.
Never stage `.claude.json`, `.gitconfig`, `.ssh/`, or any secret.
If one appears in `git status`, stop and warn the operator.

### Permissions

Global Bash permissions come from `/workspace/.claude/settings.json` (symlinked from `brain/.claude/settings.json`).
Runtime-approved permissions accumulate inside the `claude-config` volume at `/root/.claude/settings.local.json` — never visible in the repo, never committed.

## Default Workflow

Most tasks do not need heavy process. Defaults:

1. **Understand first** — read relevant files before acting.
2. **Ask when uncertain** — silence is not approval.
3. **Test when applicable** — write tests before implementation if the stack supports it.
4. **Commit in logical steps** — Conventional Commits, one logical change per commit, respect natural order (fix a file before gitignoring it).
5. **No destructive actions without approval** — no `rm -rf`, `DROP TABLE`, force push.
6. **Never hardcode secrets, credentials, or API keys.**

## When to Invoke the SDD Skill

The `sdd` skill provides a Spec-Driven Development workflow for larger work. Invoke it when:

- Starting a new project.
- Building a feature that spans multiple tasks or more than ~1h of focused work.
- The operator asks for a "plan", "spec", "SDD", or any formal approval flow.
- Scope or requirements are unclear and need to be resolved before execution.

For bug fixes, small refactors, or one-shot scripts, proceed directly — **do not** invoke SDD.

For unfamiliar technology, errors, or POCs, see the `research` skill.

## File Organization

Two domains coexist: **global** (agnostic) and **project** (specific to one codebase).

```
/workspace/                           ← where Claude runs
├── CLAUDE.md        → claude-code-jail/brain/CLAUDE.md
├── new-project.sh   → claude-code-jail/brain/new-project.sh
├── .claude/                          ← GLOBAL — symlinked from brain/.claude/
│   ├── settings.json
│   ├── skills/       (sdd, research, …)
│   ├── templates/    (used by skills)
│   ├── references/   (cross-project research)
│   ├── rules/        (global rules, empty by default)
│   ├── plans/        (cross-project plans)
│   └── tasks/
│
├── claude-code-jail/                 ← infra repo — source of truth for brain
│
└── <project-name>/                   ← PROJECT — independent git repo
    ├── CLAUDE.md                     ← project context
    └── .claude/                      ← project-specific skills, plans, tasks, specs, …
```

## Project Initialization

**New project:** run `/workspace/new-project.sh <name>` and ask the operator for purpose and stack. If the work is non-trivial, invoke the `sdd` skill to formalize the spec.

**Resuming a project:** read the project's `CLAUDE.md` and check `.claude/plans/` and `.claude/tasks/` for in-progress work. Report state before acting.

# Autonomous Development Agent

You run inside a Docker container called `claude-jail` with full control of its environment.
The operator communicates in Brazilian Portuguese — respond in PT-BR.
Code, commits, and system files stay in English.

## Environment

- Persistent Linux container with Docker-in-Docker (you can run `docker` inside).
- Home credentials persist via the `home-data` volume mounted at `/root/persist/`.
  After a rebuild, only `claude login` and `git config` need to run again.
- Workspace lives at `/workspace/` (volume `workspace-data`). Projects you create here persist.
- This file (`/workspace/CLAUDE.md`) is a symlink to `/opt/claude-jail/CLAUDE.md`,
  baked into the image. To update it, edit it on the host and run `docker compose up --build`.

## Defaults

1. Understand first — read relevant files before acting.
2. Ask when uncertain — silence is not approval.
3. Commit in logical steps — Conventional Commits, one logical change per commit.
4. Never hardcode secrets, credentials, or API keys.
5. No destructive actions without approval — no `rm -rf /`, `DROP TABLE`, force push.
6. Files in `/root/persist/` are never committed. If any appear in `git status`, stop and warn.

## SDD — only when the project has a `docs/` folder

If the project you are working on has a `docs/` folder, use this flow:

1. **Spec** — describe what needs to be done and why. Save to `docs/spec-<slug>.md`.
2. **Plan** — describe how, with risks and ordered task list. Save to `docs/plan-<slug>.md`.
3. **Tasks** — write an ordered checklist in `docs/tasks-<slug>.md`. Each task: title, short description, done condition.
4. **Execute** — work task by task, commit after each, tick the checkbox in `tasks-<slug>.md`.

If the project does not have `docs/`, proceed directly.
For bug fixes, small refactors, or one-shot scripts, skip SDD entirely.

## GitHub Setup

To configure git identity and an SSH key for GitHub, run `/workspace/github-setup.sh`.

---
name: research
description: Structured research workflow for unfamiliar technology, POCs, or unknown errors. Produces a reference file under .claude/references/ with question, findings, and sources. Invoke when starting work with new tech, when the operator asks for a study or POC, or when hitting an unfamiliar error.
---

# Research

## When to Invoke

- Starting work with a technology not yet used in the current project.
- Operator asks for a study, POC, or exploration.
- Hitting an unfamiliar error or limitation.

## Process

1. **Question** — state precisely what needs to be learned.
2. **Search** — docs, code examples, available tools.
3. **Summarize** — save findings to `.claude/references/<topic>.md`.
4. **Apply** — connect findings to the current task or spec.

## Reference File Format

Every reference file includes:
- **Date** — when the research happened.
- **Question** — what prompted it.
- **Summary** — 3-5 bullets of key findings.
- **Details** — deeper notes, code snippets, decisions.
- **Sources** — links, docs, repos consulted.
- **Status** — `current` | `outdated` | `needs-update`.

Cross-project research lives in `/workspace/.claude/references/`.
Project-specific research lives in `<project>/.claude/references/`.

## POCs

- Live in `/workspace/pocs/<name>/`.
- Have their own `sdd` invocation in light mode.
- Intentionally minimal — prove the concept, nothing more.
- Findings go into a reference file when the POC completes.
- If the POC validates an approach, link the reference from the main project spec.

# Research Guidelines

## When to Research

- Before starting any task involving a technology not yet used in the current project.
- When the operator asks for a study, POC, or exploration.
- When you encounter an unfamiliar error or limitation.

## Research Process

1. **Define the question**: what exactly do you need to learn?
2. **Search**: use available tools, read docs, explore code examples.
3. **Summarize**: create a reference file with key findings.
4. **Apply**: connect findings to the current task or project.

## Reference File Standards

Save research to `.claude/references/topic-name.md` (cross-project) or `<project>/.claude/references/topic-name.md` (project-specific).

Every reference file must include:
- **Date**: when the research was conducted.
- **Question**: what prompted the research.
- **Summary**: 3-5 bullet points of key findings.
- **Details**: deeper notes, code snippets, architecture decisions.
- **Sources**: links, docs, repos consulted.
- **Status**: `current` | `outdated` | `needs-update`

## POC Guidelines

When building a Proof of Concept:
1. Create a spec like any other task (the SDD loop applies).
2. POCs live in their own directory: `/workspace/pocs/poc-name/`.
3. POCs are intentionally minimal — prove the concept, nothing more.
4. Document findings in a reference file after completion.
5. If the POC validates the approach, reference it in the main project spec.

# Agent Directory

This directory contains custom GitHub Copilot agent definitions for `MoneyMan421/Iconic-studio-pro`.

## Agents

### `program-agent`
- **Purpose:** General-purpose coding and implementation agent.
- **Use when:** You need fast execution on software development tasks.
- **Do not use when:** The task is specifically about documentation, workflow supervision, CI/CD, or research.

### `ci-cd-pipeline-agent`
- **Purpose:** CI/CD setup, maintenance, troubleshooting, and approved expansion.
- **Use when:** You need help with workflows, automation, builds, tests, deployment pipelines, or CI configuration.
- **Do not use when:** The task is general coding unrelated to pipeline systems.

### `readme-specialist-agent`
- **Purpose:** README and standalone documentation improvement.
- **Use when:** You need to create, rewrite, or organize README files and related documentation.
- **Do not use when:** The task requires changing source code or generated API documentation.

### `supervisor-specialist-agent`
- **Purpose:** Workflow oversight and coordination guidance.
- **Use when:** You want task flow supervision, sequencing help, or better coordination between specialized agents.
- **Do not use when:** You need direct implementation of code, docs, or pipeline work.

### `master-agent`
- **Purpose:** Multi-agent orchestration and safe task coordination.
- **Use when:** A task spans multiple concerns and benefits from planning, approvals, or structured orchestration.
- **Do not use when:** A single specialized agent can handle the task directly.

### `pilot-agent`
- **Purpose:** Tool-driven task execution.
- **Use when:** The task depends heavily on using tools, actions, or interactive workflow support.
- **Do not use when:** The task is mainly conceptual planning or documentation strategy.

### `science-agent`
- **Purpose:** Research, experimentation, and creative technical investigation.
- **Use when:** You want structured exploration, brainstorming, or experimental problem-solving.
- **Do not use when:** The task is straightforward and better handled by a more specific specialized agent.

## Naming convention

All agent files use the pattern:

- `<role>.agent.md`

This keeps the directory consistent and easier to maintain.

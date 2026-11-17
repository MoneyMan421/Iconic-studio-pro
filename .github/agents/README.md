# Agent Directory

This directory contains custom GitHub Copilot agent definitions for `MoneyMan421/Iconic-studio-pro`.

## Active files

The standardized `*.agent.md` files in this directory are the active recommended agent definitions. These files represent the current operational standard and should be used as the primary reference for agent roles, boundaries, approval requirements, and responsible AI alignment.

Current active files:
- `program-agent.agent.md`
- `ci-cd-pipeline.agent.md`
- `readme-specialist.agent.md`
- `supervisor-specialist.agent.md`
- `master-agent.agent.md`
- `pilot-agent.agent.md`
- `science-agent.agent.md`
- `README.md`

## Legacy files

Some files in this directory are retained as legacy files.

Legacy files are older, superseded, experimental, or non-standard files that might otherwise be deleted during cleanup, but are intentionally preserved for archival and historical purposes. They help document the path of the project, including earlier drafts, naming patterns, structural experiments, and previous versions of agent definitions.

Legacy files are kept to preserve traceability and design history. They should not be treated as the primary active standard when a newer standardized agent file exists.

Current legacy files:
- `Program_Agent_md`
- `my-CI-CD.agent.md`
- `my-README specialist Agent md`
- `my-SSA.agent.md`
- `my-agent.agent.md`
- `my-pilotmd`
- `my-science.agent.md`

## Repository rule

Files with historical value are archived as Legacy files rather than deleted.

## Agents

### `program-agent`
- **Purpose:** General-purpose coding, refactoring, and bug-fix execution.
- **Use when:** You need implementation work on application code or other straightforward software development tasks.
- **Do not use when:** The task is specifically about CI/CD, standalone documentation, workflow governance, orchestration planning, or research-heavy exploration.
- **Approval rule:** Requires user approval before destructive, irreversible, or otherwise high-impact changes.

### `ci-cd-pipeline-agent`
- **Purpose:** CI/CD setup, maintenance, troubleshooting, and approved pipeline expansion.
- **Use when:** You need help with workflows, automation, builds, tests, deployment pipelines, or CI configuration.
- **Do not use when:** The task is general product coding unrelated to pipeline systems, or broad cross-agent planning.
- **Approval rule:** Requires user approval before destructive, irreversible, or otherwise high-impact changes.

### `readme-specialist-agent`
- **Purpose:** README and standalone documentation improvement.
- **Use when:** You need to create, rewrite, organize, or clarify README files and related project documentation.
- **Do not use when:** The task requires modifying source code, generated API documentation, CI/CD configuration, or governance/orchestration behavior.
- **Approval rule:** Requires user approval before destructive, irreversible, or otherwise high-impact changes.

### `supervisor-specialist-agent`
- **Purpose:** Workflow governance, scope monitoring, and responsible-AI oversight.
- **Use when:** You want an agent to monitor workflow discipline, maintain role boundaries, and reinforce safe, orderly coordination.
- **Do not use when:** You need direct implementation of code, docs, pipelines, or high-level orchestration planning.
- **Approval rule:** Requires user approval before destructive, irreversible, or otherwise high-impact changes.

### `master-agent`
- **Purpose:** Multi-agent orchestration, planning, and delegation.
- **Use when:** A task spans multiple concerns and benefits from decomposition, sequencing, approval-aware planning, or structured coordination between specialists.
- **Do not use when:** A single specialized agent can handle the task directly, or when the need is governance oversight rather than orchestration.
- **Approval rule:** Requires user approval before destructive, irreversible, or otherwise high-impact changes.

### `pilot-agent`
- **Purpose:** Tool-driven task execution and interactive action workflows.
- **Use when:** The task depends heavily on tool usage, action execution, or interactive workflow support.
- **Do not use when:** The task is mainly about planning, governance, documentation ownership, or deep research without a strong tool-execution component.
- **Approval rule:** Requires user approval before destructive, irreversible, or otherwise high-impact changes.

### `science-agent`
- **Purpose:** Research, experimentation, brainstorming, and exploratory technical investigation.
- **Use when:** You want structured exploration, idea generation, experimental analysis, or creative technical inquiry.
- **Do not use when:** The task is a straightforward implementation, documentation revision, CI/CD operation, or workflow governance responsibility.
- **Approval rule:** Requires user approval before destructive, irreversible, or otherwise high-impact changes.

## Validation checklist

Before adding or updating an agent file, verify the following:

- **Filename format:** Uses the standard pattern `<role>.agent.md`
- **Agent name uniqueness:** The `name` field is unique within this directory
- **Description clarity:** The description clearly defines purpose, scope, and boundaries
- **Overlap review:** The agent does not substantially duplicate the role of an existing agent
- **Approval rule:** The description states that user approval is required before destructive, irreversible, or otherwise high-impact changes
- **Responsible AI alignment:** The description reinforces safe scope control, transparency, and appropriate escalation to the user when needed

## Naming convention

All agent files use the pattern:

- `<role>.agent.md`

This keeps the directory consistent and easier to maintain.

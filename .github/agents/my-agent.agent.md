---
# Fill in the fields below to create a basic custom agent for your repository.
# The Copilot CLI can be used for local testing: https://gh.io/customagents/cli
# To make this agent available, merge this file into the default repository branch.
# For format details, see: https://gh.io/customagents/config

name:
description:
---

# My Agent

Describe what your agent does here.
High‑level architecture
- Master agent (controller)  
  - REST API (Flask/FastAPI) that accepts signed commands from subordinate pilots.  
  - Policy engine + RBAC enforcer that validates each command before execution.  
  - Sandbox runner that launches tasks inside Docker containers with strict resource limits and network disabled by default.  
  - Approval manager that queues destructive actions until a human approval token/file is present.  
  - Audit logger that writes append‑only, timestamped records (with signature/hash chain) to an audit store.  
  - Scheduler and watchdog (APScheduler + supervisor loop) to run scheduled tasks and restart failed containers.

- Subordinate pilot(s)  
  - Lightweight Python client that signs commands (Ed25519) and posts them to the master.  
  - Two example pilots in the MVP:  
    - Commander pilot (limited scope): can send high‑level non‑destructive commands and request destructive actions (which require human approval).  
    - Worker pilot (optional): receives orders from master to run local tasks or report status.

- Human approval channel  
  - Manual file toggle (e.g., /opt/agent/approvals/<request_id>.approved) or signed token workflow for production.  
  - Master refuses destructive actions until approval is present and logs the decision.

- Deployment  
  - Docker Compose for local deployment; example systemd unit for production.  
  - All secrets via environment variables or mounted secret files; no secrets in repo.


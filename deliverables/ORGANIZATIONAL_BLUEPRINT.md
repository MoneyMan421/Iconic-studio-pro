# Iconic Studio Pro — Full-Scale Organizational Blueprint

## 0) Purpose and Scope
This blueprint defines how to organize people, responsibilities, and operating cadence to build, ship, and support **Iconic Studio Pro** sustainably.

**In scope**
- Roles, reporting lines, and decision rights
- Team “pods” and handoffs
- Delivery operating system (planning, release, incident response)
- Ownership map tied to repository artifacts (docs, CI, code areas)

**Out of scope**
- Specific hiring sourcing tactics and compensation bands (handle in HR ops)

## 0.1) Organization Sizes (choose one and evolve)
### Lean (1–6 people)
- Founder/PM (Product + Growth + Ops)
- Flutter Tech Lead (also Release Owner)
- Shader/Graphics Engineer (part-time or contractor)
- QA/Automation (part-time)
- Support (shared / founder-led initially)

### Scale (7–20 people)
Dedicated leads for Product, Engineering, Design, Growth, and Operations (details below), plus specialists for QA, Release, and Support.

## 1) Executive Structure
- **Founder / Product Owner**: Owns vision, roadmap, budget, and release priorities.
- **Head of Engineering**: Owns architecture, code quality, CI health, and delivery.
- **Head of Design**: Owns UX system, visual language, and brand consistency.
- **Head of Growth**: Owns acquisition, onboarding funnel, and retention strategy.
- **Head of Operations**: Owns support workflows, documentation, and process cadence.

### 1.1) Decision Rights (single-threaded owners)
- **Product roadmap**: Founder / Product Owner
- **Architecture & quality gates**: Head of Engineering
- **UX and brand system**: Head of Design
- **Paywall, pricing, funnel experiments**: Head of Growth
- **Support policy and incident comms**: Head of Operations

## 1.2) Org Chart (example)
```
Founder / Product Owner
├─ Head of Engineering
│  ├─ Mobile Engineering Pod (Flutter)
│  ├─ Graphics & Rendering Pod
│  └─ Platform & Tooling Pod
├─ Head of Design
│  └─ Product & UX Pod
├─ Head of Growth
│  └─ Monetization & Growth Pod
└─ Head of Operations
   └─ Customer Experience Pod
```

## 2) Core Functional Pods

### A. Product & UX Pod
- Product Manager
- UX/UI Designer
- User Research support

**Mandate**
- Convert goals into scoped milestones.
- Maintain backlog and acceptance criteria.
- Validate feature value with user feedback loops.

### B. Mobile Engineering Pod (Flutter)
- Tech Lead
- 2–4 Flutter Engineers
- QA/Automation Engineer

**Mandate**
- Build editor, shader controls, export flow, and auth UX.
- Keep analyzer/test/CI green.
- Maintain performance budgets and release readiness.

### C. Graphics & Rendering Pod
- Shader Engineer
- Graphics QA support

**Mandate**
- Own GLSL shader quality and rendering realism.
- Optimize frame stability across devices.
- Maintain visual regression checks for shader changes.

### D. Platform & Tooling Pod
- DevOps/Release Engineer
- Automation Engineer

**Mandate**
- Maintain CI/CD, branch strategy, release gates, and build artifacts.
- Standardize environments and dependency updates.
- Track reliability and deployment metrics.

### E. Monetization & Growth Pod
- Growth Manager
- Lifecycle/CRM support
- Analytics support

**Mandate**
- Own paywall experiments and conversion metrics.
- Improve activation and subscription retention.
- Manage messaging, store listing tests, and funnel analytics.

### F. Customer Experience Pod
- Support Lead
- Community/Knowledge Base support

**Mandate**
- Resolve user issues within SLA targets.
- Turn support insights into prioritized backlog items.
- Keep help content and troubleshooting playbooks current.

## 2.1) Critical Cross-Pod Interfaces (avoid “lost work”)
- **Product → Engineering**: one-page PRD + acceptance criteria + analytics plan.
- **Design → Engineering**: interaction spec + edge cases + accessibility notes.
- **Graphics → Mobile**: shader uniform contract (names/ranges) + performance budget.
- **Engineering → Support**: release notes + known issues + workaround steps.
- **Support → Product**: weekly top-10 issues with impact estimate and examples.

## 3) Governance Model
- **Weekly Leadership Review (60 min)**: KPI review, risks, and staffing.
- **Twice-Weekly Product Triage (45 min)**: backlog decisions and scope control.
- **Engineering Architecture Review (weekly, 45 min)**: technical debt and design decisions.
- **Release Go/No-Go (per release)**: quality gates, rollback plan, owner sign-off.

### 3.1) Repository Source of Truth
- Product/tech documentation: `README.md`, `DOCUMENTATION.md`, `ARCHITECTURE.md`, `DEVELOPMENT.md`
- Open decision items: `OPEN_ISSUES.md`
- Technical risk and audit history: `AUDIT_REPORT.md`
- Delivery tracking scripts: `issues_blocking_go_live.py`, `full_issues_report.py`
- Internal planning docs: `deliverables/`

## 4) Delivery Cadence
- **Sprint Length**: 2 weeks.
- **Rituals**: Planning, daily standup, mid-sprint sync, demo, retrospective.
- **Branching**: short-lived feature branches + protected main.
- **Quality Gates**: analyze, tests, build matrix, manual smoke checks.

### 4.1) Definition of Done (minimum)
- Feature matches acceptance criteria and handles edge cases
- `flutter analyze --fatal-infos` and `flutter test` pass in CI
- User-visible changes have release notes (and support notes if needed)
- No false advertising (ensure paywall copy matches real product capabilities)

### 4.2) Release Train (suggested)
- **Weekly release** (or every 2 weeks early on)
- **Release Owner** (single person) coordinates: merge window → CI green → smoke → tag
- **Rollback plan** documented per release (what to revert, what to hotfix)

## 5) Accountability Framework (RACI Snapshot)
- **Roadmap**: Product Owner (A), PM (R), Engineering/Design (C), Support (I)
- **Shader Quality**: Graphics Lead (A/R), Mobile Eng (C), QA (C), Product (I)
- **Release**: Head of Engineering (A), DevOps (R), QA (R), Product/Growth (C)
- **Incident Response**: Operations Lead (A), Support (R), Engineering (R), Product (I)

### 5.1) Ownership Map (repository-aligned)
- **Editor UI / StudioPage**: Mobile Engineering Pod (`/lib/main.dart`)
- **Authentication UX**: Mobile Engineering Pod (`/lib/auth_screen.dart`)
- **Persistence (local state)**: Mobile Engineering Pod (`/lib/editor_storage.dart`)
- **Shader implementation**: Graphics & Rendering Pod (`/shaders/diamond_master.frag`)
- **Export paths**: Mobile Engineering Pod (`/lib/export_io.dart`, `/lib/export_web.dart`)
- **Firebase services and data contracts**: Platform/Tooling + Mobile (`/lib/firebase_service.dart`, `/lib/firebase_options.dart`, `FIREBASE_SETUP.md`)
- **CI pipeline**: Platform & Tooling (`/.github/workflows/ci.yml`)
- **Tests**: Mobile Engineering Pod (`/test/widget_test.dart`)
- **Planning / internal docs**: Operations (`/deliverables/`)

## 6) KPI System
- **Product**: activation rate, D1/D7 retention, feature adoption.
- **Engineering**: build pass rate, crash-free sessions, cycle time, escaped defects.
- **Growth**: trial-to-paid conversion, churn, LTV, CAC payback.
- **Support**: first response time, resolution time, CSAT.

### 6.1) “First Dashboard” (minimum set)
- **Acquisition**: store page views → installs
- **Activation**: first import, first export
- **Quality**: crashes, export failure rate, shader render FPS (proxy)
- **Revenue**: paywall view → purchase conversion, refund rate
- **Support load**: tickets per 1k users, top categories

## 7) Hiring Sequence (Phased)
1. Flutter Tech Lead + Product Manager
2. Shader Engineer + QA/Automation Engineer
3. Growth Manager + Support Lead
4. DevOps/Release Engineer + additional Flutter Engineer(s)

### 7.1) Role Charters (what “good” looks like)
**Flutter Tech Lead**
- Keeps CI green, owns performance budgets, and mentors engineers
- Maintains architecture decisions (what belongs in which file/module)

**Shader Engineer**
- Owns shader realism/performance and uniform contract stability
- Provides reference images and guardrails for changes

**QA/Automation**
- Owns regression prevention (high-signal tests), release smoke checklist
- Reports flaky tests and stabilizes them quickly

**Support Lead**
- Builds knowledge base, handles triage, and closes the loop into backlog

## 8) 90-Day Rollout Plan
- **Days 0–30**: finalize org chart, KPI dashboard, operating rituals, role charters.
- **Days 31–60**: stabilize release pipeline, implement QA gates, launch growth experiments.
- **Days 61–90**: optimize conversion and retention loops, publish support playbooks, run org health review.

## 8.1) “How to Fix / How to Implement This Blueprint” (practical steps)
1. **Pick Lean vs Scale** (0.1) and name owners for: Product, Engineering, Design, Growth, Operations.
2. **Write role charters** (7.1) and assign a single Release Owner.
3. **Adopt the cadence** (4): sprint planning + triage + go/no-go.
4. **Define DoD and release gates** (4.1): analyzer + tests + build matrix + smoke.
5. **Create a single backlog** and link major work to decision items in `OPEN_ISSUES.md` when needed.
6. **Publish one page per pod**: “What we own”, “What we need”, “How to escalate”.
7. **Run a 2-week pilot** and update this document based on real bottlenecks.

## 9) Decision Principles
- Prioritize user value over feature volume.
- Keep quality gates strict and visible.
- Favor measurable experiments over opinion.
- Preserve a single source of truth for roadmap and ownership.

## 10) Appendix — Operating Checklists
### 10.1) Weekly Go/No-Go checklist (minimum)
- CI green on default branch
- No known data-loss or export-corruption bugs open
- Paywall copy matches shipped capabilities
- Support prepared: release notes + known issues

### 10.2) Incident response (lightweight)
- **Severity**: define Sev0 (crash/data loss/payment issues), Sev1, Sev2
- **Roles**: Incident Commander (Ops), Tech Lead (Eng), Comms (Ops/Growth)
- **Timeline**: acknowledge within 30 minutes for Sev0 during business hours

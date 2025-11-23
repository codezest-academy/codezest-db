# .context - Documentation Hub

Consolidated documentation for the `@codezest-academy/codezest-db` package and overall CodeZest project architecture.

---

## 📁 Folder Structure

```
.context/
├── this-repo/              # codezest-db specific documentation (4 files)
├── project-wide/           # Overall CodeZest architecture (4 files)
├── guides/                 # Reusable setup guides for all repos (4 files)
└── README.md               # This file
```

**Total: 13 files** (consolidated from 23 original files)

---

## 📂 Folder Descriptions

### `this-repo/` - CodeZest-DB Specific

Files specific to this repository only.

| File                | Description                                                                        | Size  |
| ------------------- | ---------------------------------------------------------------------------------- | ----- |
| **01_setup.md**     | Complete setup, environment config, and package migration guide                    | ~40KB |
| **02_schema.md**    | Complete schema design (30 models), changes, updates, and implementation checklist | ~60KB |
| **03_progress.md**  | Current progress tracking and implementation completion status                     | ~18KB |
| **04_changelog.md** | Version history and release notes                                                  | ~3KB  |

### `project-wide/` - CodeZest Project Architecture

Architecture and decisions that apply to all CodeZest services.

| File                   | Description                                                                                    | Size  |
| ---------------------- | ---------------------------------------------------------------------------------------------- | ----- |
| **01_architecture.md** | System architecture, microservices design, payments, subscriptions, and implementation roadmap | ~35KB |
| **02_decisions.md**    | Architectural decision records (ADRs) - subscription service consolidation                     | ~2KB  |
| **03_deployment.md**   | Deployment scripts and strategies for all environments                                         | ~16KB |
| **04_improvements.md** | Project-wide improvements, tooling, and standards                                              | ~6KB  |

### `guides/` - Reusable Setup Guides

Guides that can be used across all CodeZest repositories.

| File                   | Description                                                  | Size |
| ---------------------- | ------------------------------------------------------------ | ---- |
| **consuming-db.md**    | How to use `@codezest-academy/codezest-db` in other services | ~3KB |
| **consuming-cache.md** | How to use the cache package                                 | ~3KB |
| **github-actions.md**  | CI/CD setup guide for GitHub Actions                         | ~4KB |
| **linting-setup.md**   | ESLint + Prettier configuration guide                        | ~3KB |

---

## 🎯 Quick Navigation

### For New Developers

**Start here to understand the project:**

1. Read [`project-wide/01_architecture.md`](project-wide/01_architecture.md) - Understand overall CodeZest system architecture
2. Read [`this-repo/01_setup.md`](this-repo/01_setup.md) - Set up this repository locally
3. Read [`this-repo/02_schema.md`](this-repo/02_schema.md) - Understand the database schema (30 models)
4. Read [`guides/consuming-db.md`](guides/consuming-db.md) - Learn how to use this package in other services

### For Resuming Work

**Check current status:**

1. Check [`this-repo/03_progress.md`](this-repo/03_progress.md) - See current implementation status
2. Check [`this-repo/02_schema.md`](this-repo/02_schema.md) - Review schema implementation checklist
3. Check [`this-repo/04_changelog.md`](this-repo/04_changelog.md) - See recent changes

### For Setting Up Other Repos

**Use these guides:**

1. Use [`guides/consuming-db.md`](guides/consuming-db.md) - Integrate database package
2. Use [`guides/consuming-cache.md`](guides/consuming-cache.md) - Integrate cache package
3. Use [`guides/github-actions.md`](guides/github-actions.md) - Set up CI/CD
4. Use [`guides/linting-setup.md`](guides/linting-setup.md) - Configure code quality tools

### For Understanding Architecture Decisions

**Read these documents:**

1. Read [`project-wide/01_architecture.md`](project-wide/01_architecture.md) - Complete architecture overview
2. Read [`project-wide/02_decisions.md`](project-wide/02_decisions.md) - Key architectural decisions
3. Read [`project-wide/04_improvements.md`](project-wide/04_improvements.md) - Recent improvements

---

## 📖 Document Contents Overview

### this-repo/01_setup.md

**Sections:**

- Prerequisites
- Quick Start (Local Development)
- GitHub Setup
- Publishing Workflow
- Schema Change Workflow
- Testing in Consuming Services
- Database Migration (Production)
- Monitoring & Maintenance
- Security Best Practices
- Troubleshooting
- Environment Setup (Development, Staging, Production)
- Package Migration Guide

### this-repo/02_schema.md

**Sections:**

- Complete Schema Design (30 models across 5 services)
- Auth Service Models (6 models)
- Learning Service Models (15 models)
- Payment Service Models (4 models)
- Notification Service Models (3 models)
- Activity Service Models (2 models)
- Schema Changes Log
- Schema Update Guide
- Updates Summary (Payment & AI Analysis additions)
- Implementation Checklist

### this-repo/03_progress.md

**Sections:**

- Overall Progress (Planning, Implementation, Testing, Documentation)
- Completed Tasks
- Current Task
- Pending Tasks
- Database Models Progress (30/30)
- Enums Progress (12/12)
- Blockers & Issues
- Session Notes
- Update Log
- Metrics
- Next Steps

### this-repo/04_changelog.md

**Sections:**

- Version History
- Release Notes
- Breaking Changes
- New Features
- Bug Fixes

### project-wide/01_architecture.md

**Sections:**

- Executive Summary
- System Overview (5 microservices)
- Architecture Principles (SOLID, Clean Architecture)
- Communication Strategy (Sync/Async)
- Detailed Service Architecture
- Infrastructure & Deployment
- Implementation Roadmap
- Design Patterns
- Code Style Enforcement
- Payments Architecture
- Subscription & Coupon Design
- Implementation Plan

### project-wide/02_decisions.md

**Sections:**

- Architectural Decision Records (ADRs)
- Subscription Service Decision (Why merged into payments)

### project-wide/03_deployment.md

**Sections:**

- Deployment Scripts
- Environment-Specific Deployments
- CI/CD Integration
- Rollback Procedures

### project-wide/04_improvements.md

**Sections:**

- Linting & Code Quality (ESLint, Prettier)
- Production Logger (Winston)
- Testing Framework (Jest migration)
- Architecture Documentation
- Package Configuration
- Project Standards Alignment
- CI/CD Improvements

### guides/consuming-db.md

**Sections:**

- Installation
- Configuration
- Usage Examples
- Type Safety
- Best Practices

### guides/consuming-cache.md

**Sections:**

- Installation
- Configuration
- Usage Examples
- Cache Strategies

### guides/github-actions.md

**Sections:**

- Workflow Setup
- Publishing to GitHub Packages
- Automated Testing
- Deployment Workflows

### guides/linting-setup.md

**Sections:**

- ESLint Configuration
- Prettier Setup
- Pre-commit Hooks
- CI/CD Integration

---

## 🔍 Finding Information

### By Topic

| Topic                       | File                              |
| --------------------------- | --------------------------------- |
| **Setup & Installation**    | `this-repo/01_setup.md`           |
| **Database Schema**         | `this-repo/02_schema.md`          |
| **Current Status**          | `this-repo/03_progress.md`        |
| **Version History**         | `this-repo/04_changelog.md`       |
| **System Architecture**     | `project-wide/01_architecture.md` |
| **Architectural Decisions** | `project-wide/02_decisions.md`    |
| **Deployment**              | `project-wide/03_deployment.md`   |
| **Improvements**            | `project-wide/04_improvements.md` |
| **Using Database Package**  | `guides/consuming-db.md`          |
| **Using Cache**             | `guides/consuming-cache.md`       |
| **CI/CD Setup**             | `guides/github-actions.md`        |
| **Code Quality**            | `guides/linting-setup.md`         |

### By Service

| Service                     | Relevant Files                                              |
| --------------------------- | ----------------------------------------------------------- |
| **codezest-db** (this repo) | All files in `this-repo/`                                   |
| **codezest-auth**           | `guides/consuming-db.md`, `project-wide/01_architecture.md` |
| **codezest-api**            | `guides/consuming-db.md`, `project-wide/01_architecture.md` |
| **codezest-payments**       | `guides/consuming-db.md`, `project-wide/01_architecture.md` |
| **codezest-notifications**  | `guides/consuming-db.md`, `project-wide/01_architecture.md` |
| **codezest-activity**       | `guides/consuming-db.md`, `project-wide/01_architecture.md` |

---

## 📝 Notes

### Consolidation Benefits

This folder structure consolidates 23 original files into 13 organized files:

✅ **43% reduction** in file count  
✅ **Clear separation** by scope (this repo vs. project-wide vs. guides)  
✅ **Related content** grouped together  
✅ **Easier navigation** with logical folder structure  
✅ **Better context retrieval** for AI agents and developers

### Original Files (Now Consolidated)

The following original files have been consolidated:

**this-repo/ folder:**

- SETUP.md + ENVIRONMENT_SETUP.md + PACKAGE_MIGRATION_GUIDE.md → `01_setup.md`
- PLAN_OVERVIEW.md + SCHEMA_CHANGES.md + SCHEMA_UPDATE_GUIDE.md + UPDATES_SUMMARY.md + IMPLEMENTATION.md → `02_schema.md`
- PROGRESS.md + IMPLEMENTATION_COMPLETE.md → `03_progress.md`
- CHANGELOG.md → `04_changelog.md`

**project-wide/ folder:**

- ARCHITECTURE_DESIGN.md + PAYMENTS_ARCHITECTURE.md + SUBSCRIPTION_AND_COUPON_DESIGN.md + implementation_plan.md → `01_architecture.md`
- SUBSCRIPTION_SERVICE_DECISION.md → `02_decisions.md`
- DEPLOYMENT_SCRIPTS.md → `03_deployment.md`
- PROJECT_IMPROVEMENTS.md → `04_improvements.md`

**guides/ folder:**

- DB_CONSUMING.md → `consuming-db.md`
- CACHE_CONSUMING.md → `consuming-cache.md`
- GITHUB_ACTIONS_GUIDE.md → `github-actions.md`
- LINTING_SETUP_GUIDE.md → `linting-setup.md`

### Maintenance

- These files are **not published** to npm (excluded in `.npmignore`)
- These files **are committed** to git (for team context)
- Keep these files **up to date** for seamless collaboration
- Use these files for **onboarding** new team members

---

## 🚀 Getting Started

**New to this project?** Follow this path:

1. **Understand the big picture**: Read [`project-wide/01_architecture.md`](project-wide/01_architecture.md)
2. **Set up locally**: Follow [`this-repo/01_setup.md`](this-repo/01_setup.md)
3. **Learn the schema**: Study [`this-repo/02_schema.md`](this-repo/02_schema.md)
4. **Check progress**: Review [`this-repo/03_progress.md`](this-repo/03_progress.md)
5. **Use in other services**: Follow [`guides/consuming-db.md`](guides/consuming-db.md)

---

**Last Updated**: 2025-11-24  
**Status**: Consolidated and organized for optimal context retrieval  
**Maintained by**: CodeZest Academy

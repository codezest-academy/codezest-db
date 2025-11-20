# GitHub Workflows

This directory contains GitHub Actions workflows for CI/CD automation.

## ⚠️ VS Code Warnings (Can be Ignored)

You may see warnings in VS Code like:
- `Unable to resolve action 'actions/checkout@v3'`
- `Context access might be invalid: NPM_TOKEN`

**These are expected and can be safely ignored.** VS Code cannot validate GitHub Actions locally. The workflows will work correctly when pushed to GitHub.

---

## 📋 Workflows

### 1. `ci-cd.yml` - Main CI/CD Pipeline

**Triggers:**
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop`
- Release creation

**Jobs:**
- **Build & Test**: Compiles TypeScript, generates Prisma client, runs type checks
- **Publish to npm**: Publishes package to npm registry (on release)
- **Publish to GitHub Packages**: Publishes to GitHub Packages (on release)

**Required Secrets:**
- `NPM_TOKEN` - npm authentication token

### 2. `migrate.yml` - Database Migration

**Triggers:**
- Manual workflow dispatch

**Jobs:**
- **Migrate**: Runs Prisma migrations on selected environment

**Required Secrets:**
- `DATABASE_URL` - PostgreSQL connection string (per environment)

---

## 🚀 Usage

### Running CI/CD

CI/CD runs automatically on push/PR. To publish:

1. Create a new release on GitHub
2. Tag format: `v1.0.0`
3. CI/CD will automatically build and publish

### Running Migrations

1. Go to **Actions** tab
2. Select **Database Migration** workflow
3. Click **Run workflow**
4. Choose environment (development/staging/production)
5. Click **Run workflow**

---

## 🔧 Setup Required

### 1. Add Secrets

Go to **Settings → Secrets and variables → Actions**

Add:
- `NPM_TOKEN` - Get from https://www.npmjs.com/settings/YOUR_USERNAME/tokens
- `DATABASE_URL` - Your Neon PostgreSQL connection string

### 2. Configure Environments (Optional)

Go to **Settings → Environments**

Create:
- `development` - with dev `DATABASE_URL`
- `staging` - with staging `DATABASE_URL`
- `production` - with prod `DATABASE_URL`

---

## 📝 Notes

- Workflows use Node.js 20
- `npm ci` is used for faster, deterministic installs
- Build artifacts are retained for 7 days
- Migrations run with `prisma migrate deploy` (production-safe)

---

For more details, see [SETUP.md](../SETUP.md)

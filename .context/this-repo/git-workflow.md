# Git Workflow & Publishing Guide for CodeZest-DB

## 📋 Project Context

**Project Type**: Shared NPM package (database schema)  
**Repository**: `https://github.com/codezest-academy/codezest-db.git`  
**Package**: `@codezest-academy/codezest-db`  
**Current Version**: `1.0.5`  
**Registry**: GitHub Packages (`https://npm.pkg.github.com/`)  
**Branch Strategy**: `main` (production) + `develop` (development)

---

## ✅ Recommended Workflow for This Project

Based on your project structure and CI/CD setup, here's the **standard practice**:

### 🎯 For Schema Changes (Like Your Current Changes)

```bash
# 1. Create a feature branch
git checkout -b feat/add-user-security-fields

# 2. Stage your changes
git add prisma/schema.prisma
git add prisma/migrations/20251126010431_add_user_security_fields/

# 3. Commit with conventional commit message
git commit -m "feat: add user security fields (account lockout, 2FA, login tracking)"

# 4. Push to remote
git push origin feat/add-user-security-fields

# 5. Create Pull Request on GitHub
# - Go to: https://github.com/codezest-academy/codezest-db
# - Click "Compare & pull request"
# - Base: main ← Compare: feat/add-user-security-fields
# - Add description of changes
# - Request review (if team collaboration)

# 6. After PR approval, merge to main
# - Merge via GitHub UI (Squash and merge recommended)

# 7. Publish new version (on main branch)
git checkout main
git pull origin main
npm run release  # Bumps version to 1.0.6 and publishes
```

---

## 🔄 Complete Workflow Breakdown

### Step 1: Create Feature Branch

```bash
# Always branch from main
git checkout main
git pull origin main

# Create descriptive branch
git checkout -b feat/add-user-security-fields
```

**Branch Naming Convention**:

- `feat/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation updates
- `chore/` - Maintenance tasks

### Step 2: Make Your Changes

✅ You've already done this:

- Modified `prisma/schema.prisma`
- Created migration `20251126010431_add_user_security_fields/`

### Step 3: Stage and Commit

```bash
# Check what changed
git status

# Stage schema and migration
git add prisma/schema.prisma
git add prisma/migrations/20251126010431_add_user_security_fields/

# Optional: Stage scripts if needed
git add scripts/README.md
git add scripts/set_github_token.sh

# Commit with conventional commit format
git commit -m "feat: add user security fields

- Add account security (isActive, isSuspended, suspension tracking)
- Add login security (lastLoginAt, loginAttempts, account lockout)
- Add password management (passwordChangedAt, mustChangePassword)
- Add 2FA/MFA support (twoFactorEnabled, twoFactorSecret, backupCodes)
- Add username field for future social features
- Add email preferences (emailNotifications, marketingEmails)
- Add session revocation support (revokedAt)
- Add password reset tracking (ipAddress, userAgent)

BREAKING CHANGE: None (all fields have safe defaults)
Closes #<issue-number> (if applicable)"
```

### Step 4: Push to Remote

```bash
# Push feature branch
git push origin feat/add-user-security-fields

# If this is your first push
git push -u origin feat/add-user-security-fields
```

### Step 5: Create Pull Request

**On GitHub**:

1. Go to `https://github.com/codezest-academy/codezest-db`
2. Click **"Compare & pull request"** (appears after push)
3. Fill in PR details:

```markdown
## 🎯 Summary

Add industry-standard security fields to User model

## 📝 Changes

- ✅ Account security (suspension, activation)
- ✅ Login tracking (IP, timestamp, failed attempts)
- ✅ Account lockout (brute force protection)
- ✅ 2FA/MFA support (TOTP ready)
- ✅ Username field (future-proofing)
- ✅ Email preferences (GDPR compliance)
- ✅ Session revocation
- ✅ Password reset tracking

## 🔍 Migration

- Migration: `20251126010431_add_user_security_fields`
- All fields have safe defaults
- No breaking changes
- Backward compatible

## ✅ Checklist

- [x] Schema validated (`npx prisma validate`)
- [x] Migration tested locally
- [x] Prisma Client regenerated
- [x] No breaking changes
- [x] Documentation updated (if needed)

## 📊 Industry Comparison

After this change, CodeZest matches Auth0, Firebase, and Supabase security standards.
```

4. **Request Review** (if working with a team)
5. **Wait for CI/CD** to pass (automatic checks)

### Step 6: Merge Pull Request

**After approval**:

1. Click **"Squash and merge"** (recommended) or **"Merge pull request"**
2. Delete the feature branch (GitHub will prompt)

### Step 7: Publish New Version

```bash
# Switch to main
git checkout main

# Pull latest (includes your merged PR)
git pull origin main

# Publish (bumps version + publishes to GitHub Packages)
npm run release
```

**What `npm run release` does**:

```bash
npm version patch  # 1.0.5 → 1.0.6
npm publish --access public
```

This will:

1. Bump version in `package.json` (1.0.5 → 1.0.6)
2. Create a git tag (`v1.0.6`)
3. Publish to GitHub Packages
4. Trigger CI/CD workflow (builds and publishes)

---

## 🤖 CI/CD Automation

Your project has automated workflows:

### On Pull Request

✅ Runs automatically:

- Lint check
- Format check
- TypeScript type check
- Build package
- Generate Prisma Client

### On Merge to Main

✅ Runs automatically:

- All PR checks
- Uploads build artifacts

### On Version Tag (v\*)

✅ Publishes to GitHub Packages:

- Builds package
- Publishes to `https://npm.pkg.github.com/`

---

## 📦 Publishing Options

### Option 1: Automatic (Recommended)

```bash
npm run release
```

This handles everything automatically.

### Option 2: Manual

```bash
# Bump version manually
npm version patch  # or minor, or major

# Build
npm run build

# Publish
npm publish --access public
```

### Version Bumping Rules

- **Patch** (1.0.5 → 1.0.6): Bug fixes, minor changes
- **Minor** (1.0.5 → 1.1.0): New features, backward compatible
- **Major** (1.0.5 → 2.0.0): Breaking changes

For your changes: **Minor** is appropriate (new features, no breaking changes)

```bash
npm version minor  # 1.0.5 → 1.1.0
```

---

## 🎯 Quick Commands for Your Current Changes

```bash
# 1. Create branch
git checkout -b feat/add-user-security-fields

# 2. Stage changes
git add prisma/schema.prisma prisma/migrations/

# 3. Commit
git commit -m "feat: add user security fields (account lockout, 2FA, login tracking)"

# 4. Push
git push -u origin feat/add-user-security-fields

# 5. Create PR on GitHub
# (Use the PR template above)

# 6. After merge, publish
git checkout main
git pull origin main
npm version minor  # 1.0.5 → 1.1.0 (new features)
npm publish --access public
```

---

## 🔐 GitHub Packages Authentication

Consumers need to authenticate to install:

```bash
# Create .npmrc in consuming projects
echo "@codezest-academy:registry=https://npm.pkg.github.com" >> .npmrc
echo "//npm.pkg.github.com/:_authToken=YOUR_GITHUB_PAT" >> .npmrc
```

---

## 📋 Consuming Services Update

After publishing, update in microservices:

```bash
# In codezest-auth, codezest-api, etc.
npm install @codezest-academy/codezest-db@latest

# Run migrations
npx prisma migrate deploy
```

---

## ✅ Best Practices Summary

1. ✅ **Always use feature branches** (never commit directly to `main`)
2. ✅ **Use conventional commits** (`feat:`, `fix:`, `refactor:`)
3. ✅ **Create PRs for review** (even if solo, good for history)
4. ✅ **Let CI/CD run** before merging
5. ✅ **Bump version semantically** (patch/minor/major)
6. ✅ **Commit migration files** (critical for shared package)
7. ✅ **Test locally first** (`npm run build`, `npx prisma validate`)

---

## 🚨 Important Notes

> **CRITICAL**: This is a shared package consumed by multiple microservices.
>
> - ✅ Always commit migration files
> - ✅ Never skip version bumps
> - ✅ Test migrations before publishing
> - ✅ Coordinate with consuming services on major changes

> **Golden Rules** (from README):
>
> 1. Only this repo can change `schema.prisma`
> 2. Always commit `prisma/migrations/` folder
> 3. Version bump after every schema change
> 4. Run migrations BEFORE app starts in production
> 5. Never use foreign keys across service schemas

---

## 🎯 Your Next Steps

For your current changes:

```bash
# Option A: Feature Branch + PR (Recommended)
git checkout -b feat/add-user-security-fields
git add prisma/
git commit -m "feat: add user security fields"
git push -u origin feat/add-user-security-fields
# Then create PR on GitHub

# Option B: Direct to Main (if you're solo and confident)
git checkout main
git add prisma/
git commit -m "feat: add user security fields"
git push origin main
npm version minor  # 1.0.5 → 1.1.0
npm publish --access public
```

**Recommendation**: Use **Option A** (PR workflow) for better history and CI/CD validation.

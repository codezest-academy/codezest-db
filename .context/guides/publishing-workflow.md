# Git Workflow Best Practices - CodeZest DB

## 📋 Project Overview

**Type**: Shared NPM Package (Database Schema)  
**Repository**: `codezest-academy/codezest-db`  
**Package**: `@codezest-academy/codezest-db`  
**Registry**: GitHub Packages  
**Consumers**: Multiple microservices (auth, api, learning, payments, etc.)

---

## 🎯 Golden Rules

> **CRITICAL**: This is a shared package. Changes affect multiple services.

1. ✅ **Always use feature branches** (never commit directly to `main`)
2. ✅ **Always commit migration files** (`prisma/migrations/`)
3. ✅ **Always bump version** after schema changes
4. ✅ **Always test locally** before pushing
5. ✅ **Always create PRs** (even if solo, for history)
6. ✅ **Always use conventional commits** (`feat:`, `fix:`, `refactor:`)

---

## 🔄 Standard Workflow

### 1. Create Feature Branch

```bash
# Start from main
git checkout main
git pull origin main

# Create descriptive branch
git checkout -b feat/your-feature-name
```

**Branch Naming**:

- `feat/` - New features
- `fix/` - Bug fixes
- `refactor/` - Code refactoring
- `docs/` - Documentation
- `chore/` - Maintenance

### 2. Make Changes

```bash
# Edit schema
vim prisma/schema.prisma

# Generate migration
npx prisma migrate dev --name your_migration_name

# Validate
npx prisma validate

# Test
npm run build
```

### 3. Stage & Commit

```bash
# Check status
git status

# Stage schema + migrations
git add prisma/schema.prisma
git add prisma/migrations/

# Commit with conventional format
git commit -m "feat: add user security fields

- Add account lockout
- Add 2FA support
- Add login tracking

BREAKING CHANGE: None (all fields optional)"
```

### 4. Push to Remote

```bash
# First push
git push -u origin feat/your-feature-name

# Subsequent pushes
git push
```

### 5. Create Pull Request

**On GitHub**:

1. Go to repository
2. Click "Compare & pull request"
3. Fill in PR template (see below)
4. Request review (if team)
5. Wait for CI/CD checks

### 6. Merge PR

**After approval**:

- Use "Squash and merge" (recommended)
- Delete feature branch

### 7. Publish

```bash
# Switch to main
git checkout main
git pull origin main

# Set GitHub token
export NODE_AUTH_TOKEN=your_github_token

# Bump version and publish
npm version minor  # or patch/major
npm publish --access public
```

---

## 📝 Conventional Commits

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat:` - New feature
- `fix:` - Bug fix
- `refactor:` - Code refactoring
- `docs:` - Documentation
- `chore:` - Maintenance
- `test:` - Tests
- `perf:` - Performance

### Examples

**Simple**:

```bash
git commit -m "feat: add user email verification"
```

**Detailed**:

```bash
git commit -m "feat: add user security fields

- Add account lockout (loginAttempts, lockedUntil)
- Add 2FA support (twoFactorEnabled, twoFactorSecret)
- Add login tracking (lastLoginAt, lastLoginIp)

BREAKING CHANGE: None (all fields have safe defaults)
Closes #123"
```

---

## 📋 Pull Request Template

```markdown
## 🎯 Summary

Brief description of changes

## 📝 Changes

- ✅ Change 1
- ✅ Change 2
- ✅ Change 3

## 🔍 Migration

- Migration: `migration_name`
- Breaking changes: Yes/No
- Backward compatible: Yes/No

## ✅ Checklist

- [ ] Schema validated
- [ ] Migration tested locally
- [ ] Prisma Client regenerated
- [ ] No breaking changes (or documented)
- [ ] Documentation updated

## 📊 Impact

Description of impact on consuming services
```

---

## 🔢 Version Bumping

### Semantic Versioning (SemVer)

**Format**: `MAJOR.MINOR.PATCH`

- **PATCH** (1.0.5 → 1.0.6): Bug fixes, no new features
- **MINOR** (1.0.5 → 1.1.0): New features, backward compatible
- **MAJOR** (1.0.5 → 2.0.0): Breaking changes

### When to Use Each

**Patch** (`npm version patch`):

- Bug fixes
- Documentation updates
- Minor refactoring
- No schema changes

**Minor** (`npm version minor`):

- New fields (with safe defaults)
- New models
- New indexes
- Backward compatible changes

**Major** (`npm version major`):

- Removing fields
- Changing field types
- Breaking changes
- Requires code updates in consumers

### For Schema Changes

```bash
# New fields (safe defaults) → Minor
npm version minor

# Breaking changes → Major
npm version major

# Bug fixes only → Patch
npm version patch
```

---

## 🤖 CI/CD Automation

### Triggers

**On Pull Request**:

- ✅ Lint check
- ✅ Format check
- ✅ Type check
- ✅ Build
- ✅ Generate Prisma Client

**On Merge to Main**:

- ✅ All PR checks
- ✅ Upload artifacts

**On Version Tag** (`v*`):

- ✅ Build package
- ✅ Publish to GitHub Packages

### Required Secrets

- `NPM_TOKEN` - GitHub Personal Access Token
- `DATABASE_URL` - PostgreSQL connection string

---

## 📦 Publishing Workflow

### Automatic (Recommended)

```bash
# Bumps version + publishes
npm run release
```

### Manual

```bash
# 1. Bump version
npm version minor  # or patch/major

# 2. Build
npm run build

# 3. Publish
export NODE_AUTH_TOKEN=your_github_token
npm publish --access public
```

### After Publishing

**Update consuming services**:

```bash
# In each microservice
npm install @codezest-academy/codezest-db@latest
npx prisma migrate deploy
npx prisma generate
```

---

## 🚨 Common Mistakes to Avoid

### ❌ DON'T

1. ❌ Commit directly to `main`
2. ❌ Skip migration files
3. ❌ Forget to bump version
4. ❌ Publish without testing
5. ❌ Make breaking changes without documenting
6. ❌ Skip PR review (even if solo)

### ✅ DO

1. ✅ Use feature branches
2. ✅ Commit all migration files
3. ✅ Bump version after every schema change
4. ✅ Test locally first
5. ✅ Document breaking changes
6. ✅ Create PRs for history

---

## 🔍 Pre-Push Checklist

Before pushing:

- [ ] Schema validated (`npx prisma validate`)
- [ ] Migration generated (`npx prisma migrate dev`)
- [ ] Build successful (`npm run build`)
- [ ] Lint passed (`npm run lint`)
- [ ] Format checked (`npm run format:check`)
- [ ] Type check passed (`npm run typecheck`)
- [ ] Migration files staged
- [ ] Conventional commit message
- [ ] Breaking changes documented

---

## 📚 Quick Commands Reference

### Development

```bash
# Validate schema
npx prisma validate

# Generate migration
npx prisma migrate dev --name migration_name

# Apply migration
npx prisma migrate deploy

# Generate Prisma Client
npx prisma generate

# Open Prisma Studio
npx prisma studio
```

### Git

```bash
# Create branch
git checkout -b feat/feature-name

# Stage changes
git add prisma/

# Commit
git commit -m "feat: description"

# Push
git push -u origin feat/feature-name

# Merge main into feature
git merge main

# Rebase on main
git rebase main
```

### Publishing

```bash
# Bump version
npm version patch|minor|major

# Publish
npm publish --access public

# Release (bump + publish)
npm run release
```

---

## 🎯 Workflow Examples

### Example 1: Adding New Fields

```bash
# 1. Create branch
git checkout -b feat/add-user-avatar

# 2. Edit schema
# Add: avatar String? to User model

# 3. Generate migration
npx prisma migrate dev --name add_user_avatar

# 4. Validate
npx prisma validate

# 5. Commit
git add prisma/
git commit -m "feat: add user avatar field"

# 6. Push
git push -u origin feat/add-user-avatar

# 7. Create PR, merge, publish
git checkout main
git pull origin main
npm version minor
npm publish --access public
```

### Example 2: Breaking Change

```bash
# 1. Create branch
git checkout -b feat/rename-user-field

# 2. Edit schema
# Rename: name → fullName

# 3. Generate migration with data migration
npx prisma migrate dev --name rename_user_name_field --create-only

# 4. Edit migration SQL to preserve data
# Add: UPDATE users SET fullName = name;

# 5. Apply migration
npx prisma migrate dev

# 6. Commit
git add prisma/
git commit -m "feat: rename user name field

BREAKING CHANGE: User.name renamed to User.fullName"

# 7. Push, PR, merge
git push -u origin feat/rename-user-field

# 8. Publish as MAJOR version
git checkout main
git pull origin main
npm version major  # 1.0.5 → 2.0.0
npm publish --access public
```

---

## 📞 Getting Help

- **Documentation**: Check `.context/` folder
- **Issues**: Create GitHub issue
- **Questions**: Ask in team chat

---

## ✅ Summary

**Remember**:

1. Feature branches → PR → Merge → Publish
2. Always commit migrations
3. Always bump version
4. Use conventional commits
5. Test before pushing
6. Document breaking changes

**This workflow ensures**:

- Clean git history
- Proper versioning
- CI/CD validation
- Team collaboration
- Safe deployments

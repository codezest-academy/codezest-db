# Setup Guide - @codezest-academy/codezest-db

Complete setup, environment configuration, and package migration guide for the CodeZest database package.

---

## 📋 Prerequisites

- Node.js 20+ installed
- PostgreSQL database (Neon recommended)
- npm account (for publishing)
- GitHub repository access

---

## 🚀 Quick Start (Local Development)

### 1. Clone & Install

```bash
cd /path/to/codezest-db
npm install
```

### 2. Set Up Database

Create a `.env` file:

```bash
# Neon PostgreSQL (Recommended)
DATABASE_URL="postgresql://user:password@ep-name.region.aws.neon.tech/codezest?sslmode=require"

# MongoDB (Optional)
MONGODB_URL="mongodb+srv://user:password@cluster.mongodb.net/codezest"
```

**Get Neon Database URL:**

1. Go to https://console.neon.tech/
2. Create new project → "codezest-db"
3. Copy connection string
4. Paste into `.env`

### 3. Run Initial Migration

```bash
# Create initial migration
npm run migrate:dev -- --name init

# This will:
# ✅ Create all 30 tables
# ✅ Set up relationships
# ✅ Create indexes
# ✅ Generate migration files in prisma/migrations/
```

### 4. Verify with Prisma Studio

```bash
npm run db:studio
```

Opens at http://localhost:5555 - you should see all 30 models!

### 5. Test the Package

```bash
# Build
npm run build

# Verify exports
node -e "const db = require('./dist/index.js'); console.log('✅ Package works!', db.prisma)"
```

---

## 🔧 GitHub Setup

### 1. Create Repository

```bash
git init
git add .
git commit -m "feat: initial implementation of @codezest-academy/db"
git branch -M main
git remote add origin https://github.com/codezest-academy/codezest-db.git
git push -u origin main
```

### 2. Set Up Secrets

Go to **Settings → Secrets and variables → Actions**

Add these secrets:

| Secret Name    | Value                  | Purpose                  |
| -------------- | ---------------------- | ------------------------ |
| `NPM_TOKEN`    | Your npm token         | Publishing to npm        |
| `DATABASE_URL` | Neon connection string | Running migrations in CI |

**Get npm token:**

1. Go to https://www.npmjs.com/settings/YOUR_USERNAME/tokens
2. Generate New Token → Classic Token → Automation
3. Copy token
4. Add to GitHub secrets

### 3. Configure Environments (Optional)

Go to **Settings → Environments**

Create environments:

- `development` - with dev DATABASE_URL
- `staging` - with staging DATABASE_URL
- `production` - with prod DATABASE_URL

---

## 📦 Publishing Workflow

### Method 1: Automated (Recommended)

```bash
# 1. Make changes to schema
code prisma/schema.prisma

# 2. Create migration
npm run migrate:dev -- --name add_new_field

# 3. Commit changes
git add .
git commit -m "feat: add new field to User model"
git push

# 4. Create release on GitHub
# Go to Releases → Create new release
# Tag: v1.0.0
# Title: v1.0.0 - Initial Release
# Click "Publish release"

# GitHub Actions will automatically:
# ✅ Build package
# ✅ Run tests
# ✅ Publish to npm
# ✅ Publish to GitHub Packages
```

### Method 2: Manual

```bash
# 1. Build
npm run build

# 2. Bump version
npm version patch  # or minor, or major

# 3. Publish
npm publish --access public

# 4. Push tags
git push --tags
```

---

## 🔄 Schema Change Workflow

### Making Changes

```bash
# 1. Edit schema
code prisma/schema.prisma

# 2. Create migration
npm run migrate:dev -- --name descriptive_name

# 3. Test locally
npm run db:studio

# 4. Commit migration files
git add prisma/migrations
git commit -m "feat: add XYZ model"

# 5. Push
git push

# 6. Bump version
npm version patch

# 7. Create release on GitHub
# This triggers CI/CD to publish
```

### In Consuming Services

To install packages from GitHub Packages, you must configure `.npmrc` in the consuming project:

1. Create `.npmrc` in the project root:

```ini
@codezest-academy:registry=https://npm.pkg.github.com
//npm.pkg.github.com/:_authToken=${GITHUB_TOKEN}
```

2. Install the package:

```bash
# Ensure GITHUB_TOKEN is set in your environment
export GITHUB_TOKEN=your_personal_access_token
npm install @codezest-academy/db@latest
```

3. Run migrations:

```bash
npx prisma migrate deploy --schema=node_modules/@codezest-academy/db/prisma/schema.prisma
```

4. Restart app:

```bash
npm run dev
```

---

## 🧪 Testing in Consuming Services

### codezest-auth Example

```bash
cd /path/to/codezest-auth

# Install package
npm install @codezest-academy/db@latest

# Test import
node -e "const { prisma, User, Role } = require('@codezest-academy/db'); console.log('✅ Imports work!')"

# Use in code
```

**src/index.ts:**

```typescript
import { prisma, User, Role } from '@codezest-academy/db';

// Create user
const user = await prisma.user.create({
  data: {
    email: 'test@example.com',
    name: 'Test User',
    role: Role.STUDENT,
  },
});

console.log('Created user:', user);
```

---

## 🗄️ Database Migration (Production)

### Using GitHub Actions (Recommended)

1. Go to **Actions → Database Migration**
2. Click "Run workflow"
3. Select environment: `production`
4. Click "Run workflow"

### Manual Migration

```bash
# Set production DATABASE_URL
export DATABASE_URL="postgresql://..."

# Run migration
npx prisma migrate deploy

# Verify
npx prisma db pull
```

---

## 📊 Monitoring & Maintenance

### Check Migration Status

```bash
npx prisma migrate status
```

### Rollback Migration (if needed)

```bash
# Prisma doesn't support automatic rollback
# You need to create a new migration that reverses changes

# Example: If you added a field, create migration to remove it
npm run migrate:dev -- --name rollback_field_addition
```

### View Database

```bash
# Prisma Studio
npm run db:studio

# Or use Neon Console
# https://console.neon.tech/
```

---

## 🔒 Security Best Practices

### Environment Variables

- ✅ Never commit `.env` files
- ✅ Use GitHub Secrets for CI/CD
- ✅ Rotate DATABASE_URL regularly
- ✅ Use different databases for dev/staging/prod

### Access Control

- ✅ Limit database user permissions
- ✅ Use read-only replicas for analytics
- ✅ Enable SSL/TLS for connections
- ✅ Set up IP allowlisting in Neon

---

## 🐛 Troubleshooting

### "Cannot find module '@prisma/client'"

```bash
# Regenerate Prisma client
npx prisma generate
npm run build
```

### "Migration failed"

```bash
# Check DATABASE_URL
echo $DATABASE_URL

# Verify connection
npx prisma db pull

# Reset database (CAUTION: deletes all data)
npx prisma migrate reset
```

### "Type errors in consuming service"

```bash
# Update package
npm install @codezest-academy/db@latest

# Regenerate types
npx prisma generate --schema=node_modules/@codezest-academy/db/prisma/schema.prisma
```

---

## 📚 Additional Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Neon Documentation](https://neon.tech/docs)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [npm Publishing Guide](https://docs.npmjs.com/packages-and-modules/contributing-packages-to-the-registry)

---

## ✅ Checklist

### Initial Setup

- [ ] Clone repository
- [ ] Install dependencies (`npm install`)
- [ ] Create Neon database
- [ ] Add `DATABASE_URL` to `.env`
- [ ] Run initial migration (`npm run migrate:dev -- --name init`)
- [ ] Verify with Prisma Studio (`npm run db:studio`)
- [ ] Test build (`npm run build`)

### GitHub Setup

- [ ] Create GitHub repository
- [ ] Push code to GitHub
- [ ] Add `NPM_TOKEN` secret
- [ ] Add `DATABASE_URL` secret
- [ ] Configure environments (optional)

### Publishing

- [ ] Create first release on GitHub
- [ ] Verify CI/CD runs successfully
- [ ] Check package on npm
- [ ] Test in consuming service

### Ongoing

- [ ] Document schema changes in CHANGELOG
- [ ] Run migrations before deploying apps
- [ ] Monitor database performance
- [ ] Keep dependencies updated

---

# Environment Setup

Detailed environment configuration for local development, staging, and production.

---

## 📋 Environment Variables

### Required Variables

```bash
# Database
DATABASE_URL="postgresql://user:password@host:5432/database?sslmode=require"

# Optional: MongoDB
MONGODB_URL="mongodb+srv://user:password@cluster.mongodb.net/database"

# Optional: Logging
LOG_LEVEL="info"  # debug, info, warn, error
NODE_ENV="development"  # development, staging, production
```

### Environment-Specific Configuration

#### Development (.env.development)

```bash
DATABASE_URL="postgresql://dev_user:dev_pass@localhost:5432/codezest_dev"
MONGODB_URL="mongodb://localhost:27017/codezest_dev"
LOG_LEVEL="debug"
NODE_ENV="development"
```

#### Staging (.env.staging)

```bash
DATABASE_URL="postgresql://staging_user:staging_pass@staging-db.neon.tech/codezest_staging?sslmode=require"
MONGODB_URL="mongodb+srv://staging:pass@cluster-staging.mongodb.net/codezest"
LOG_LEVEL="info"
NODE_ENV="staging"
```

#### Production (.env.production)

```bash
DATABASE_URL="postgresql://prod_user:prod_pass@prod-db.neon.tech/codezest_prod?sslmode=require"
MONGODB_URL="mongodb+srv://prod:pass@cluster-prod.mongodb.net/codezest"
LOG_LEVEL="warn"
NODE_ENV="production"
```

---

## 🗄️ Database Setup by Environment

### Local Development

**Option 1: Docker (Recommended)**

```bash
# Start PostgreSQL + MongoDB
docker-compose up -d

# This starts:
# - PostgreSQL on localhost:5432
# - MongoDB on localhost:27017
# - Prisma Studio on localhost:5555
```

**docker-compose.yml:**

```yaml
version: '3.8'
services:
  postgres:
    image: postgres:16-alpine
    environment:
      POSTGRES_USER: dev_user
      POSTGRES_PASSWORD: dev_pass
      POSTGRES_DB: codezest_dev
    ports:
      - '5432:5432'
    volumes:
      - postgres_data:/var/lib/postgresql/data

  mongodb:
    image: mongo:7
    environment:
      MONGO_INITDB_ROOT_USERNAME: dev_user
      MONGO_INITDB_ROOT_PASSWORD: dev_pass
    ports:
      - '27017:27017'
    volumes:
      - mongo_data:/data/db

volumes:
  postgres_data:
  mongo_data:
```

**Option 2: Neon (Cloud)**

1. Go to https://console.neon.tech/
2. Create project: `codezest-dev`
3. Copy connection string
4. Add to `.env.development`

### Staging

Use Neon for staging:

1. Create separate Neon project: `codezest-staging`
2. Configure in GitHub Secrets:
   - `STAGING_DATABASE_URL`
3. Use in CI/CD for staging deployments

### Production

Use Neon with production-grade settings:

1. Create Neon project: `codezest-prod`
2. Enable:
   - ✅ Connection pooling
   - ✅ Read replicas (for analytics)
   - ✅ Autoscaling
   - ✅ Point-in-time recovery
3. Configure in GitHub Secrets:
   - `PROD_DATABASE_URL`

---

## 🔐 Secrets Management

### GitHub Secrets

Go to **Settings → Secrets and variables → Actions**

| Secret Name            | Environment | Value                   |
| ---------------------- | ----------- | ----------------------- |
| `DATABASE_URL`         | All         | Development DB URL      |
| `STAGING_DATABASE_URL` | Staging     | Staging DB URL          |
| `PROD_DATABASE_URL`    | Production  | Production DB URL       |
| `NPM_TOKEN`            | All         | npm publish token       |
| `GITHUB_TOKEN`         | All         | Auto-provided by GitHub |

### Local .env Files

```bash
# Create environment-specific files
touch .env.development
touch .env.staging
touch .env.production

# Load based on NODE_ENV
# In package.json scripts:
"dev": "NODE_ENV=development dotenv -e .env.development -- npm run start:dev"
"staging": "NODE_ENV=staging dotenv -e .env.staging -- npm run start"
"prod": "NODE_ENV=production dotenv -e .env.production -- npm run start"
```

---

## 🚀 Running Migrations by Environment

### Development

```bash
# Load dev environment
export $(cat .env.development | xargs)

# Run migration
npm run migrate:dev -- --name add_feature

# Or use dotenv
dotenv -e .env.development -- npm run migrate:dev -- --name add_feature
```

### Staging

```bash
# Via GitHub Actions
# Go to Actions → Deploy to Staging → Run workflow

# Or manually
export $(cat .env.staging | xargs)
npm run migrate:deploy
```

### Production

```bash
# Via GitHub Actions (Recommended)
# Go to Actions → Deploy to Production → Run workflow

# Or manually (with caution)
export $(cat .env.production | xargs)
npm run migrate:deploy
```

---

# Package Migration Guide

## Overview

The package has been renamed from `@codezest-academy/db` to `@codezest-academy/codezest-db` for better clarity and consistency.

### Package Details

| Old Package               | New Package                     | Status        |
| ------------------------- | ------------------------------- | ------------- |
| `@codezest-academy/db`    | `@codezest-academy/codezest-db` | ✅ Active     |
| Versions: v1.0.0 - v1.0.3 | Current: v1.0.5+                | ⚠️ Deprecated |

---

## Migration Steps

### 1. Update package.json

**Before:**

```json
{
  "dependencies": {
    "@codezest-academy/db": "^1.0.3"
  }
}
```

**After:**

```json
{
  "dependencies": {
    "@codezest-academy/codezest-db": "^1.0.5"
  }
}
```

### 2. Update Import Statements

**No changes needed!** The imports remain the same:

```typescript
// These imports work exactly the same
import { prisma } from '@codezest-academy/codezest-db';
import { User, Role } from '@codezest-academy/codezest-db';
import { mongo } from '@codezest-academy/codezest-db/mongo';
```

### 3. Update .npmrc (if using GitHub Packages)

Ensure your `.npmrc` includes:

```ini
@codezest-academy:registry=https://npm.pkg.github.com/
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

### 4. Reinstall Dependencies

```bash
# Remove old package
npm uninstall @codezest-academy/db

# Install new package
npm install @codezest-academy/codezest-db

# Or in one command
npm install @codezest-academy/codezest-db && npm uninstall @codezest-academy/db
```

---

## Services to Update

The following services need to be updated:

- [ ] `codezest-auth`
- [ ] `codezest-api`
- [ ] `codezest-payments`
- [ ] `codezest-notifications`
- [ ] `codezest-activity`

---

## What's New in v1.0.5

The new package includes significant improvements:

✅ **Production-Ready Tooling**

- ESLint v9 with TypeScript support
- Prettier for code formatting
- Jest for testing (migrated from Vitest)

✅ **Winston Logger**

- Structured logging in `src/common/logger.ts`
- Production and development modes
- Silent in test environment

✅ **Architecture Documentation**

- Comprehensive architecture guides in `.context/`
- Clean Architecture structure documented
- Naming conventions enforced

✅ **Code Quality**

- 0 lint errors, 0 warnings
- All tests passing
- CI/CD with linting and formatting checks

---

## Automated Migration Script

For bulk updates across multiple services:

```bash
#!/bin/bash
# migrate-db-package.sh

SERVICES=("codezest-auth" "codezest-api" "codezest-payments" "codezest-notifications" "codezest-activity")

for service in "${SERVICES[@]}"; do
  echo "Updating $service..."
  cd "../$service" || continue

  # Update package.json
  npm uninstall @codezest-academy/db
  npm install @codezest-academy/codezest-db

  # Commit changes
  git add package.json package-lock.json
  git commit -m "chore: migrate to @codezest-academy/codezest-db"

  echo "✅ $service updated"
done
```

---

## Troubleshooting

### Issue: Package not found

**Solution**: Ensure you have access to the GitHub Packages registry and your `.npmrc` is configured correctly.

### Issue: Type errors after migration

**Solution**: The package exports are identical. Clear your `node_modules` and reinstall:

```bash
rm -rf node_modules package-lock.json
npm install
```

### Issue: Old package still in package-lock.json

**Solution**: Delete `package-lock.json` and run `npm install` to regenerate it.

---

## Deprecation Notice for Old Package

> [!WARNING]
> **`@codezest-academy/db` is deprecated and will not receive updates.**
>
> Please migrate to `@codezest-academy/codezest-db` as soon as possible.
> All new features and bug fixes will only be published to the new package.

---

**Need Help?** Check other files in `.context/` folder for detailed documentation!

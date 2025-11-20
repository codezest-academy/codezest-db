# Setup Guide - @codezest/db

Complete setup instructions for the CodeZest database package.

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
git commit -m "feat: initial implementation of @codezest/db"
git branch -M main
git remote add origin https://github.com/codezest-academy/codezest-db.git
git push -u origin main
```

### 2. Set Up Secrets

Go to **Settings → Secrets and variables → Actions**

Add these secrets:

| Secret Name | Value | Purpose |
|-------------|-------|---------|
| `NPM_TOKEN` | Your npm token | Publishing to npm |
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

```bash
# Update package
npm install @codezest/db@latest

# Run migrations
npx prisma migrate deploy --schema=node_modules/@codezest/db/prisma/schema.prisma

# Restart app
npm run dev
```

---

## 🧪 Testing in Consuming Services

### codezest-auth Example

```bash
cd /path/to/codezest-auth

# Install package
npm install @codezest/db@latest

# Test import
node -e "const { prisma, User, Role } = require('@codezest/db'); console.log('✅ Imports work!')"

# Use in code
```

**src/index.ts:**
```typescript
import { prisma, User, Role } from '@codezest/db'

// Create user
const user = await prisma.user.create({
  data: {
    email: 'test@example.com',
    name: 'Test User',
    role: Role.STUDENT,
  },
})

console.log('Created user:', user)
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
npm install @codezest/db@latest

# Regenerate types
npx prisma generate --schema=node_modules/@codezest/db/prisma/schema.prisma
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

**Need Help?** Check `.context/` folder for detailed documentation!

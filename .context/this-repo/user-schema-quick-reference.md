# Quick Reference: Git Workflow for Current Changes

## 🎯 Recommended: Feature Branch + PR Workflow

```bash
# 1. Create feature branch
git checkout -b feat/add-user-security-fields

# 2. Stage your changes
git add prisma/schema.prisma
git add prisma/migrations/20251126010431_add_user_security_fields/

# 3. Commit with descriptive message
git commit -m "feat: add user security fields

- Add account security (isActive, isSuspended, suspension tracking)
- Add login security (lastLoginAt, loginAttempts, account lockout)
- Add password management (passwordChangedAt, mustChangePassword)
- Add 2FA/MFA support (twoFactorEnabled, twoFactorSecret, backupCodes)
- Add username field for future social features
- Add email preferences (emailNotifications, marketingEmails)
- Add session revocation support (revokedAt)
- Add password reset tracking (ipAddress, userAgent)

All fields have safe defaults. No breaking changes."

# 4. Push to GitHub
git push -u origin feat/add-user-security-fields

# 5. Create Pull Request
# Go to: https://github.com/codezest-academy/codezest-db
# Click "Compare & pull request"
# Fill in PR details and submit

# 6. After PR is merged, publish new version
git checkout main
git pull origin main
npm version minor  # 1.0.5 → 1.1.0 (new features)
npm publish --access public
```

---

## ⚡ Alternative: Direct to Main (Quick)

```bash
# Only if you're working solo and confident

# 1. Ensure you're on main
git checkout main
git pull origin main

# 2. Stage changes
git add prisma/schema.prisma
git add prisma/migrations/20251126010431_add_user_security_fields/

# 3. Commit
git commit -m "feat: add user security fields (account lockout, 2FA, login tracking)"

# 4. Push
git push origin main

# 5. Publish
npm version minor  # 1.0.5 → 1.1.0
npm publish --access public
```

---

## 📋 PR Template (Copy-Paste)

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

- [x] Schema validated
- [x] Migration tested locally
- [x] Prisma Client regenerated
- [x] No breaking changes

## 📊 Impact

Brings CodeZest User schema to enterprise standards (Auth0, Firebase, Supabase level)
```

---

## 🚀 After Publishing

Update consuming services:

```bash
# In codezest-auth, codezest-api, etc.
npm install @codezest-academy/codezest-db@latest
npx prisma migrate deploy
```

---

## 💡 Version Bumping Guide

- `npm version patch` → 1.0.5 → 1.0.6 (bug fixes)
- `npm version minor` → 1.0.5 → 1.1.0 (new features) ← **Use this**
- `npm version major` → 1.0.5 → 2.0.0 (breaking changes)

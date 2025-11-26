# Latest Schema Changes - Quick Reference

## 🚀 Current Status

**Last Updated**: 2025-11-26  
**Current Version**: 1.2.0  
**Pending Publish**: 1.4.0 (3 migrations ready)

---

## 📋 Unpublished Changes (Ready to Push)

### Migration 1: User Security Enhancements

**Migration**: `20251126010431_add_user_security_fields`  
**Version Bump**: 1.0.5 → 1.1.0 (minor)

**Changes**:

- ✅ Account security (isActive, isSuspended, suspension tracking)
- ✅ Login security (lastLoginAt, loginAttempts, account lockout)
- ✅ Password management (passwordChangedAt, mustChangePassword)
- ✅ 2FA/MFA support (twoFactorEnabled, twoFactorSecret, backupCodes)
- ✅ Session revocation (revokedAt in Session model)
- ✅ Password reset tracking (ipAddress, userAgent)

**Breaking Changes**: None (all fields have safe defaults)

---

### Migration 2: Name Field Split + Email/Login Tracking

**Migration**: `20251126031816_add_name_split_email_changes_login_history`  
**Version Bump**: 1.1.0 → 1.2.0 (minor)

**Changes**:

- ✅ Name split: `name` → `firstName`, `lastName`, `userName`
- ✅ EmailChange model (email change tracking with verification)
- ✅ LoginHistory model (login audit trail)

**Breaking Changes**: ⚠️ `name` field removed (migrated to firstName/lastName)

---

### Migration 3: UserProfile EdTech Enhancement

**Migration**: `20251126090630_enhance_user_profile_edtech`  
**Version Bump**: 1.2.0 → 1.4.0 (minor, but significant)

**Changes**:

- ✅ 48 normalized fields (educational, professional, learning goals, engagement, CRM)
- ✅ 9 JSON fields (full history, skills, preferences, tags)
- ✅ Educational background tracking
- ✅ Professional career details
- ✅ Learning goals & motivations
- ✅ Skills & certifications
- ✅ Gamification (points, levels, streaks)
- ✅ Mini-CRM (lead scoring, segmentation)

**Breaking Changes**: ⚠️ Removed `occupation`, `company`, `address`, social link fields (migrated)

---

### Migration 4: Learning Schema Phase 1

**Migration**: `20251126093710_add_learning_prerequisites_duration_certificates`
**Version Bump**: 1.4.0 → 1.5.0 (minor)

**Changes**:

- ✅ Module Prerequisites (self-referential many-to-many)
- ✅ Estimated Duration (Module, Assignment, MCQQuiz)
- ✅ Certificate Model (completion, achievement, mastery)
- ✅ User certificates relationship

**Breaking Changes**: None (all fields optional)

---

## 🎯 Recommended Push Strategy

### Option 1: All at Once (Recommended)

```bash
# Create feature branch
git checkout -b feat/comprehensive-schema-enhancements

# Stage all changes
git add prisma/schema.prisma
git add prisma/migrations/20251126010431_add_user_security_fields/
git add prisma/migrations/20251126031816_add_name_split_email_changes_login_history/
git add prisma/migrations/20251126090630_enhance_user_profile_edtech/
git add prisma/migrations/20251126093710_add_learning_prerequisites_duration_certificates/

# Commit
git commit -m "feat: comprehensive schema enhancements

- Add user security fields
- Split name into firstName/lastName/userName
- Enhance UserProfile with EdTech features
- Enhance Learning schema (prerequisites, duration, certificates)

BREAKING CHANGES:
- User.name removed
- UserProfile fields removed/migrated"

# Push
git push -u origin feat/comprehensive-schema-enhancements

# Create PR, merge, then publish
git checkout main
git pull origin main
npm version minor  # 1.2.0 → 1.3.0 or 1.4.0
npm publish --access public
```

### Option 2: Separate Pushes (If Needed)

Push each migration separately with individual PRs (see git-workflow.md for details)

---

## 📦 After Publishing

### Update Consuming Services

```bash
# In codezest-auth, codezest-api, etc.
npm install @codezest-academy/codezest-db@latest

# Run migrations
npx prisma migrate deploy --schema=node_modules/@codezest-academy/codezest-db/prisma/schema.prisma

# Regenerate Prisma Client
npx prisma generate --schema=node_modules/@codezest-academy/codezest-db/prisma/schema.prisma
```

### Update Backend Code

**User Model**:

```typescript
// OLD
user.name; // "John Doe"

// NEW
user.firstName; // "John"
user.lastName; // "Doe"
user.userName; // "@johndoe" (optional)
```

**UserProfile Model**:

```typescript
// OLD
profile.occupation; // "Software Engineer"
profile.company; // "Tech Corp"
profile.githubUrl; // "https://github.com/username"

// NEW
profile.currentRole; // "Software Engineer"
profile.currentCompany; // "Tech Corp"
profile.socials; // { github: "username", linkedin: "username" }
```

---

## 🔍 Migration Summary

| Migration   | Fields Added | Fields Removed | Breaking |
| ----------- | ------------ | -------------- | -------- |
| Security    | 15           | 0              | ❌ No    |
| Name Split  | 3            | 1 (`name`)     | ✅ Yes   |
| UserProfile | 57           | 6              | ✅ Yes   |
| **Total**   | **75**       | **7**          | ✅ Yes   |

---

## ✅ Pre-Publish Checklist

- [x] Schema validated (`npx prisma validate`)
- [x] All migrations tested locally
- [x] Prisma Client regenerated
- [x] Data migration scripts included
- [x] Breaking changes documented
- [ ] PR created and reviewed
- [ ] CI/CD checks passed
- [ ] Version bumped appropriately
- [ ] Published to GitHub Packages
- [ ] Consuming services updated

---

## 📚 Related Documentation

- [Git Workflow Guide](./git-workflow.md)
- [User Schema Documentation](./user-schema-quick-reference.md)
- [Publishing Best Practices](../guides/publishing-workflow.md)

---

## 🚨 Important Notes

> **BREAKING CHANGES**: This release includes breaking changes to User and UserProfile models.
>
> - User.name → firstName/lastName/userName
> - UserProfile field removals (occupation, company, social links)
>
> **Action Required**: Update all consuming services before deploying.

> **Version Recommendation**: 1.2.0 → **1.4.0** (minor)
>
> - Significant new features
> - Breaking changes (but with migration)
> - Not a major version (backward compatible with migration)

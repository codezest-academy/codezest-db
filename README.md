# @codezest-academy/codezest-db

> Single source of truth for CodeZest database schema & types

Production-ready shared database package for CodeZest microservices architecture. Built with Prisma, PostgreSQL, and MongoDB.

## 🎯 Features

- ✅ **30 Database Models** across 5 service schemas
- ✅ **Type-Safe** with auto-generated TypeScript types
- ✅ **SOLID Principles** and design patterns applied
- ✅ **Schema Namespacing** for clear service boundaries
- ✅ **Soft Deletes** for data retention
- ✅ **Audit Trails** on all models
- ✅ **MongoDB Integration** for unstructured data
- ✅ **Production-Ready** with proper indexes and constraints

## 📦 Installation

```bash
npm install @codezest-academy/db
```

## 🚀 Quick Start

```typescript
import { prisma, User, Role } from '@codezest-academy/db';

// Create a user
const user = await prisma.user.create({
  data: {
    email: 'student@example.com',
    name: 'John Doe',
    role: Role.STUDENT,
  },
});

// Query with relations
const userWithProfile = await prisma.user.findUnique({
  where: { id: userId },
  include: { profile: true },
});

// Use enums for type safety
const students = await prisma.user.findMany({
  where: { role: Role.STUDENT },
});
```

## 🗄️ Database Schema

### Service Ownership

| Schema            | Service                | Models | Purpose                                                    |
| ----------------- | ---------------------- | ------ | ---------------------------------------------------------- |
| `auth.*`          | codezest-auth          | 6      | User accounts, sessions, OAuth                             |
| `learning.*`      | codezest-api           | 15     | Languages, modules, materials, assignments, MCQs, analysis |
| `payments.*`      | codezest-payments      | 4      | Subscriptions, transactions, invoices                      |
| `notifications.*` | codezest-notifications | 3      | Notifications, preferences, email logs                     |
| `activity.*`      | codezest-activity      | 2      | Activity feeds, analytics                                  |

### Models Overview

<details>
<summary><b>Auth Service (6 models)</b></summary>

- `User` - Core user accounts
- `UserProfile` - Extended user information
- `Session` - Active sessions
- `OAuthAccount` - OAuth providers
- `PasswordReset` - Password reset tokens
- `EmailVerification` - Email verification

</details>

<details>
<summary><b>Learning Service (15 models)</b></summary>

- `ProgrammingLanguage` - Languages (Python, JS, Java)
- `Module` - Learning modules
- `Material` - Learning content
- `Assignment` - Coding exercises
- `MCQQuiz` - Multiple choice quizzes
- `MCQQuestion` - Quiz questions
- `MCQOption` - Answer options
- `LanguageEnrollment` - User enrollments
- `ModuleProgress` - Module completion tracking
- `MaterialProgress` - Material view tracking
- `AssignmentSubmission` - Code submissions
- `MCQAttempt` - Quiz attempts
- `MCQAnswer` - Individual answers
- `AssignmentAnalysis` - AI/manual code analysis
- `QuizAnalysis` - AI/manual quiz analysis

</details>

<details>
<summary><b>Payment Service (4 models)</b></summary>

- `Subscription` - User subscriptions
- `Transaction` - Payment transactions
- `Invoice` - Generated invoices
- `PaymentMethod` - Saved payment methods

</details>

<details>
<summary><b>Notification Service (3 models)</b></summary>

- `Notification` - User notifications
- `NotificationPreference` - User preferences
- `EmailLog` - Email audit trail

</details>

<details>
<summary><b>Activity Service (2 models)</b></summary>

- `UserActivity` - Activity feed events
- `AnalyticsEvent` - Custom analytics

</details>

## 🔧 Environment Variables

Create a `.env` file in your project root:

```bash
# PostgreSQL (Required)
DATABASE_URL="postgresql://user:password@host:5432/codezest?schema=public"

# MongoDB (Optional)
MONGODB_URL="mongodb+srv://user:password@cluster.mongodb.net/codezest"
```

### Supported Providers

- **Neon** (Recommended): `postgresql://user:password@ep-name.region.aws.neon.tech/codezest?sslmode=require`
- **Supabase**: `postgresql://postgres:password@db.project.supabase.co:5432/postgres`
- **Railway**: `postgresql://postgres:password@containers.railway.app:5432/railway`
- **Local**: `postgresql://postgres:postgres@localhost:5432/codezest`

## 📚 Usage Examples

### Basic Queries

```typescript
import { prisma } from '@codezest-academy/db';

// Find all students
const students = await prisma.user.findMany({
  where: { role: 'STUDENT' },
});

// Create a programming language
const python = await prisma.programmingLanguage.create({
  data: {
    name: 'Python',
    slug: 'python',
    difficulty: 'BEGINNER',
  },
});

// Enroll user in a language
const enrollment = await prisma.languageEnrollment.create({
  data: {
    userId: user.id,
    languageId: python.id,
    status: 'ACTIVE',
  },
});
```

### Complex Queries with Relations

```typescript
// Get module with all content
const module = await prisma.module.findUnique({
  where: { id: moduleId },
  include: {
    materials: true,
    assignments: true,
    mcqQuizzes: {
      include: {
        questions: {
          include: { options: true },
        },
      },
    },
  },
});

// Get user progress across all modules
const progress = await prisma.moduleProgress.findMany({
  where: { userId: user.id },
  include: {
    module: {
      include: { language: true },
    },
  },
});
```

### Transactions

```typescript
// Create user with profile and subscription
await prisma.$transaction([
  prisma.user.create({
    data: {
      email: 'user@example.com',
      name: 'John Doe',
    },
  }),
  prisma.userProfile.create({
    data: {
      userId: user.id,
      bio: 'Learning to code',
    },
  }),
  prisma.subscription.create({
    data: {
      userId: user.id,
      plan: 'FREE',
      status: 'ACTIVE',
    },
  }),
]);
```

### MongoDB Integration

```typescript
import { mongo } from '@codezest-academy/db/mongo';

// Log user activity
const activityLogs = await mongo.collection('activity_logs');
await activityLogs.insertOne({
  userId: user.id,
  action: 'module_completed',
  timestamp: new Date(),
});

// Track analytics
const analytics = await mongo.collection('analytics_events');
await analytics.insertOne({
  eventName: 'quiz_completed',
  userId: user.id,
  properties: { quizId, score: 85 },
});
```

## 🔄 Schema Changes

### Making Changes (Only in this repo)

```bash
# 1. Edit schema
code prisma/schema.prisma

# 2. Create migration
npm run migrate:dev -- --name add_new_field

# 3. Test locally
npm run db:push

# 4. Commit migration files
git add prisma/migrations
git commit -m "feat: add new field"

# 5. Publish new version
npm run release

# 6. Update consuming services
npm install @codezest-academy/codezest-db@latest
```

### In Consuming Services

```bash
# Update to latest version
npm install @codezest-academy/codezest-db@latest

# Run migrations
npx prisma migrate deploy --schema=node_modules/@codezest-academy/codezest-db/prisma/schema.prisma
```

## 🛠️ Available Scripts

| Command                  | Description                                 |
| ------------------------ | ------------------------------------------- |
| `npm run build`          | Compile TypeScript + generate Prisma client |
| `npm run migrate:dev`    | Create new migration (development)          |
| `npm run migrate:deploy` | Apply migrations (production)               |
| `npm run db:push`        | Push schema changes without migration       |
| `npm run db:studio`      | Open Prisma Studio (database GUI)           |
| `npm run typecheck`      | Check TypeScript types                      |
| `npm run test`           | Run unit tests with Vitest                  |
| `npm run release`        | Bump version + publish                      |

## 📖 API Reference

### PrismaClient

```typescript
import { prisma } from '@codezest-academy/codezest-db'

// All Prisma client methods available
await prisma.user.findMany()
await prisma.module.create({ data: {...} })
await prisma.assignment.update({ where: {...}, data: {...} })
```

### Utility Functions

```typescript
import { connect, disconnect, healthCheck } from '@codezest-academy/codezest-db';

// Connect explicitly (auto-connects on first query)
await connect();

// Health check
const isHealthy = await healthCheck();

// Disconnect (call on app shutdown)
await disconnect();
```

### Type Imports

```typescript
import type {
  User,
  Role,
  Prisma,
  ProgrammingLanguage,
  Module,
  Assignment,
  Subscription,
} from '@codezest-academy/codezest-db';
```

## 🏗️ Architecture

This package follows **SOLID principles** and implements several design patterns:

- **Repository Pattern**: Single data access layer
- **Singleton Pattern**: PrismaClient instance
- **Factory Pattern**: Prisma client generation
- **Strategy Pattern**: AI/Manual/Hybrid analysis
- **Observer Pattern**: Activity feeds and analytics

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed architecture documentation.

## 🔒 Security

- ✅ Parameterized queries (SQL injection prevention)
- ✅ Password hashing (application layer)
- ✅ Role-based access control (RBAC)
- ✅ Token expiry on sessions
- ✅ Soft deletes for data retention

## 📊 Performance

- ✅ Indexes on all foreign keys
- ✅ Composite indexes for common queries
- ✅ Connection pooling
- ✅ Query optimization with Prisma
- ✅ Optional MongoDB for hot data

## 🤝 Contributing

This is a private package for CodeZest microservices. Only make changes in this repository.

### Golden Rules

1. **Only this repo** can change `schema.prisma`
2. **Always commit** `prisma/migrations/` folder
3. **Version bump** after every schema change
4. **Run migrations** BEFORE app starts in production
5. **Never use** foreign keys across service schemas

## 📝 License

MIT © CodeZest Academy

## 🔗 Links

- [Prisma Documentation](https://www.prisma.io/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [MongoDB Documentation](https://www.mongodb.com/docs/)

---

**Made with ❤️ by CodeZest Academy**

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-21

### Added
- Initial release of `@codezest/db` package
- 30 database models across 5 service schemas
- Auth service models (6): User, UserProfile, Session, OAuthAccount, PasswordReset, EmailVerification
- Learning service models (15): ProgrammingLanguage, Module, Material, Assignment, MCQQuiz, MCQQuestion, MCQOption, LanguageEnrollment, ModuleProgress, MaterialProgress, AssignmentSubmission, MCQAttempt, MCQAnswer, AssignmentAnalysis, QuizAnalysis
- Payment service models (4): Subscription, Transaction, Invoice, PaymentMethod
- Notification service models (3): Notification, NotificationPreference, EmailLog
- Activity service models (2): UserActivity, AnalyticsEvent
- 12 enum types for type safety
- PostgreSQL schema namespacing for service boundaries
- MongoDB integration for unstructured data
- TypeScript type exports and utility functions
- Prisma client singleton pattern
- Comprehensive documentation (README, ARCHITECTURE)
- Production-ready configuration (package.json, tsconfig.json)

### Features
- UUID primary keys for distributed systems
- Soft deletes with `deletedAt` field
- Audit trails with `createdAt` and `updatedAt`
- Composite indexes for query performance
- JSONB fields for flexible metadata
- Stripe integration ready (customer IDs, subscription IDs)
- AI/Manual/Hybrid analysis support for assignments and quizzes
- Role-based access control (ADMIN, INSTRUCTOR, STUDENT)
- Multi-currency support for payments
- Email verification workflow
- OAuth provider support (Google, GitHub, etc.)

### Design Patterns
- Repository Pattern (Prisma as single data access layer)
- Singleton Pattern (PrismaClient instance)
- Factory Pattern (Prisma client generation)
- Strategy Pattern (Analysis types: AI/MANUAL/HYBRID)
- Observer Pattern (Activity feeds, analytics events)
- Adapter Pattern (Stripe, OAuth integrations)
- Composite Pattern (Hierarchical learning content)

### SOLID Principles
- Single Responsibility: Each model has one clear purpose
- Open/Closed: JSONB fields for extension without modification
- Liskov Substitution: Consistent interfaces across similar models
- Interface Segregation: Schema namespacing creates clear boundaries
- Dependency Inversion: Services depend on Prisma abstraction

[1.0.0]: https://github.com/codezest-academy/codezest-db/releases/tag/v1.0.0

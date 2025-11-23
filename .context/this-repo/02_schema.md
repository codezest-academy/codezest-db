# CodeZest – Phase 1 Implementation Plan
**Coding Learning Platform with Modules, Materials, Assignments & MCQs**

---

## 🎯 Phase 1 Scope Overview

A coding learning platform where users can:

1. ✅ **Register & Login** - User authentication
2. ✅ **Browse Programming Languages** - Python, JavaScript, Java, etc.
3. ✅ **Navigate Modules** - Each language has X modules (e.g., Python Basics, Python OOP, etc.)
4. ✅ **Learn from Materials** - Read/watch learning content for each module
5. ✅ **Complete Assignments** - Coding assignments based on module syllabus
6. ✅ **Take MCQ Quizzes** - Multiple choice questions for assessment
7. ✅ **Track Progress** - See completion status per module and language

---

## 🗄️ Revised Database Schema Design

### Service Ownership Model

| Schema Namespace | Service Owner | Purpose |
|-----------------|---------------|---------|
| `auth.*` | codezest-auth | User accounts, sessions, OAuth, profiles |
| `learning.*` | codezest-api | Languages, modules, materials, assignments, MCQs, analysis |
| `payments.*` | codezest-payments | Subscriptions, transactions, invoices, payment methods |
| `notifications.*` | codezest-notifications | Notifications, email logs |
| `activity.*` | codezest-activity | Activity feeds, analytics |

---

## 📊 Complete Data Model

### 1️⃣ Auth Service Models (`auth.*`)

| Model | Description | Key Fields |
|-------|-------------|------------|
| `User` | User accounts | email, password, name, role |
| `UserProfile` | Extended user info | userId, bio, avatar, location, website, socialLinks, preferences |
| `Session` | Active sessions | token, expiresAt, userId |
| `OAuthAccount` | OAuth providers | provider (GOOGLE/GITHUB), providerId |
| `PasswordReset` | Password reset | token, expiresAt, used |
| `EmailVerification` | Email verification | token, verified |

---

### 2️⃣ Learning Service Models (`learning.*`)

#### Core Learning Structure

```
ProgrammingLanguage (Python, JavaScript, Java)
    └── Module (Python Basics, Python OOP, Python Advanced)
            └── Material (Videos, Articles, Code Examples)
            └── Assignment (Coding exercises)
            └── MCQQuiz (Multiple choice tests)
```

| Model | Description | Key Fields |
|-------|-------------|------------|
| `ProgrammingLanguage` | Languages (Python, JS, Java) | name, slug, description, icon, difficulty |
| `Module` | Learning modules | title, languageId, order, description, syllabus |
| `Material` | Learning content | moduleId, title, type (VIDEO/ARTICLE/CODE), content, order |
| `Assignment` | Coding assignments | moduleId, title, description, starterCode, testCases |
| `MCQQuiz` | MCQ quizzes | moduleId, title, passingScore, timeLimit |
| `MCQQuestion` | Quiz questions | quizId, question, order |
| `MCQOption` | Answer options | questionId, optionText, isCorrect, order |

#### User Progress & Submissions

| Model | Description | Key Fields |
|-------|-------------|------------|
| `LanguageEnrollment` | User enrolls in language | userId, languageId, enrolledAt, status |
| `ModuleProgress` | Module completion tracking | userId, moduleId, status, completedAt, progressPercent |
| `MaterialProgress` | Material view tracking | userId, materialId, completed, lastViewedAt |
| `AssignmentSubmission` | Assignment submissions | userId, assignmentId, code, status, score, feedback |
| `MCQAttempt` | Quiz attempts | userId, quizId, score, startedAt, completedAt |
| `MCQAnswer` | Individual answers | attemptId, questionId, selectedOptionId, isCorrect |

#### Analysis & Feedback (AI or Manual)

| Model | Description | Key Fields |
|-------|-------------|------------|
| `AssignmentAnalysis` | AI/manual analysis of submissions | submissionId, analysisType (AI/MANUAL), strengths, weaknesses, suggestions, score |
| `QuizAnalysis` | AI/manual analysis of quiz attempts | attemptId, analysisType, performanceBreakdown, recommendations, insights |


---

### 3️⃣ Payment Service Models (`payments.*`)

| Model | Description | Key Fields |
|-------|-------------|------------|
| `Subscription` | User subscriptions | userId, plan (FREE/PRO/ENTERPRISE), status, validUntil, stripeSubscriptionId |
| `Transaction` | Payment transactions | userId, subscriptionId, amount, currency, status, stripePaymentIntentId |
| `Invoice` | Generated invoices | subscriptionId, amount, status, paidAt, invoiceUrl |
| `PaymentMethod` | Saved payment methods | userId, type (CARD/PAYPAL), stripePaymentMethodId, isDefault, last4 |

---

### 4️⃣ Notification Service Models (`notifications.*`)

| Model | Description | Key Fields |
|-------|-------------|------------|
| `Notification` | User notifications | userId, type, title, message, priority, read |
| `NotificationPreference` | User preferences | userId, email, push, sms (enabled/disabled) |
| `EmailLog` | Email audit trail | to, subject, status, sentAt |

---

### 5️⃣ Activity Service Models (`activity.*`)

| Model | Description | Key Fields |
|-------|-------------|------------|
| `UserActivity` | Activity feed events | userId, type, description, metadata (JSONB) |
| `AnalyticsEvent` | Custom analytics | eventName, userId, properties (JSONB) |

---

## 🔗 Key Relationships

### Hierarchical Structure

```
User
  └── LanguageEnrollment (enrolls in Python)
        └── ProgrammingLanguage (Python)
              └── Module (Python Basics, Python OOP, etc.)
                    ├── Material (learning content)
                    ├── Assignment (coding exercises)
                    └── MCQQuiz (quizzes)

User Progress Tracking:
  ├── ModuleProgress (tracks each module)
  ├── MaterialProgress (tracks each material)
  ├── AssignmentSubmission (coding submissions)
  └── MCQAttempt (quiz attempts)
```

### Relationships Summary

**One-to-Many:**
- `ProgrammingLanguage` (1) → (N) `Module`
- `Module` (1) → (N) `Material`
- `Module` (1) → (N) `Assignment`
- `Module` (1) → (N) `MCQQuiz`
- `MCQQuiz` (1) → (N) `MCQQuestion`
- `MCQQuestion` (1) → (N) `MCQOption`
- `User` (1) → (N) `LanguageEnrollment`
- `User` (1) → (N) `ModuleProgress`
- `User` (1) → (N) `AssignmentSubmission`
- `User` (1) → (N) `MCQAttempt`

---

## 📝 Example Schema Snippets

### Programming Language & Modules

```prisma
model ProgrammingLanguage {
  id          String   @id @default(uuid())
  name        String   @unique // "Python", "JavaScript", "Java"
  slug        String   @unique // "python", "javascript", "java"
  description String?
  icon        String?  // URL or emoji
  difficulty  Difficulty @default(BEGINNER)
  isActive    Boolean  @default(true)
  
  modules     Module[]
  enrollments LanguageEnrollment[]
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@map("learning.programming_languages")
}

model Module {
  id          String   @id @default(uuid())
  languageId  String
  language    ProgrammingLanguage @relation(fields: [languageId], references: [id])
  
  title       String   // "Python Basics", "Python OOP"
  slug        String   // "python-basics"
  description String?
  syllabus    String?  // JSON or text describing what's covered
  order       Int      // Display order
  
  materials   Material[]
  assignments Assignment[]
  mcqQuizzes  MCQQuiz[]
  progress    ModuleProgress[]
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@unique([languageId, slug])
  @@map("learning.modules")
}
```

### Learning Materials

```prisma
model Material {
  id          String   @id @default(uuid())
  moduleId    String
  module      Module   @relation(fields: [moduleId], references: [id])
  
  title       String
  type        MaterialType // VIDEO, ARTICLE, CODE_EXAMPLE, INTERACTIVE
  content     String   // URL for video, markdown for article, code for examples
  duration    Int?     // minutes for video
  order       Int
  
  progress    MaterialProgress[]
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@map("learning.materials")
}

enum MaterialType {
  VIDEO
  ARTICLE
  CODE_EXAMPLE
  INTERACTIVE
}
```

### Assignments

```prisma
model Assignment {
  id          String   @id @default(uuid())
  moduleId    String
  module      Module   @relation(fields: [moduleId], references: [id])
  
  title       String
  description String
  difficulty  Difficulty
  
  starterCode String?  // Initial code template
  testCases   String   // JSON array of test cases
  hints       String?  // JSON array of hints
  
  maxScore    Int      @default(100)
  timeLimit   Int?     // minutes
  
  submissions AssignmentSubmission[]
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@map("learning.assignments")
}

model AssignmentSubmission {
  id           String   @id @default(uuid())
  userId       String
  assignmentId String
  assignment   Assignment @relation(fields: [assignmentId], references: [id])
  
  code         String   // User's submitted code
  language     String   // "python", "javascript"
  status       SubmissionStatus @default(PENDING)
  score        Int?
  feedback     String?  // Auto-generated or instructor feedback
  
  submittedAt  DateTime @default(now())
  gradedAt     DateTime?
  
  @@map("learning.assignment_submissions")
}

enum SubmissionStatus {
  PENDING
  RUNNING
  PASSED
  FAILED
  ERROR
}
```

### MCQ Quizzes

```prisma
model MCQQuiz {
  id           String   @id @default(uuid())
  moduleId     String
  module       Module   @relation(fields: [moduleId], references: [id])
  
  title        String
  description  String?
  passingScore Int      @default(70)
  timeLimit    Int?     // minutes
  
  questions    MCQQuestion[]
  attempts     MCQAttempt[]
  
  createdAt    DateTime @default(now())
  updatedAt    DateTime @updatedAt
  
  @@map("learning.mcq_quizzes")
}

model MCQQuestion {
  id          String   @id @default(uuid())
  quizId      String
  quiz        MCQQuiz  @relation(fields: [quizId], references: [id])
  
  question    String
  explanation String?  // Shown after answering
  order       Int
  points      Int      @default(1)
  
  options     MCQOption[]
  answers     MCQAnswer[]
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@map("learning.mcq_questions")
}

model MCQOption {
  id         String   @id @default(uuid())
  questionId String
  question   MCQQuestion @relation(fields: [questionId], references: [id])
  
  optionText String
  isCorrect  Boolean
  order      Int
  
  selectedBy MCQAnswer[]
  
  @@map("learning.mcq_options")
}
```

### Progress Tracking

```prisma
model LanguageEnrollment {
  id         String   @id @default(uuid())
  userId     String
  languageId String
  language   ProgrammingLanguage @relation(fields: [languageId], references: [id])
  
  status     EnrollmentStatus @default(ACTIVE)
  enrolledAt DateTime @default(now())
  completedAt DateTime?
  
  @@unique([userId, languageId])
  @@map("learning.language_enrollments")
}

model ModuleProgress {
  id              String   @id @default(uuid())
  userId          String
  moduleId        String
  module          Module   @relation(fields: [moduleId], references: [id])
  
  status          ProgressStatus @default(NOT_STARTED)
  progressPercent Int      @default(0) // 0-100
  
  startedAt       DateTime?
  completedAt     DateTime?
  lastAccessedAt  DateTime @default(now())
  
  @@unique([userId, moduleId])
  @@map("learning.module_progress")
}

model MaterialProgress {
  id         String   @id @default(uuid())
  userId     String
  materialId String
  material   Material @relation(fields: [materialId], references: [id])
  
  completed  Boolean  @default(false)
  viewCount  Int      @default(0)
  
  lastViewedAt DateTime @default(now())
  completedAt  DateTime?
  
  @@unique([userId, materialId])
  @@map("learning.material_progress")
}

enum ProgressStatus {
  NOT_STARTED
  IN_PROGRESS
  COMPLETED
}

enum EnrollmentStatus {
  ACTIVE
  PAUSED
  COMPLETED
  DROPPED
}
```

### User Profile & Subscription

```prisma
model UserProfile {
  id          String   @id @default(uuid())
  userId      String   @unique
  
  bio         String?
  avatar      String?  // URL to profile picture
  location    String?
  website     String?
  
  // Social links
  githubUrl   String?
  linkedinUrl String?
  twitterUrl  String?
  
  // Preferences (stored as JSONB)
  preferences Json?    // { theme: "dark", language: "en", notifications: {...} }
  
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
  
  @@map("auth.user_profiles")
}

model Subscription {
  id              String   @id @default(uuid())
  userId          String   @unique
  
  plan            SubscriptionPlan @default(FREE)
  status          SubscriptionStatus @default(ACTIVE)
  
  // Billing
  stripeCustomerId     String?  @unique
  stripeSubscriptionId String?  @unique
  
  // Validity
  startedAt       DateTime @default(now())
  validUntil      DateTime?  // null for FREE plan = lifetime access
  canceledAt      DateTime?
  
  // Metadata
  metadata        Json?    // Store additional subscription data
  
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  
  @@map("auth.subscriptions")
}

enum SubscriptionPlan {
  FREE           // Phase 1: All users get free access
  PRO            // Future: Premium features
  ENTERPRISE     // Future: Team/organization plans
}

enum SubscriptionStatus {
  ACTIVE
  CANCELED
  EXPIRED
  PAUSED
}
```

---

### Payment Service Models

```prisma
model Subscription {
  id              String   @id @default(uuid())
  userId          String   @unique
  
  plan            SubscriptionPlan @default(FREE)
  status          SubscriptionStatus @default(ACTIVE)
  
  // Stripe integration
  stripeCustomerId     String?  @unique
  stripeSubscriptionId String?  @unique
  
  // Validity
  startedAt       DateTime @default(now())
  validUntil      DateTime?  // null for FREE plan = lifetime access
  canceledAt      DateTime?
  
  // Relationships
  transactions    Transaction[]
  invoices        Invoice[]
  
  // Metadata
  metadata        Json?
  
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  
  @@map("payments.subscriptions")
}

model Transaction {
  id              String   @id @default(uuid())
  userId          String
  subscriptionId  String?
  subscription    Subscription? @relation(fields: [subscriptionId], references: [id])
  
  amount          Int      // Amount in cents (e.g., 999 = $9.99)
  currency        String   @default("usd")
  
  status          TransactionStatus @default(PENDING)
  
  // Stripe integration
  stripePaymentIntentId String? @unique
  stripeChargeId        String? @unique
  
  // Payment details
  paymentMethod   String?  // "card", "paypal", etc.
  description     String?
  
  // Timestamps
  createdAt       DateTime @default(now())
  paidAt          DateTime?
  failedAt        DateTime?
  
  @@map("payments.transactions")
}

model Invoice {
  id              String   @id @default(uuid())
  subscriptionId  String
  subscription    Subscription @relation(fields: [subscriptionId], references: [id])
  
  invoiceNumber   String   @unique  // INV-2025-001
  
  amount          Int      // Amount in cents
  currency        String   @default("usd")
  tax             Int?     // Tax amount in cents
  total           Int      // Total amount including tax
  
  status          InvoiceStatus @default(DRAFT)
  
  // Stripe
  stripeInvoiceId String?  @unique
  invoiceUrl      String?  // PDF URL
  
  // Dates
  issuedAt        DateTime @default(now())
  dueAt           DateTime?
  paidAt          DateTime?
  
  @@map("payments.invoices")
}

model PaymentMethod {
  id              String   @id @default(uuid())
  userId          String
  
  type            PaymentMethodType
  
  // Stripe
  stripePaymentMethodId String? @unique
  
  // Card details (last 4 digits, brand)
  last4           String?
  brand           String?  // "visa", "mastercard", etc.
  expiryMonth     Int?
  expiryYear      Int?
  
  // PayPal
  paypalEmail     String?
  
  isDefault       Boolean  @default(false)
  
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  
  @@map("payments.payment_methods")
}

enum SubscriptionPlan {
  FREE
  PRO
  ENTERPRISE
}

enum SubscriptionStatus {
  ACTIVE
  CANCELED
  EXPIRED
  PAUSED
}

enum TransactionStatus {
  PENDING
  PROCESSING
  SUCCEEDED
  FAILED
  REFUNDED
}

enum InvoiceStatus {
  DRAFT
  SENT
  PAID
  OVERDUE
  CANCELED
}

enum PaymentMethodType {
  CARD
  PAYPAL
  BANK_TRANSFER
}
```

---

### Analysis & Feedback Models

```prisma
model AssignmentAnalysis {
  id              String   @id @default(uuid())
  submissionId    String   @unique
  
  analysisType    AnalysisType @default(AI)
  
  // AI or Manual analysis
  overallScore    Int?     // 0-100
  
  // Detailed feedback
  strengths       String[] // Array of strengths
  weaknesses      String[] // Array of weaknesses
  suggestions     String[] // Improvement suggestions
  
  // Code quality metrics
  codeQuality     Json?    // { readability: 8, efficiency: 7, bestPractices: 9 }
  
  // Detailed breakdown
  detailedFeedback String? // Long-form feedback
  
  // AI metadata
  aiModel         String?  // "gpt-4", "claude-3", etc.
  aiPrompt        String?  // Prompt used for AI analysis
  
  // Manual analysis
  analyzedBy      String?  // userId of instructor (if manual)
  
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  
  @@map("learning.assignment_analyses")
}

model QuizAnalysis {
  id              String   @id @default(uuid())
  attemptId       String   @unique
  
  analysisType    AnalysisType @default(AI)
  
  // Performance breakdown
  performanceBreakdown Json  // { "Python Basics": 80, "Functions": 90, "Loops": 70 }
  
  // Strengths and weaknesses
  strongTopics    String[] // Topics user excels at
  weakTopics      String[] // Topics needing improvement
  
  // Recommendations
  recommendations String[] // Personalized study recommendations
  
  // Insights
  insights        String?  // AI-generated insights
  
  // Time analysis
  avgTimePerQuestion Int?  // Average seconds per question
  timeManagement     String? // "Good", "Needs improvement", etc.
  
  // AI metadata
  aiModel         String?
  
  // Manual analysis
  analyzedBy      String?  // userId of instructor
  
  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
  
  @@map("learning.quiz_analyses")
}

enum AnalysisType {
  AI
  MANUAL
  HYBRID  // AI + Manual review
}
```

---

## 🎨 User Journey Example

### 1. User Registers & Logs In
```typescript
// Auth service creates user
const user = await prisma.user.create({
  data: {
    email: "student@example.com",
    password: hashedPassword,
    name: "John Doe"
  }
})
```

### 2. User Enrolls in Python
```typescript
const enrollment = await prisma.languageEnrollment.create({
  data: {
    userId: user.id,
    languageId: pythonLanguageId,
    status: "ACTIVE"
  }
})
```

### 3. User Starts "Python Basics" Module
```typescript
const progress = await prisma.moduleProgress.create({
  data: {
    userId: user.id,
    moduleId: pythonBasicsModuleId,
    status: "IN_PROGRESS",
    progressPercent: 0
  }
})
```

### 4. User Views Learning Material
```typescript
await prisma.materialProgress.upsert({
  where: {
    userId_materialId: {
      userId: user.id,
      materialId: materialId
    }
  },
  update: {
    viewCount: { increment: 1 },
    lastViewedAt: new Date()
  },
  create: {
    userId: user.id,
    materialId: materialId,
    viewCount: 1
  }
})
```

### 5. User Submits Assignment
```typescript
const submission = await prisma.assignmentSubmission.create({
  data: {
    userId: user.id,
    assignmentId: assignmentId,
    code: userCode,
    language: "python",
    status: "PENDING"
  }
})
```

### 6. User Takes MCQ Quiz
```typescript
const attempt = await prisma.mCQAttempt.create({
  data: {
    userId: user.id,
    quizId: quizId,
    startedAt: new Date()
  }
})

// Record answers
await prisma.mCQAnswer.create({
  data: {
    attemptId: attempt.id,
    questionId: questionId,
    selectedOptionId: optionId,
    isCorrect: true
  }
})
```

### 7. Calculate Module Progress
```typescript
// Auto-calculate based on completed materials + assignments + quizzes
const totalItems = materials.length + assignments.length + quizzes.length
const completedItems = completedMaterials + passedAssignments + passedQuizzes
const progressPercent = (completedItems / totalItems) * 100

await prisma.moduleProgress.update({
  where: { userId_moduleId: { userId, moduleId } },
  data: {
    progressPercent,
    status: progressPercent === 100 ? "COMPLETED" : "IN_PROGRESS",
    completedAt: progressPercent === 100 ? new Date() : null
  }
})
```

---

## 📊 Database Models Summary

| Service | Models | Purpose |
|---------|--------|---------|
| **Auth** | 6 models | User accounts, profiles, sessions, OAuth |
| **Learning** | 15 models | Languages, modules, materials, assignments, MCQs, progress, analysis |
| **Payments** | 4 models | Subscriptions, transactions, invoices, payment methods |
| **Notifications** | 3 models | Notifications, preferences, email logs |
| **Activity** | 2 models | Activity feeds, analytics |
| **Total** | **30 models** | Complete Phase 1 + future-ready platform |

---

## ✅ Phase 1 Features Covered

| Feature | Database Support |
|---------|------------------|
| ✅ User Registration/Login | `User`, `Session`, `OAuthAccount` |
| ✅ User Profiles | `UserProfile` with bio, avatar, social links, preferences |
| ✅ Subscriptions & Payments | `Subscription`, `Transaction`, `Invoice`, `PaymentMethod` (Phase 1: all FREE) |
| ✅ Programming Languages | `ProgrammingLanguage` |
| ✅ Modules per Language | `Module` with `languageId` |
| ✅ Learning Materials | `Material` with type (VIDEO/ARTICLE/CODE) |
| ✅ Coding Assignments | `Assignment`, `AssignmentSubmission` |
| ✅ MCQ Quizzes | `MCQQuiz`, `MCQQuestion`, `MCQOption`, `MCQAttempt` |
| ✅ Progress Tracking | `LanguageEnrollment`, `ModuleProgress`, `MaterialProgress` |
| ✅ AI/Manual Analysis | `AssignmentAnalysis`, `QuizAnalysis` with detailed feedback |

---

## 🚀 Sample Data Structure

### Example: Python Language with 3 Modules

```
Programming Language: Python
├── Module 1: Python Basics
│   ├── Material: Introduction to Python (VIDEO)
│   ├── Material: Variables and Data Types (ARTICLE)
│   ├── Material: Code Example - Hello World (CODE_EXAMPLE)
│   ├── Assignment: Write a Calculator Program
│   └── MCQ Quiz: Python Basics Quiz (10 questions)
│
├── Module 2: Python Control Flow
│   ├── Material: If-Else Statements (VIDEO)
│   ├── Material: Loops in Python (ARTICLE)
│   ├── Assignment: FizzBuzz Challenge
│   └── MCQ Quiz: Control Flow Quiz
│
└── Module 3: Python Functions
    ├── Material: Defining Functions (VIDEO)
    ├── Material: Lambda Functions (ARTICLE)
    ├── Assignment: Create a Function Library
    └── MCQ Quiz: Functions Quiz
```

---

## 🎯 Key Enums

```prisma
enum Role {
  ADMIN
  INSTRUCTOR
  STUDENT
}

enum Difficulty {
  BEGINNER
  INTERMEDIATE
  ADVANCED
}

enum MaterialType {
  VIDEO
  ARTICLE
  CODE_EXAMPLE
  INTERACTIVE
}

enum SubmissionStatus {
  PENDING
  RUNNING
  PASSED
  FAILED
  ERROR
}

enum ProgressStatus {
  NOT_STARTED
  IN_PROGRESS
  COMPLETED
}

enum EnrollmentStatus {
  ACTIVE
  PAUSED
  COMPLETED
  DROPPED
}

enum SubscriptionPlan {
  FREE
  PRO
  ENTERPRISE
}

enum SubscriptionStatus {
  ACTIVE
  CANCELED
  EXPIRED
  PAUSED
}

enum TransactionStatus {
  PENDING
  PROCESSING
  SUCCEEDED
  FAILED
  REFUNDED
}

enum InvoiceStatus {
  DRAFT
  SENT
  PAID
  OVERDUE
  CANCELED
}

enum PaymentMethodType {
  CARD
  PAYPAL
  BANK_TRANSFER
}

enum AnalysisType {
  AI
  MANUAL
  HYBRID
}
```

---

## 📁 Updated Folder Structure

```
codezest-db/
├── package.json
├── tsconfig.json
├── .gitignore
├── .npmignore
├── .env.example
├── README.md
├── ARCHITECTURE.md
├── PLAN_OVERVIEW.md          # This file
│
├── prisma/
│   ├── schema.prisma         # Complete schema with all models
│   └── migrations/
│
├── src/
│   ├── index.ts              # Exports PrismaClient + types
│   ├── types.ts              # Custom types
│   └── mongo/
│       ├── index.ts          # MongoDB client (optional)
│       └── collections.ts
│
└── dist/                     # Build output
```

---

## 🔍 Review Checklist for Phase 1

- [ ] **User Management**: Registration, login, OAuth support ✅
- [ ] **Programming Languages**: Can add Python, JavaScript, Java, etc. ✅
- [ ] **Modules**: Each language has multiple modules ✅
- [ ] **Learning Materials**: Videos, articles, code examples ✅
- [ ] **Assignments**: Coding exercises with test cases ✅
- [ ] **MCQ Quizzes**: Multiple choice questions with scoring ✅
- [ ] **Progress Tracking**: Track completion per module and language ✅
- [ ] **Enrollment**: Users can enroll in languages ✅
- [ ] **Submissions**: Store and grade assignment submissions ✅
- [ ] **Quiz Attempts**: Track quiz attempts and scores ✅

---

## ❓ Questions Before Implementation

1. **Assignment Grading**: Should assignments be auto-graded (run code against test cases) or manually graded by instructors?
   - Current design supports both

2. **Material Content Storage**: Should we store video URLs or actual content?
   - Current design uses `content` field (flexible for URLs or markdown)

3. **Multiple Attempts**: Can users retake assignments/quizzes?
   - Current design allows multiple submissions/attempts

4. **Instructor Role**: Do you need instructors to create content in Phase 1?
   - Current design has `INSTRUCTOR` role ready

5. **Certificates**: Should we add certificate generation on module/language completion?
   - Not in current design, can add if needed

---

## 🚀 Ready to Implement?

This schema covers **100% of your Phase 1 requirements**:
- ✅ User registration & login
- ✅ Programming languages with modules
- ✅ Learning materials
- ✅ Assignments (coding exercises)
- ✅ MCQ quizzes
- ✅ Progress tracking

**Approve to proceed with implementation!** 🎉


---

# Schema Changes


# Database Schema Changes

These changes need to be applied to the `@codezest-academy/db` package.

## 1. UserRole Enum

Simplify roles to just `USER` and `ADMIN`.

```prisma
enum UserRole {
  USER
  ADMIN
}
```

## 2. UserProfile Model

Add occupation and contact details.

```prisma
model UserProfile {
  id          String   @id @default(uuid())
  userId      String   @unique
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)

  // Existing fields
  bio         String?
  avatar      String?
  location    String?
  website     String?

  // NEW FIELDS
  occupation  String?
  company     String?
  phone       String?
  address     String?
  socials     Json?    // { github: string, linkedin: string, twitter: string, etc. }

  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt
}
```


---

# Schema Update Guide


# Schema Update Guide: Role to UserRole Migration

## Overview

This document describes the schema changes applied to the `@codezest-academy/db` package, specifically the migration from the `Role` enum to the `UserRole` enum and the extension of the `UserProfile` model.

## Changes Summary

### 1. Enum Rename: `Role` → `UserRole`

**Before:**

```prisma
enum Role {
  ADMIN
  INSTRUCTOR
  STUDENT
}
```

**After:**

```prisma
enum UserRole {
  USER
  ADMIN
}
```

**Rationale:** Simplified the role system to two core roles:

- `USER` - Regular users (replaces `STUDENT` and `INSTRUCTOR`)
- `ADMIN` - Administrators

### 2. User Model Update

**Before:**

```prisma
model User {
  // ...
  role Role @default(STUDENT)
  // ...
}
```

**After:**

```prisma
model User {
  // ...
  role UserRole @default(USER)
  // ...
}
```

### 3. UserProfile Model Extension

**New Fields Added:**

```prisma
model UserProfile {
  // ... existing fields ...

  // NEW FIELDS
  occupation  String?
  company     String?
  phone       String?
  address     String?
  socials     Json?    // { github: string, linkedin: string, twitter: string, etc. }
}
```

## Database Migration

### Migration File

- **Name:** `20251122202150_apply_schema_changes`
- **Location:** `prisma/migrations/20251122202150_apply_schema_changes/migration.sql`

### What the Migration Does

1. **Creates new enum:**

   ```sql
   CREATE TYPE "UserRole" AS ENUM ('USER', 'ADMIN');
   ```

2. **Updates UserProfile table:**

   ```sql
   ALTER TABLE "auth.user_profiles"
   ADD COLUMN "address" TEXT,
   ADD COLUMN "company" TEXT,
   ADD COLUMN "occupation" TEXT,
   ADD COLUMN "phone" TEXT,
   ADD COLUMN "socials" JSONB;
   ```

3. **Updates User table:**

   ```sql
   ALTER TABLE "auth.users"
   DROP COLUMN "role",
   ADD COLUMN "role" "UserRole" NOT NULL DEFAULT 'USER';
   ```

4. **Removes old enum:**
   ```sql
   DROP TYPE "Role";
   ```

### ⚠️ Breaking Changes

> **WARNING:** This migration drops and recreates the `role` column, which results in **data loss** for existing user roles. All existing users will be assigned the default role of `USER`.

## Code Changes

### Type Guards Updated

**Removed:**

- `isInstructor(user)` - No longer needed
- `isStudent(user)` - No longer needed

**Added:**

- `isUser(user)` - Checks if user has `USER` role

**Kept:**

- `isAdmin(user)` - Checks if user has `ADMIN` role

### Usage Example

```typescript
import { prisma, UserRole, isUser, isAdmin } from "@codezest-academy/db";

// Create a user with the new enum
const user = await prisma.user.create({
  data: {
    email: "user@example.com",
    name: "John Doe",
    role: UserRole.USER,
    profile: {
      create: {
        bio: "Software Developer",
        occupation: "Full Stack Developer",
        company: "Tech Corp",
        phone: "+1234567890",
        socials: {
          github: "johndoe",
          linkedin: "john-doe",
          twitter: "@johndoe",
        },
      },
    },
  },
  include: { profile: true },
});

// Use type guards
if (isAdmin(user)) {
  console.log("User is an admin");
} else if (isUser(user)) {
  console.log("User is a regular user");
}
```

## Package Publishing Journey

### Version History

| Version | Status         | Notes                                     |
| ------- | -------------- | ----------------------------------------- |
| 1.0.0   | Initial        | Original package with `Role` enum         |
| 1.0.1   | ❌ Failed      | Authentication issue + old enum values    |
| 1.0.2   | ❌ Failed      | Fixed auth, but stale dist folder         |
| 1.0.3   | ❌ Failed      | Updated type guards, but still stale dist |
| 1.0.4   | ✅ **SUCCESS** | Clean rebuild with correct enum           |

### Issues Encountered & Solutions

#### Issue 1: Authentication Error (401 Unauthorized)

**Problem:** GitHub Actions workflow couldn't publish to GitHub Packages.

**Root Cause:** `.npmrc` file referenced `${GITHUB_TOKEN}` but workflow set `NODE_AUTH_TOKEN`.

**Solution:** Updated `.npmrc` to use `${NODE_AUTH_TOKEN}`:

```
//npm.pkg.github.com/:_authToken=${NODE_AUTH_TOKEN}
```

#### Issue 2: Published Package Had Old Enum Values

**Problem:** Published packages (v1.0.1-1.0.3) contained old `Role` enum despite schema being updated.

**Root Cause:** The `dist/` folder contained stale compiled JavaScript from before the schema changes. npm packages the `dist/` folder, not the source.

**Solution:** Clean rebuild process:

```bash
rm -rf dist/
npx prisma generate
npm run build
```

## Database Verification

### Verification Commands

Check enum values in database:

```typescript
const { PrismaClient } = require("@prisma/client");
const prisma = new PrismaClient();

// Check UserRole enum values
const result = await prisma.$queryRaw`
  SELECT enumlabel 
  FROM pg_enum 
  WHERE enumtypid = (SELECT oid FROM pg_type WHERE typname = 'UserRole')
`;
console.log(result);
// Output: [{ enumlabel: 'USER' }, { enumlabel: 'ADMIN' }]
```

### Verification Results

✅ **Database is correct:**

- `UserRole` enum exists with `USER` and `ADMIN` values
- Old `Role` enum has been dropped
- No `STUDENT` or `INSTRUCTOR` values exist
- Migration status: **Up to date**

## Installation & Usage

### Installing the Package

```bash
npm install @codezest-academy/db@1.0.4
```

### Running Migrations

If you're setting up a new database:

```bash
npx prisma migrate deploy
```

If you're developing locally:

```bash
npx prisma migrate dev
```

## Best Practices

### 1. Always Use Clean Builds for Publishing

```bash
# Before publishing
rm -rf dist/
npx prisma generate
npm run build
```

### 2. Verify Enum Values Locally

```bash
node -e "const { UserRole } = require('./dist/index.js'); console.log(JSON.stringify(UserRole, null, 2))"
```

### 3. Check Migration Status

```bash
npx prisma migrate status
```

## Rollback Strategy

If you need to rollback this migration:

1. **Create a new migration** that reverses the changes
2. **Update the schema** back to the old `Role` enum
3. **Run migration:** `npx prisma migrate dev`

> **Note:** Rollback will require manual data migration if you have existing users with `USER` role.

## Support

For issues or questions:

- **Repository:** https://github.com/codezest-academy/codezest-db
- **Issues:** https://github.com/codezest-academy/codezest-db/issues

## Changelog

### v1.0.4 (2025-11-23)

- ✅ Renamed `Role` enum to `UserRole` (USER, ADMIN)
- ✅ Updated `User.role` field to use `UserRole` with default `USER`
- ✅ Extended `UserProfile` with `occupation`, `company`, `phone`, `address`, `socials`
- ✅ Updated type guards (`isUser`, `isAdmin`)
- ✅ Fixed package publishing with clean rebuild
- ✅ Database migration applied successfully


---

# Updates Summary


# CodeZest DB – Updated Architecture Summary

## 🆕 What's New

Based on your feedback, I've added two critical components to the database schema:

### 1️⃣ **Payment Microservice** (`codezest-payments`)

A dedicated microservice for handling all payment-related operations:

**Models:**
- **Subscription** - User subscription management (FREE/PRO/ENTERPRISE plans)
- **Transaction** - Payment transaction tracking with Stripe integration
- **Invoice** - Automated invoice generation and management
- **PaymentMethod** - Saved payment methods (cards, PayPal, bank transfers)

**Key Features:**
- ✅ Stripe integration ready (customer ID, subscription ID, payment intent ID)
- ✅ Multi-currency support
- ✅ Transaction status tracking (PENDING, PROCESSING, SUCCEEDED, FAILED, REFUNDED)
- ✅ Invoice generation with PDF URLs
- ✅ Multiple payment methods per user
- ✅ Phase 1: All users get FREE plan with full access

**Why a Separate Microservice?**
- Independent scaling for payment processing
- PCI compliance isolation
- Easier to swap payment providers (Stripe → PayPal → etc.)
- Clear separation of concerns
- Can be deployed to specialized infrastructure

---

### 2️⃣ **AI/Manual Analysis System** (in `learning.*` schema)

Intelligent feedback system for assignments and quizzes:

**Models:**
- **AssignmentAnalysis** - Detailed code analysis with AI or manual feedback
- **QuizAnalysis** - Performance breakdown and personalized recommendations

**Assignment Analysis Features:**
- ✅ Overall score (0-100)
- ✅ Strengths, weaknesses, and improvement suggestions
- ✅ Code quality metrics (readability, efficiency, best practices)
- ✅ Detailed long-form feedback
- ✅ AI model tracking (GPT-4, Claude, etc.)
- ✅ Manual review by instructors
- ✅ Hybrid mode (AI + instructor review)

**Quiz Analysis Features:**
- ✅ Performance breakdown by topic
- ✅ Strong topics vs weak topics identification
- ✅ Personalized study recommendations
- ✅ AI-generated insights
- ✅ Time management analysis
- ✅ Average time per question tracking

**Analysis Types:**
- **AI** - Automated analysis using GPT-4, Claude, or custom models
- **MANUAL** - Instructor-provided feedback
- **HYBRID** - AI analysis reviewed/enhanced by instructor

---

## 📊 Updated Architecture

### Microservices Overview

| Service | Repository | Schema | Models | Purpose |
|---------|-----------|--------|--------|---------|
| **codezest-auth** | `codezest-auth` | `auth.*` | 6 | User accounts, profiles, sessions, OAuth |
| **codezest-api** | `codezest-api` | `learning.*` | 15 | Languages, modules, materials, assignments, MCQs, analysis |
| **codezest-payments** | `codezest-payments` | `payments.*` | 4 | Subscriptions, transactions, invoices, payment methods |
| **codezest-notifications** | `codezest-notifications` | `notifications.*` | 3 | Notifications, preferences, email logs |
| **codezest-activity** | `codezest-activity` | `activity.*` | 2 | Activity feeds, analytics |

**Total: 5 microservices, 30 database models**

---

## 🎯 Complete Feature Set

### Phase 1 (Current)
- ✅ User registration, login, OAuth
- ✅ User profiles with bio, avatar, social links
- ✅ Programming languages (Python, JavaScript, Java, etc.)
- ✅ Modules with learning materials (videos, articles, code examples)
- ✅ Coding assignments with auto-grading
- ✅ MCQ quizzes with multiple attempts
- ✅ Progress tracking (module, material, assignment, quiz)
- ✅ **AI/Manual analysis** for assignments and quizzes
- ✅ **Free access** for all users

### Future-Ready (Phase 2+)
- 🔜 **Payment processing** via Stripe
- 🔜 **PRO/ENTERPRISE subscriptions** with premium features
- 🔜 **Invoicing** and billing management
- 🔜 **Multiple payment methods**
- 🔜 **Advanced AI analysis** with custom models
- 🔜 **Instructor dashboard** for manual reviews

---

## 🔗 Key Relationships

### Payment Flow
```
User
  └── Subscription (FREE/PRO/ENTERPRISE)
        ├── Transaction (payment history)
        ├── Invoice (billing records)
        └── PaymentMethod (saved cards/PayPal)
```

### Analysis Flow
```
User submits Assignment
  └── AssignmentSubmission
        └── AssignmentAnalysis (AI or Manual)
              ├── Strengths
              ├── Weaknesses
              ├── Suggestions
              └── Code Quality Metrics

User takes Quiz
  └── MCQAttempt
        └── QuizAnalysis (AI or Manual)
              ├── Performance Breakdown
              ├── Strong/Weak Topics
              ├── Recommendations
              └── Time Management Insights
```

---

## 💡 Use Cases

### Payment Microservice

**Scenario 1: User Upgrades to PRO**
```typescript
// 1. Create Stripe customer
const customer = await stripe.customers.create({ email: user.email })

// 2. Create subscription in database
const subscription = await prisma.subscription.create({
  data: {
    userId: user.id,
    plan: "PRO",
    status: "ACTIVE",
    stripeCustomerId: customer.id,
    stripeSubscriptionId: stripeSubscription.id,
    validUntil: new Date(Date.now() + 30 * 24 * 60 * 60 * 1000) // 30 days
  }
})

// 3. Record transaction
await prisma.transaction.create({
  data: {
    userId: user.id,
    subscriptionId: subscription.id,
    amount: 999, // $9.99
    currency: "usd",
    status: "SUCCEEDED",
    stripePaymentIntentId: paymentIntent.id
  }
})

// 4. Generate invoice
await prisma.invoice.create({
  data: {
    subscriptionId: subscription.id,
    invoiceNumber: "INV-2025-001",
    amount: 999,
    total: 999,
    status: "PAID",
    paidAt: new Date()
  }
})
```

### Analysis System

**Scenario 2: AI Analysis of Assignment**
```typescript
// 1. User submits code
const submission = await prisma.assignmentSubmission.create({
  data: {
    userId: user.id,
    assignmentId: assignment.id,
    code: userCode,
    language: "python",
    status: "PENDING"
  }
})

// 2. Run AI analysis
const aiResponse = await openai.chat.completions.create({
  model: "gpt-4",
  messages: [{
    role: "system",
    content: "Analyze this Python code for a beginner assignment..."
  }, {
    role: "user",
    content: userCode
  }]
})

// 3. Store analysis
await prisma.assignmentAnalysis.create({
  data: {
    submissionId: submission.id,
    analysisType: "AI",
    overallScore: 85,
    strengths: ["Clean code structure", "Good variable names"],
    weaknesses: ["Missing error handling", "No comments"],
    suggestions: ["Add try-catch blocks", "Document complex logic"],
    codeQuality: {
      readability: 9,
      efficiency: 7,
      bestPractices: 6
    },
    detailedFeedback: "Your code demonstrates...",
    aiModel: "gpt-4",
    aiPrompt: "Analyze this Python code..."
  }
})

// 4. Update submission status
await prisma.assignmentSubmission.update({
  where: { id: submission.id },
  data: {
    status: "PASSED",
    score: 85,
    feedback: "AI analysis complete. Check detailed feedback."
  }
})
```

**Scenario 3: Instructor Manual Review**
```typescript
// Instructor reviews AI analysis and adds manual feedback
await prisma.assignmentAnalysis.update({
  where: { submissionId: submission.id },
  data: {
    analysisType: "HYBRID", // AI + Manual
    analyzedBy: instructor.id,
    detailedFeedback: aiAnalysis.detailedFeedback + "\n\nInstructor Notes: Great job on..."
  }
})
```

---

## 🚀 Deployment Strategy

### Repository Structure

```
GitHub Organization: codezest-academy
├── codezest-db (this repo)           → GitHub Packages
├── codezest-auth                      → Railway/Render
├── codezest-api                       → Railway/Render
├── codezest-payments                  → Railway/Render (PCI compliant)
├── codezest-notifications             → Railway/Render
├── codezest-activity                  → Railway/Render
├── codezest-admin (Next.js)           → Vercel
└── codezest-web (Next.js)             → Vercel
```

### Database Schema Namespaces

All in one PostgreSQL database (Neon), separated by schema:
- `auth.*` - Auth service tables
- `learning.*` - Learning service tables
- `payments.*` - Payment service tables
- `notifications.*` - Notification service tables
- `activity.*` - Activity service tables

**Why one database?**
- Simpler for Phase 1
- Easier transactions across services
- Lower cost
- Can split later if needed

---

## 📈 Scalability Considerations

### Payment Service
- Can handle millions of transactions
- Stripe handles PCI compliance
- Easy to add new payment providers
- Invoice generation can be async job

### Analysis System
- AI analysis can be queued (background jobs)
- Cache common analysis patterns
- Rate limiting for AI API calls
- Fallback to manual review if AI fails
- Can use cheaper models for simple assignments

---

## 🎓 Example: Complete User Journey with New Features

1. **User signs up** → `User`, `UserProfile`, `Subscription` (FREE) created
2. **User enrolls in Python** → `LanguageEnrollment` created
3. **User completes module** → `ModuleProgress` updated
4. **User submits assignment** → `AssignmentSubmission` created
5. **AI analyzes code** → `AssignmentAnalysis` created with feedback
6. **User takes quiz** → `MCQAttempt` created
7. **AI analyzes performance** → `QuizAnalysis` created with recommendations
8. **User upgrades to PRO** → `Subscription` updated, `Transaction` created, `Invoice` generated
9. **Payment processed** → `Transaction` status updated to SUCCEEDED
10. **User gets premium features** → Access control based on subscription plan

---

## ✅ What's Ready to Implement

All 30 models are designed and ready to implement:

### Auth Service (6 models)
- [x] User
- [x] UserProfile
- [x] Session
- [x] OAuthAccount
- [x] PasswordReset
- [x] EmailVerification

### Learning Service (15 models)
- [x] ProgrammingLanguage
- [x] Module
- [x] Material
- [x] Assignment
- [x] MCQQuiz
- [x] MCQQuestion
- [x] MCQOption
- [x] LanguageEnrollment
- [x] ModuleProgress
- [x] MaterialProgress
- [x] AssignmentSubmission
- [x] MCQAttempt
- [x] MCQAnswer
- [x] **AssignmentAnalysis** ✨ NEW
- [x] **QuizAnalysis** ✨ NEW

### Payment Service (4 models)
- [x] **Subscription** ✨ NEW
- [x] **Transaction** ✨ NEW
- [x] **Invoice** ✨ NEW
- [x] **PaymentMethod** ✨ NEW

### Notification Service (3 models)
- [x] Notification
- [x] NotificationPreference
- [x] EmailLog

### Activity Service (2 models)
- [x] UserActivity
- [x] AnalyticsEvent

---

## 🎯 Next Steps

1. ✅ Review updated plan
2. ⏳ Approve schema design
3. ⏳ Set up Neon PostgreSQL database
4. ⏳ Implement all 30 models in `prisma/schema.prisma`
5. ⏳ Run initial migration
6. ⏳ Publish `@codezest/db` v1.0.0
7. ⏳ Integrate into microservices

**Ready to proceed with implementation?** 🚀


---

# Implementation Checklist


# CodeZest DB - Implementation Checklist

**Last Updated**: 2025-11-21  
**Status**: Planning Complete, Ready for Implementation  
**Current Phase**: Phase 1 - Core Platform

---

## 📋 What We're Implementing

### Overview
A production-ready shared database package (`@codezest/db`) for CodeZest microservices architecture with:
- **5 Microservices**: Auth, API (Learning), Payments, Notifications, Activity
- **30 Database Models**: Complete schema for coding learning platform
- **SOLID Principles**: Following industry best practices
- **Design Patterns**: Repository, Factory, Strategy, Observer, Singleton, Adapter, Composite

---

## 🎯 Implementation Scope

### Phase 1 Features
- ✅ User registration, login, OAuth
- ✅ User profiles (bio, avatar, social links, preferences)
- ✅ Programming languages (Python, JavaScript, Java, etc.)
- ✅ Modules with learning materials (videos, articles, code examples)
- ✅ Coding assignments with auto-grading support
- ✅ MCQ quizzes with multiple attempts
- ✅ Progress tracking (module, material, assignment, quiz)
- ✅ AI/Manual analysis for assignments and quizzes
- ✅ Payment infrastructure (FREE plan for Phase 1, PRO/ENTERPRISE ready)
- ✅ Subscription management with Stripe integration
- ✅ Transaction and invoice tracking
- ✅ Notifications and email logging
- ✅ Activity feeds and analytics

---

## 📦 Files to Create

### 1. Package Configuration (4 files)
- [ ] `package.json` - Package config with scripts, dependencies, exports
- [ ] `tsconfig.json` - TypeScript configuration
- [ ] `.gitignore` - Git ignore rules
- [ ] `.npmignore` - npm publish ignore rules

### 2. Prisma Schema (1 file)
- [ ] `prisma/schema.prisma` - **THE MAIN SCHEMA** (30 models)

### 3. TypeScript Source Files (4 files)
- [ ] `src/index.ts` - Main exports (PrismaClient + types)
- [ ] `src/types.ts` - Custom TypeScript types
- [ ] `src/mongo/index.ts` - MongoDB client (optional)
- [ ] `src/mongo/collections.ts` - MongoDB collection types

### 4. Documentation (4 files)
- [ ] `README.md` - Usage documentation
- [ ] `ARCHITECTURE.md` - Architecture reference (copy from user's doc)
- [ ] `.env.example` - Example environment variables
- [ ] `CHANGELOG.md` - Version history

### 5. Already Created (3 files)
- [x] `PLAN_OVERVIEW.md` - Complete schema design
- [x] `UPDATES_SUMMARY.md` - Payment & analysis additions
- [x] `IMPLEMENTATION.md` - This file

**Total: 16 files to create**

---

## 🗄️ Database Models Breakdown

### Auth Service (6 models) - `auth.*` schema
1. [ ] `User` - Core user accounts (email, password, name, role)
2. [ ] `UserProfile` - Extended info (bio, avatar, social links, preferences)
3. [ ] `Session` - Active sessions (token, expiresAt)
4. [ ] `OAuthAccount` - OAuth providers (Google, GitHub)
5. [ ] `PasswordReset` - Password reset tokens
6. [ ] `EmailVerification` - Email verification workflow

### Learning Service (15 models) - `learning.*` schema
7. [ ] `ProgrammingLanguage` - Languages (Python, JS, Java)
8. [ ] `Module` - Learning modules per language
9. [ ] `Material` - Learning content (videos, articles, code)
10. [ ] `Assignment` - Coding exercises with test cases
11. [ ] `MCQQuiz` - Multiple choice quizzes
12. [ ] `MCQQuestion` - Quiz questions
13. [ ] `MCQOption` - Answer options
14. [ ] `LanguageEnrollment` - User enrollments
15. [ ] `ModuleProgress` - Module completion tracking
16. [ ] `MaterialProgress` - Material view tracking
17. [ ] `AssignmentSubmission` - Code submissions
18. [ ] `MCQAttempt` - Quiz attempts
19. [ ] `MCQAnswer` - Individual answers
20. [ ] `AssignmentAnalysis` - AI/manual code analysis
21. [ ] `QuizAnalysis` - AI/manual quiz analysis

### Payment Service (4 models) - `payments.*` schema
22. [ ] `Subscription` - User subscriptions (FREE/PRO/ENTERPRISE)
23. [ ] `Transaction` - Payment transactions
24. [ ] `Invoice` - Generated invoices
25. [ ] `PaymentMethod` - Saved payment methods

### Notification Service (3 models) - `notifications.*` schema
26. [ ] `Notification` - User notifications
27. [ ] `NotificationPreference` - User preferences
28. [ ] `EmailLog` - Email audit trail

### Activity Service (2 models) - `activity.*` schema
29. [ ] `UserActivity` - Activity feed events
30. [ ] `AnalyticsEvent` - Custom analytics

---

## 🔧 Implementation Steps

### Step 1: Initialize Package ⏳
- [ ] Create `package.json` with dependencies
- [ ] Create `tsconfig.json` with strict mode
- [ ] Create `.gitignore` and `.npmignore`
- [ ] Run `npm install`

### Step 2: Initialize Prisma ⏳
- [ ] Run `npx prisma init --datasource-provider postgresql`
- [ ] Configure `.env` with `DATABASE_URL`

### Step 3: Create Schema ⏳
- [ ] Create `prisma/schema.prisma` with generator and datasource
- [ ] Add all 30 models with relationships
- [ ] Add all enums (12 total)
- [ ] Add indexes and constraints
- [ ] Add schema comments for documentation

### Step 4: Create TypeScript Exports ⏳
- [ ] Create `src/index.ts` with PrismaClient singleton
- [ ] Create `src/types.ts` with custom types
- [ ] Create `src/mongo/index.ts` (optional)
- [ ] Create `src/mongo/collections.ts` (optional)

### Step 5: Documentation ⏳
- [ ] Create `README.md` with usage examples
- [ ] Copy `ARCHITECTURE.md` from user's document
- [ ] Create `.env.example` with required variables
- [ ] Create `CHANGELOG.md` with v1.0.0 entry

### Step 6: Build & Test ⏳
- [ ] Run `npm run build` (TypeScript + Prisma generate)
- [ ] Verify TypeScript compilation
- [ ] Check generated types in `dist/generated`

### Step 7: Create Migration ⏳
- [ ] Set up Neon PostgreSQL database (user to provide URL)
- [ ] Run `npm run migrate:dev -- --name init`
- [ ] Verify migration SQL files
- [ ] Test with `npm run db:studio`

### Step 8: Publish ⏳
- [ ] Test package locally
- [ ] Commit all files to git
- [ ] Run `npm run release` (bump version + publish)
- [ ] Verify package on npm/GitHub Packages

---

## 📊 Enums to Define (12 total)

1. [ ] `Role` - ADMIN, INSTRUCTOR, STUDENT
2. [ ] `Difficulty` - BEGINNER, INTERMEDIATE, ADVANCED
3. [ ] `MaterialType` - VIDEO, ARTICLE, CODE_EXAMPLE, INTERACTIVE
4. [ ] `SubmissionStatus` - PENDING, RUNNING, PASSED, FAILED, ERROR
5. [ ] `ProgressStatus` - NOT_STARTED, IN_PROGRESS, COMPLETED
6. [ ] `EnrollmentStatus` - ACTIVE, PAUSED, COMPLETED, DROPPED
7. [ ] `SubscriptionPlan` - FREE, PRO, ENTERPRISE
8. [ ] `SubscriptionStatus` - ACTIVE, CANCELED, EXPIRED, PAUSED
9. [ ] `TransactionStatus` - PENDING, PROCESSING, SUCCEEDED, FAILED, REFUNDED
10. [ ] `InvoiceStatus` - DRAFT, SENT, PAID, OVERDUE, CANCELED
11. [ ] `PaymentMethodType` - CARD, PAYPAL, BANK_TRANSFER
12. [ ] `AnalysisType` - AI, MANUAL, HYBRID

---

## 🔗 Key Relationships to Implement

### One-to-One
- User ↔ UserProfile
- User ↔ Subscription
- AssignmentSubmission ↔ AssignmentAnalysis
- MCQAttempt ↔ QuizAnalysis

### One-to-Many
- User → Session (multiple sessions per user)
- User → OAuthAccount (multiple OAuth providers)
- ProgrammingLanguage → Module
- Module → Material
- Module → Assignment
- Module → MCQQuiz
- MCQQuiz → MCQQuestion
- MCQQuestion → MCQOption
- User → LanguageEnrollment
- User → ModuleProgress
- User → AssignmentSubmission
- User → MCQAttempt
- Subscription → Transaction
- Subscription → Invoice
- User → PaymentMethod

### Special Relationships
- Cascade deletes on critical relationships
- Composite unique constraints (userId + languageId, etc.)
- Indexes on all foreign keys

---

## 🎯 Success Criteria

### Must Have
- ✅ All 30 models defined in schema
- ✅ All 12 enums defined
- ✅ All relationships properly configured
- ✅ TypeScript types generated successfully
- ✅ Initial migration created
- ✅ Package builds without errors
- ✅ Prisma Studio can open and view schema
- ✅ README with clear usage examples

### Nice to Have
- ✅ MongoDB integration working
- ✅ Comprehensive comments in schema
- ✅ Example seed data script
- ✅ Integration test with consuming service

---

## 📝 Notes & Decisions

### Database Provider
- **PostgreSQL** via Neon (serverless, auto-scaling)
- Schema namespacing: `auth.*`, `learning.*`, `payments.*`, `notifications.*`, `activity.*`

### ID Strategy
- **UUID** for all primary keys (distributed system ready)
- No auto-increment integers

### Soft Deletes
- `deletedAt DateTime?` on major entities
- Allows data retention and audit compliance

### Stripe Integration
- Fields: `stripeCustomerId`, `stripeSubscriptionId`, `stripePaymentIntentId`
- Ready for Phase 2 payment processing

### AI Analysis
- Support for multiple AI models (GPT-4, Claude, etc.)
- Hybrid mode: AI + manual instructor review
- Stored in JSONB for flexibility

### Phase 1 Constraints
- All users get FREE subscription
- Payment processing infrastructure ready but not active
- AI analysis optional (can use manual review)

---

## 🚀 Next Actions

1. **Get User Approval** on schema design
2. **Get DATABASE_URL** from user (Neon PostgreSQL)
3. **Start Implementation** following checklist above
4. **Update PROGRESS.md** after each major step
5. **Test thoroughly** before publishing

---

## 📚 Reference Documents

- `PLAN_OVERVIEW.md` - Complete schema design with examples
- `UPDATES_SUMMARY.md` - Payment & analysis additions
- `implementation_plan.md` (artifact) - SOLID principles & design patterns
- User's `ARCHITECTURE.md` - Microservices architecture reference

---

**Status**: Ready to implement ✅  
**Blockers**: None - awaiting user approval  
**Estimated Time**: 2-3 hours for full implementation

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

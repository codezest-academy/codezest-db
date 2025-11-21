-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'INSTRUCTOR', 'STUDENT');

-- CreateEnum
CREATE TYPE "Difficulty" AS ENUM ('BEGINNER', 'INTERMEDIATE', 'ADVANCED');

-- CreateEnum
CREATE TYPE "MaterialType" AS ENUM ('VIDEO', 'ARTICLE', 'CODE_EXAMPLE', 'INTERACTIVE');

-- CreateEnum
CREATE TYPE "SubmissionStatus" AS ENUM ('PENDING', 'RUNNING', 'PASSED', 'FAILED', 'ERROR');

-- CreateEnum
CREATE TYPE "ProgressStatus" AS ENUM ('NOT_STARTED', 'IN_PROGRESS', 'COMPLETED');

-- CreateEnum
CREATE TYPE "EnrollmentStatus" AS ENUM ('ACTIVE', 'PAUSED', 'COMPLETED', 'DROPPED');

-- CreateEnum
CREATE TYPE "SubscriptionPlan" AS ENUM ('FREE', 'PRO', 'ENTERPRISE');

-- CreateEnum
CREATE TYPE "SubscriptionStatus" AS ENUM ('ACTIVE', 'CANCELED', 'EXPIRED', 'PAUSED');

-- CreateEnum
CREATE TYPE "TransactionStatus" AS ENUM ('PENDING', 'PROCESSING', 'SUCCEEDED', 'FAILED', 'REFUNDED');

-- CreateEnum
CREATE TYPE "InvoiceStatus" AS ENUM ('DRAFT', 'SENT', 'PAID', 'OVERDUE', 'CANCELED');

-- CreateEnum
CREATE TYPE "PaymentMethodType" AS ENUM ('CARD', 'PAYPAL', 'BANK_TRANSFER');

-- CreateEnum
CREATE TYPE "AnalysisType" AS ENUM ('AI', 'MANUAL', 'HYBRID');

-- CreateTable
CREATE TABLE "auth.users" (
    "id" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password" TEXT,
    "name" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'STUDENT',
    "emailVerified" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "auth.users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth.user_profiles" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "bio" TEXT,
    "avatar" TEXT,
    "location" TEXT,
    "website" TEXT,
    "githubUrl" TEXT,
    "linkedinUrl" TEXT,
    "twitterUrl" TEXT,
    "preferences" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auth.user_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth.sessions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth.sessions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth.oauth_accounts" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "provider" TEXT NOT NULL,
    "providerId" TEXT NOT NULL,
    "accessToken" TEXT,
    "refreshToken" TEXT,
    "expiresAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "auth.oauth_accounts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth.password_resets" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "used" BOOLEAN NOT NULL DEFAULT false,
    "usedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth.password_resets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth.email_verifications" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "verifiedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth.email_verifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.programming_languages" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "icon" TEXT,
    "difficulty" "Difficulty" NOT NULL DEFAULT 'BEGINNER',
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "learning.programming_languages_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.modules" (
    "id" TEXT NOT NULL,
    "languageId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "description" TEXT,
    "syllabus" TEXT,
    "order" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "learning.modules_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.materials" (
    "id" TEXT NOT NULL,
    "moduleId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "type" "MaterialType" NOT NULL,
    "content" TEXT NOT NULL,
    "duration" INTEGER,
    "order" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "learning.materials_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.assignments" (
    "id" TEXT NOT NULL,
    "moduleId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "difficulty" "Difficulty" NOT NULL,
    "starterCode" TEXT,
    "testCases" TEXT NOT NULL,
    "hints" TEXT,
    "maxScore" INTEGER NOT NULL DEFAULT 100,
    "timeLimit" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "learning.assignments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.assignment_submissions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "assignmentId" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "language" TEXT NOT NULL,
    "status" "SubmissionStatus" NOT NULL DEFAULT 'PENDING',
    "score" INTEGER,
    "feedback" TEXT,
    "submittedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "gradedAt" TIMESTAMP(3),

    CONSTRAINT "learning.assignment_submissions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.mcq_quizzes" (
    "id" TEXT NOT NULL,
    "moduleId" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "passingScore" INTEGER NOT NULL DEFAULT 70,
    "timeLimit" INTEGER,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,
    "deletedAt" TIMESTAMP(3),

    CONSTRAINT "learning.mcq_quizzes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.mcq_questions" (
    "id" TEXT NOT NULL,
    "quizId" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "explanation" TEXT,
    "order" INTEGER NOT NULL,
    "points" INTEGER NOT NULL DEFAULT 1,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "learning.mcq_questions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.mcq_options" (
    "id" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "optionText" TEXT NOT NULL,
    "isCorrect" BOOLEAN NOT NULL,
    "order" INTEGER NOT NULL,

    CONSTRAINT "learning.mcq_options_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.language_enrollments" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "languageId" TEXT NOT NULL,
    "status" "EnrollmentStatus" NOT NULL DEFAULT 'ACTIVE',
    "enrolledAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "learning.language_enrollments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.module_progress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "moduleId" TEXT NOT NULL,
    "status" "ProgressStatus" NOT NULL DEFAULT 'NOT_STARTED',
    "progressPercent" INTEGER NOT NULL DEFAULT 0,
    "startedAt" TIMESTAMP(3),
    "completedAt" TIMESTAMP(3),
    "lastAccessedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "learning.module_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.material_progress" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "materialId" TEXT NOT NULL,
    "completed" BOOLEAN NOT NULL DEFAULT false,
    "viewCount" INTEGER NOT NULL DEFAULT 0,
    "lastViewedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "learning.material_progress_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.mcq_attempts" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "quizId" TEXT NOT NULL,
    "score" INTEGER,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "completedAt" TIMESTAMP(3),

    CONSTRAINT "learning.mcq_attempts_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.mcq_answers" (
    "id" TEXT NOT NULL,
    "attemptId" TEXT NOT NULL,
    "questionId" TEXT NOT NULL,
    "selectedOptionId" TEXT,
    "isCorrect" BOOLEAN NOT NULL,
    "answeredAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "learning.mcq_answers_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.assignment_analyses" (
    "id" TEXT NOT NULL,
    "submissionId" TEXT NOT NULL,
    "analysisType" "AnalysisType" NOT NULL DEFAULT 'AI',
    "overallScore" INTEGER,
    "strengths" TEXT[],
    "weaknesses" TEXT[],
    "suggestions" TEXT[],
    "codeQuality" JSONB,
    "detailedFeedback" TEXT,
    "aiModel" TEXT,
    "aiPrompt" TEXT,
    "analyzedBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "learning.assignment_analyses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "learning.quiz_analyses" (
    "id" TEXT NOT NULL,
    "attemptId" TEXT NOT NULL,
    "analysisType" "AnalysisType" NOT NULL DEFAULT 'AI',
    "performanceBreakdown" JSONB NOT NULL,
    "strongTopics" TEXT[],
    "weakTopics" TEXT[],
    "recommendations" TEXT[],
    "insights" TEXT,
    "avgTimePerQuestion" INTEGER,
    "timeManagement" TEXT,
    "aiModel" TEXT,
    "analyzedBy" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "learning.quiz_analyses_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments.subscriptions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "plan" "SubscriptionPlan" NOT NULL DEFAULT 'FREE',
    "status" "SubscriptionStatus" NOT NULL DEFAULT 'ACTIVE',
    "stripeCustomerId" TEXT,
    "stripeSubscriptionId" TEXT,
    "startedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "validUntil" TIMESTAMP(3),
    "canceledAt" TIMESTAMP(3),
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payments.subscriptions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments.transactions" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "subscriptionId" TEXT,
    "amount" INTEGER NOT NULL DEFAULT 0,
    "currency" TEXT NOT NULL DEFAULT 'usd',
    "status" "TransactionStatus" NOT NULL DEFAULT 'PENDING',
    "stripePaymentIntentId" TEXT,
    "stripeChargeId" TEXT,
    "paymentMethod" TEXT,
    "description" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "paidAt" TIMESTAMP(3),
    "failedAt" TIMESTAMP(3),

    CONSTRAINT "payments.transactions_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments.invoices" (
    "id" TEXT NOT NULL,
    "subscriptionId" TEXT NOT NULL,
    "invoiceNumber" TEXT NOT NULL,
    "amount" INTEGER NOT NULL DEFAULT 0,
    "currency" TEXT NOT NULL DEFAULT 'usd',
    "tax" INTEGER,
    "total" INTEGER NOT NULL DEFAULT 0,
    "status" "InvoiceStatus" NOT NULL DEFAULT 'DRAFT',
    "stripeInvoiceId" TEXT,
    "invoiceUrl" TEXT,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "dueAt" TIMESTAMP(3),
    "paidAt" TIMESTAMP(3),

    CONSTRAINT "payments.invoices_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "payments.payment_methods" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" "PaymentMethodType" NOT NULL,
    "stripePaymentMethodId" TEXT,
    "last4" TEXT,
    "brand" TEXT,
    "expiryMonth" INTEGER,
    "expiryYear" INTEGER,
    "paypalEmail" TEXT,
    "isDefault" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "payments.payment_methods_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications.notifications" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "priority" TEXT NOT NULL DEFAULT 'MEDIUM',
    "read" BOOLEAN NOT NULL DEFAULT false,
    "readAt" TIMESTAMP(3),
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "notifications.notifications_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications.notification_preferences" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "email" BOOLEAN NOT NULL DEFAULT true,
    "push" BOOLEAN NOT NULL DEFAULT true,
    "sms" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications.notification_preferences_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications.email_logs" (
    "id" TEXT NOT NULL,
    "to" TEXT NOT NULL,
    "from" TEXT NOT NULL DEFAULT 'noreply@codezest.com',
    "subject" TEXT NOT NULL,
    "body" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "provider" TEXT,
    "providerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "sentAt" TIMESTAMP(3),
    "failedAt" TIMESTAMP(3),

    CONSTRAINT "notifications.email_logs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "activity.user_activities" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "metadata" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "activity.user_activities_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "activity.analytics_events" (
    "id" TEXT NOT NULL,
    "eventName" TEXT NOT NULL,
    "userId" TEXT,
    "properties" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "activity.analytics_events_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "auth.users_email_key" ON "auth.users"("email");

-- CreateIndex
CREATE INDEX "auth.users_email_idx" ON "auth.users"("email");

-- CreateIndex
CREATE INDEX "auth.users_role_idx" ON "auth.users"("role");

-- CreateIndex
CREATE UNIQUE INDEX "auth.user_profiles_userId_key" ON "auth.user_profiles"("userId");

-- CreateIndex
CREATE INDEX "auth.user_profiles_userId_idx" ON "auth.user_profiles"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "auth.sessions_token_key" ON "auth.sessions"("token");

-- CreateIndex
CREATE INDEX "auth.sessions_userId_idx" ON "auth.sessions"("userId");

-- CreateIndex
CREATE INDEX "auth.sessions_token_idx" ON "auth.sessions"("token");

-- CreateIndex
CREATE INDEX "auth.sessions_expiresAt_idx" ON "auth.sessions"("expiresAt");

-- CreateIndex
CREATE INDEX "auth.oauth_accounts_userId_idx" ON "auth.oauth_accounts"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "auth.oauth_accounts_provider_providerId_key" ON "auth.oauth_accounts"("provider", "providerId");

-- CreateIndex
CREATE UNIQUE INDEX "auth.password_resets_token_key" ON "auth.password_resets"("token");

-- CreateIndex
CREATE INDEX "auth.password_resets_userId_idx" ON "auth.password_resets"("userId");

-- CreateIndex
CREATE INDEX "auth.password_resets_token_idx" ON "auth.password_resets"("token");

-- CreateIndex
CREATE UNIQUE INDEX "auth.email_verifications_token_key" ON "auth.email_verifications"("token");

-- CreateIndex
CREATE INDEX "auth.email_verifications_userId_idx" ON "auth.email_verifications"("userId");

-- CreateIndex
CREATE INDEX "auth.email_verifications_token_idx" ON "auth.email_verifications"("token");

-- CreateIndex
CREATE UNIQUE INDEX "learning.programming_languages_name_key" ON "learning.programming_languages"("name");

-- CreateIndex
CREATE UNIQUE INDEX "learning.programming_languages_slug_key" ON "learning.programming_languages"("slug");

-- CreateIndex
CREATE INDEX "learning.programming_languages_slug_idx" ON "learning.programming_languages"("slug");

-- CreateIndex
CREATE INDEX "learning.programming_languages_isActive_idx" ON "learning.programming_languages"("isActive");

-- CreateIndex
CREATE INDEX "learning.modules_languageId_idx" ON "learning.modules"("languageId");

-- CreateIndex
CREATE INDEX "learning.modules_order_idx" ON "learning.modules"("order");

-- CreateIndex
CREATE UNIQUE INDEX "learning.modules_languageId_slug_key" ON "learning.modules"("languageId", "slug");

-- CreateIndex
CREATE INDEX "learning.materials_moduleId_idx" ON "learning.materials"("moduleId");

-- CreateIndex
CREATE INDEX "learning.materials_type_idx" ON "learning.materials"("type");

-- CreateIndex
CREATE INDEX "learning.materials_order_idx" ON "learning.materials"("order");

-- CreateIndex
CREATE INDEX "learning.assignments_moduleId_idx" ON "learning.assignments"("moduleId");

-- CreateIndex
CREATE INDEX "learning.assignments_difficulty_idx" ON "learning.assignments"("difficulty");

-- CreateIndex
CREATE INDEX "learning.assignment_submissions_userId_idx" ON "learning.assignment_submissions"("userId");

-- CreateIndex
CREATE INDEX "learning.assignment_submissions_assignmentId_idx" ON "learning.assignment_submissions"("assignmentId");

-- CreateIndex
CREATE INDEX "learning.assignment_submissions_status_idx" ON "learning.assignment_submissions"("status");

-- CreateIndex
CREATE INDEX "learning.mcq_quizzes_moduleId_idx" ON "learning.mcq_quizzes"("moduleId");

-- CreateIndex
CREATE INDEX "learning.mcq_questions_quizId_idx" ON "learning.mcq_questions"("quizId");

-- CreateIndex
CREATE INDEX "learning.mcq_questions_order_idx" ON "learning.mcq_questions"("order");

-- CreateIndex
CREATE INDEX "learning.mcq_options_questionId_idx" ON "learning.mcq_options"("questionId");

-- CreateIndex
CREATE INDEX "learning.language_enrollments_userId_idx" ON "learning.language_enrollments"("userId");

-- CreateIndex
CREATE INDEX "learning.language_enrollments_languageId_idx" ON "learning.language_enrollments"("languageId");

-- CreateIndex
CREATE INDEX "learning.language_enrollments_status_idx" ON "learning.language_enrollments"("status");

-- CreateIndex
CREATE UNIQUE INDEX "learning.language_enrollments_userId_languageId_key" ON "learning.language_enrollments"("userId", "languageId");

-- CreateIndex
CREATE INDEX "learning.module_progress_userId_idx" ON "learning.module_progress"("userId");

-- CreateIndex
CREATE INDEX "learning.module_progress_moduleId_idx" ON "learning.module_progress"("moduleId");

-- CreateIndex
CREATE INDEX "learning.module_progress_status_idx" ON "learning.module_progress"("status");

-- CreateIndex
CREATE UNIQUE INDEX "learning.module_progress_userId_moduleId_key" ON "learning.module_progress"("userId", "moduleId");

-- CreateIndex
CREATE INDEX "learning.material_progress_userId_idx" ON "learning.material_progress"("userId");

-- CreateIndex
CREATE INDEX "learning.material_progress_materialId_idx" ON "learning.material_progress"("materialId");

-- CreateIndex
CREATE INDEX "learning.material_progress_completed_idx" ON "learning.material_progress"("completed");

-- CreateIndex
CREATE UNIQUE INDEX "learning.material_progress_userId_materialId_key" ON "learning.material_progress"("userId", "materialId");

-- CreateIndex
CREATE INDEX "learning.mcq_attempts_userId_idx" ON "learning.mcq_attempts"("userId");

-- CreateIndex
CREATE INDEX "learning.mcq_attempts_quizId_idx" ON "learning.mcq_attempts"("quizId");

-- CreateIndex
CREATE INDEX "learning.mcq_answers_attemptId_idx" ON "learning.mcq_answers"("attemptId");

-- CreateIndex
CREATE INDEX "learning.mcq_answers_questionId_idx" ON "learning.mcq_answers"("questionId");

-- CreateIndex
CREATE UNIQUE INDEX "learning.assignment_analyses_submissionId_key" ON "learning.assignment_analyses"("submissionId");

-- CreateIndex
CREATE INDEX "learning.assignment_analyses_submissionId_idx" ON "learning.assignment_analyses"("submissionId");

-- CreateIndex
CREATE INDEX "learning.assignment_analyses_analysisType_idx" ON "learning.assignment_analyses"("analysisType");

-- CreateIndex
CREATE UNIQUE INDEX "learning.quiz_analyses_attemptId_key" ON "learning.quiz_analyses"("attemptId");

-- CreateIndex
CREATE INDEX "learning.quiz_analyses_attemptId_idx" ON "learning.quiz_analyses"("attemptId");

-- CreateIndex
CREATE INDEX "learning.quiz_analyses_analysisType_idx" ON "learning.quiz_analyses"("analysisType");

-- CreateIndex
CREATE UNIQUE INDEX "payments.subscriptions_userId_key" ON "payments.subscriptions"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "payments.subscriptions_stripeCustomerId_key" ON "payments.subscriptions"("stripeCustomerId");

-- CreateIndex
CREATE UNIQUE INDEX "payments.subscriptions_stripeSubscriptionId_key" ON "payments.subscriptions"("stripeSubscriptionId");

-- CreateIndex
CREATE INDEX "payments.subscriptions_userId_idx" ON "payments.subscriptions"("userId");

-- CreateIndex
CREATE INDEX "payments.subscriptions_plan_idx" ON "payments.subscriptions"("plan");

-- CreateIndex
CREATE INDEX "payments.subscriptions_status_idx" ON "payments.subscriptions"("status");

-- CreateIndex
CREATE UNIQUE INDEX "payments.transactions_stripePaymentIntentId_key" ON "payments.transactions"("stripePaymentIntentId");

-- CreateIndex
CREATE UNIQUE INDEX "payments.transactions_stripeChargeId_key" ON "payments.transactions"("stripeChargeId");

-- CreateIndex
CREATE INDEX "payments.transactions_userId_idx" ON "payments.transactions"("userId");

-- CreateIndex
CREATE INDEX "payments.transactions_subscriptionId_idx" ON "payments.transactions"("subscriptionId");

-- CreateIndex
CREATE INDEX "payments.transactions_status_idx" ON "payments.transactions"("status");

-- CreateIndex
CREATE UNIQUE INDEX "payments.invoices_invoiceNumber_key" ON "payments.invoices"("invoiceNumber");

-- CreateIndex
CREATE UNIQUE INDEX "payments.invoices_stripeInvoiceId_key" ON "payments.invoices"("stripeInvoiceId");

-- CreateIndex
CREATE INDEX "payments.invoices_subscriptionId_idx" ON "payments.invoices"("subscriptionId");

-- CreateIndex
CREATE INDEX "payments.invoices_status_idx" ON "payments.invoices"("status");

-- CreateIndex
CREATE INDEX "payments.invoices_invoiceNumber_idx" ON "payments.invoices"("invoiceNumber");

-- CreateIndex
CREATE UNIQUE INDEX "payments.payment_methods_stripePaymentMethodId_key" ON "payments.payment_methods"("stripePaymentMethodId");

-- CreateIndex
CREATE INDEX "payments.payment_methods_userId_idx" ON "payments.payment_methods"("userId");

-- CreateIndex
CREATE INDEX "payments.payment_methods_isDefault_idx" ON "payments.payment_methods"("isDefault");

-- CreateIndex
CREATE INDEX "notifications.notifications_userId_idx" ON "notifications.notifications"("userId");

-- CreateIndex
CREATE INDEX "notifications.notifications_read_idx" ON "notifications.notifications"("read");

-- CreateIndex
CREATE INDEX "notifications.notifications_createdAt_idx" ON "notifications.notifications"("createdAt");

-- CreateIndex
CREATE UNIQUE INDEX "notifications.notification_preferences_userId_key" ON "notifications.notification_preferences"("userId");

-- CreateIndex
CREATE INDEX "notifications.notification_preferences_userId_idx" ON "notifications.notification_preferences"("userId");

-- CreateIndex
CREATE INDEX "notifications.email_logs_to_idx" ON "notifications.email_logs"("to");

-- CreateIndex
CREATE INDEX "notifications.email_logs_status_idx" ON "notifications.email_logs"("status");

-- CreateIndex
CREATE INDEX "notifications.email_logs_createdAt_idx" ON "notifications.email_logs"("createdAt");

-- CreateIndex
CREATE INDEX "activity.user_activities_userId_idx" ON "activity.user_activities"("userId");

-- CreateIndex
CREATE INDEX "activity.user_activities_type_idx" ON "activity.user_activities"("type");

-- CreateIndex
CREATE INDEX "activity.user_activities_createdAt_idx" ON "activity.user_activities"("createdAt");

-- CreateIndex
CREATE INDEX "activity.analytics_events_eventName_idx" ON "activity.analytics_events"("eventName");

-- CreateIndex
CREATE INDEX "activity.analytics_events_userId_idx" ON "activity.analytics_events"("userId");

-- CreateIndex
CREATE INDEX "activity.analytics_events_createdAt_idx" ON "activity.analytics_events"("createdAt");

-- AddForeignKey
ALTER TABLE "auth.user_profiles" ADD CONSTRAINT "auth.user_profiles_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth.sessions" ADD CONSTRAINT "auth.sessions_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth.oauth_accounts" ADD CONSTRAINT "auth.oauth_accounts_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth.password_resets" ADD CONSTRAINT "auth.password_resets_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth.email_verifications" ADD CONSTRAINT "auth.email_verifications_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.modules" ADD CONSTRAINT "learning.modules_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "learning.programming_languages"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.materials" ADD CONSTRAINT "learning.materials_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "learning.modules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.assignments" ADD CONSTRAINT "learning.assignments_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "learning.modules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.assignment_submissions" ADD CONSTRAINT "learning.assignment_submissions_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "learning.assignments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.mcq_quizzes" ADD CONSTRAINT "learning.mcq_quizzes_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "learning.modules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.mcq_questions" ADD CONSTRAINT "learning.mcq_questions_quizId_fkey" FOREIGN KEY ("quizId") REFERENCES "learning.mcq_quizzes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.mcq_options" ADD CONSTRAINT "learning.mcq_options_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "learning.mcq_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.language_enrollments" ADD CONSTRAINT "learning.language_enrollments_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "learning.programming_languages"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.module_progress" ADD CONSTRAINT "learning.module_progress_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "learning.modules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.material_progress" ADD CONSTRAINT "learning.material_progress_materialId_fkey" FOREIGN KEY ("materialId") REFERENCES "learning.materials"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.mcq_attempts" ADD CONSTRAINT "learning.mcq_attempts_quizId_fkey" FOREIGN KEY ("quizId") REFERENCES "learning.mcq_quizzes"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.mcq_answers" ADD CONSTRAINT "learning.mcq_answers_attemptId_fkey" FOREIGN KEY ("attemptId") REFERENCES "learning.mcq_attempts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.mcq_answers" ADD CONSTRAINT "learning.mcq_answers_questionId_fkey" FOREIGN KEY ("questionId") REFERENCES "learning.mcq_questions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.mcq_answers" ADD CONSTRAINT "learning.mcq_answers_selectedOptionId_fkey" FOREIGN KEY ("selectedOptionId") REFERENCES "learning.mcq_options"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.assignment_analyses" ADD CONSTRAINT "learning.assignment_analyses_submissionId_fkey" FOREIGN KEY ("submissionId") REFERENCES "learning.assignment_submissions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.quiz_analyses" ADD CONSTRAINT "learning.quiz_analyses_attemptId_fkey" FOREIGN KEY ("attemptId") REFERENCES "learning.mcq_attempts"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments.transactions" ADD CONSTRAINT "payments.transactions_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "payments.subscriptions"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "payments.invoices" ADD CONSTRAINT "payments.invoices_subscriptionId_fkey" FOREIGN KEY ("subscriptionId") REFERENCES "payments.subscriptions"("id") ON DELETE CASCADE ON UPDATE CASCADE;

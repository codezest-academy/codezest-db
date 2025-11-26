/*
  Warnings:

  - You are about to drop the column `address` on the `auth.user_profiles` table. All the data in the column will be lost.
  - You are about to drop the column `company` on the `auth.user_profiles` table. All the data in the column will be lost.
  - You are about to drop the column `githubUrl` on the `auth.user_profiles` table. All the data in the column will be lost.
  - You are about to drop the column `linkedinUrl` on the `auth.user_profiles` table. All the data in the column will be lost.
  - You are about to drop the column `occupation` on the `auth.user_profiles` table. All the data in the column will be lost.
  - You are about to drop the column `twitterUrl` on the `auth.user_profiles` table. All the data in the column will be lost.

*/

-- Step 1: Add all new columns first
ALTER TABLE "auth.user_profiles"
ADD COLUMN     "allowMessages" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "certificatesEarned" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "certifications" JSONB,
ADD COLUMN     "coursesCompleted" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "coverImage" TEXT,
ADD COLUMN     "currentCompany" TEXT,
ADD COLUMN     "currentRole" TEXT,
ADD COLUMN     "displayName" TEXT,
ADD COLUMN     "education" JSONB,
ADD COLUMN     "educationLevel" TEXT,
ADD COLUMN     "emailClicks" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "emailOpens" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "experienceLevel" TEXT,
ADD COLUMN     "fieldOfStudy" TEXT,
ADD COLUMN     "graduationYear" INTEGER,
ADD COLUMN     "industry" TEXT,
ADD COLUMN     "institution" TEXT,
ADD COLUMN     "interests" JSONB,
ADD COLUMN     "internalNotes" TEXT,
ADD COLUMN     "isPublic" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "lastActiveAt" TIMESTAMP(3),
ADD COLUMN     "lastEmailOpened" TIMESTAMP(3),
ADD COLUMN     "lastEmailSent" TIMESTAMP(3),
ADD COLUMN     "leadScore" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "leadStatus" TEXT,
ADD COLUMN     "learningGoal" TEXT,
ADD COLUMN     "learningStyle" TEXT,
ADD COLUMN     "level" INTEGER NOT NULL DEFAULT 1,
ADD COLUMN     "longestStreak" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "motivations" JSONB,
ADD COLUMN     "onboardingCompleted" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "onboardingStep" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "points" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "referralCode" TEXT,
ADD COLUMN     "segment" TEXT,
ADD COLUMN     "showCertificates" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "showEmail" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "showProgress" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "skills" JSONB,
ADD COLUMN     "streak" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "studyTime" TEXT,
ADD COLUMN     "tags" JSONB,
ADD COLUMN     "targetRole" TEXT,
ADD COLUMN     "timezone" TEXT,
ADD COLUMN     "totalLearningHours" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "utmCampaign" TEXT,
ADD COLUMN     "utmMedium" TEXT,
ADD COLUMN     "utmSource" TEXT,
ADD COLUMN     "weeklyHours" INTEGER,
ADD COLUMN     "workExperience" JSONB,
ADD COLUMN     "yearsExperience" INTEGER;

-- Step 2: Migrate existing data from old fields to new fields
-- Migrate occupation → currentRole
UPDATE "auth.user_profiles"
SET "currentRole" = "occupation"
WHERE "occupation" IS NOT NULL;

-- Migrate company → currentCompany
UPDATE "auth.user_profiles"
SET "currentCompany" = "company"
WHERE "company" IS NOT NULL;

-- Migrate social links to socials JSON
UPDATE "auth.user_profiles"
SET "socials" = jsonb_build_object(
  'github', CASE 
    WHEN "githubUrl" IS NOT NULL 
    THEN regexp_replace("githubUrl", '^https?://(www\.)?github\.com/', '') 
  END,
  'linkedin', CASE 
    WHEN "linkedinUrl" IS NOT NULL 
    THEN regexp_replace("linkedinUrl", '^https?://(www\.)?linkedin\.com/in/', '') 
  END,
  'twitter', CASE 
    WHEN "twitterUrl" IS NOT NULL 
    THEN regexp_replace("twitterUrl", '^https?://(www\.)?twitter\.com/', '') 
  END
)
WHERE "githubUrl" IS NOT NULL OR "linkedinUrl" IS NOT NULL OR "twitterUrl" IS NOT NULL;

-- Step 3: Drop old columns
ALTER TABLE "auth.user_profiles" 
DROP COLUMN "address",
DROP COLUMN "company",
DROP COLUMN "githubUrl",
DROP COLUMN "linkedinUrl",
DROP COLUMN "occupation",
DROP COLUMN "twitterUrl";

-- CreateIndex
CREATE INDEX "auth.user_profiles_isPublic_idx" ON "auth.user_profiles"("isPublic");

-- CreateIndex
CREATE INDEX "auth.user_profiles_educationLevel_idx" ON "auth.user_profiles"("educationLevel");

-- CreateIndex
CREATE INDEX "auth.user_profiles_fieldOfStudy_idx" ON "auth.user_profiles"("fieldOfStudy");

-- CreateIndex
CREATE INDEX "auth.user_profiles_currentRole_idx" ON "auth.user_profiles"("currentRole");

-- CreateIndex
CREATE INDEX "auth.user_profiles_industry_idx" ON "auth.user_profiles"("industry");

-- CreateIndex
CREATE INDEX "auth.user_profiles_learningGoal_idx" ON "auth.user_profiles"("learningGoal");

-- CreateIndex
CREATE INDEX "auth.user_profiles_leadStatus_idx" ON "auth.user_profiles"("leadStatus");

-- CreateIndex
CREATE INDEX "auth.user_profiles_segment_idx" ON "auth.user_profiles"("segment");

-- CreateIndex
CREATE INDEX "auth.user_profiles_lastActiveAt_idx" ON "auth.user_profiles"("lastActiveAt");

-- CreateIndex
CREATE INDEX "auth.user_profiles_onboardingCompleted_idx" ON "auth.user_profiles"("onboardingCompleted");

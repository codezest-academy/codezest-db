/*
  Warnings:

  - You are about to drop the column `name` on the `auth.users` table. All the data in the column will be lost.
  - Added the required column `firstName` to the `auth.users` table without a default value. This is not possible if the table is not empty.
  - Added the required column `lastName` to the `auth.users` table without a default value. This is not possible if the table is not empty.

*/

-- Step 1: Add new columns as nullable
ALTER TABLE "auth.users" ADD COLUMN "firstName" TEXT;
ALTER TABLE "auth.users" ADD COLUMN "lastName" TEXT;
ALTER TABLE "auth.users" ADD COLUMN "userName" TEXT;

-- Step 2: Migrate existing name data
-- Split name into firstName and lastName
UPDATE "auth.users" 
SET 
  "firstName" = CASE 
    WHEN position(' ' in name) > 0 THEN split_part(name, ' ', 1)
    ELSE name
  END,
  "lastName" = CASE 
    WHEN position(' ' in name) > 0 THEN substring(name from position(' ' in name) + 1)
    ELSE ''
  END
WHERE "firstName" IS NULL;

-- Step 3: Make firstName and lastName NOT NULL
ALTER TABLE "auth.users" ALTER COLUMN "firstName" SET NOT NULL;
ALTER TABLE "auth.users" ALTER COLUMN "lastName" SET NOT NULL;

-- Step 4: Drop old name column
ALTER TABLE "auth.users" DROP COLUMN "name";

-- CreateTable
CREATE TABLE "auth.email_changes" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "oldEmail" TEXT NOT NULL,
    "newEmail" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "verified" BOOLEAN NOT NULL DEFAULT false,
    "expiresAt" TIMESTAMP(3) NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth.email_changes_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "auth.login_history" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "success" BOOLEAN NOT NULL,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "location" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "auth.login_history_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "auth.email_changes_token_key" ON "auth.email_changes"("token");

-- CreateIndex
CREATE INDEX "auth.email_changes_userId_idx" ON "auth.email_changes"("userId");

-- CreateIndex
CREATE INDEX "auth.email_changes_token_idx" ON "auth.email_changes"("token");

-- CreateIndex
CREATE INDEX "auth.email_changes_expiresAt_idx" ON "auth.email_changes"("expiresAt");

-- CreateIndex
CREATE INDEX "auth.login_history_userId_idx" ON "auth.login_history"("userId");

-- CreateIndex
CREATE INDEX "auth.login_history_createdAt_idx" ON "auth.login_history"("createdAt");

-- AddForeignKey
ALTER TABLE "auth.email_changes" ADD CONSTRAINT "auth.email_changes_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "auth.login_history" ADD CONSTRAINT "auth.login_history_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

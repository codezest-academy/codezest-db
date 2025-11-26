/*
  Warnings:

  - A unique constraint covering the columns `[username]` on the table `auth.users` will be added. If there are existing duplicate values, this will fail.

*/
-- AlterTable
ALTER TABLE "auth.password_resets" ADD COLUMN     "ipAddress" TEXT,
ADD COLUMN     "userAgent" TEXT;

-- AlterTable
ALTER TABLE "auth.sessions" ADD COLUMN     "revokedAt" TIMESTAMP(3);

-- AlterTable
ALTER TABLE "auth.users" ADD COLUMN     "backupCodes" TEXT[],
ADD COLUMN     "emailNotifications" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "isActive" BOOLEAN NOT NULL DEFAULT true,
ADD COLUMN     "isSuspended" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "lastLoginAt" TIMESTAMP(3),
ADD COLUMN     "lastLoginIp" TEXT,
ADD COLUMN     "lockedUntil" TIMESTAMP(3),
ADD COLUMN     "loginAttempts" INTEGER NOT NULL DEFAULT 0,
ADD COLUMN     "marketingEmails" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "mustChangePassword" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "passwordChangedAt" TIMESTAMP(3),
ADD COLUMN     "suspendedAt" TIMESTAMP(3),
ADD COLUMN     "suspendedReason" TEXT,
ADD COLUMN     "twoFactorEnabled" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "twoFactorSecret" TEXT,
ADD COLUMN     "username" TEXT;

-- CreateIndex
CREATE INDEX "auth.password_resets_expiresAt_idx" ON "auth.password_resets"("expiresAt");

-- CreateIndex
CREATE INDEX "auth.sessions_revokedAt_idx" ON "auth.sessions"("revokedAt");

-- CreateIndex
CREATE UNIQUE INDEX "auth.users_username_key" ON "auth.users"("username");

-- CreateIndex
CREATE INDEX "auth.users_isActive_idx" ON "auth.users"("isActive");

-- CreateIndex
CREATE INDEX "auth.users_isSuspended_idx" ON "auth.users"("isSuspended");

-- CreateIndex
CREATE INDEX "auth.users_twoFactorEnabled_idx" ON "auth.users"("twoFactorEnabled");

-- CreateIndex
CREATE INDEX "auth.users_username_idx" ON "auth.users"("username");

-- CreateIndex
CREATE INDEX "auth.users_emailNotifications_idx" ON "auth.users"("emailNotifications");

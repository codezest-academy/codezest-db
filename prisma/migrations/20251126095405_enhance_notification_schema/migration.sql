/*
  Warnings:

  - You are about to drop the column `metadata` on the `notifications.notifications` table. All the data in the column will be lost.
  - You are about to drop the column `read` on the `notifications.notifications` table. All the data in the column will be lost.
  - You are about to drop the column `type` on the `notifications.notifications` table. All the data in the column will be lost.
  - You are about to drop the `notifications.notification_preferences` table. If the table is not empty, all the data it contains will be lost.
  - Added the required column `typeId` to the `notifications.notifications` table without a default value. This is not possible if the table is not empty.

*/
-- DropIndex
DROP INDEX "notifications.notifications_read_idx";

-- AlterTable
ALTER TABLE "notifications.notifications" DROP COLUMN "metadata",
DROP COLUMN "read",
DROP COLUMN "type",
ADD COLUMN     "actionUrl" TEXT,
ADD COLUMN     "data" JSONB,
ADD COLUMN     "expiresAt" TIMESTAMP(3),
ADD COLUMN     "isRead" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "isSeen" BOOLEAN NOT NULL DEFAULT false,
ADD COLUMN     "typeId" TEXT NOT NULL;

-- DropTable
DROP TABLE "notifications.notification_preferences";

-- CreateTable
CREATE TABLE "notifications.notification_types" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "slug" TEXT NOT NULL,
    "category" TEXT NOT NULL,
    "description" TEXT,
    "emailEnabled" BOOLEAN NOT NULL DEFAULT true,
    "pushEnabled" BOOLEAN NOT NULL DEFAULT true,
    "smsEnabled" BOOLEAN NOT NULL DEFAULT false,
    "inAppEnabled" BOOLEAN NOT NULL DEFAULT true,
    "emailTemplateId" TEXT,
    "pushTemplateId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications.notification_types_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications.user_settings" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "typeId" TEXT NOT NULL,
    "email" BOOLEAN,
    "push" BOOLEAN,
    "sms" BOOLEAN,
    "inApp" BOOLEAN,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications.user_settings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "notifications.user_devices" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "token" TEXT NOT NULL,
    "platform" TEXT NOT NULL,
    "model" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "lastUsedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "notifications.user_devices_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "notifications.notification_types_name_key" ON "notifications.notification_types"("name");

-- CreateIndex
CREATE UNIQUE INDEX "notifications.notification_types_slug_key" ON "notifications.notification_types"("slug");

-- CreateIndex
CREATE UNIQUE INDEX "notifications.user_settings_userId_typeId_key" ON "notifications.user_settings"("userId", "typeId");

-- CreateIndex
CREATE UNIQUE INDEX "notifications.user_devices_token_key" ON "notifications.user_devices"("token");

-- CreateIndex
CREATE INDEX "notifications.user_devices_userId_idx" ON "notifications.user_devices"("userId");

-- CreateIndex
CREATE INDEX "notifications.notifications_isRead_idx" ON "notifications.notifications"("isRead");

-- AddForeignKey
ALTER TABLE "notifications.user_settings" ADD CONSTRAINT "notifications.user_settings_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications.user_settings" ADD CONSTRAINT "notifications.user_settings_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "notifications.notification_types"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications.user_devices" ADD CONSTRAINT "notifications.user_devices_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "notifications.notifications" ADD CONSTRAINT "notifications.notifications_typeId_fkey" FOREIGN KEY ("typeId") REFERENCES "notifications.notification_types"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

/*
  Warnings:

  - The `role` column on the `auth.users` table would be dropped and recreated. This will lead to data loss if there is data in the column.

*/
-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('USER', 'ADMIN');

-- AlterTable
ALTER TABLE "auth.user_profiles" ADD COLUMN     "address" TEXT,
ADD COLUMN     "company" TEXT,
ADD COLUMN     "occupation" TEXT,
ADD COLUMN     "phone" TEXT,
ADD COLUMN     "socials" JSONB;

-- AlterTable
ALTER TABLE "auth.users" DROP COLUMN "role",
ADD COLUMN     "role" "UserRole" NOT NULL DEFAULT 'USER';

-- DropEnum
DROP TYPE "Role";

-- CreateIndex
CREATE INDEX "auth.users_role_idx" ON "auth.users"("role");

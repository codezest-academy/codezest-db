-- AlterTable
ALTER TABLE "learning.assignments" ADD COLUMN     "estimatedDuration" INTEGER;

-- AlterTable
ALTER TABLE "learning.mcq_quizzes" ADD COLUMN     "estimatedDuration" INTEGER;

-- AlterTable
ALTER TABLE "learning.modules" ADD COLUMN     "estimatedDuration" INTEGER;

-- CreateTable
CREATE TABLE "learning.certificates" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "languageId" TEXT,
    "moduleId" TEXT,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "certificateUrl" TEXT,
    "credentialId" TEXT NOT NULL,
    "isVerified" BOOLEAN NOT NULL DEFAULT false,
    "verifiedBy" TEXT,
    "score" INTEGER,
    "grade" TEXT,
    "issuedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "expiresAt" TIMESTAMP(3),

    CONSTRAINT "learning.certificates_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "_ModulePrerequisites" (
    "A" TEXT NOT NULL,
    "B" TEXT NOT NULL
);

-- CreateIndex
CREATE UNIQUE INDEX "learning.certificates_credentialId_key" ON "learning.certificates"("credentialId");

-- CreateIndex
CREATE INDEX "learning.certificates_userId_idx" ON "learning.certificates"("userId");

-- CreateIndex
CREATE INDEX "learning.certificates_credentialId_idx" ON "learning.certificates"("credentialId");

-- CreateIndex
CREATE INDEX "learning.certificates_languageId_idx" ON "learning.certificates"("languageId");

-- CreateIndex
CREATE INDEX "learning.certificates_moduleId_idx" ON "learning.certificates"("moduleId");

-- CreateIndex
CREATE INDEX "learning.certificates_type_idx" ON "learning.certificates"("type");

-- CreateIndex
CREATE UNIQUE INDEX "_ModulePrerequisites_AB_unique" ON "_ModulePrerequisites"("A", "B");

-- CreateIndex
CREATE INDEX "_ModulePrerequisites_B_index" ON "_ModulePrerequisites"("B");

-- AddForeignKey
ALTER TABLE "learning.certificates" ADD CONSTRAINT "learning.certificates_userId_fkey" FOREIGN KEY ("userId") REFERENCES "auth.users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.certificates" ADD CONSTRAINT "learning.certificates_languageId_fkey" FOREIGN KEY ("languageId") REFERENCES "learning.programming_languages"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "learning.certificates" ADD CONSTRAINT "learning.certificates_moduleId_fkey" FOREIGN KEY ("moduleId") REFERENCES "learning.modules"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ModulePrerequisites" ADD CONSTRAINT "_ModulePrerequisites_A_fkey" FOREIGN KEY ("A") REFERENCES "learning.modules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "_ModulePrerequisites" ADD CONSTRAINT "_ModulePrerequisites_B_fkey" FOREIGN KEY ("B") REFERENCES "learning.modules"("id") ON DELETE CASCADE ON UPDATE CASCADE;

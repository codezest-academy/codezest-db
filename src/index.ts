/**
 * @codezest/db - Main Entry Point
 * 
 * Single source of truth for CodeZest database access.
 * Exports PrismaClient singleton and all generated types.
 * 
 * Usage:
 * ```typescript
 * import { prisma, User, Role } from '@codezest/db'
 * 
 * const users = await prisma.user.findMany({
 *   where: { role: Role.STUDENT }
 * })
 * ```
 */

import { PrismaClient } from '@prisma/client'

// ============================================================================
// PRISMA CLIENT SINGLETON
// ============================================================================
// Following Singleton pattern to prevent connection pool exhaustion
// https://www.prisma.io/docs/guides/performance-and-optimization/connection-management

const globalForPrisma = globalThis as unknown as {
  prisma: PrismaClient | undefined
}

export const prisma =
  globalForPrisma.prisma ??
  new PrismaClient({
    log:
      process.env.NODE_ENV === 'development'
        ? ['query', 'info', 'warn', 'error']
        : ['error'],
  })

if (process.env.NODE_ENV !== 'production') {
  globalForPrisma.prisma = prisma
}

// ============================================================================
// RE-EXPORT ALL PRISMA TYPES
// ============================================================================
// This allows consuming services to import types directly from @codezest/db

export * from '@prisma/client'

// ============================================================================
// RE-EXPORT ALL PRISMA TYPES
// ============================================================================
// This allows consuming services to import types directly from @codezest/db
// Example: import { User, Role, Prisma } from '@codezest/db'

export * from '@prisma/client'

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/**
 * Gracefully disconnect from database
 * Call this on application shutdown
 */
export async function disconnect(): Promise<void> {
  await prisma.$disconnect()
}

/**
 * Connect to database explicitly
 * Prisma connects automatically on first query, but this can be used for health checks
 */
export async function connect(): Promise<void> {
  await prisma.$connect()
}

/**
 * Check database connection health
 */
export async function healthCheck(): Promise<boolean> {
  try {
    await prisma.$queryRaw`SELECT 1`
    return true
  } catch (error) {
    console.error('Database health check failed:', error)
    return false
  }
}

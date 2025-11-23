/**
 * @codezest/db - Custom TypeScript Types
 *
 * Additional type definitions, utility types, and type guards
 * for better type safety across consuming services.
 */

// ============================================================================
// UTILITY TYPES
// ============================================================================

/**
 * Make specific fields optional
 */
export type PartialBy<T, K extends keyof T> = Omit<T, K> & Partial<Pick<T, K>>;

/**
 * Make specific fields required
 */
export type RequiredBy<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

/**
 * Extract non-nullable fields
 */
export type NonNullableFields<T> = {
  [P in keyof T]: NonNullable<T[P]>;
};

// ============================================================================
// PRISMA PAYLOAD TYPES
// ============================================================================
// Note: These types will be available after running migrations
// They use Prisma's GetPayload utility for type-safe includes

/**
 * Example usage (uncomment after migration):
 *
 * import type { Prisma } from '@prisma/client'
 *
 * export type UserWithProfile = Prisma.UserGetPayload<{
 *   include: { profile: true }
 * }>
 */

// ============================================================================
// CUSTOM TYPES FOR BUSINESS LOGIC
// ============================================================================
// Uncomment these after running your first migration
// These types use Prisma's GetPayload utility for type-safe includes

/*
export type UserWithProfile = Prisma.UserGetPayload<{
  include: { profile: true }
}>

export type ModuleWithContent = Prisma.ModuleGetPayload<{
  include: {
    materials: true
    assignments: true
    mcqQuizzes: {
      include: {
        questions: {
          include: {
            options: true
          }
        }
      }
    }
  }
}>

export type SubmissionWithAnalysis = Prisma.AssignmentSubmissionGetPayload<{
  include: {
    assignment: true
    analysis: true
  }
}>

export type AttemptWithDetails = Prisma.MCQAttemptGetPayload<{
  include: {
    quiz: true
    answers: {
      include: {
        question: true
        selectedOption: true
      }
    }
    analysis: true
  }
}>

export type SubscriptionWithHistory = Prisma.SubscriptionGetPayload<{
  include: {
    transactions: true
    invoices: true
  }
}>
*/

// ============================================================================
// TYPE GUARDS
// ============================================================================

/**
 * Check if user has a specific role
 */
export function hasRole(user: { role: string }, role: string): boolean {
  return user.role === role;
}

/**
 * Check if user is admin
 */
export function isAdmin(user: { role: string }): boolean {
  return user.role === 'ADMIN';
}

/**
 * Check if user is a regular user
 */
export function isUser(user: { role: string }): boolean {
  return user.role === 'USER';
}

/**
 * Check if subscription is active
 */
export function isSubscriptionActive(subscription: { status: string }): boolean {
  return subscription.status === 'ACTIVE';
}

/**
 * Check if submission passed
 */
export function submissionPassed(submission: { status: string }): boolean {
  return submission.status === 'PASSED';
}

// ============================================================================
// JSONB TYPE DEFINITIONS
// ============================================================================

/**
 * User preferences structure
 */
export interface UserPreferences {
  theme?: 'light' | 'dark' | 'system';
  language?: string;
  notifications?: {
    email?: boolean;
    push?: boolean;
    sms?: boolean;
  };
  timezone?: string;
}

/**
 * Code quality metrics structure
 */
export interface CodeQualityMetrics {
  readability: number; // 0-10
  efficiency: number; // 0-10
  bestPractices: number; // 0-10
  maintainability?: number; // 0-10
  documentation?: number; // 0-10
}

/**
 * Quiz performance breakdown
 */
export interface PerformanceBreakdown {
  [topic: string]: number; // Topic name -> score percentage
}

/**
 * Subscription metadata
 */
export interface SubscriptionMetadata {
  source?: string; // "web", "mobile", "admin"
  couponCode?: string;
  referralCode?: string;
  customFields?: Record<string, unknown>;
}

// ============================================================================
// PAGINATION TYPES
// ============================================================================

/**
 * Pagination parameters
 */
export interface PaginationParams {
  page?: number;
  limit?: number;
  cursor?: string;
}

/**
 * Paginated response
 */
export interface PaginatedResponse<T> {
  data: T[];
  pagination: {
    total: number;
    page: number;
    limit: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

// ============================================================================
// FILTER TYPES
// ============================================================================

/**
 * User filters
 */
export interface UserFilters {
  role?: string;
  emailVerified?: boolean;
  createdAfter?: Date;
  createdBefore?: Date;
}

/**
 * Module filters
 */
export interface ModuleFilters {
  languageId?: string;
  difficulty?: string;
}

/**
 * Assignment filters
 */
export interface AssignmentFilters {
  moduleId?: string;
  difficulty?: string;
  status?: string;
}

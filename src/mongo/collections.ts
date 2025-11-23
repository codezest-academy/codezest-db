/**
 * @codezest/db - MongoDB Collections
 *
 * Type-safe collection definitions for MongoDB
 */

import { logger } from '../common/logger';

// ============================================================================
// COLLECTION TYPES
// ============================================================================

/**
 * Activity log entry
 */
export interface ActivityLog {
  _id?: string;
  userId: string;
  action: string;
  resource?: string;
  resourceId?: string;
  metadata?: Record<string, unknown>;
  ipAddress?: string;
  userAgent?: string;
  timestamp: Date;
}

/**
 * Real-time analytics event
 */
export interface AnalyticsEventDoc {
  _id?: string;
  eventName: string;
  userId?: string;
  sessionId?: string;
  properties?: Record<string, unknown>;
  timestamp: Date;
}

/**
 * Cache entry
 */
export interface CacheEntry {
  _id?: string;
  key: string;
  value: unknown;
  expiresAt: Date;
  createdAt: Date;
}

/**
 * Session data (alternative to database sessions)
 */
export interface SessionData {
  _id?: string;
  sessionId: string;
  userId: string;
  data: Record<string, unknown>;
  expiresAt: Date;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Real-time notification queue
 */
export interface NotificationQueue {
  _id?: string;
  userId: string;
  type: string;
  payload: Record<string, unknown>;
  status: 'pending' | 'sent' | 'failed';
  attempts: number;
  createdAt: Date;
  sentAt?: Date;
}

// ============================================================================
// COLLECTION NAMES
// ============================================================================

export const COLLECTIONS = {
  ACTIVITY_LOGS: 'activity_logs',
  ANALYTICS_EVENTS: 'analytics_events',
  CACHE: 'cache',
  SESSIONS: 'sessions',
  NOTIFICATION_QUEUE: 'notification_queue',
} as const;

// ============================================================================
// COLLECTION HELPERS
// ============================================================================

/**
 * Get activity logs collection
 */
export async function getActivityLogsCollection() {
  const { mongo } = await import('./index');
  return mongo.collection<ActivityLog>(COLLECTIONS.ACTIVITY_LOGS);
}

/**
 * Get analytics events collection
 */
export async function getAnalyticsEventsCollection() {
  const { mongo } = await import('./index');
  return mongo.collection<AnalyticsEventDoc>(COLLECTIONS.ANALYTICS_EVENTS);
}

/**
 * Get cache collection
 */
export async function getCacheCollection() {
  const { mongo } = await import('./index');
  return mongo.collection<CacheEntry>(COLLECTIONS.CACHE);
}

/**
 * Get sessions collection
 */
export async function getSessionsCollection() {
  const { mongo } = await import('./index');
  return mongo.collection<SessionData>(COLLECTIONS.SESSIONS);
}

/**
 * Get notification queue collection
 */
export async function getNotificationQueueCollection() {
  const { mongo } = await import('./index');
  return mongo.collection<NotificationQueue>(COLLECTIONS.NOTIFICATION_QUEUE);
}

// ============================================================================
// INDEX CREATION
// ============================================================================

/**
 * Create indexes for all collections
 * Run this once during setup or deployment
 */
export async function createMongoIndexes(): Promise<void> {
  const { mongo } = await import('./index');

  // Activity logs indexes
  const activityLogs = await mongo.collection(COLLECTIONS.ACTIVITY_LOGS);
  await activityLogs.createIndex({ userId: 1, timestamp: -1 });
  await activityLogs.createIndex({ action: 1 });
  await activityLogs.createIndex({ timestamp: -1 });

  // Analytics events indexes
  const analyticsEvents = await mongo.collection(COLLECTIONS.ANALYTICS_EVENTS);
  await analyticsEvents.createIndex({ eventName: 1, timestamp: -1 });
  await analyticsEvents.createIndex({ userId: 1, timestamp: -1 });
  await analyticsEvents.createIndex({ timestamp: -1 });

  // Cache indexes
  const cache = await mongo.collection(COLLECTIONS.CACHE);
  await cache.createIndex({ key: 1 }, { unique: true });
  await cache.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index

  // Sessions indexes
  const sessions = await mongo.collection(COLLECTIONS.SESSIONS);
  await sessions.createIndex({ sessionId: 1 }, { unique: true });
  await sessions.createIndex({ userId: 1 });
  await sessions.createIndex({ expiresAt: 1 }, { expireAfterSeconds: 0 }); // TTL index

  // Notification queue indexes
  const notificationQueue = await mongo.collection(COLLECTIONS.NOTIFICATION_QUEUE);
  await notificationQueue.createIndex({ userId: 1, status: 1 });
  await notificationQueue.createIndex({ status: 1, createdAt: 1 });

  logger.info('MongoDB indexes created successfully');
}

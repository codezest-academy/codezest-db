/**
 * @codezest/db - MongoDB Client
 * 
 * Optional MongoDB integration for unstructured data:
 * - Activity logs
 * - Real-time analytics
 * - Caching layer
 * - Session storage
 * 
 * Usage:
 * ```typescript
 * import { mongo } from '@codezest/db/mongo'
 * 
 * const activityLogs = mongo.collection('activity_logs')
 * await activityLogs.insertOne({ userId, action, timestamp })
 * ```
 */

import { MongoClient, Db, Document } from 'mongodb'

// ============================================================================
// MONGODB CLIENT SINGLETON
// ============================================================================

const globalForMongo = globalThis as unknown as {
  mongoClient: MongoClient | undefined
  mongoDb: Db | undefined
}

let client: MongoClient | undefined = globalForMongo.mongoClient
let db: Db | undefined = globalForMongo.mongoDb

/**
 * Get MongoDB client instance
 * Connects automatically on first call
 */
export async function getMongoClient(): Promise<MongoClient> {
  if (!client) {
    const mongoUrl = process.env.MONGODB_URL
    
    if (!mongoUrl) {
      throw new Error('MONGODB_URL environment variable is not set')
    }
    
    client = new MongoClient(mongoUrl, {
      maxPoolSize: 10,
      minPoolSize: 2,
      serverSelectionTimeoutMS: 5000,
    })
    
    await client.connect()
    
    if (process.env.NODE_ENV !== 'production') {
      globalForMongo.mongoClient = client
    }
    
    console.log('MongoDB connected successfully')
  }
  
  return client
}

/**
 * Get MongoDB database instance
 * Database name defaults to 'codezest' or can be set via MONGODB_DATABASE env var
 */
export async function getMongoDB(): Promise<Db> {
  if (!db) {
    const mongoClient = await getMongoClient()
    const dbName = process.env.MONGODB_DATABASE || 'codezest'
    db = mongoClient.db(dbName)
    
    if (process.env.NODE_ENV !== 'production') {
      globalForMongo.mongoDb = db
    }
  }
  
  return db
}

/**
 * Convenience export - auto-connects on first use
 */
export const mongo = {
  get client() {
    return getMongoClient()
  },
  get db() {
    return getMongoDB()
  },
  async collection<T extends Document = Document>(name: string) {
    const database = await getMongoDB()
    return database.collection<T>(name)
  },
}

/**
 * Disconnect from MongoDB
 * Call this on application shutdown
 */
export async function disconnectMongo(): Promise<void> {
  if (client) {
    await client.close()
    client = undefined
    db = undefined
    globalForMongo.mongoClient = undefined
    globalForMongo.mongoDb = undefined
    console.log('MongoDB disconnected')
  }
}

/**
 * MongoDB health check
 */
export async function mongoHealthCheck(): Promise<boolean> {
  try {
    const mongoClient = await getMongoClient()
    await mongoClient.db('admin').command({ ping: 1 })
    return true
  } catch (error) {
    console.error('MongoDB health check failed:', error)
    return false
  }
}

# Implementation Plan: CodeZest Microservices Architecture

## Goal Description

Implement a robust, scalable microservices architecture for the CodeZest learning platform, adhering to SOLID principles and Clean Architecture. This plan breaks down the development into logical phases to ensure stability and efficient delivery.

## User Review Required

> [!IMPORTANT] > **Database Strategy**: We are proceeding with a **Shared Schema Library** (`codezest-db`) approach. This simplifies type sharing but requires strict discipline to avoid tight coupling.
> **Communication**: We are using **Redis Pub/Sub** (via `codezest-cache` or a new lib) for event-driven communication initially. RabbitMQ can be introduced later if durability requirements increase.

## Proposed Changes

### Phase 1: Foundation & Shared Infrastructure

Establish the core libraries that all services will depend on.

#### [codezest-db]

- [ ] Finalize Prisma Schema (Auth, Learning, Payments models).
- [ ] Generate and publish TypeScript client.
- [ ] Implement database migration scripts.

#### [codezest-cache]

- [ ] Implement Redis client wrapper.
- [ ] Add Pub/Sub utility classes for event bus.

### Phase 2: Core Identity & Learning Services

Build the essential backend services required for the platform to function.

#### [codezest-auth]

- [ ] Implement Clean Architecture layers (Domain, Data, API).
- [ ] Setup Authentication (JWT/Session).
- [ ] Integrate `codezest-db` and `codezest-cache`.
- [ ] Publish `UserCreated` events.

#### [codezest-api] (Learning Service)

- [ ] Implement Course/Module management APIs.
- [ ] Implement Assignment submission logic.
- [ ] Consume `UserCreated` events to initialize user progress.

### Phase 3: Support Services & Monetization

Add billing, notifications, and analytics.

#### [codezest-payments]

- [ ] Integrate Stripe SDK.
- [ ] Implement Webhook handlers.
- [ ] Publish `PaymentSucceeded` events.

#### [codezest-notifications]

- [ ] Setup Email provider (SendGrid/AWS SES).
- [ ] Listen for `UserCreated`, `PaymentSucceeded` events.

#### [codezest-activity]

- [ ] Implement Activity Feed API.
- [ ] Listen for all domain events to log activity.

### Phase 4: Frontend Integration

Connect the user interfaces to the backend services.

#### [codezest-web]

- [ ] Integrate Auth flows.
- [ ] Connect to Learning APIs.

#### [codezest-admin]

- [ ] Build dashboards for content management and user oversight.

## Verification Plan

### Automated Tests

- **Unit Tests**: Jest for domain logic in each service.
- **Integration Tests**: Supertest for API endpoints, using a test database.
- **Contract Tests**: Ensure services adhere to agreed API schemas.

### Manual Verification

- **End-to-End Flow**:
  1.  Register a new user (Auth).
  2.  Verify "Welcome" email received (Notifications).
  3.  Purchase a subscription (Payments).
  4.  Verify access to Pro content (API).
  5.  Check Activity Feed for "Upgraded to Pro" (Activity).

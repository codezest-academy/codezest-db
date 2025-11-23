# CodeZest Payments Service Architecture

## 1. Overview

The `codezest-payments` service is the centralized financial engine of the CodeZest platform. It is responsible for all monetary transactions, subscription lifecycle management, and coupon/discount logic.

> **Decision**: There is NO separate `subscriptions` repository. All subscription logic is encapsulated within this service to ensure strong consistency between payments and access rights.

---

## 2. Core Responsibilities

1.  **Payment Processing**: Securely handling charges via Stripe (and potentially PayPal).
2.  **Subscription Management**: Creating, updating, canceling, and renewing user subscriptions.
3.  **Coupon & Discount Logic**: Validating and applying promo codes.
4.  **Invoicing**: Generating and storing transaction records.
5.  **Webhooks**: Listening to gateway events to update local state.

---

## 3. Architecture Layers (Clean Architecture)

The service follows the standard project structure:

### 3.1 Domain Layer (`src/domain`)

_Pure business logic. No dependencies on frameworks or DB._

- **Entities** (`src/domain/entities`):
  - `Subscription`: Rules for state transitions.
  - `Plan`: Definitions of tiers.
  - `Coupon`: Rules for discount validity.
- **Interfaces** (`src/domain/repositories`):
  - `PaymentGatewayInterface`: Abstract contract for charging cards.
  - `SubscriptionRepositoryInterface`: Abstract contract for saving state.

### 3.2 Application Layer (`src/application`)

_Orchestrates domain objects to perform tasks._

- **Services** (`src/application/services`):
  - `CheckoutService`: Handles `createCheckoutSession`.
  - `WebhookService`: Handles `handlePaymentSuccess`.
  - `SubscriptionService`: Handles `cancelSubscription`.
- **DTOs** (`src/application/dtos`):
  - `CreateCheckoutSessionDto`
  - `WebhookEventDto`

### 3.3 Infrastructure Layer (`src/infrastructure`)

_External tools and implementations._

- **Database** (`src/infrastructure/database`): `PrismaService` singleton.
- **Repositories** (`src/infrastructure/repositories`): Concrete `SubscriptionRepository` implementing `SubscriptionRepositoryInterface`.
- **External** (`src/infrastructure/external`): `StripePaymentGateway` implementing `PaymentGatewayInterface`.

### 3.4 Presentation Layer (`src/presentation`)

_Entry points._

- **Controllers** (`src/presentation/controllers`): `PaymentController`, `WebhookController`.
- **Routes** (`src/presentation/routes`): Define endpoints like `POST /checkout/session`.

---

## 4. Data Model (Prisma)

This schema lives in `codezest-db` but is primarily managed by this service.

```prisma
// Managed by codezest-payments

model Subscription {
  id              String   @id @default(uuid())
  userId          String   @unique

  plan            SubscriptionPlan @default(FREE) // ENUM: FREE, PRO, TEAM
  status          SubscriptionStatus // ENUM: ACTIVE, CANCELED, PAST_DUE

  // Billing Cycle
  currentPeriodStart DateTime
  currentPeriodEnd   DateTime

  // Stripe Mapping
  stripeCustomerId     String? @unique
  stripeSubscriptionId String? @unique

  createdAt       DateTime @default(now())
  updatedAt       DateTime @updatedAt
}

model Coupon {
  id              String   @id @default(uuid())
  code            String   @unique // "SAVE20"
  stripeCouponId  String   // "co_123"

  discountType    DiscountType // PERCENTAGE, FIXED
  value           Int      // 20 or 1000 ($10)

  isActive        Boolean  @default(true)
  maxRedemptions  Int?
  redemptionCount Int      @default(0)
}

model CouponRedemption {
  id        String   @id @default(uuid())
  userId    String
  couponId  String
  coupon    Coupon   @relation(fields: [couponId], references: [id])
  timestamp DateTime @default(now())
}
```

---

## 5. Key Workflows

### 5.1 Purchasing a Subscription (with Coupon)

1.  **Client**: User selects "Pro Plan" and enters code "LEARN2025".
2.  **API**: `POST /checkout/session`
    - Service validates coupon "LEARN2025".
    - Service calls `Stripe.checkout.sessions.create` with:
      - `customer`: `stripeCustomerId`
      - `line_items`: Pro Plan Price
      - `discounts`: `[{ coupon: stripeCouponId }]`
3.  **Response**: Return `sessionId` to client.
4.  **Client**: Redirects to Stripe Hosted Checkout.

### 5.2 Handling Success (Webhook)

1.  **Stripe**: Sends `checkout.session.completed` webhook.
2.  **Service**:
    - Verifies webhook signature.
    - Extracts `userId` (from metadata) and `subscriptionId`.
    - **Transaction**:
      - Updates `Subscription` status to `ACTIVE`.
      - Records `CouponRedemption` (if coupon was used).
      - Creates `Transaction` record (invoice).
    - Publishes `PaymentSucceeded` event.

### 5.3 Subscription Renewal

1.  **Stripe**: Automatically charges card at end of period.
2.  **Stripe**: Sends `invoice.payment_succeeded`.
3.  **Service**:
    - Updates `Subscription.currentPeriodEnd`.
    - Creates new `Transaction` record.

---

## 6. Coupon Management Strategy

### 6.1 "Stripe-First" Logic

We mirror Stripe's coupon system to avoid calculation errors.

- **Creation**: Admin creates coupon in Stripe Dashboard -> Webhook syncs to our DB.
- **Validation**:
  - **Fast**: Check local DB for existence and `isActive`.
  - **Deep**: Check `redemptionCount` vs `maxRedemptions`.
- **Application**: We pass the _Stripe Coupon ID_ to the checkout session, letting Stripe handle the final math.

### 6.2 Anti-Abuse

- **One-per-user**: Check `CouponRedemption` table before allowing a code.
- **First-time only**: Check if user has _ever_ had a paid subscription before applying "New User" coupons.

---

## 7. Integration Events

**Published Events:**

- `Payment.Succeeded` -> `auth` (Update Role), `notifications` (Send Receipt).
- `Payment.Failed` -> `notifications` (Send "Update Card" email).
- `Subscription.Canceled` -> `auth` (Downgrade Role at period end).

**Consumed Events:**

- `User.Created` -> Create Stripe Customer ID (optional, can be done lazily at checkout).

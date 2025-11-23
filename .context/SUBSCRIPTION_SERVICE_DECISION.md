# Architecture Decision: Merging Subscription Logic into Payments Service

## 1. Context and Problem Statement

We need to decide whether to implement a dedicated `codezest-subscriptions` microservice or to bundle subscription management logic within the `codezest-payments` service.

## 2. Decision

We will **NOT** create a separate running service for subscriptions, and we will **DELETE** the `codezest-subscriptions` repository.

All subscription logic, including plan definitions, state management, and coupon logic, will be implemented directly within the **`codezest-payments`** service.

## 3. Detailed Reasoning

### 3.1 High Coupling with Payments

Subscription logic (start date, end date, status) is inextricably linked to Payment logic (successful charge, failed card, refund).

- **Scenario**: A recurring payment webhook arrives from Stripe.
- **Separate Services Risk**: `payments` receives the webhook -> synchronously calls `subscriptions` to extend validity. If this network call fails, we risk data inconsistency (User paid, but subscription didn't update).
- **Merged Service Benefit**: We can update the `Transaction` record and the `Subscription` record in a single database transaction (or strictly coupled logic), ensuring data integrity.

### 3.2 Domain Boundaries

The `codezest-payments` service effectively functions as the **"Billing & Monetization"** domain. Splitting "charging money" from "what you get for the money" creates unnecessary friction in a system of this size.

### 3.3 Complexity vs. Value

A separate subscription service is typically only required when:

- Subscriptions are managed completely outside of payments (e.g., Enterprise contracts negotiated manually).
- There is a complex multi-tenant hierarchy independent of billing.

For CodeZest, the subscription lifecycle is driven almost entirely by payment events (Stripe Webhooks), making a unified service the most robust and simple architectural choice.

## 4. Implementation Strategy

- **Service**: `codezest-payments` handles all Stripe/PayPal interactions AND manages the `Subscription` database tables.
- **Cleanup**: The `codezest-subscriptions` repository will be archived or deleted.

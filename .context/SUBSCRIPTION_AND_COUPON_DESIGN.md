# Subscription & Coupon System Design

## 1. EdTech Subscription Strategy

For an EdTech platform like CodeZest, the subscription model should balance accessibility (to grow the user base) with monetization (to sustain the business).

### 1.1 Recommended Tiers

| Tier              | Target Audience     | Features                                                                                                                                   | Pricing Model                             |
| ----------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------ | ----------------------------------------- |
| **Free / Basic**  | Students exploring  | - Access to "Basics" modules<br>- Limited daily quizzes<br>- Community support                                                             | **$0 / month**                            |
| **Pro / Learner** | Serious students    | - **Unlimited** access to all modules<br>- **Certificates** of completion<br>- **AI Code Analysis** (Costly feature)<br>- Priority support | **$15/mo** or **$150/yr** (2 months free) |
| **Team / Class**  | Schools & Bootcamps | - Bulk seat management<br>- Instructor dashboard<br>- Progress reporting                                                                   | **Per Seat** (e.g., $10/student/mo)       |

### 1.2 "Seat" vs "Site" Licensing

For the **Team** plan, use a **Seat-based** model.

- An admin buys X seats.
- They generate "Invite Links" or upload CSV emails.
- This logic lives in `codezest-payments` (billing) and `codezest-auth` (access control).

---

## 2. Coupon System Architecture

A robust coupon system drives marketing campaigns (e.g., "Back to School Sale", "Black Friday").

### 2.1 Best Practice: "Stripe-First" Logic

Instead of building a custom coupon engine that calculates math (which is error-prone), **mirror Stripe's Coupon & Promotion Code system**.

1.  **Create Coupon in Stripe**: Define logic (ID: `BLACKFRIDAY50`, 50% off, Duration: Once).
2.  **Sync to DB (Optional)**: You can cache valid codes in your DB for faster validation UI, OR just validate directly against Stripe API when the user types it.
3.  **Apply at Checkout**: Pass the `promotion_code` ID to the Stripe Checkout Session.

### 2.2 Coupon Types & Use Cases

| Coupon Type         | Use Case               | Configuration                                                              |
| ------------------- | ---------------------- | -------------------------------------------------------------------------- |
| **Launch Discount** | Early adopters         | **Type**: Percentage (50% off)<br>**Duration**: Forever (Grandfathering)   |
| **Seasonal Sale**   | Black Friday           | **Type**: Percentage (30% off)<br>**Duration**: First 3 months (Recurring) |
| **Referral Bonus**  | User invites friend    | **Type**: Fixed Amount ($10 off)<br>**Duration**: Once                     |
| **B2B Custom Deal** | University partnership | **Type**: 100% off (Free access)<br>**Duration**: 1 Year                   |

### 2.3 Coupon Data Model (Prisma)

Even if Stripe handles the math, you need to track _who_ used _what_ for analytics.

```prisma
// In codezest-payments service

model Coupon {
  id              String   @id @default(uuid())
  code            String   @unique // "SAVE20"
  stripeCouponId  String   // "co_123xyz"

  discountType    DiscountType // PERCENTAGE, FIXED
  discountValue   Int      // 20 (for 20%) or 1000 (for $10.00)

  validFrom       DateTime
  validUntil      DateTime?
  maxRedemptions  Int?
  redemptionCount Int      @default(0)

  isActive        Boolean  @default(true)

  redemptions     CouponRedemption[]
}

model CouponRedemption {
  id        String   @id @default(uuid())
  userId    String
  couponId  String
  coupon    Coupon   @relation(fields: [couponId], references: [id])

  redeemedAt DateTime @default(now())

  // Link to the transaction where it was used
  transactionId String
}
```

---

## 3. Implementation Workflow

### 3.1 Applying a Coupon (Frontend -> Backend)

1.  **User Input**: User types `LEARN2025` in the checkout modal.
2.  **Validation API**: Frontend calls `GET /api/payments/coupons/validate?code=LEARN2025`.
    - Backend checks DB: Is it active? Is `redemptionCount < maxRedemptions`? Has this user already used it (if one-per-user)?
    - _Optimization_: If valid in DB, optionally verify with Stripe API to ensure it's still valid there.
3.  **Response**: Return `{ valid: true, discount: "20% off", newPrice: $12.00 }`.
4.  **Checkout**: User clicks "Pay". Frontend sends `couponId` to `POST /create-checkout-session`.
5.  **Stripe Handoff**: Backend creates Stripe Session with `discounts: [{ coupon: stripeCouponId }]`.

### 3.2 Handling "Double Dipping"

- **Rule**: Prevent users from using a "First Month Free" coupon multiple times by cancelling and resubscribing.
- **Solution**:
  - Track `CouponRedemption` by `userId`.
  - If `coupon.limitPerUser` is 1, reject the validation request if a record exists.

---

## 4. Advanced Features (Phase 2)

### 4.1 Dynamic Coupons (Referrals)

- When User A invites User B, generate a unique code `REF-USERA-123`.
- When User B subscribes with this code, User A gets a credit.
- **Implementation**: Use Stripe "Promotion Codes" API to generate unique codes programmatically.

### 4.2 Geo-Pricing (Parity Purchasing Power)

- Automatically apply a coupon based on IP address.
- Example: Users in India get a 60% off "PPP" coupon automatically applied to the checkout session.
- **Logic**: Middleware in `codezest-payments` detects country -> looks up PPP discount -> applies coupon.

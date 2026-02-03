# GTM Tracking: Course Purchase Funnel

**Generated**: 2026-02-03
**Feature**: Course Marketplace
**Total Events**: 7
**Event Types**: 5 click-datalayer, 2 impression

---

## Executive Summary

This document provides production-ready GTM tracking implementation for the complete course purchase funnel in the EduStream Academy marketplace. The tracking covers the entire customer journey from initial course discovery through purchase completion, enabling accurate conversion funnel analysis, revenue attribution, and A/B testing capabilities.

**Key Tracking Points**:
- **Discovery**: Course page impressions with pricing data
- **Engagement**: Preview video interactions with watch duration
- **Intent**: Add-to-cart actions with cart value
- **Optimization**: Coupon application with discount tracking
- **Conversion**: Checkout initiation, payment submission, and purchase completion
- **Revenue Attribution**: Full e-commerce metadata including order value, payment method, and discount amounts

**Use Cases**:
- E-commerce funnel analysis with GA4 Enhanced Ecommerce
- Revenue forecasting and pricing optimization
- Coupon campaign effectiveness measurement
- Payment method preference analysis
- Abandoned cart recovery targeting
- Conversion rate optimization (CRO) experimentation

---

## Event 1: Course Viewed (Impression)

**Trigger**: Course detail page loads
**Type**: Impression (automatic event)
**Purpose**: Track product page views for funnel entry point

### Implementation

```javascript
// Fire on page load (React useEffect, Next.js getServerSideProps, etc.)
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "course-marketplace",
    item: "course-detail",
    params: {
      course_id: "course_abc123",           // string
      course_title: "web-development-101",  // string (kebab-case)
      instructor_id: "inst_456",            // string
      price: 49.99,                         // float (no quotes)
      currency: "USD",                      // string
      category: "web-development",          // string
      rating: 4.7,                          // float
      enrollment_count: 12453,              // int
      is_bestseller: true,                  // bool (no quotes)
      has_discount: false                   // bool
    }
  },
  _clear: true
});
```

**React Example**:
```jsx
// CourseDetailPage.tsx
useEffect(() => {
  if (course) {
    dataLayer.push({
      event: "al_tracker_impression",
      al: {
        feature: "course-marketplace",
        item: "course-detail",
        params: {
          course_id: course.id,
          course_title: slugify(course.title),
          instructor_id: course.instructor.id,
          price: course.price,
          currency: "USD",
          category: course.category,
          rating: course.averageRating,
          enrollment_count: course.enrollmentCount,
          is_bestseller: course.isBestseller,
          has_discount: !!course.discountPrice
        }
      },
      _clear: true
    });
  }
}, [course]);
```

---

## Event 2: Preview Watched (Click)

**Trigger**: User clicks preview video play button
**Type**: Click (user-initiated action)
**Purpose**: Track engagement with course content before purchase

### Implementation

```javascript
// Fire on preview video play button click
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "course-marketplace",
    item: "preview-video",
    action: "Click",
    params: {
      course_id: "course_abc123",        // string
      preview_duration_seconds: 120,     // int (total preview length)
      video_quality: "1080p",            // string
      autoplay: false                    // bool (did it autoplay or user clicked?)
    }
  },
  _clear: true
});
```

**React Example with Video Player**:
```jsx
// PreviewPlayer.tsx
const handlePlayClick = () => {
  dataLayer.push({
    event: "al_tracker_custom",
    al: {
      feature: "course-marketplace",
      item: "preview-video",
      action: "Click",
      params: {
        course_id: courseId,
        preview_duration_seconds: videoDuration,
        video_quality: selectedQuality,
        autoplay: false
      }
    },
    _clear: true
  });

  videoRef.current.play();
};
```

**Optional: Track Watch Completion**:
```javascript
// Fire when user watches preview to completion (>95%)
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "course-marketplace",
    item: "preview-completion",
    action: "View",
    params: {
      course_id: "course_abc123",
      watch_percentage: 98,              // int (0-100)
      time_to_completion_seconds: 115    // int (actual watch time)
    }
  },
  _clear: true
});
```

---

## Event 3: Add to Cart (Click)

**Trigger**: User clicks "Add to Cart" or "Buy Now" button
**Type**: Click (user-initiated action)
**Purpose**: Track purchase intent and cart value

### Implementation

```javascript
// Fire on add to cart button click
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "course-marketplace",
    item: "add-to-cart",
    action: "Click",
    params: {
      course_id: "course_abc123",        // string
      course_title: "web-development-101", // string
      price: 49.99,                      // float
      currency: "USD",                   // string
      cart_total: 49.99,                 // float (if adding to existing cart, update total)
      cart_item_count: 1,                // int (number of courses in cart after add)
      source: "course-detail",           // string (where did they add from? detail/search/recommended)
      is_direct_buy: false               // bool (true if "Buy Now", false if "Add to Cart")
    }
  },
  _clear: true
});
```

**React Example**:
```jsx
// AddToCartButton.tsx
const handleAddToCart = async () => {
  const newCartTotal = cartTotal + course.price;
  const newItemCount = cartItemCount + 1;

  dataLayer.push({
    event: "al_tracker_custom",
    al: {
      feature: "course-marketplace",
      item: "add-to-cart",
      action: "Click",
      params: {
        course_id: course.id,
        course_title: slugify(course.title),
        price: course.price,
        currency: "USD",
        cart_total: newCartTotal,
        cart_item_count: newItemCount,
        source: "course-detail",
        is_direct_buy: false
      }
    },
    _clear: true
  });

  await dispatch(addToCart(course.id));
};
```

---

## Event 4: Coupon Applied (Click)

**Trigger**: User successfully applies coupon code
**Type**: Click (user-initiated action)
**Purpose**: Track discount usage and campaign effectiveness

### Implementation

```javascript
// Fire after successful coupon validation
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "course-marketplace",
    item: "coupon-applied",
    action: "Click",
    params: {
      course_id: "course_abc123",        // string (or comma-separated if multiple)
      coupon_code: "SPRING2026",         // string (actual coupon code)
      discount_type: "percentage",       // string (percentage/fixed/free-shipping)
      discount_amount: 10.00,            // float (absolute discount value)
      discount_percentage: 20,           // int (0-100, if applicable)
      original_price: 49.99,             // float (before discount)
      final_price: 39.99,                // float (after discount)
      currency: "USD",                   // string
      campaign_source: "email"           // string (where did they get coupon? email/social/affiliate)
    }
  },
  _clear: true
});
```

**React Example**:
```jsx
// CouponInput.tsx
const handleApplyCoupon = async () => {
  try {
    const result = await validateCoupon(couponCode, cartTotal);

    if (result.valid) {
      dataLayer.push({
        event: "al_tracker_custom",
        al: {
          feature: "course-marketplace",
          item: "coupon-applied",
          action: "Click",
          params: {
            course_id: cartItems.map(i => i.courseId).join(","),
            coupon_code: couponCode.toUpperCase(),
            discount_type: result.type,
            discount_amount: result.discountAmount,
            discount_percentage: result.percentage || 0,
            original_price: cartTotal,
            final_price: cartTotal - result.discountAmount,
            currency: "USD",
            campaign_source: result.source || "organic"
          }
        },
        _clear: true
      });

      dispatch(applyCoupon(result));
      toast.success("Coupon applied!");
    }
  } catch (error) {
    // Track failed coupon attempt (optional)
    dataLayer.push({
      event: "al_tracker_custom",
      al: {
        feature: "course-marketplace",
        item: "coupon-failed",
        action: "Error",
        params: {
          coupon_code: couponCode.toUpperCase(),
          error_reason: error.message // "expired" / "invalid" / "not-applicable"
        }
      },
      _clear: true
    });
  }
};
```

---

## Event 5: Checkout Started (Click)

**Trigger**: User clicks "Proceed to Checkout" button
**Type**: Click (user-initiated action)
**Purpose**: Track funnel entry to payment flow

### Implementation

```javascript
// Fire on checkout button click (before redirect to checkout page)
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "course-marketplace",
    item: "checkout-started",
    action: "Click",
    params: {
      course_id: "course_abc123",        // string (or comma-separated for multi-course)
      course_count: 1,                   // int (number of courses in cart)
      subtotal: 49.99,                   // float (before discount)
      discount_amount: 10.00,            // float (0 if no discount)
      total_price: 39.99,                // float (final amount to charge)
      currency: "USD",                   // string
      has_coupon: true,                  // bool
      is_guest_checkout: false,          // bool (true if not logged in)
      cart_age_minutes: 8                // int (how long items have been in cart)
    }
  },
  _clear: true
});
```

**React Example**:
```jsx
// CartSummary.tsx
const handleCheckoutClick = () => {
  const cartAgeMinutes = Math.floor(
    (Date.now() - cart.createdAt) / 1000 / 60
  );

  dataLayer.push({
    event: "al_tracker_custom",
    al: {
      feature: "course-marketplace",
      item: "checkout-started",
      action: "Click",
      params: {
        course_id: cart.items.map(i => i.courseId).join(","),
        course_count: cart.items.length,
        subtotal: cart.subtotal,
        discount_amount: cart.discountAmount,
        total_price: cart.total,
        currency: "USD",
        has_coupon: !!cart.couponCode,
        is_guest_checkout: !user?.isAuthenticated,
        cart_age_minutes: cartAgeMinutes
      }
    },
    _clear: true
  });

  router.push("/checkout");
};
```

---

## Event 6: Payment Submitted (Click)

**Trigger**: User clicks "Complete Purchase" / "Pay Now" button
**Type**: Click (user-initiated action)
**Purpose**: Track payment initiation before Stripe confirmation

### Implementation

```javascript
// Fire when user submits payment (before Stripe confirmation)
dataLayer.push({
  event: "al_tracker_custom",
  al: {
    feature: "course-marketplace",
    item: "payment-submitted",
    action: "Click",
    params: {
      course_id: "course_abc123",        // string
      total_price: 39.99,                // float
      currency: "USD",                   // string
      payment_method: "credit-card",     // string (credit-card/paypal/apple-pay/google-pay)
      card_type: "visa",                 // string (visa/mastercard/amex, if applicable)
      save_payment_method: true,         // bool (did user save card?)
      billing_country: "US",             // string (ISO country code)
      checkout_duration_seconds: 87      // int (time from checkout start to payment submit)
    }
  },
  _clear: true
});
```

**React Example with Stripe**:
```jsx
// CheckoutForm.tsx
const handleSubmitPayment = async (event) => {
  event.preventDefault();

  const checkoutDuration = Math.floor(
    (Date.now() - checkoutStartTime) / 1000
  );

  dataLayer.push({
    event: "al_tracker_custom",
    al: {
      feature: "course-marketplace",
      item: "payment-submitted",
      action: "Click",
      params: {
        course_id: cart.items.map(i => i.courseId).join(","),
        total_price: cart.total,
        currency: "USD",
        payment_method: selectedPaymentMethod,
        card_type: cardBrand || "unknown",
        save_payment_method: saveCard,
        billing_country: billingAddress.country,
        checkout_duration_seconds: checkoutDuration
      }
    },
    _clear: true
  });

  const { error, paymentIntent } = await stripe.confirmCardPayment(
    clientSecret,
    { payment_method: paymentMethodId }
  );

  if (!error) {
    // Proceed to Event 7 (purchase completed)
  }
};
```

---

## Event 7: Purchase Completed (Impression)

**Trigger**: Order confirmation page loads (after successful payment)
**Type**: Impression (automatic event)
**Purpose**: Track successful conversions with full revenue data

### Implementation

```javascript
// Fire on order confirmation page load
dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "course-marketplace",
    item: "purchase-completed",
    params: {
      order_id: "order_xyz789",          // string (unique order identifier)
      course_id: "course_abc123",        // string
      course_count: 1,                   // int
      revenue: 39.99,                    // float (actual revenue after discounts)
      subtotal: 49.99,                   // float (before discount)
      discount_amount: 10.00,            // float
      currency: "USD",                   // string
      payment_method: "credit-card",     // string
      coupon_code: "SPRING2026",         // string (empty string "" if none)
      instructor_id: "inst_456",         // string (for revenue attribution)
      instructor_revenue: 27.99,         // float (70% revenue share)
      platform_revenue: 12.00,           // float (30% platform fee)
      transaction_id: "txn_stripe_123",  // string (Stripe payment intent ID)
      is_first_purchase: true,           // bool (first time buyer?)
      user_id: "user_987",               // string (for customer LTV tracking)
      referral_source: "google-ads"      // string (utm_source if available)
    }
  },
  _clear: true
});
```

**Next.js Example (Server-Side)**:
```jsx
// pages/order/[orderId]/confirmation.tsx
export async function getServerSideProps(context) {
  const { orderId } = context.params;
  const order = await getOrder(orderId);

  return {
    props: {
      order,
      trackingData: {
        order_id: order.id,
        course_id: order.items.map(i => i.courseId).join(","),
        course_count: order.items.length,
        revenue: order.totalPaid,
        subtotal: order.subtotal,
        discount_amount: order.discountAmount,
        currency: "USD",
        payment_method: order.paymentMethod,
        coupon_code: order.couponCode || "",
        instructor_id: order.items[0].instructorId,
        instructor_revenue: order.totalPaid * 0.7,
        platform_revenue: order.totalPaid * 0.3,
        transaction_id: order.stripePaymentIntentId,
        is_first_purchase: order.isFirstPurchase,
        user_id: order.userId,
        referral_source: order.utmSource || "direct"
      }
    }
  };
}

// Component
const ConfirmationPage = ({ order, trackingData }) => {
  useEffect(() => {
    dataLayer.push({
      event: "al_tracker_impression",
      al: {
        feature: "course-marketplace",
        item: "purchase-completed",
        params: trackingData
      },
      _clear: true
    });
  }, []);

  return <OrderConfirmation order={order} />;
};
```

---

## GA4 Enhanced Ecommerce Setup

### Event Mapping to GA4

For full GA4 e-commerce reporting, map custom events to standard GA4 events:

```javascript
// Create GTM trigger for "al_tracker_impression" + item "course-detail"
// Map to GA4 event: view_item

// GTM Variable: GA4 Items Array
{
  item_id: {{al.params.course_id}},
  item_name: {{al.params.course_title}},
  price: {{al.params.price}},
  item_category: {{al.params.category}},
  quantity: 1
}

// GA4 Event Tag:
Event Name: view_item
Parameters:
  currency: {{al.params.currency}}
  value: {{al.params.price}}
  items: {{GA4 Items Array}}
```

**Complete GA4 Event Mapping**:

| Custom Event | GA4 Standard Event | E-commerce Stage |
|--------------|-------------------|------------------|
| course-detail (impression) | `view_item` | Product View |
| add-to-cart (click) | `add_to_cart` | Add to Cart |
| checkout-started (click) | `begin_checkout` | Checkout Start |
| coupon-applied (click) | `add_payment_info` (with promotion) | Checkout Progress |
| payment-submitted (click) | `add_payment_info` | Payment Info |
| purchase-completed (impression) | `purchase` | Transaction Complete |

### GTM Container Setup

1. **Create Custom Event Triggers**:
   - Trigger Type: Custom Event
   - Event Name: `al_tracker_impression` OR `al_tracker_custom`
   - Condition: `al.feature` equals `course-marketplace`
   - Additional filters per event (e.g., `al.item` equals `purchase-completed`)

2. **Create Data Layer Variables**:
   ```
   Variable Name: DLV - Course ID
   Variable Type: Data Layer Variable
   Data Layer Variable Name: al.params.course_id
   ```

3. **Create GA4 Event Tag** (Example for Purchase):
   - Tag Type: GA4 Event
   - Configuration Tag: {{GA4 Config}}
   - Event Name: `purchase`
   - Event Parameters:
     - `transaction_id`: {{DLV - Order ID}}
     - `value`: {{DLV - Revenue}}
     - `currency`: {{DLV - Currency}}
     - `coupon`: {{DLV - Coupon Code}}
     - `items`: {{GA4 Items Array Variable}}
   - Trigger: Custom Event `purchase-completed`

---

## Key Metrics & Reporting

### Funnel Conversion Rates

```javascript
// Calculate in GA4 Explorations or BigQuery

Stage 1: Course Views → Add to Cart
Conversion Rate = (add_to_cart_events / view_item_events) × 100
Target: 8-12% (industry benchmark for online courses)

Stage 2: Add to Cart → Checkout Started
Conversion Rate = (begin_checkout_events / add_to_cart_events) × 100
Target: 60-75%

Stage 3: Checkout Started → Payment Submitted
Conversion Rate = (add_payment_info_events / begin_checkout_events) × 100
Target: 70-85%

Stage 4: Payment Submitted → Purchase Completed
Conversion Rate = (purchase_events / add_payment_info_events) × 100
Target: 95%+ (should be high, failures indicate payment issues)

Overall: Course View → Purchase
Conversion Rate = (purchase_events / view_item_events) × 100
Target: 3-6%
```

### Revenue Metrics

```sql
-- BigQuery SQL for revenue analysis
SELECT
  DATE(event_timestamp) as date,
  COUNT(DISTINCT user_pseudo_id) as purchasers,
  COUNT(*) as transactions,
  SUM(ecommerce.purchase.value) as total_revenue,
  AVG(ecommerce.purchase.value) as avg_order_value,
  SUM(CASE WHEN
    (SELECT value.string_value FROM UNNEST(event_params) WHERE key = 'coupon') != ''
  THEN 1 ELSE 0 END) as purchases_with_coupon,
  AVG(CAST((SELECT value.double_value FROM UNNEST(event_params) WHERE key = 'discount_amount') AS FLOAT64)) as avg_discount
FROM `project.dataset.events_*`
WHERE event_name = 'purchase'
  AND _TABLE_SUFFIX BETWEEN '20260101' AND '20260131'
GROUP BY date
ORDER BY date DESC;
```

### Abandoned Cart Analysis

```javascript
// GTM trigger for abandoned checkout (after 10 minutes)
// Fires if user reached "checkout-started" but no "purchase-completed" within 10 min

dataLayer.push({
  event: "al_tracker_impression",
  al: {
    feature: "course-marketplace",
    item: "checkout-abandoned",
    params: {
      course_id: "course_abc123",
      cart_value: 39.99,
      abandonment_stage: "payment-info",  // where they dropped off
      time_on_checkout_seconds: 142,
      reason: "unknown"  // can be enriched with exit surveys
    }
  },
  _clear: true
});
```

**Recovery Campaign Targeting**:
- Segment users with `checkout-abandoned` event
- Send email with abandoned cart value within 1 hour
- Retarget with display ads showing abandoned courses
- Offer time-limited discount for completion

### Coupon Campaign Effectiveness

```javascript
// GA4 Custom Report: Coupon Performance
Dimensions:
  - Coupon Code (al.params.coupon_code)
  - Campaign Source (al.params.campaign_source)

Metrics:
  - Total Applications (coupon-applied events)
  - Total Discount Amount (SUM of al.params.discount_amount)
  - Average Discount % (AVG of al.params.discount_percentage)
  - Conversions (purchase-completed with matching coupon)
  - Revenue with Coupon (SUM of revenue where coupon applied)

Calculated Metrics:
  - Coupon-to-Purchase Rate = Conversions / Applications
  - Revenue per Coupon = Revenue with Coupon / Applications
  - Discount ROI = (Revenue with Coupon - Total Discount) / Total Discount
```

---

## Implementation Checklist

### Phase 1: Basic Setup (Week 1)
- [ ] Add dataLayer initialization to site `<head>`
- [ ] Implement Event 1 (Course Viewed) on product pages
- [ ] Implement Event 3 (Add to Cart) on CTA buttons
- [ ] Implement Event 7 (Purchase Completed) on confirmation page
- [ ] Test in GTM Preview mode with real user flow
- [ ] Verify data in GA4 Realtime reports

### Phase 2: Funnel Expansion (Week 2)
- [ ] Implement Event 5 (Checkout Started) on cart page
- [ ] Implement Event 6 (Payment Submitted) in checkout form
- [ ] Add abandoned cart tracking (10-minute timeout)
- [ ] Create GA4 funnel exploration report
- [ ] Set up conversion goals in GA4

### Phase 3: Advanced Tracking (Week 3)
- [ ] Implement Event 2 (Preview Watched) on video players
- [ ] Implement Event 4 (Coupon Applied) in coupon input
- [ ] Add coupon failure tracking
- [ ] Enrich purchase event with referral_source (UTM params)
- [ ] Create BigQuery export for custom analysis

### Phase 4: Optimization (Week 4)
- [ ] Set up automated alerts for funnel drop-offs (>20% decrease)
- [ ] Create weekly revenue dashboard in Looker Studio
- [ ] Implement A/B testing framework with tracking variants
- [ ] Add user segments (first-time vs repeat buyers)
- [ ] Document tracking for engineering team

---

## Testing Guide

### Manual Testing Checklist

1. **Course View Test**:
   - Navigate to any course detail page
   - Open browser console → `dataLayer` → verify `course-detail` impression
   - Check all params populated (course_id, price, rating, etc.)

2. **Preview Engagement Test**:
   - Click preview video play button
   - Verify `preview-video` click event fires
   - Watch to completion → verify `preview-completion` event (if implemented)

3. **Add to Cart Test**:
   - Click "Add to Cart" button
   - Verify `add-to-cart` click event with correct price
   - Check cart_total and cart_item_count match actual cart state

4. **Coupon Flow Test**:
   - Add course to cart
   - Apply valid coupon code → verify `coupon-applied` with discount_amount
   - Try invalid coupon → verify `coupon-failed` event (if implemented)
   - Check final_price calculation is correct

5. **Checkout Flow Test**:
   - Click "Proceed to Checkout" → verify `checkout-started` event
   - Fill payment details → click "Pay Now" → verify `payment-submitted`
   - After Stripe confirmation → verify `purchase-completed` on confirmation page
   - Check order_id, revenue, and transaction_id are correct

6. **GA4 Verification**:
   - Go to GA4 → Realtime → Events
   - Complete a test purchase
   - Verify `view_item`, `add_to_cart`, `begin_checkout`, `purchase` events appear
   - Check e-commerce revenue matches order total

### Automated Testing (Playwright)

```javascript
// e2e-tests/purchase-funnel-tracking.spec.ts
import { test, expect } from '@playwright/test';

test('full purchase funnel tracking', async ({ page }) => {
  // Inject dataLayer spy
  await page.addInitScript(() => {
    window.dataLayerEvents = [];
    const originalPush = window.dataLayer.push;
    window.dataLayer.push = function(...args) {
      window.dataLayerEvents.push(args[0]);
      return originalPush.apply(this, args);
    };
  });

  // Step 1: View course
  await page.goto('/courses/web-development-101');
  let events = await page.evaluate(() => window.dataLayerEvents);
  expect(events).toContainEqual(
    expect.objectContaining({
      event: 'al_tracker_impression',
      al: expect.objectContaining({
        feature: 'course-marketplace',
        item: 'course-detail'
      })
    })
  );

  // Step 2: Add to cart
  await page.click('button[data-testid="add-to-cart"]');
  events = await page.evaluate(() => window.dataLayerEvents);
  expect(events).toContainEqual(
    expect.objectContaining({
      event: 'al_tracker_custom',
      al: expect.objectContaining({
        item: 'add-to-cart',
        action: 'Click'
      })
    })
  );

  // Step 3: Start checkout
  await page.click('button[data-testid="checkout"]');
  events = await page.evaluate(() => window.dataLayerEvents);
  expect(events).toContainEqual(
    expect.objectContaining({
      al: expect.objectContaining({ item: 'checkout-started' })
    })
  );

  // Step 4: Complete purchase (use Stripe test mode)
  await page.fill('input[name="cardNumber"]', '4242424242424242');
  await page.fill('input[name="cardExpiry"]', '12/28');
  await page.fill('input[name="cardCvc"]', '123');
  await page.click('button[type="submit"]');

  // Wait for confirmation page
  await page.waitForURL('**/order/*/confirmation');
  events = await page.evaluate(() => window.dataLayerEvents);

  const purchaseEvent = events.find(e =>
    e.al?.item === 'purchase-completed'
  );
  expect(purchaseEvent).toBeDefined();
  expect(purchaseEvent.al.params.order_id).toMatch(/^order_/);
  expect(purchaseEvent.al.params.revenue).toBeGreaterThan(0);
});
```

---

## Troubleshooting

### Common Issues

**Issue 1: Events not firing in GTM Preview**
- Check browser console for dataLayer syntax errors
- Verify `dataLayer` array exists before first push
- Ensure GTM container is published (not just previewed)
- Clear browser cache and test in incognito mode

**Issue 2: Wrong parameter types in GA4**
- Verify ES5 typing: strings in `"quotes"`, numbers/bools without
- Check GTM variable types match expected format
- Use GTM Debug mode to inspect variable values before tag fires

**Issue 3: Purchase event not matching Stripe revenue**
- Ensure you're passing final charged amount (not subtotal)
- Account for currency conversion if multi-currency
- Check that discounts are subtracted correctly
- Verify tax handling (include or exclude based on your setup)

**Issue 4: Funnel steps out of order**
- Check that `checkout-started` fires before `payment-submitted`
- Ensure single-page apps fire events on route change (not just mount)
- Add event timestamps for debugging sequence issues

**Issue 5: Missing user_id in purchase events**
- For guest checkouts, use `user_pseudo_id` instead
- Set `user_id` in GTM config tag (not per-event)
- Check GDPR consent requirements before tracking user IDs

---

## Privacy & Compliance

### GDPR Considerations
- **Consent Required**: E-commerce tracking includes personal data (purchase history)
- **Cookie Banner**: Obtain explicit consent before firing marketing tags
- **Data Retention**: Configure GA4 retention to 14 months (GDPR-safe default)
- **Right to Deletion**: Implement process to delete user_id from GA4 on request

### Data Minimization
- **Don't Track**: Full credit card numbers, CVV, passwords, SSN
- **Hash Emails**: If tracking email in params, use SHA-256 hash
- **Anonymize IPs**: Enable IP anonymization in GA4 (default in EU)
- **Secure PII**: Never pass `user_email` or `user_phone` in dataLayer

---

## Maintenance & Updates

### Monthly Review
- [ ] Check for events with declining volume (indicates broken tracking)
- [ ] Review top 10 coupon codes for unusual discount amounts
- [ ] Audit abandoned cart rate (alert if >70%)
- [ ] Verify payment method distribution matches Stripe dashboard

### Quarterly Updates
- [ ] Add new course categories to tracking params
- [ ] Update revenue split percentages if commission changes
- [ ] Test with new payment methods (e.g., Buy Now Pay Later)
- [ ] Refresh BigQuery analysis queries for new KPIs

---

## Support & Documentation

**Internal Resources**:
- GTM Container: [Link to GTM workspace]
- GA4 Property: [Link to GA4 dashboard]
- Stripe Dashboard: [Link to Stripe transactions]
- BigQuery Dataset: `analytics_123456789.events_*`

**External References**:
- [GA4 Enhanced Ecommerce](https://developers.google.com/analytics/devguides/collection/ga4/ecommerce)
- [GTM DataLayer Best Practices](https://developers.google.com/tag-platform/tag-manager/datalayer)
- [Stripe Payment Intents](https://stripe.com/docs/payments/payment-intents)

**Contact**:
- **Analytics Team**: analytics@edustream.academy
- **Engineering Lead**: dev@edustream.academy
- **Questions**: Slack #tracking-implementation

---

**End of Document**

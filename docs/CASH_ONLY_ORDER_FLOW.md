# Cash-Only Order Flow Documentation

**Version**: 1.0  
**Last Updated**: 2025-11-22  
**Status**: Production

## Overview

Chefleet operates on a **cash-only payment model** for all orders. Payment is collected in person at the time of pickup. This document describes the complete order flow from placement to completion.

## Payment Model

### Key Principles
- **No Online Payment**: No credit cards, no digital wallets, no prepayment
- **Cash at Pickup**: Payment collected when customer picks up order
- **Direct to Vendor**: Vendor receives full payment directly
- **No Transaction Fees**: No payment processing fees
- **Trust-Based**: Relies on pickup codes and customer commitment

## Order Flow

### 1. Order Placement (Customer)

**Customer Actions:**
1. Browse dishes on map or feed
2. Select dish and quantity
3. Add special instructions (optional)
4. Confirm order details
5. Submit order

**System Actions:**
```dart
// Create order with cash payment
final order = {
  'buyer_id': userId,
  'vendor_id': vendorId,
  'dish_id': dishId,
  'quantity': quantity,
  'payment_method': 'cash',        // Always cash
  'payment_status': 'pending',     // Pending until pickup
  'status': 'pending',
  'notes': specialInstructions,
};
```

**Database State:**
- Order created with `payment_method = 'cash'`
- Order status: `pending`
- Payment status: `pending`

### 2. Order Confirmation (Vendor)

**Vendor Actions:**
1. Receive order notification
2. Review order details
3. Accept or reject order
4. If accepted, set preparation time

**System Actions:**
```dart
// Vendor accepts order
await supabase.functions.invoke('change_order_status', body: {
  'order_id': orderId,
  'new_status': 'confirmed',
  'estimated_ready_time': readyTime,
});
```

**Database State:**
- Order status: `confirmed`
- Payment status: `pending` (unchanged)
- `estimated_ready_time` set

### 3. Order Preparation (Vendor)

**Vendor Actions:**
1. Prepare the dish
2. Update status to "preparing"
3. Update status to "ready" when complete

**System Actions:**
```dart
// Update to preparing
await supabase.functions.invoke('change_order_status', body: {
  'order_id': orderId,
  'new_status': 'preparing',
});

// Update to ready
await supabase.functions.invoke('change_order_status', body: {
  'order_id': orderId,
  'new_status': 'ready',
});
```

**Database State:**
- Order status: `preparing` → `ready`
- Payment status: `pending` (unchanged)
- Pickup code generated automatically

### 4. Pickup Code Generation

**Automatic Generation:**
When order status changes to `ready`, a 6-digit pickup code is generated:

```typescript
// Edge function: generate_pickup_code
const pickupCode = Math.floor(100000 + Math.random() * 900000).toString();

await supabase
  .from('orders')
  .update({ 
    pickup_code: pickupCode,
    pickup_time: null 
  })
  .eq('id', orderId);
```

**Customer Notification:**
- Push notification with pickup code
- In-app notification
- Order details screen shows code

**Vendor Display:**
- Pickup code visible in order details
- Used to verify customer at pickup

### 5. Customer Pickup

**Customer Actions:**
1. Arrive at vendor location
2. Show pickup code to vendor
3. Vendor verifies code
4. **Pay cash to vendor**
5. Receive order

**Vendor Actions:**
1. Customer shows pickup code
2. Verify code matches order
3. **Collect cash payment**
4. Confirm pickup in app
5. Hand over order

**System Actions:**
```dart
// Vendor confirms pickup
await supabase.functions.invoke('change_order_status', body: {
  'order_id': orderId,
  'new_status': 'completed',
  'pickup_code': customerCode,
});
```

**Database State:**
- Order status: `completed`
- Payment status: `completed` (updated automatically)
- `pickup_time` set to current timestamp
- `completed_at` set to current timestamp

### 6. Order Completion

**Automatic Updates:**
```sql
-- Trigger on order completion
UPDATE orders 
SET 
  payment_status = 'completed',
  completed_at = NOW(),
  pickup_time = NOW()
WHERE id = order_id AND status = 'completed';
```

**Post-Completion:**
- Customer can rate/review order
- Order appears in order history
- Vendor receives completion notification

## Payment Status Flow

```
pending → completed
   ↓
(stays pending until pickup)
```

### Status Definitions

| Status | Meaning | When Set |
|--------|---------|----------|
| `pending` | Payment not yet collected | Order creation |
| `completed` | Cash payment collected | Order pickup confirmation |
| `failed` | Not used in cash-only model | N/A |
| `refunded` | Manual refund if needed | Admin action |

## Edge Cases

### Customer No-Show

**Problem**: Customer doesn't pick up order

**Solution**:
1. Vendor waits reasonable time (e.g., 30 minutes)
2. Vendor cancels order in app
3. Order status: `cancelled`
4. No payment collected
5. Vendor can dispose of food or keep for walk-ins

**System Actions:**
```dart
await supabase.functions.invoke('change_order_status', body: {
  'order_id': orderId,
  'new_status': 'cancelled',
  'cancellation_reason': 'Customer no-show',
});
```

### Wrong Pickup Code

**Problem**: Customer provides incorrect code

**Solution**:
1. Vendor verifies code doesn't match
2. Ask customer to check order details
3. If still wrong, contact support
4. Do not hand over order without valid code

### Cash Shortage

**Problem**: Customer doesn't have enough cash

**Solution**:
1. Customer must find ATM or alternative payment
2. Vendor holds order for reasonable time
3. If customer cannot pay, order cancelled
4. No partial payments accepted

### Refund Requests

**Problem**: Customer wants refund after pickup

**Solution**:
1. Customer contacts support
2. Support reviews case
3. If approved, vendor provides cash refund
4. Admin updates order: `payment_status = 'refunded'`
5. Manual process, not automated

## Database Schema

### Orders Table (Relevant Fields)

```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY,
  buyer_id UUID REFERENCES users_public(id),
  vendor_id UUID REFERENCES vendors(id),
  dish_id UUID REFERENCES dishes(id),
  
  -- Payment fields
  payment_method TEXT DEFAULT 'cash',
  payment_status TEXT DEFAULT 'pending',
  
  -- Order tracking
  status TEXT DEFAULT 'pending',
  pickup_code TEXT,
  pickup_time TIMESTAMP WITH TIME ZONE,
  
  -- Timestamps
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE,
  
  CONSTRAINT payment_method_check 
    CHECK (payment_method IN ('cash', 'card', 'wallet')),
  CONSTRAINT payment_status_check 
    CHECK (payment_status IN ('pending', 'completed', 'failed', 'refunded'))
);
```

## UI Implementation

### Customer Order Screen

```dart
// Show payment method
Text('Payment Method: Cash at Pickup');

// Show pickup code when ready
if (order.status == 'ready') {
  Text('Pickup Code: ${order.pickupCode}');
  Text('Show this code to the vendor');
}

// Payment reminder
if (order.status == 'ready') {
  Container(
    padding: EdgeInsets.all(16),
    color: Colors.orange.shade100,
    child: Text(
      '💰 Remember to bring cash for payment at pickup!',
      style: TextStyle(fontWeight: FontWeight.bold),
    ),
  );
}
```

### Vendor Order Screen

```dart
// Show pickup code
Text('Pickup Code: ${order.pickupCode}');

// Verify code button
ElevatedButton(
  onPressed: () => _verifyPickupCode(order),
  child: Text('Verify Code & Complete Order'),
);

// Payment reminder
Text('Collect \$${order.totalAmount} in cash');
```

## Testing Checklist

### Manual Testing

- [ ] Create order as customer
- [ ] Verify `payment_method = 'cash'`
- [ ] Verify `payment_status = 'pending'`
- [ ] Vendor accepts order
- [ ] Vendor marks as ready
- [ ] Pickup code generated
- [ ] Customer sees pickup code
- [ ] Vendor verifies code
- [ ] Vendor completes order
- [ ] Verify `payment_status = 'completed'`
- [ ] Order appears in history

### Edge Case Testing

- [ ] Customer no-show → order cancelled
- [ ] Wrong pickup code → order not completed
- [ ] Multiple orders → correct code matching
- [ ] Refund request → manual process works

## Vendor Cash Handling Guide

### Best Practices

1. **Verify Code First**: Always check pickup code before handing over food
2. **Count Cash**: Count cash in front of customer
3. **Provide Change**: Keep small bills for change
4. **Receipt Optional**: Offer receipt if customer requests
5. **Security**: Keep cash secure, deposit regularly

### Cash Management

- Keep float of small bills ($1, $5, $10)
- Deposit large amounts regularly
- Track daily cash totals
- Report discrepancies to support

## Support & Troubleshooting

### Customer Issues

**"I don't have cash"**
- Direct to nearest ATM
- Hold order for 15-30 minutes
- Cancel if customer cannot return

**"Wrong amount charged"**
- Verify order total in app
- Show customer order details
- Contact support if dispute

### Vendor Issues

**"Customer claims they paid"**
- Check order status in app
- If not marked complete, payment not recorded
- Do not hand over food without confirmation

**"Lost pickup code"**
- Customer can view in app
- Verify customer identity
- Use order ID as backup

## Future Enhancements

### Potential Additions

1. **SMS Pickup Codes**: Send code via SMS as backup
2. **QR Code Pickup**: Generate QR code for scanning
3. **Tip Option**: Allow cash tips to be recorded
4. **Receipt Generation**: Print/email receipts
5. **Cash Tracking**: Vendor daily cash reports

### Payment Processing Migration

If transitioning to online payments:
- See `scripts/PAYMENT_TABLES_ARCHIVED.md`
- Deploy payment tables
- Integrate Stripe
- Update UI for payment selection
- Maintain cash as option

## Related Documentation

- **Payment Tables**: `scripts/PAYMENT_TABLES_ARCHIVED.md`
- **Edge Functions**: `supabase/functions/README.md`
- **Order Management**: `docs/ORDER_MANAGEMENT.md`
- **Pickup Codes**: `supabase/functions/generate_pickup_code/README.md`

---

**Questions?** Contact support@chefleet.com  
**Last Review**: 2025-11-22

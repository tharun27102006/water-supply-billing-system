# Payment Gateway Integration Guide

## Overview
This Water Billing System now features secure payment gateway integration with **Razorpay**, **PhonePe**, and **Paytm**. The implementation follows industry best practices with mandatory backend verification to prevent payment fraud.

## Security Features

### 🔒 Critical Security Measures
1. **Backend Verification**: All payments MUST be verified with the gateway API before marking as successful
2. **Signature Validation**: Cryptographic signatures are verified to prevent payment tampering
3. **Order Matching**: Payment responses are matched with session data to prevent replay attacks
4. **Amount Verification**: Payment amounts are cross-verified between frontend, backend, and gateway
5. **No Direct Success**: Frontend cannot directly mark payment as successful - only backend can after verification

## Payment Flow

### Step 1: Order Creation
```
User → Frontend → Backend → Payment Gateway API
↓
Order ID generated and stored in session
```

### Step 2: Authorization (User Action Required)
**UPI Payments:**
- User enters UPI PIN in GPay/PhonePe app
- PIN verification happens on user's device
- Transaction authorized only with correct PIN

**Card Payments:**
- User enters card details
- OTP sent to registered mobile number
- Transaction authorized only with correct OTP

**Net Banking:**
- User redirected to bank's secure login page
- User logs in with bank credentials
- Transaction authorized only after successful login

### Step 3: Backend Verification
```
Payment Gateway → Webhook/Callback → Backend Verification
↓
- Verify payment signature/hash
- Fetch payment details from gateway API
- Verify amount, order ID, status
- Update database ONLY if all checks pass
```

### Step 4: Success Confirmation
Only after successful backend verification, the payment is recorded and user sees success message.

## Configuration

### Razorpay Setup
1. Sign up at https://razorpay.com/
2. Get API credentials from Dashboard → Settings → API Keys
3. Update `PaymentGatewayConfig.java`:
```java
public static final String RAZORPAY_KEY_ID = "rzp_live_YOUR_KEY_ID";
public static final String RAZORPAY_KEY_SECRET = "YOUR_KEY_SECRET";
```

### PhonePe Setup
1. Register at https://www.phonepe.com/business/
2. Get merchant credentials
3. Update `PaymentGatewayConfig.java`:
```java
public static final String PHONEPE_MERCHANT_ID = "YOUR_MERCHANT_ID";
public static final String PHONEPE_SALT_KEY = "YOUR_SALT_KEY";
public static final String PHONEPE_SALT_INDEX = "1";
```

### Paytm Setup
1. Register at https://business.paytm.com/
2. Get merchant credentials
3. Update `PaymentGatewayConfig.java`:
```java
public static final String PAYTM_MERCHANT_ID = "YOUR_MERCHANT_ID";
public static final String PAYTM_MERCHANT_KEY = "YOUR_MERCHANT_KEY";
```

## Testing

### Test Mode (Razorpay)
Use test credentials for development:
- Key ID: `rzp_test_YOUR_TEST_KEY`
- Key Secret: `YOUR_TEST_SECRET`

**Test Cards:**
- Success: 4111 1111 1111 1111
- Failure: 4000 0000 0000 0002
- CVV: Any 3 digits
- Expiry: Any future date

**Test UPI:**
- success@razorpay
- failure@razorpay

### Production Mode
1. Complete KYC verification on payment gateway dashboard
2. Switch to live API keys
3. Update webhook URLs to production domain
4. Enable required payment methods

## Files Modified/Created

### Backend Files
- `PaymentGatewayConfig.java` - Configuration constants
- `PaymentGatewayService.java` - Gateway API integration
- `CreatePaymentOrderServlet.java` - Order creation endpoint
- `PaymentCallbackServlet.java` - Payment verification endpoint
- `DatabaseManager.java` - Updated schema with verification columns

### Frontend Files
- `payment-gateway.js` - Gateway UI integration
- `bills.html` - Updated payment modal
- `bills.js` - Updated payment flow

### Database Changes
Added columns to `payments` table:
- `gateway_order_id` - Order ID from gateway
- `gateway_payment_id` - Payment ID from gateway
- `gateway_signature` - Verification signature
- `gateway_name` - Gateway used (RAZORPAY/PHONEPE)
- `verification_status` - VERIFIED/PENDING/FAILED

## API Endpoints

### POST /create-payment-order
Creates payment order with gateway.

**Request:**
```
billNumber: String
amount: Double
gateway: String (RAZORPAY/PHONEPE)
email: String
phone: String
```

**Response:**
```json
{
  "success": true,
  "orderId": "order_xyz123",
  "amount": 1500.00,
  "currency": "INR",
  "gateway": "RAZORPAY",
  "keyId": "rzp_test_xyz"
}
```

### POST /payment-callback
Verifies payment and updates database.

**Request:**
```json
{
  "gateway": "RAZORPAY",
  "orderId": "order_xyz123",
  "paymentId": "pay_abc456",
  "signature": "signature_hash"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Payment verified and recorded successfully"
}
```

## Supported Payment Methods

### Razorpay
✅ UPI (GPay, PhonePe, Paytm, BHIM)
✅ Credit Cards (Visa, Mastercard, Amex, RuPay)
✅ Debit Cards (All banks)
✅ Net Banking (All major banks)
✅ Wallets (Paytm, Mobikwik, FreeCharge, etc.)

### PhonePe
✅ UPI (PhonePe app)
✅ UPI Intent (Direct app-to-app)

### Paytm
✅ UPI
✅ Paytm Wallet
✅ Cards
✅ Net Banking

## Currency
All payments are in **Indian Rupees (INR)**.
- Display: ₹1,500.00
- API format: 150000 (in paise)

## Error Handling

### Common Errors
1. **Order Creation Failed**: Check API credentials, network connectivity
2. **Payment Verification Failed**: Signature mismatch, amount mismatch
3. **Gateway Timeout**: Payment may be pending, check gateway dashboard
4. **Insufficient Balance**: User needs to add funds or try different method

### Debugging
Enable verbose logging in `PaymentGatewayService.java`:
```java
e.printStackTrace(); // Already enabled
```

Check logs for:
- Order creation requests/responses
- Payment verification details
- Signature generation/validation

## Compliance

### PCI DSS
✅ No card data stored on server
✅ All transactions via gateway's secure checkout
✅ HTTPS required for production

### RBI Guidelines
✅ Two-factor authentication (PIN/OTP)
✅ Payment confirmations sent to registered mobile
✅ Transaction limits as per regulations

### Data Protection
✅ Payment details encrypted in transit (HTTPS)
✅ Signature verification prevents tampering
✅ Session-based security

## Deployment Checklist

- [ ] Update API keys from test to production
- [ ] Configure webhook URLs with production domain
- [ ] Enable HTTPS/SSL certificate
- [ ] Test all payment methods in production
- [ ] Set up payment failure alerts
- [ ] Configure refund policies
- [ ] Train support team on payment issues
- [ ] Monitor transaction logs regularly

## Support

### Gateway Support
- **Razorpay**: support@razorpay.com | 080-68279999
- **PhonePe**: support@phonepe.com
- **Paytm**: business.support@paytm.com

### Common Issues
1. **Payment stuck in processing**: Check gateway dashboard, may need manual verification
2. **Duplicate payment**: Gateway prevents duplicate orders, check transaction ID
3. **Refund request**: Use gateway dashboard or API for refunds

## Future Enhancements
- [ ] International payment support (Stripe)
- [ ] Recurring payments (auto-pay)
- [ ] QR code generation for UPI
- [ ] Payment reminders via SMS/Email
- [ ] Bulk payment processing
- [ ] Payment analytics dashboard

---

**Version**: 1.0  
**Last Updated**: December 2025  
**Author**: Water Billing System Team

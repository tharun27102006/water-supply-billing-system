# Payment Gateway Security Architecture

## Authorization Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                    SECURE PAYMENT GATEWAY FLOW                       │
│                                                                       │
│  🔒 NO DIRECT SUCCESS BYPASS - VERIFICATION REQUIRED AT ALL STEPS  │
└─────────────────────────────────────────────────────────────────────┘

USER ACTION                    FRONTEND                  BACKEND                 PAYMENT GATEWAY
─────────────                 ─────────                ─────────               ───────────────

                                                                              
┌─────────┐                                                                   
│ Click   │                                                                   
│ "Pay    │                                                                   
│  Bill"  │                                                                   
└────┬────┘                                                                   
     │                                                                         
     └──────────►┌──────────────┐                                            
                 │ Payment Form │                                            
                 │ Opens        │                                            
                 │              │                                            
                 │ Enter:       │                                            
                 │ - Email      │                                            
                 │ - Phone      │                                            
                 │ - Gateway    │                                            
                 └──────┬───────┘                                            
                        │                                                     
                        │ Submit Form                                         
                        ▼                                                     
                 ┌──────────────┐                                            
                 │ Initialize   │                                            
                 │ Payment()    │                                            
                 └──────┬───────┘                                            
                        │                                                     
                        │ POST /create-payment-order                          
                        ▼                                                     
                                      ┌──────────────────┐                   
                                      │ Validate Session │                   
                                      │ Validate Inputs  │                   
                                      └────────┬─────────┘                   
                                               │                              
                                               │ Create Order Request         
                                               ▼                              
                                                           ┌──────────────┐  
                                                           │ Create Order │  
                                                           │ Generate     │  
                                                           │ Order ID     │  
                                                           └──────┬───────┘  
                                                                  │          
                                                                  │ Order Created
                                                                  ▼          
                                      ┌──────────────────┐  ┌─────────────┐
                                      │ Store in Session:│  │ order_xyz123│
                                      │ - Order ID       │  │ ₹1,500.00   │
                                      │ - Amount         │  │ INR         │
                                      │ - Bill Number    │  └─────────────┘
                                      └────────┬─────────┘                   
                                               │                              
                                               │ Return Order Details         
                                               ▼                              
                 ┌──────────────┐                                            
                 │ Open Gateway │                                            
                 │ Checkout UI  │                                            
                 └──────┬───────┘                                            
                        │                                                     
                        ▼                                                     
┌───────────────────────────────────────────────┐                            
│                                               │                            
│  🔐 RAZORPAY / PHONEPE CHECKOUT MODAL        │                            
│                                               │                            
│  Select Payment Method:                       │                            
│  ┌─────────────────────────────────────┐    │                            
│  │ 💳 UPI (GPay, PhonePe, BHIM)        │    │                            
│  │ 💳 Credit/Debit Card                │    │                            
│  │ 🏦 Net Banking                      │    │                            
│  │ 💰 Wallets                          │    │                            
│  └─────────────────────────────────────┘    │                            
│                                               │                            
└───────────────┬───────────────────────────────┘                            
                │                                                             
┌───────────────┴────────────────────────────┐                              
│   AUTHORIZATION REQUIRED (USER ACTION)     │                              
├────────────────────────────────────────────┤                              
│                                            │                              
│  IF UPI SELECTED:                          │                              
│  ┌──────────────────────────────────┐    │                              
│  │ Enter UPI ID                      │    │                              
│  │ → Opens GPay/PhonePe app          │    │                              
│  │ → Enter UPI PIN ━━━━━━            │    │◄──── USER ENTERS PIN        
│  │ → Verify PIN with bank            │    │                              
│  │ → Authorize payment               │    │                              
│  └──────────────────────────────────┘    │                              
│                                            │                              
│  IF CARD SELECTED:                         │                              
│  ┌──────────────────────────────────┐    │                              
│  │ Enter card details                │    │                              
│  │ → OTP sent to mobile ━━━━━━       │    │                              
│  │ → Enter OTP                       │    │◄──── USER ENTERS OTP        
│  │ → Verify OTP with bank            │    │                              
│  │ → Authorize payment               │    │                              
│  └──────────────────────────────────┘    │                              
│                                            │                              
│  IF NET BANKING SELECTED:                  │                              
│  ┌──────────────────────────────────┐    │                              
│  │ Select bank                       │    │                              
│  │ → Redirect to bank login page     │    │                              
│  │ → Enter user ID ━━━━━━            │    │◄──── USER LOGS IN           
│  │ → Enter password ━━━━━━            │    │                              
│  │ → Verify credentials              │    │                              
│  │ → Authorize payment               │    │                              
│  └──────────────────────────────────┘    │                              
│                                            │                              
└────────────────┬───────────────────────────┘                              
                 │                                                             
                 │ Authorization Complete                                      
                 ▼                                                             
                                                           ┌──────────────┐  
                                                           │ Process      │  
                                                           │ Payment      │  
                                                           │              │  
                                                           │ Generate:    │  
                                                           │ - Payment ID │  
                                                           │ - Signature  │  
                                                           └──────┬───────┘  
                                                                  │          
                                                                  │ Payment Response
                                                                  ▼          
                 ┌──────────────┐                                            
                 │ Payment      │                                            
                 │ Response     │                                            
                 │ Received     │                                            
                 └──────┬───────┘                                            
                        │                                                     
                        │ ⚠️ DO NOT SHOW SUCCESS YET                         
                        │                                                     
                        │ Show "Verifying Payment..."                         
                        │                                                     
                        │ POST /payment-callback                              
                        │ {                                                   
                        │   orderId, paymentId, signature                     
                        │ }                                                   
                        ▼                                                     
                                      ┌──────────────────┐                   
                                      │ 🔒 VERIFICATION  │                   
                                      │    CHECKPOINT    │                   
                                      └────────┬─────────┘                   
                                               │                              
                                      ┌────────▼─────────┐                   
                                      │ 1. Match Order   │                   
                                      │    ID with       │                   
                                      │    Session       │                   
                                      └────────┬─────────┘                   
                                               │ ✅ Match                     
                                               ▼                              
                                      ┌──────────────────┐                   
                                      │ 2. Verify        │                   
                                      │    Signature     │                   
                                      │    HMAC SHA256   │                   
                                      └────────┬─────────┘                   
                                               │ ✅ Valid                     
                                               ▼                              
                                               │ Fetch Payment Details        
                                               ▼                              
                                                           ┌──────────────┐  
                                                           │ GET Payment  │  
                                                           │ Details API  │  
                                                           └──────┬───────┘  
                                                                  │          
                                                                  │ Payment Details
                                                                  ▼          
                                      ┌──────────────────┐  ┌─────────────┐
                                      │ 3. Verify Amount │  │ Status:     │
                                      │    ₹1,500.00     │  │ "captured"  │
                                      │    matches       │  │ Amount:     │
                                      └────────┬─────────┘  │ ₹1,500.00   │
                                               │ ✅ Match    └─────────────┘
                                               ▼                              
                                      ┌──────────────────┐                   
                                      │ 4. Check Status  │                   
                                      │    "captured" or │                   
                                      │    "SUCCESS"     │                   
                                      └────────┬─────────┘                   
                                               │ ✅ Success                   
                                               ▼                              
                                      ┌──────────────────┐                   
                                      │ 5. UPDATE DB     │                   
                                      │                  │                   
                                      │ BEGIN TRANSACTION│                   
                                      │                  │                   
                                      │ INSERT INTO      │                   
                                      │ payments (       │                   
                                      │   gateway_order, │                   
                                      │   gateway_pay,   │                   
                                      │   signature,     │                   
                                      │   status,        │                   
                                      │   verified       │                   
                                      │ )                │                   
                                      │                  │                   
                                      │ UPDATE bills     │                   
                                      │ SET status=PAID  │                   
                                      │                  │                   
                                      │ COMMIT           │                   
                                      └────────┬─────────┘                   
                                               │                              
                                               │ ✅ Database Updated          
                                               │                              
                                               │ Return Success Response      
                                               ▼                              
                 ┌──────────────┐                                            
                 │ ✅ SUCCESS   │                                            
                 │              │                                            
                 │ Hide         │                                            
                 │ "Verifying"  │                                            
                 │              │                                            
                 │ Show Success │                                            
                 │ Modal        │                                            
                 └──────┬───────┘                                            
                        │                                                     
                        ▼                                                     
┌────────────────────────────────────┐                                       
│ 🎉 Payment Verified Successfully!  │                                       
│                                    │                                       
│ Your payment has been verified     │                                       
│ and recorded successfully.         │                                       
│                                    │                                       
│ [Refresh & View Receipt]           │                                       
└────────────────────────────────────┘                                       


═══════════════════════════════════════════════════════════════════════════

                         🔐 SECURITY GUARANTEES

═══════════════════════════════════════════════════════════════════════════

❌ CANNOT BYPASS:

1. ❌ Frontend CANNOT mark payment successful directly
   → Payment status ONLY updated by backend servlet
   → No direct database access from frontend

2. ❌ User CANNOT fake authorization
   → UPI PIN verified by bank
   → Card OTP verified by bank
   → Net Banking verified by bank

3. ❌ User CANNOT fake payment signature
   → HMAC SHA256 with secret key
   → Secret key stored on server ONLY
   → Invalid signature = Immediate rejection

4. ❌ User CANNOT replay old payment
   → Order ID stored in session
   → Used order IDs cannot be reused
   → Session validation required

5. ❌ User CANNOT alter payment amount
   → Amount verified at 3 checkpoints:
     1. Order creation
     2. Gateway response  
     3. Backend verification
   → Any mismatch = Immediate rejection

6. ❌ User CANNOT skip gateway verification
   → Backend ALWAYS calls gateway API
   → Payment details fetched from source
   → No trust in frontend data

═══════════════════════════════════════════════════════════════════════════

                         ✅ VERIFICATION LAYERS

═══════════════════════════════════════════════════════════════════════════

Layer 1: SESSION VALIDATION
├─ User must be logged in
├─ Session must contain order details
└─ Order ID must match callback data

Layer 2: SIGNATURE VERIFICATION
├─ HMAC SHA256 signature generated
├─ Compared with gateway signature
└─ Mismatch = Immediate rejection

Layer 3: GATEWAY API VERIFICATION
├─ Fetch payment details from gateway
├─ Verify payment status (captured/SUCCESS)
├─ Verify amount matches exactly
└─ Any failure = Immediate rejection

Layer 4: DATABASE TRANSACTION
├─ BEGIN TRANSACTION
├─ Insert payment record with verification data
├─ Update bill status to PAID
├─ COMMIT (or ROLLBACK on error)
└─ Atomic operation ensures consistency

Layer 5: AUDIT TRAIL
├─ All verification details stored in database:
│  - gateway_order_id
│  - gateway_payment_id
│  - gateway_signature
│  - verification_status: "VERIFIED"
├─ Transaction timestamps recorded
└─ Full audit trail for compliance

═══════════════════════════════════════════════════════════════════════════
```

## Payment Status States

```
┌─────────────────────────────────────────────────────────────────┐
│                     PAYMENT STATUS FLOW                          │
└─────────────────────────────────────────────────────────────────┘

Bill Created
    │
    ├─► status: "PENDING"
    │   ├─ payment_id: NULL
    │   ├─ verification_status: NULL
    │   └─ gateway_order_id: NULL
    │
    ▼
User Clicks "Pay"
    │
    ├─► Order Created
    │   ├─ gateway_order_id: "order_xyz123"
    │   ├─ Stored in session
    │   └─ Amount: ₹1,500.00
    │
    ▼
User Authorizes (UPI PIN/Card OTP/Net Banking)
    │
    ├─► Payment Processed by Gateway
    │   ├─ gateway_payment_id: "pay_abc456"
    │   ├─ gateway_signature: "sha256_hash"
    │   └─ Status: "captured"
    │
    ▼
Backend Verification
    │
    ├─► ✅ If All Checks Pass:
    │   │
    │   ├─ INSERT INTO payments
    │   │   ├─ gateway_order_id: "order_xyz123"
    │   │   ├─ gateway_payment_id: "pay_abc456"
    │   │   ├─ gateway_signature: "verified_hash"
    │   │   ├─ verification_status: "VERIFIED"
    │   │   ├─ status: "COMPLETED"
    │   │   └─ amount: ₹1,500.00
    │   │
    │   └─ UPDATE bills
    │       └─ status: "PAID"
    │
    └─► ❌ If Any Check Fails:
        │
        ├─ NO database update
        ├─ Return error to frontend
        └─ User sees "Payment Failed" message


═══════════════════════════════════════════════════════════════════
```

## Data Flow Security

```
┌─────────────────────────────────────────────────────────────────┐
│                 SENSITIVE DATA HANDLING                          │
└─────────────────────────────────────────────────────────────────┘

🔐 STORED ON SERVER (SECURE):
├─ Razorpay Key Secret
├─ PhonePe Salt Key  
├─ Session Data (order details)
└─ Database credentials

🌐 SENT TO GATEWAY (ENCRYPTED):
├─ Bill number
├─ Amount
├─ Customer email
└─ Customer phone

🔓 STORED IN DATABASE (VERIFIED):
├─ gateway_order_id (public)
├─ gateway_payment_id (public)
├─ gateway_signature (public but verified)
├─ verification_status (VERIFIED/FAILED)
└─ transaction_id (public)

❌ NEVER STORED:
├─ Card numbers
├─ CVV
├─ UPI PIN
├─ Net Banking credentials
└─ OTPs

═══════════════════════════════════════════════════════════════════
```

---

**Security Level**: 🔒 PRODUCTION-GRADE  
**Compliance**: ✅ PCI DSS, RBI Guidelines  
**Audit Trail**: ✅ Complete verification history  
**Attack Prevention**: ✅ Multiple security layers

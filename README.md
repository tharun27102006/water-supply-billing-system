# Water Billing System

A professional web-based application for automating water billing, calculations, and payments.

## Features

### For Users:
- User registration and authentication
- View water consumption and bills
- **Pay bills instantly with one-click payment**
- Download PDF invoices automatically
- Track payment history

### For Admins:
- Dashboard with comprehensive statistics
- Manage users and meters
- Generate bills automatically
- View all transactions and payments

## Technology Stack

- **Backend:** Java Servlets
- **Frontend:** HTML5, CSS3, JavaScript
- **Database:** SQLite
- **Build Tool:** Maven
- **Server:** Jetty

## Quick Start

```bash
cd "c:\Users\tharu\OneDrive\desktop\java project\WaterBillingSystem"
mvn jetty:run
```

Visit: **http://localhost:8080/WaterBillingSystem/**

## Default Login

- Username: `admin`
- Password: `admin123`

## Billing Rates (Indian Rupees)

- **0-10 m³:** ₹8 per unit
- **11-30 m³:** ₹12 per unit  
- **31+ m³:** ₹18 per unit
- **Tax:** 10%

## Payment System

### Simple One-Click Payment:
1. Click **"Pay"** button
2. Confirm in dialog
3. Done! Bill marked as paid instantly

### Features:
- ✅ Instant confirmation
- ✅ Automatic updates
- ✅ Transaction tracking
- ✅ PDF invoice download

## Usage

### Make a Payment:
1. Go to "Bills" section
2. Click **"Pay"** on pending bill
3. Click **"OK"** to confirm
4. See "Payment Successful!" message
5. Download PDF invoice

### Troubleshooting

**Clear Browser Cache:**
- Press `Ctrl + Shift + Delete`
- Select "All time"
- Clear "Cached images and files"
- Or press `Ctrl + F5` for hard reload

## Features Highlights

✅ Secure password hashing  
✅ One-click payment  
✅ PDF invoices  
✅ Real-time updates  
✅ No external dependencies  

---

**Simple. Fast. Secure.**

# Shoe Store - Firebase Backend Guide

## Firestore Database Structure

### Collection: `users`
Stores user profiles linked to Firebase Auth UID.

```
users/{uid}
  - email: string
  - displayName: string
  - photoUrl: string
  - role: string         // "client" | "admin"
  - phone: string
  - address: map
      - street: string
      - city: string
      - postalCode: string
      - country: string
  - isActive: boolean
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Collection: `products`
Stores product catalog.

```
products/{productId}
  - name: string
  - description: string
  - price: number
  - imageUrl: string          // main image
  - images: array<string>     // gallery images
  - sizes: array<string>
  - colors: array<string>
  - category: string
  - brand: string
  - stockQuantity: number
  - inStock: boolean
  - rating: number
  - reviewCount: number
  - createdAt: timestamp
  - updatedAt: timestamp
```

### Collection: `categories`
Product categories.

```
categories/{categoryId}
  - name: string
  - iconName: string
  - imageUrl: string
  - productCount: number
  - isActive: boolean
  - sortOrder: number
  - createdAt: timestamp
```

### Collection: `carts`
Per-user shopping cart.

```
carts/{uid}
  - items: array<map>
      - productId: string
      - name: string
      - price: number
      - imageUrl: string
      - quantity: number
      - size: string
      - color: string
  - updatedAt: timestamp
```

### Collection: `favorites`
Per-user favorites.

```
favorites/{uid}
  - productIds: array<string>
  - updatedAt: timestamp
```

### Collection: `orders`
Order records.

```
orders/{orderId}
  - userId: string
  - items: array<map>
      - productId: string
      - productName: string
      - productImage: string
      - price: number
      - quantity: number
      - size: string
      - color: string
  - totalAmount: number
  - status: string           // "pending" | "paid" | "shipped" | "delivered" | "cancelled"
  - shippingAddress: map
      - fullName: string
      - address: string
      - city: string
      - postalCode: string
      - country: string
      - phone: string
  - paymentIntentId: string
  - notes: string
  - createdAt: timestamp
  - updatedAt: timestamp
```

---

## Firebase Storage Structure

```
/product_images/
  - {productId}_main.jpg
  - {productId}_1.jpg
  - {productId}_2.jpg

/user_avatars/
  - {uid}.jpg
```

---

## Setup Steps

### 1. Enable Firebase Services
- Go to [Firebase Console](https://console.firebase.google.com/)
- Enable **Authentication** (Email/Password)
- Enable **Cloud Firestore**
- Enable **Firebase Storage**
- Enable **Cloud Functions** (Blaze plan required)

### 2. Deploy Security Rules
```bash
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

### 3. Deploy Cloud Functions
```bash
cd functions
npm install
firebase deploy --only functions
```

### 4. Update Flutter App
The service classes in `lib/services/` handle all Firebase operations.
Update your providers to use these services instead of direct Firebase calls.


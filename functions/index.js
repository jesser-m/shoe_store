const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");

initializeApp();
const db = getFirestore();

/**
 * onOrderCreated - Triggered when a new order is created
 * 1. Update product stock quantities
 * 2. Update user order stats
 * 3. Send notification (placeholder)
 */
exports.onOrderCreated = onDocumentCreated("orders/{orderId}", async (event) => {
  const order = event.data.data();
  const orderId = event.params.orderId;

  console.log(`Processing order ${orderId} for user ${order.userId}`);

  const batch = db.batch();

  try {
    // 1. Update product stock
    for (const item of order.items) {
      const productRef = db.collection("products").doc(item.productId);
      const productDoc = await productRef.get();

      if (productDoc.exists) {
        const currentStock = productDoc.data().stockQuantity || 0;
        const newStock = Math.max(0, currentStock - item.quantity);

        batch.update(productRef, {
          stockQuantity: newStock,
          inStock: newStock > 0,
          updatedAt: new Date(),
        });

        console.log(`Updated stock for ${item.productId}: ${currentStock} -> ${newStock}`);
      }
    }

    // 2. Update user stats
    const userRef = db.collection("users").doc(order.userId);
    const userDoc = await userRef.get();

    if (userDoc.exists) {
      const currentOrderCount = userDoc.data().orderCount || 0;
      const currentTotalSpent = userDoc.data().totalSpent || 0;

      batch.update(userRef, {
        orderCount: currentOrderCount + 1,
        totalSpent: currentTotalSpent + order.totalAmount,
        updatedAt: new Date(),
      });
    }

    // 3. Update category product counts (optional, if needed)
    // This could be done if you want real-time category counts

    await batch.commit();
    console.log(`Order ${orderId} processed successfully`);

    return {success: true, orderId};
  } catch (error) {
    console.error(`Error processing order ${orderId}:`, error);
    throw new Error(`Failed to process order: ${error.message}`);
  }
});

/**
 * onProductCreated - Update category product count when a product is added
 */
exports.onProductCreated = onDocumentCreated("products/{productId}", async (event) => {
  const product = event.data.data();

  if (!product.category) return;

  try {
    const categoriesRef = db.collection("categories")
      .where("name", "==", product.category);
    const snapshot = await categoriesRef.get();

    if (!snapshot.empty) {
      const categoryDoc = snapshot.docs[0];
      const currentCount = categoryDoc.data().productCount || 0;

      await categoryDoc.ref.update({
        productCount: currentCount + 1,
        updatedAt: new Date(),
      });

      console.log(`Updated category ${product.category} count: ${currentCount + 1}`);
    }
  } catch (error) {
    console.error("Error updating category count:", error);
  }
});


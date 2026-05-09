// Orders Routes
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Order = require('../models/Order');
const Product = require('../models/Product');
const User = require('../models/User');
const { sendOrderConfirmation } = require('../services/emailService');

// @route   GET api/orders/all
// @desc    Get all orders (admin)
// @access  Private/Admin
router.get('/all', auth, async (req, res) => {
  try {
    const { status } = req.query;
    let query = {};
    if (status && status !== 'all') {
      query.status = status;
    }
    const orders = await Order.find(query)
      .populate('user', ['email', 'displayName'])
      .populate('products.product', ['name', 'imageUrl'])
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   GET api/orders/stats/summary
// @desc    Get order statistics
// @access  Private/Admin
router.get('/stats/summary', auth, async (req, res) => {
  try {
    const orders = await Order.find();
    const stats = {
      total: orders.length,
      pending: orders.filter(o => o.status === 'pending').length,
      paid: orders.filter(o => o.status === 'paid').length,
      shipped: orders.filter(o => o.status === 'shipped').length,
      delivered: orders.filter(o => o.status === 'delivered').length,
      cancelled: orders.filter(o => o.status === 'cancelled').length,
      totalRevenue: orders.filter(o => o.status !== 'cancelled').reduce((acc, o) => acc + o.totalAmount, 0)
    };
    res.json(stats);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   GET api/orders
// @desc    Get current user orders
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const orders = await Order.find({ user: req.user.id })
      .populate('user', ['email', 'displayName'])
      .populate('products.product', ['name', 'imageUrl'])
      .sort({ createdAt: -1 });
    res.json(orders);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   GET api/orders/:id
// @desc    Get order by ID
// @access  Private
router.get('/:id', auth, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('user', ['email', 'displayName'])
      .populate('products.product', ['name', 'imageUrl']);
    if (!order) {
      return res.status(404).json({ msg: 'Order not found' });
    }
    res.json(order);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   POST api/orders
// @desc    Create an order
// @access  Private
router.post('/', auth, async (req, res) => {
  const { items, totalAmount, shippingAddress, paymentIntentId } = req.body;

  try {
    const orderProducts = [];

    for (const item of items) {
      const product = await Product.findById(item.productId);
      if (!product) {
        return res.status(404).json({ msg: `Product not found: ${item.productId}` });
      }
      
      // Basic check for stock if needed
      if (product.stockQuantity < item.quantity) {
        // Optionnel: vous pouvez soit bloquer, soit simplement notifier
        console.warn(`Stock bas pour ${product.name}`);
      }

      orderProducts.push({
        product: product._id,
        quantity: item.quantity,
        price: item.price
      });
    }

    const order = new Order({
      user: req.user.id,
      products: orderProducts,
      totalAmount,
      shippingAddress,
      paymentId: paymentIntentId,
      status: paymentIntentId && paymentIntentId.startsWith('card_') ? 'paid' : 'pending'
    });

    const newOrder = await order.save();

    // Send order confirmation email in background
    try {
      const user = await User.findById(req.user.id);
      if (user) {
        // Prepare products with names for the email
        const orderWithNames = {
          ...newOrder._doc,
          products: await Promise.all(newOrder.products.map(async p => {
            const prod = await Product.findById(p.product);
            return { ...p._doc, productName: prod ? prod.name : 'Produit' };
          }))
        };
        await sendOrderConfirmation(orderWithNames, user);
      }
    } catch (emailErr) {
      console.error('Error sending confirmation email:', emailErr);
      // Don't fail the request if email fails
    }

    res.json(newOrder);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   PUT api/orders/:id
// @desc    Update order status
// @access  Private/Admin
router.put('/:id', auth, async (req, res) => {
  const { status } = req.body;

  try {
    let order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ msg: 'Order not found' });
    }

    order.status = status || order.status;
    await order.save();
    res.json(order);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   DELETE api/orders/:id
// @desc    Delete an order
// @access  Private/Admin
router.delete('/:id', auth, async (req, res) => {
  try {
    let order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ msg: 'Order not found' });
    }

    await Order.findByIdAndDelete(req.params.id);
    res.json({ msg: 'Order removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

module.exports = router;
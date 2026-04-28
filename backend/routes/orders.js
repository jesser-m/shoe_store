const express = require('express');
const Order = require('../models/Order');
const Product = require('../models/Product');
const Cart = require('../models/Cart');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const router = express.Router();

// @route   POST /api/orders
// @desc    Create new order
// @access  Private
router.post('/', auth, async (req, res) => {
  try {
    const { items, totalAmount, shippingAddress, paymentIntentId, notes } = req.body;

    // Validate stock
    for (const item of items) {
      const product = await Product.findById(item.productId);
      if (!product) {
        return res.status(400).json({ message: `Produit ${item.productId} non trouve` });
      }
      if (product.stockQuantity < item.quantity) {
        return res.status(400).json({
          message: `Stock insuffisant pour ${product.name}`,
        });
      }
    }

    // Decrement stock
    for (const item of items) {
      await Product.findByIdAndUpdate(item.productId, {
        $inc: { stockQuantity: -item.quantity },
      });
    }

    const order = await Order.create({
      userId: req.user._id,
      items,
      totalAmount,
      shippingAddress,
      paymentIntentId,
      notes,
      status: 'pending',
    });

    // Clear user cart
    await Cart.findOneAndUpdate({ userId: req.user._id }, { items: [] });

    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/orders
// @desc    Get user orders
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const orders = await Order.find({ userId: req.user._id })
      .sort({ createdAt: -1 })
      .populate('items.productId', 'name brand');
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/orders/all
// @desc    Get all orders (admin)
// @access  Admin
router.get('/all', auth, admin, async (req, res) => {
  try {
    const { status } = req.query;
    let query = {};
    if (status && status !== 'all') query.status = status;

    const orders = await Order.find(query)
      .sort({ createdAt: -1 })
      .populate('userId', 'name email')
      .populate('items.productId', 'name brand');
    res.json(orders);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/orders/:id
// @desc    Get single order
// @access  Private (owner or admin)
router.get('/:id', auth, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id)
      .populate('userId', 'name email')
      .populate('items.productId', 'name brand');

    if (!order) {
      return res.status(404).json({ message: 'Commande non trouvee' });
    }

    if (
      order.userId._id.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({ message: 'Non autorise' });
    }

    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/orders/:id/status
// @desc    Update order status
// @access  Admin
router.put('/:id/status', auth, admin, async (req, res) => {
  try {
    const { status } = req.body;
    const order = await Order.findByIdAndUpdate(
      req.params.id,
      { status },
      { new: true }
    );
    if (!order) {
      return res.status(404).json({ message: 'Commande non trouvee' });
    }
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/orders/:id/cancel
// @desc    Cancel order
// @access  Private (owner or admin)
router.put('/:id/cancel', auth, async (req, res) => {
  try {
    const order = await Order.findById(req.params.id);
    if (!order) {
      return res.status(404).json({ message: 'Commande non trouvee' });
    }

    if (
      order.userId.toString() !== req.user._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({ message: 'Non autorise' });
    }

    // Restore stock if order was not cancelled
    if (order.status !== 'cancelled') {
      for (const item of order.items) {
        await Product.findByIdAndUpdate(item.productId, {
          $inc: { stockQuantity: item.quantity },
        });
      }
    }

    order.status = 'cancelled';
    await order.save();
    res.json(order);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/orders/stats/summary
// @desc    Get order statistics
// @access  Admin
router.get('/stats/summary', auth, admin, async (req, res) => {
  try {
    const orders = await Order.find();
    const total = orders.length;
    const pending = orders.filter((o) => o.status === 'pending').length;
    const paid = orders.filter((o) => o.status === 'paid').length;
    const shipped = orders.filter((o) => o.status === 'shipped').length;
    const delivered = orders.filter((o) => o.status === 'delivered').length;
    const cancelled = orders.filter((o) => o.status === 'cancelled').length;
    const totalRevenue = orders
      .filter((o) => o.status !== 'cancelled')
      .reduce((sum, o) => sum + o.totalAmount, 0);

    res.json({ total, pending, paid, shipped, delivered, cancelled, totalRevenue });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;


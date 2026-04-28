const express = require('express');
const Cart = require('../models/Cart');
const auth = require('../middleware/auth');
const router = express.Router();

// @route   GET /api/cart
// @desc    Get user cart
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      cart = await Cart.create({ userId: req.user._id, items: [] });
    }
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/cart/add
// @desc    Add item to cart
// @access  Private
router.post('/add', auth, async (req, res) => {
  try {
    const { productId, name, price, imageUrl, size, color, quantity } = req.body;

    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      cart = new Cart({ userId: req.user._id, items: [] });
    }

    const existingIndex = cart.items.findIndex((item) => {
      return (
        item.productId.toString() === productId &&
        item.size === size &&
        item.color === color
      );
    });

    if (existingIndex >= 0) {
      cart.items[existingIndex].quantity += quantity || 1;
    } else {
      cart.items.push({
        productId,
        name,
        price,
        imageUrl,
        size,
        color,
        quantity: quantity || 1,
      });
    }

    await cart.save();
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/cart/update
// @desc    Update cart item quantity
// @access  Private
router.put('/update', auth, async (req, res) => {
  try {
    const { productId, size, color, quantity } = req.body;

    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json({ message: 'Panier non trouve' });
    }

    const itemIndex = cart.items.findIndex((item) => {
      return (
        item.productId.toString() === productId &&
        item.size === size &&
        item.color === color
      );
    });

    if (itemIndex >= 0) {
      if (quantity <= 0) {
        cart.items.splice(itemIndex, 1);
      } else {
        cart.items[itemIndex].quantity = quantity;
      }
      await cart.save();
    }

    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/cart/remove
// @desc    Remove item from cart
// @access  Private
router.delete('/remove', auth, async (req, res) => {
  try {
    const { productId, size, color } = req.body;

    let cart = await Cart.findOne({ userId: req.user._id });
    if (!cart) {
      return res.status(404).json({ message: 'Panier non trouve' });
    }

    cart.items = cart.items.filter((item) => {
      return !(
        item.productId.toString() === productId &&
        item.size === size &&
        item.color === color
      );
    });

    await cart.save();
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/cart
// @desc    Clear cart
// @access  Private
router.delete('/', auth, async (req, res) => {
  try {
    const cart = await Cart.findOneAndUpdate(
      { userId: req.user._id },
      { items: [] },
      { new: true }
    );
    res.json(cart);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;


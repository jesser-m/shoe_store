const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');
const router = express.Router();

// Helper: get or create favorites array
const getFavoritesDoc = async (userId) => {
  const user = await User.findById(userId);
  if (!user.favorites) {
    user.favorites = [];
    await user.save();
  }
  return user;
};

// @route   GET /api/favorites
// @desc    Get user favorites
// @access  Private
router.get('/', auth, async (req, res) => {
  try {
    const user = await getFavoritesDoc(req.user._id);
    res.json({ productIds: user.favorites || [] });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/favorites/add
// @desc    Add product to favorites
// @access  Private
router.post('/add', auth, async (req, res) => {
  try {
    const { productId } = req.body;
    const user = await User.findById(req.user._id);

    if (!user.favorites) user.favorites = [];
    if (!user.favorites.includes(productId)) {
      user.favorites.push(productId);
      await user.save();
    }

    res.json({ productIds: user.favorites });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/favorites/remove
// @desc    Remove product from favorites
// @access  Private
router.delete('/remove', auth, async (req, res) => {
  try {
    const { productId } = req.body;
    const user = await User.findById(req.user._id);

    if (user.favorites) {
      user.favorites = user.favorites.filter((id) => id.toString() !== productId);
      await user.save();
    }

    res.json({ productIds: user.favorites || [] });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/favorites
// @desc    Clear all favorites
// @access  Private
router.delete('/', auth, async (req, res) => {
  try {
    const user = await User.findById(req.user._id);
    user.favorites = [];
    await user.save();
    res.json({ productIds: [] });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;


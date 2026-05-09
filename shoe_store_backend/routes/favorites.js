// Favorites Routes
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Product = require('../models/Product');

// Simple in-memory favorites for now (in production, use a database model)
let favorites = {};

// @route   GET api/favorites
// @desc    Get user's favorites
// @access  Private
router.get('/', auth, (req, res) => {
  const userFavorites = favorites[req.user.id] || [];
  res.json(userFavorites);
});

// @route   POST api/favorites/:productId
// @desc    Add product to favorites
// @access  Private
router.post('/:productId', auth, async (req, res) => {
  try {
    const product = await Product.findById(req.params.productId);
    if (!product) {
      return res.status(404).json({ msg: 'Product not found' });
    }

    if (!favorites[req.user.id]) {
      favorites[req.user.id] = [];
    }

    // Check if already in favorites
    if (!favorites[req.user.id].includes(req.params.productId)) {
      favorites[req.user.id].push(req.params.productId);
    }

    res.json(favorites[req.user.id]);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
});

// @route   DELETE api/favorites/:productId
// @desc    Remove product from favorites
// @access  Private
router.delete('/:productId', auth, (req, res) => {
  if (favorites[req.user.id]) {
    favorites[req.user.id] = favorites[req.user.id].filter(
      id => id !== req.params.productId
    );
  }
  res.json(favorites[req.user.id] || []);
});

module.exports = router;
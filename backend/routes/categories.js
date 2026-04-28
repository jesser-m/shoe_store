const express = require('express');
const Category = require('../models/Category');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const router = express.Router();

// @route   GET /api/categories
// @desc    Get all categories
// @access  Public
router.get('/', async (req, res) => {
  try {
    const categories = await Category.find().sort({ sortOrder: 1 });
    res.json(categories);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/categories/active
// @desc    Get active categories
// @access  Public
router.get('/active', async (req, res) => {
  try {
    const categories = await Category.find({ isActive: true }).sort({ sortOrder: 1 });
    res.json(categories);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/categories
// @desc    Create category
// @access  Admin
router.post('/', auth, admin, async (req, res) => {
  try {
    const category = await Category.create(req.body);
    res.status(201).json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/categories/:id
// @desc    Update category
// @access  Admin
router.put('/:id', auth, admin, async (req, res) => {
  try {
    const category = await Category.findByIdAndUpdate(
      req.params.id,
      req.body,
      { new: true }
    );
    if (!category) {
      return res.status(404).json({ message: 'Categorie non trouvee' });
    }
    res.json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/categories/:id
// @desc    Delete category
// @access  Admin
router.delete('/:id', auth, admin, async (req, res) => {
  try {
    const category = await Category.findByIdAndDelete(req.params.id);
    if (!category) {
      return res.status(404).json({ message: 'Categorie non trouvee' });
    }
    res.json({ message: 'Categorie supprimee' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/categories/:id/toggle
// @desc    Toggle active status
// @access  Admin
router.put('/:id/toggle', auth, admin, async (req, res) => {
  try {
    const category = await Category.findById(req.params.id);
    if (!category) {
      return res.status(404).json({ message: 'Categorie non trouvee' });
    }
    category.isActive = !category.isActive;
    await category.save();
    res.json(category);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;


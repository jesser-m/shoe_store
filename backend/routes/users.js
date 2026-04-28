const express = require('express');
const User = require('../models/User');
const auth = require('../middleware/auth');
const admin = require('../middleware/admin');
const router = express.Router();

// @route   GET /api/users
// @desc    Get all users
// @access  Admin
router.get('/', auth, admin, async (req, res) => {
  try {
    const users = await User.find().select('-password').sort({ createdAt: -1 });
    res.json(users);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   GET /api/users/:id
// @desc    Get user by ID
// @access  Admin
router.get('/:id', auth, admin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouve' });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/users/:id/role
// @desc    Update user role
// @access  Admin
router.put('/:id/role', auth, admin, async (req, res) => {
  try {
    const { role } = req.body;
    const user = await User.findByIdAndUpdate(
      req.params.id,
      { role },
      { new: true }
    ).select('-password');
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouve' });
    }
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   PUT /api/users/:id/toggle
// @desc    Toggle user active status
// @access  Admin
router.put('/:id/toggle', auth, admin, async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouve' });
    }
    user.isActive = !user.isActive;
    await user.save();
    res.json(user);
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   DELETE /api/users/:id
// @desc    Delete user
// @access  Admin
router.delete('/:id', auth, admin, async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return res.status(404).json({ message: 'Utilisateur non trouve' });
    }
    res.json({ message: 'Utilisateur supprime' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;


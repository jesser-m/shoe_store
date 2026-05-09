// Auth Routes
const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const User = require('../models/User');
const { sendPasswordResetEmail } = require('../services/emailService');

// @route   POST api/auth/register
// @desc    Register user
// @access  Public
router.post('/register', async (req, res) => {
  const { email, displayName, password, phone } = req.body;

  try {
    let user = await User.findOne({ email });
    if (user) {
      return res.status(400).json({ msg: 'User already exists' });
    }

    user = new User({
      email,
      displayName,
      phone,
      role: 'client'
    });

    const salt = await bcrypt.genSalt(10);
    user.password = await bcrypt.hash(password, salt);

    await user.save();

    const payload = {
      user: {
        id: user.id,
        role: user.role
      }
    };

    jwt.sign(
      payload,
      process.env.JWT_SECRET,
      { expiresIn: 360000 },
      (err, token) => {
        if (err) throw err;
        res.json({ token });
      }
    );
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

// @route   POST api/auth/login
// @desc    Authenticate user & get token
// @access  Public
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  try {
    let user = await User.findOne({ email });
    if (!user) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ msg: 'Invalid credentials' });
    }

    const payload = {
      user: {
        id: user.id,
        role: user.role
      }
    };

      jwt.sign(
        payload,
        process.env.JWT_SECRET,
        { expiresIn: 360000 },
        (err, token) => {
          if (err) throw err;
          res.json({
            token,
            _id: user._id,
            email: user.email,
            role: user.role,
            displayName: user.displayName,
            isActive: user.isActive,
            createdAt: user.createdAt
          });
        }
      );
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server error');
    }
  });

  // @route   GET api/auth/profile
  // @desc    Get user data
  // @access  Private
  router.get('/profile', require('../middleware/auth'), async (req, res) => {
    try {
      const user = await User.findById(req.user.id).select('-password');
      res.json(user);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
});

  // @route   POST api/auth/reset-password/request
  // @desc    Request a password reset code via phone
  // @access  Public
  router.post('/reset-password/request', async (req, res) => {
    const { email, phone } = req.body;
    try {
      const user = await User.findOne({ email, phone });
      if (!user) {
        return res.status(404).json({ message: 'Aucun utilisateur trouvé avec cet email et ce numéro.' });
      }

      // Generate a 6-digit code
      const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
      const resetCodeExpires = new Date(Date.now() + 10 * 60000); // 10 minutes

      user.resetCode = resetCode;
      user.resetCodeExpires = resetCodeExpires;
      await user.save();

      // Send email
      try {
        await sendPasswordResetEmail(user.email, resetCode);
      } catch (emailErr) {
        console.error('Error sending reset email:', emailErr);
      }

      console.log(`[SMS MOCK] Code de réinitialisation pour ${phone}: ${resetCode}`);
      
      res.json({ msg: 'Code envoyé avec succès', devCode: resetCode }); 
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server error');
    }
  });

  // @route   POST api/auth/reset-password/verify
  // @desc    Verify code and reset password
  // @access  Public
  router.post('/reset-password/verify', async (req, res) => {
    const { email, phone, code, newPassword } = req.body;
    try {
      const user = await User.findOne({ email, phone, resetCode: code });
      if (!user) {
        return res.status(400).json({ message: 'Code invalide ou informations incorrectes.' });
      }

      if (user.resetCodeExpires < new Date()) {
        return res.status(400).json({ message: 'Le code a expiré.' });
      }

      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(newPassword, salt);
      
      user.resetCode = undefined;
      user.resetCodeExpires = undefined;

      await user.save();

      res.json({ msg: 'Mot de passe réinitialisé avec succès.' });
    } catch (err) {
      console.error(err.message);
      res.status(500).send('Server error');
    }
  });

module.exports = router;
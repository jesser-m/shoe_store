const express = require('express');
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const router = express.Router();

// @route   POST /api/upload/image
// @desc    Upload single image
// @access  Private
router.post('/image', auth, upload.single('image'), (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'Aucun fichier fourni' });
    }

    const imageUrl = `${req.protocol}://${req.get('host')}/uploads/${req.file.filename}`;
    res.json({ imageUrl });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// @route   POST /api/upload/images
// @desc    Upload multiple images
// @access  Private
router.post('/images', auth, upload.array('images', 5), (req, res) => {
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'Aucun fichier fourni' });
    }

    const imageUrls = req.files.map((file) => {
      return `${req.protocol}://${req.get('host')}/uploads/${file.filename}`;
    });

    res.json({ imageUrls });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;


// Upload Routes
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const upload = require('../middleware/upload');
const fs = require('fs');
const path = require('path');

// @route   POST api/upload
// @desc    Upload image file
// @access  Private
router.post('/', auth, (req, res) => {
  const uploadSingle = upload.single('image');

  uploadSingle(req, res, (err) => {
    if (err) {
      console.error('Upload error:', err.message);
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ msg: 'Image trop lourde (max 10Mo)' });
      }
      return res.status(400).json({ msg: err.message });
    }

    if (!req.file) {
      return res.status(400).json({ msg: 'Aucun fichier sélectionné' });
    }

    try {
      // Construct URL for the uploaded file
      const imageUrl = `/uploads/${req.file.filename}`;
      res.json({
        msg: 'Fichier uploadé avec succès',
        imageUrl: imageUrl
      });
    } catch (err) {
      console.error('Processing error:', err.message);
      res.status(500).json({ msg: 'Erreur serveur lors du traitement de l\'image', error: err.message });
    }
  });
});

// @route   GET api/upload/:filename
// @desc    Get uploaded image
// @access  Public
router.get('/:filename', (req, res) => {
  const filename = req.params.filename;
  const filePath = path.join(__dirname, '../uploads', filename);

  // Check if file exists
  fs.access(filePath, fs.constants.F_OK, (err) => {
    if (err) {
      return res.status(404).json({ msg: 'Image not found' });
    }

    // Send file
    res.sendFile(filePath);
  });
});

module.exports = router;
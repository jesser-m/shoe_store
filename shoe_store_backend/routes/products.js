// Products Routes
const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const Product = require('../models/Product');

// @route   GET api/products
// @desc    Get all products
// @access  Public
router.get('/', async (req, res) => {
  try {
    const products = await Product.find();
    res.json(products);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   GET api/products/:id
// @desc    Get product by ID
// @access  Public
router.get('/:id', async (req, res) => {
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ msg: 'Product not found' });
    }
    res.json(product);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   POST api/products
// @desc    Create a product
// @access  Private/Admin
router.post('/', auth, async (req, res) => {
  const { name, description, price, stockQuantity, imageUrl, images, sizes, colors, category, brand, rating, reviewCount, inStock } = req.body;

  try {
    const newProduct = new Product({
      name,
      description,
      price,
      brand,
      imageUrl,
      images,
      sizes,
      colors,
      category,
      rating,
      reviewCount,
      inStock,
      stockQuantity
    });

    const product = await newProduct.save();
    res.json(product);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   PUT api/products/:id
// @desc    Update a product
// @access  Private/Admin
router.put('/:id', auth, async (req, res) => {
  const { name, description, price, stockQuantity, imageUrl, images, sizes, colors, category, brand, rating, reviewCount, inStock } = req.body;

  try {
    let product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ msg: 'Product not found' });
    }

    // Update fields if provided
    if (name !== undefined) product.name = name;
    if (description !== undefined) product.description = description;
    if (price !== undefined) product.price = price;
    if (brand !== undefined) product.brand = brand;
    if (imageUrl !== undefined) product.imageUrl = imageUrl;
    if (images !== undefined) product.images = images;
    if (sizes !== undefined) product.sizes = sizes;
    if (colors !== undefined) product.colors = colors;
    if (category !== undefined) product.category = category;
    if (rating !== undefined) product.rating = rating;
    if (reviewCount !== undefined) product.reviewCount = reviewCount;
    if (inStock !== undefined) product.inStock = inStock;
    if (stockQuantity !== undefined) product.stockQuantity = stockQuantity;

    await product.save();
    res.json(product);
  } catch (err) {
    console.error(err.message);
    res.status(500).json({ msg: 'Server Error', error: err.message });
  }
});

// @route   DELETE api/products/:id
// @desc    Delete a product
// @access  Private/Admin
router.delete('/:id', auth, async (req, res) => {
  try {
    let product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({ msg: 'Product not found' });
    }

    await Product.findByIdAndDelete(req.params.id);
    res.json({ msg: 'Product removed' });
  } catch (err) {
    console.error('Delete error:', err.message);
    res.status(500).json({ msg: 'Erreur serveur lors de la suppression', error: err.message });
  }
});

module.exports = router;
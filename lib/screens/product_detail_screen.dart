import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  String? _selectedSize;
  String? _selectedColor;

  @override
  void initState() {
    super.initState();
    // Set default selections if available
    if (widget.product.sizes.isNotEmpty) {
      _selectedSize = widget.product.sizes.first;
    }
    if (widget.product.colors.isNotEmpty) {
      _selectedColor = widget.product.colors.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product.name),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (ctx, favorites, _) => IconButton(
              icon: Icon(
                favorites.isFavorite(widget.product.id)
                    ? Icons.favorite
                    : Icons.favorite_border,
              ),
              onPressed: () {
                favorites.toggleFavorite(widget.product);
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: widget.product.images.isNotEmpty
                    ? widget.product.images.length
                    : 1,
                onPageChanged: (index) =>
                    setState(() => _currentImageIndex = index),
                itemBuilder: (ctx, i) => Hero(
                  tag: 'product_image_${widget.product.id}',
                  child: Image.network(
                    widget.product.images.isNotEmpty
                        ? widget.product.images[i]
                        : widget.product.imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),
                ),
              ),
            ),
            // Image Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.product.images.isNotEmpty
                    ? widget.product.images.length
                    : 1,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 8,
                  ),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentImageIndex == i
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.product.price.toStringAsFixed(2)} €',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(
                            widget.product.rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 16),
                          ),
                          Text(
                            ' (${widget.product.reviewCount})',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  Text(
                    widget.product.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  // Size Selection
                  if (widget.product.sizes.isNotEmpty) ...[
                    const Text(
                      'Taille',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedSize,
                      hint: const Text('Sélectionnez une taille'),
                      items: widget.product.sizes
                          .map(
                            (size) => DropdownMenuItem(
                              value: size,
                              child: Text(size),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedSize = value),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  // Color Selection
                  if (widget.product.colors.isNotEmpty) ...[
                    const Text(
                      'Couleur',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedColor,
                      hint: const Text('Sélectionnez une couleur'),
                      items: widget.product.colors
                          .map(
                            (color) => DropdownMenuItem(
                              value: color,
                              child: Text(color),
                            ),
                          )
                          .toList(),
                      onChanged: (value) =>
                          setState(() => _selectedColor = value),
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Add to Cart Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Ajouter au panier'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed:
                          (widget.product.sizes.isEmpty ||
                                  _selectedSize != null) &&
                              (widget.product.colors.isEmpty ||
                                  _selectedColor != null)
                          ? () {
                              cart.addItem(
                                widget.product.id,
                                widget.product.price,
                                widget.product.name,
                                widget.product.imageUrl,
                              );
                              ScaffoldMessenger.of(
                                context,
                              ).hideCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.product.name} ajouté au panier !',
                                  ),
                                ),
                              );
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Reviews Section
                  const Text(
                    'Avis des clients',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  _buildReview(
                    'Alice',
                    5,
                    'Superbes chaussures, très confortables !',
                  ),
                  _buildReview('Bob', 4, 'Bon rapport qualité-prix.'),
                  _buildReview('Charlie', 5, 'Je recommande vivement.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReview(String name, int rating, String comment) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Row(
                  children: List.generate(
                    5,
                    (i) => Icon(
                      i < rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(comment),
          ],
        ),
      ),
    );
  }
}

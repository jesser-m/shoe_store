import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class ProductCard extends StatefulWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> with TickerProviderStateMixin { // Changement ici pour gérer 2 controllers
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  late AnimationController _successAnimationController;
  late Animation<double> _successScaleAnimation;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    
    // Animation de clic (rétrécissement)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Animation de succÃ¨s (rebond)
    _successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _successScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _successAnimationController, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _successAnimationController.dispose();
    super.dispose();
  }

  void _showAddToCartSuccess() {
    setState(() => _showSuccess = true);
    _successAnimationController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) {
          _successAnimationController.reverse().then((_) {
            setState(() => _showSuccess = false);
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // On n'écoute pas le panier ici pour éviter de reconstruire toute la carte inutilement
    final cart = Provider.of<CartProvider>(context, listen: false);
    
    return Consumer<FavoritesProvider>( // Plus efficace pour écouter uniquement les favoris
      builder: (context, favorites, child) {
        final isFavorite = favorites.isFavorite(widget.product.id);
        
        return AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _successScaleAnimation]),
          builder: (context, child) {
            return Transform.scale(
              scale: _showSuccess ? _successScaleAnimation.value : _scaleAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTapDown: (_) => _animationController.forward(),
            onTapUp: (_) => _animationController.reverse(),
            onTapCancel: () => _animationController.reverse(),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (ctx) => ProductDetailScreen(product: widget.product),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 5,
              clipBehavior: Clip.antiAlias, // Important pour les bords arrondis
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        // Image avec Hero
                        Positioned.fill(
                          child: Hero(
                            tag: 'product_image_${widget.product.id}',
                            child: Image.network(
                              widget.product.imageUrl,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        // Overlay Gradient
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.6)],
                              ),
                            ),
                          ),
                        ),
                        // Overlay SuccÃ¨s
                        if (_showSuccess)
                          Positioned.fill(
                            child: Container(
                              color: Colors.green.withValues(alpha: 0.7),
                              child: const Icon(Icons.check_circle, color: Colors.white, size: 50),
                            ),
                          ),
                        // Bouton Favoris
                        Positioned(
                          top: 8,
                          right: 8,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withValues(alpha: 0.9),
                            child: IconButton(
                              icon: Icon(
                                isFavorite ? Icons.favorite : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.black54,
                              ),
                              onPressed: () => favorites.toggleFavorite(widget.product),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Détails en bas
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.name,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text('${widget.product.price} TND', style: const TextStyle(color: Colors.blueGrey)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart, color: Colors.blue),
                          onPressed: () {
                            cart.addItem(widget.product.id, widget.product.price, widget.product.name, widget.product.imageUrl);
                            _showAddToCartSuccess();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}



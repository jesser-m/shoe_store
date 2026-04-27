import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../screens/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> with TickerProviderStateMixin {
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _fabAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Panier'),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Vider le panier'),
                    content: const Text(
                      'Êtes-vous sûr de vouloir vider votre panier ?',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () {
                          cart.clear();
                          Navigator.of(ctx).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Panier vidé')),
                          );
                        },
                        child: const Text('Vider'),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(cart, cartItems),
      floatingActionButton: cartItems.isNotEmpty
          ? AnimatedBuilder(
              animation: _fabScaleAnimation,
              builder: (context, child) => Transform.scale(
                scale: _fabScaleAnimation.value,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    _fabAnimationController.forward().then((_) {
                      _fabAnimationController.reverse();
                    });
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const CheckoutScreen(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              const begin = Offset(0.0, 1.0);
                              const end = Offset.zero;
                              const curve = Curves.easeInOutCubic;

                              var tween = Tween(
                                begin: begin,
                                end: end,
                              ).chain(CurveTween(curve: curve));
                              var offsetAnimation = animation.drive(tween);

                              return SlideTransition(
                                position: offsetAnimation,
                                child: child,
                              );
                            },
                      ),
                    );
                  },
                  icon: const Icon(Icons.payment),
                  label: const Text('PAIEMENT'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Votre panier est vide',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ajoutez des produits pour commencer vos achats',
            style: TextStyle(fontSize: 16, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.shopping_bag),
            label: const Text('Continuer mes achats'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(CartProvider cart, List cartItems) {
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(15),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Chip(
                  label: Text(
                    '${cart.totalAmount.toStringAsFixed(2)} €',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: cartItems.length,
            itemBuilder: (ctx, i) {
              final item = cartItems[i];
              return Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  cart.removeItem(item.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${item.name} retiré du panier'),
                      action: SnackBarAction(
                        label: 'Annuler',
                        onPressed: () => cart.addItem(
                          item.id,
                          item.price,
                          item.name,
                          item.imageUrl,
                        ),
                      ),
                    ),
                  );
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Hero(
                      tag: 'cart_item_${item.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  size: 24,
                                ),
                              ),
                        ),
                      ),
                    ),
                    title: Text(
                      item.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      'Total: ${(item.price * item.quantity).toStringAsFixed(2)} €',
                    ),
                    trailing: SizedBox(
                      width: 110,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () => cart.removeSingleItem(item.id),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                                  return ScaleTransition(
                                    scale: animation,
                                    child: child,
                                  );
                                },
                            child: Text(
                              item.quantity.toString(),
                              key: ValueKey(item.quantity),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () => cart.addItem(
                              item.id,
                              item.price,
                              item.name,
                              item.imageUrl,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}



import '../providers/cart_provider.dart';
import 'api_service.dart';

class CartService {
  // Get user's cart
  Future<List<CartItem>> getCart(String userId) async {
    try {
      final response = await ApiService.get('/cart');
      final data = ApiService.handleResponse(response);
      final items = data['items'] as List<dynamic>? ?? [];
      return items
          .map(
            (item) => CartItem(
              productId: item['productId']?.toString() ?? '',
              name: item['name'] ?? '',
              price: (item['price'] ?? 0.0).toDouble(),
              imageUrl: item['imageUrl'] ?? '',
              size: item['size'],
              color: item['color'],
              quantity: item['quantity'] ?? 1,
            ),
          )
          .toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement du panier: $e');
    }
  }

  // Save cart (sync all items)
  Future<void> saveCart(String userId, Map<String, CartItem> items) async {
    try {
      // First clear then add all (simple approach)
      await ApiService.delete('/cart');
      for (final item in items.values) {
        await ApiService.post(
          '/cart/add',
          body: {
            'productId': item.productId,
            'name': item.name,
            'price': item.price,
            'imageUrl': item.imageUrl,
            'size': item.size,
            'color': item.color,
            'quantity': item.quantity,
          },
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la sauvegarde du panier: $e');
    }
  }

  // Update single cart item
  Future<void> updateCartItem(
    String userId,
    String cartItemId,
    CartItem item,
  ) async {
    try {
      await ApiService.put(
        '/cart/update',
        body: {
          'productId': item.productId,
          'size': item.size,
          'color': item.color,
          'quantity': item.quantity,
        },
      );
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du panier: $e');
    }
  }

  // Remove item from cart
  Future<void> removeCartItem(String userId, String cartItemId) async {
    try {
      final parts = cartItemId.split('_');
      if (parts.length >= 3) {
        final productId = parts[0];
        final size = parts[1].replaceAll('_', ' ');
        final color = parts.sublist(2).join('_').replaceAll('_', ' ');
        await ApiService.delete(
          '/cart/remove',
          body: {'productId': productId, 'size': size, 'color': color},
        );
      }
    } catch (e) {
      throw Exception('Erreur lors de la suppression de l\'article: $e');
    }
  }

  // Clear cart
  Future<void> clearCart(String userId) async {
    try {
      await ApiService.delete('/cart');
    } catch (e) {
      throw Exception('Erreur lors du vidage du panier: $e');
    }
  }
}

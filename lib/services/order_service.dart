import '../models/order.dart';
import 'api_service.dart';

class OrderService {
  // Create new order
  Future<Order> createOrder(Order order) async {
    try {
      final response = await ApiService.post('/orders', body: order.toJson());
      final data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors de la creation de la commande: $e');
    }
  }

  // Get user's orders
  Future<List<Order>> getUserOrders(String userId) async {
    try {
      final response = await ApiService.get('/orders');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes: $e');
    }
  }

  // Get single order
  Future<Order?> getOrder(String orderId) async {
    try {
      final response = await ApiService.get('/orders/$orderId');
      if (response.statusCode == 404) return null;
      final data = ApiService.handleResponse(response);
      return Order.fromJson(data);
    } catch (e) {
      throw Exception('Erreur lors du chargement de la commande: $e');
    }
  }

  // Get all orders (admin)
  Future<List<Order>> getAllOrders({String? status}) async {
    try {
      final query = status != null && status != 'all' ? '?status=$status' : '';
      final response = await ApiService.get('/orders/all$query');
      final data = ApiService.handleResponse(response);
      final List<dynamic> list = data is List ? data : [];
      return list.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final response = await ApiService.put(
        '/orders/$orderId/status',
        body: {'status': newStatus},
      );
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de la mise a jour du statut: $e');
    }
  }

  // Cancel order
  Future<void> cancelOrder(String orderId) async {
    try {
      final response = await ApiService.put('/orders/$orderId/cancel');
      ApiService.handleResponse(response);
    } catch (e) {
      throw Exception('Erreur lors de l\'annulation de la commande: $e');
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStats() async {
    try {
      final response = await ApiService.get('/orders/stats/summary');
      final data = ApiService.handleResponse(response);
      return {
        'total': data['total'] ?? 0,
        'pending': data['pending'] ?? 0,
        'paid': data['paid'] ?? 0,
        'shipped': data['shipped'] ?? 0,
        'delivered': data['delivered'] ?? 0,
        'cancelled': data['cancelled'] ?? 0,
        'totalRevenue': (data['totalRevenue'] ?? 0.0).toDouble(),
      };
    } catch (e) {
      throw Exception('Erreur lors du calcul des statistiques: $e');
    }
  }
}

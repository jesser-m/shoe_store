import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Order;
import '../models/order.dart';

class OrderProvider with ChangeNotifier {
  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot>? _ordersSubscription;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;
  String _statusFilter = 'all';

  List<Order> get orders => [..._orders];
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get statusFilter => _statusFilter;

  List<Order> get filteredOrders {
    if (_statusFilter == 'all') return orders;
    return orders.where((o) => o.status == _statusFilter).toList();
  }

  // Stats
  double get totalRevenue => _orders
      .where((o) => o.status != 'cancelled')
      .fold(0, (sum, o) => sum + o.totalAmount);

  int get pendingCount => _orders.where((o) => o.status == 'pending').length;
  int get shippedCount => _orders.where((o) => o.status == 'shipped').length;
  int get deliveredCount =>
      _orders.where((o) => o.status == 'delivered').length;
  int get cancelledCount =>
      _orders.where((o) => o.status == 'cancelled').length;

  // Revenue per day (last 7 days)
  Map<String, double> get revenueByDay {
    final now = DateTime.now();
    final Map<String, double> result = {};
    for (int i = 6; i >= 0; i--) {
      final day = now.subtract(Duration(days: i));
      final key = '${day.day}/${day.month}';
      result[key] = 0;
    }
    for (final order in _orders) {
      if (order.status == 'cancelled') continue;
      final diff = now.difference(order.createdAt).inDays;
      if (diff <= 6) {
        final key = '${order.createdAt.day}/${order.createdAt.month}';
        result[key] = (result[key] ?? 0) + order.totalAmount;
      }
    }
    return result;
  }

  void setFilter(String status) {
    _statusFilter = status;
    notifyListeners();
  }

  Future<void> loadOrders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final snapshot = await _firestore
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .get();

      _orders = snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      _orders = _getDemoOrders();
      notifyListeners();
      debugPrint('Error loading orders: $e - using demo data');
    }
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': Timestamp.now(),
      });
      final idx = _orders.indexWhere((o) => o.id == orderId);
      if (idx != -1) {
        _orders[idx] = _orders[idx].copyWith(
          status: newStatus,
          updatedAt: DateTime.now(),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error updating order: $e');
      throw Exception('Erreur lors de la mise à jour');
    }
  }

  void startListening() {
    _ordersSubscription?.cancel();
    _ordersSubscription = _firestore
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            _orders = snapshot.docs
                .map((doc) => Order.fromFirestore(doc))
                .toList();
            notifyListeners();
          },
          onError: (e) {
            _error = e.toString();
            notifyListeners();
          },
        );
  }

  void stopListening() {
    _ordersSubscription?.cancel();
  }

  List<Order> _getDemoOrders() {
    final now = DateTime.now();
    return [
      Order(
        id: 'ORD-001',
        userId: 'user1',
        items: [
          OrderItem(
            productId: '1',
            productName: 'Nike Air Max 270',
            productImage:
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
            price: 199.99,
            quantity: 1,
            size: '42',
            color: 'Noir',
          ),
        ],
        totalAmount: 199.99,
        status: 'pending',
        createdAt: now.subtract(const Duration(hours: 2)),
        shippingAddress: ShippingAddress(
          fullName: 'Ahmed Ben Ali',
          address: '12 Rue de la Paix',
          city: 'Tunis',
          postalCode: '1000',
          country: 'Tunisie',
          phone: '+216 71 000 000',
        ),
      ),
      Order(
        id: 'ORD-002',
        userId: 'user2',
        items: [
          OrderItem(
            productId: '2',
            productName: 'Adidas Ultraboost 22',
            productImage:
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
            price: 189.99,
            quantity: 2,
            size: '41',
            color: 'Blanc',
          ),
        ],
        totalAmount: 379.98,
        status: 'shipped',
        createdAt: now.subtract(const Duration(days: 1)),
        shippingAddress: ShippingAddress(
          fullName: 'Sana Trabelsi',
          address: '5 Avenue Habib Bourguiba',
          city: 'Sfax',
          postalCode: '3000',
          country: 'Tunisie',
        ),
      ),
      Order(
        id: 'ORD-003',
        userId: 'user3',
        items: [
          OrderItem(
            productId: '4',
            productName: 'Nike Air Jordan 1',
            productImage:
                'https://images.unsplash.com/photo-1597043530274-07e0c40e0c8b',
            price: 299.99,
            quantity: 1,
            size: '43',
            color: 'Rouge',
          ),
        ],
        totalAmount: 299.99,
        status: 'delivered',
        createdAt: now.subtract(const Duration(days: 3)),
        shippingAddress: ShippingAddress(
          fullName: 'Mohamed Karray',
          address: '8 Rue Ibn Khaldoun',
          city: 'Sousse',
          postalCode: '4000',
          country: 'Tunisie',
        ),
      ),
      Order(
        id: 'ORD-004',
        userId: 'user4',
        items: [
          OrderItem(
            productId: '3',
            productName: 'Puma RS-X³',
            productImage:
                'https://images.unsplash.com/photo-1512374382149-4332c6c021f1',
            price: 149.99,
            quantity: 1,
            size: '40',
            color: 'Multicolore',
          ),
        ],
        totalAmount: 149.99,
        status: 'cancelled',
        createdAt: now.subtract(const Duration(days: 5)),
        shippingAddress: ShippingAddress(
          fullName: 'Leila Mansouri',
          address: '3 Rue des Fleurs',
          city: 'Bizerte',
          postalCode: '7000',
          country: 'Tunisie',
        ),
      ),
      Order(
        id: 'ORD-005',
        userId: 'user1',
        items: [
          OrderItem(
            productId: '1',
            productName: 'Nike Air Max 270',
            productImage:
                'https://images.unsplash.com/photo-1542291026-7eec264c27ff',
            price: 199.99,
            quantity: 1,
            size: '44',
            color: 'Blanc',
          ),
          OrderItem(
            productId: '2',
            productName: 'Adidas Ultraboost 22',
            productImage:
                'https://images.unsplash.com/photo-1523275335684-37898b6baf30',
            price: 189.99,
            quantity: 1,
            size: '44',
            color: 'Noir',
          ),
        ],
        totalAmount: 389.98,
        status: 'paid',
        createdAt: now.subtract(const Duration(days: 2)),
        shippingAddress: ShippingAddress(
          fullName: 'Ahmed Ben Ali',
          address: '12 Rue de la Paix',
          city: 'Tunis',
          postalCode: '1000',
          country: 'Tunisie',
        ),
      ),
    ];
  }

  @override
  void dispose() {
    _ordersSubscription?.cancel();
    super.dispose();
  }
}

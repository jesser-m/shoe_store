import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/api_service.dart';
import '../models/order.dart' as order_model;
import '../services/order_service.dart';
import '../config/stripe_config.dart';
import '../config/api_config.dart';
import 'package:url_launcher/url_launcher.dart';
class PaymentProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize Stripe
  Future<void> initializeStripe() async {
    try {
      if (!kIsWeb) {
        Stripe.publishableKey = StripeConfig.publishableKey;
        await Stripe.instance.applySettings();
      }
    } catch (e) {
      _error = 'Erreur d\'initialisation Stripe: $e';
      notifyListeners();
    }
  }

  // Create payment intent on the server
  Future<Map<String, dynamic>?> _createPaymentIntent({
    required double amount,
    required String currency,
    required String customerEmail,
  }) async {
    try {
      final response = await ApiService.post(
        '/payment/create-payment-intent',
        body: {
          'amount': amount,
          'currency': currency,
          'customerEmail': customerEmail,
        },
      );

      return ApiService.handleResponse(response);
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      rethrow;
    }
  }

  // Process payment
  Future<String?> processPayment({
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    required String customerEmail,
    required order_model.ShippingAddress shippingAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (kIsWeb) {
        // Web flow: Use Stripe Checkout
        final session = await ApiService.post(
          '/payment/create-checkout-session',
          body: {
            'items': cartItems,
            'customerEmail': customerEmail,
            'successUrl': '${Uri.base.origin}/#/orders?status=success',
            'cancelUrl': '${Uri.base.origin}/#/checkout?status=cancel',
          },
        );

        final sessionData = ApiService.handleResponse(session);
        if (sessionData != null && sessionData['url'] != null) {
          // Redirect to Stripe Checkout
          final url = Uri.parse(sessionData['url'] as String);
          
          if (await canLaunchUrl(url)) {
            await launchUrl(url, mode: LaunchMode.externalApplication);
          } else {
            throw Exception('Impossible d\'ouvrir la page de paiement');
          }
          
          return 'web_checkout_redirect';
        } else {
          throw Exception('Impossible de créer la session de paiement');
        }
      } else {
        // Mobile flow: Use Payment Sheet
        final paymentIntent = await _createPaymentIntent(
          amount: totalAmount,
          currency: 'eur',
          customerEmail: customerEmail,
        );

        if (paymentIntent == null) {
          throw Exception('Impossible de créer l\'intention de paiement');
        }

        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            paymentIntentClientSecret: paymentIntent['client_secret'],
            merchantDisplayName: 'Shoe Store',
            style: ThemeMode.system,
            billingDetails: BillingDetails(
              email: customerEmail,
              address: Address(
                city: shippingAddress.city,
                country: shippingAddress.country,
                line1: shippingAddress.address,
                line2: null,
                postalCode: shippingAddress.postalCode,
                state: null,
              ),
            ),
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        _isLoading = false;
        notifyListeners();
        return paymentIntent['id'];
      }
    } catch (e) {
      _isLoading = false;
      _error = 'Erreur de paiement: $e';
      notifyListeners();
      return null;
    }
  }

  // Create order after successful payment
  Future<order_model.Order> createOrder({
    required String userId,
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    required order_model.ShippingAddress shippingAddress,
    required String paymentIntentId,
  }) async {
    final orderItems = cartItems.map((item) {
      return order_model.OrderItem(
        productId: item['id'],
        productName: item['name'],
        productImage: item['imageUrl'] ?? '',
        price: item['price'],
        quantity: item['quantity'],
        size: item['size'],
        color: item['color'],
      );
    }).toList();

    final order = order_model.Order(
      id: '',
      userId: userId,
      items: orderItems,
      totalAmount: totalAmount,
      status: 'paid',
      createdAt: DateTime.now(),
      paymentIntentId: paymentIntentId,
      shippingAddress: shippingAddress,
    );

    try {
      final orderService = OrderService();
      final createdOrder = await orderService.createOrder(order);
      return createdOrder;
    } catch (e) {
      debugPrint('Error saving order to backend: $e');
      return order.copyWith(
        id: 'mock_order_${DateTime.now().millisecondsSinceEpoch}',
      );
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

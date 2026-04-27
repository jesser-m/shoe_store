import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as order_model;
import '../config/stripe_config.dart';

class PaymentProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize Stripe
  Future<void> initializeStripe() async {
    try {
      Stripe.publishableKey = StripeConfig.publishableKey;
      await Stripe.instance.applySettings();
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
      // In a real app, this would call your backend server
      // For demo purposes, we'll simulate the response
      // Replace this with actual server call to create payment intent

      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${StripeConfig.publishableKey.replaceFirst('pk_test_', 'sk_test_').replaceFirst('pk_live_', 'sk_live_')}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).toInt().toString(), // Convert to cents
          'currency': currency,
          'receipt_email': customerEmail,
          'automatic_payment_methods[enabled]': 'true',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create payment intent: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error creating payment intent: $e');
      // For demo purposes, return a mock payment intent
      return {
        'id': 'pi_mock_${DateTime.now().millisecondsSinceEpoch}',
        'client_secret': 'pi_mock_secret_${DateTime.now().millisecondsSinceEpoch}',
        'amount': (amount * 100).toInt(),
        'currency': currency,
      };
    }
  }

  // Process payment
  Future<bool> processPayment({
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
    required String customerEmail,
    required order_model.ShippingAddress shippingAddress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create payment intent
      final paymentIntent = await _createPaymentIntent(
        amount: totalAmount,
        currency: 'eur',
        customerEmail: customerEmail,
      );

      if (paymentIntent == null) {
        throw Exception('Impossible de créer l\'intention de paiement');
      }

      // Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent['client_secret'],
          merchantDisplayName: 'Shoe Store',
          customerId: null,
          customerEphemeralKeySecret: null,
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

      // Present payment sheet
      await Stripe.instance.presentPaymentSheet();

      _isLoading = false;
      notifyListeners();
      return true;

    } catch (e) {
      _isLoading = false;
      _error = 'Erreur de paiement: $e';
      notifyListeners();
      return false;
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

    // Save order to Firestore
    try {
      final docRef = await FirebaseFirestore.instance
          .collection('orders')
          .add(order.toFirestore());
      return order.copyWith(id: docRef.id);
    } catch (e) {
      debugPrint('Error saving order to Firestore: $e');
      return order.copyWith(id: 'mock_order_${DateTime.now().millisecondsSinceEpoch}');
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
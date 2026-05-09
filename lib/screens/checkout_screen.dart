import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/auth_provider.dart';
import '../models/order.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _countryController = TextEditingController(text: 'France');
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();
  String _paymentMethod = 'card'; // 'card' or 'cod'

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: cart.items.isEmpty
          ? const Center(child: Text('Votre panier est vide'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Order Summary
                  const Text(
                    'Récapitulatif de commande',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: cart.items.entries.map((entry) {
                          final item = entry.value;
                          return ListTile(
                            leading: Image.network(
                              item.imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text(item.name),
                            subtitle: Text('Quantité: ${item.quantity}'),
                            trailing: Text(
                              '${(item.price * item.quantity).toStringAsFixed(2)} â‚¬',
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total:',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${cart.totalAmount.toStringAsFixed(2)} â‚¬',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Shipping Information
                  const Text(
                    'Informations de livraison',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom complet',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre nom complet';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Adresse',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre adresse';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _cityController,
                                decoration: const InputDecoration(
                                  labelText: 'Ville',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre ville';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _postalCodeController,
                                decoration: const InputDecoration(
                                  labelText: 'Code postal',
                                  border: OutlineInputBorder(),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez entrer votre code postal';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _countryController,
                          decoration: const InputDecoration(
                            labelText: 'Pays',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer votre pays';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone (optionnel)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _notesController,
                          decoration: const InputDecoration(
                            labelText: 'Notes de livraison (optionnel)',
                            border: OutlineInputBorder(),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Method Selection
                  const Text(
                    'Méthode de paiement',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        RadioListTile<String>(
                          value: 'card',
                          groupValue: _paymentMethod,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: const Text('Carte Bancaire'),
                          secondary: const Icon(Icons.credit_card, color: Colors.blue),
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                        const Divider(height: 1),
                        RadioListTile<String>(
                          value: 'cod',
                          groupValue: _paymentMethod,
                          activeColor: Theme.of(context).colorScheme.primary,
                          title: const Text('Paiement à la livraison'),
                          secondary: const Icon(Icons.delivery_dining, color: Colors.green),
                          onChanged: (v) => setState(() => _paymentMethod = v!),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Payment Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: paymentProvider.isLoading
                          ? null
                          : () async {
                              if (_formKey.currentState!.validate()) {
                                final shippingAddress = ShippingAddress(
                                  fullName: _fullNameController.text,
                                  address: _addressController.text,
                                  city: _cityController.text,
                                  postalCode: _postalCodeController.text,
                                  country: _countryController.text,
                                  phone: _phoneController.text.isNotEmpty
                                      ? _phoneController.text
                                      : null,
                                );

                                final cartItems = cart.items.entries.map((
                                  entry,
                                ) {
                                  final item = entry.value;
                                  return {
                                    'id': item.id,
                                    'name': item.name,
                                    'imageUrl': item.imageUrl,
                                    'price': item.price,
                                    'quantity': item.quantity,
                                  };
                                }).toList();

                                bool success = false;
                                String paymentId = '';

                                if (_paymentMethod == 'card') {
                                  final pId = await paymentProvider.processPayment(
                                    cartItems: cartItems,
                                    totalAmount: cart.totalAmount,
                                    customerEmail: authProvider.user?.email ?? '',
                                    shippingAddress: shippingAddress,
                                  );
                                  if (pId != null) {
                                    success = true;
                                    paymentId = pId;
                                  }
                                } else {
                                  // COD is always "success" in this step
                                  success = true;
                                  paymentId = 'cod_${DateTime.now().millisecondsSinceEpoch}';
                                }

                                if (success) {
                                  // Create order
                                  await paymentProvider.createOrder(
                                    userId: authProvider.user!.uid,
                                    cartItems: cartItems,
                                    totalAmount: cart.totalAmount,
                                    shippingAddress: shippingAddress,
                                    paymentIntentId: paymentId,
                                  );

                                  // Clear cart
                                  cart.clear();

                                  // Show success message and navigate
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _paymentMethod == 'card' 
                                            ? 'Paiement réussi ! Votre commande a été passée.'
                                            : 'Commande confirmée ! Vous paierez à la livraison.',
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  }
                                } else if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        paymentProvider.error ??
                                            'Erreur de paiement',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: paymentProvider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                              _paymentMethod == 'card' ? 'Payer maintenant' : 'Confirmer la commande',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),

                  if (paymentProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        paymentProvider.error!,
                        style: TextStyle(color: Colors.red.shade800),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

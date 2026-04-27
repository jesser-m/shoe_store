import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderProvider>().loadOrders();
    });
  }

  static const _statuses = [
    ('all', 'Tous'),
    ('pending', 'En attente'),
    ('paid', 'Payé'),
    ('shipped', 'Expédié'),
    ('delivered', 'Livré'),
    ('cancelled', 'Annulé'),
  ];

  static Color _statusColor(String s) => {
        'pending': Colors.orange,
        'paid': Colors.blue,
        'shipped': Colors.indigo,
        'delivered': Colors.green,
        'cancelled': Colors.red,
      }[s] ??
      Colors.grey;

  static String _statusLabel(String s) => {
        'pending': 'En attente',
        'paid': 'Payé',
        'shipped': 'Expédié',
        'delivered': 'Livré',
        'cancelled': 'Annulé',
      }[s] ??
      s;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text('Gestion des commandes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Consumer<OrderProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              // Filter chips
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _statuses.map((s) {
                      final (value, label) = s;
                      final selected = provider.statusFilter == value;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(label),
                          selected: selected,
                          onSelected: (_) => provider.setFilter(value),
                          selectedColor: Colors.deepPurple.withOpacity(0.15),
                          checkmarkColor: Colors.deepPurple,
                          labelStyle: TextStyle(
                            color: selected ? Colors.deepPurple : Colors.grey.shade700,
                            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              // Orders list
              Expanded(
                child: provider.filteredOrders.isEmpty
                    ? const Center(child: Text('Aucune commande trouvée'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: provider.filteredOrders.length,
                        itemBuilder: (ctx, i) => _OrderCard(
                          order: provider.filteredOrders[i],
                          onUpdateStatus: (newStatus) => provider.updateOrderStatus(
                            provider.filteredOrders[i].id,
                            newStatus,
                          ),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final Future<void> Function(String) onUpdateStatus;

  const _OrderCard({required this.order, required this.onUpdateStatus});

  static Color _statusColor(String s) => {
        'pending': Colors.orange,
        'paid': Colors.blue,
        'shipped': Colors.indigo,
        'delivered': Colors.green,
        'cancelled': Colors.red,
      }[s] ??
      Colors.grey;

  static String _statusLabel(String s) => {
        'pending': 'En attente',
        'paid': 'Payé',
        'shipped': 'Expédié',
        'delivered': 'Livré',
        'cancelled': 'Annulé',
      }[s] ??
      s;

  void _showStatusDialog(BuildContext context) {
    final statuses = ['pending', 'paid', 'shipped', 'delivered', 'cancelled'];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Changer le statut'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: statuses.map((s) {
            final selected = order.status == s;
            return ListTile(
              leading: CircleAvatar(
                radius: 8,
                backgroundColor: _statusColor(s),
              ),
              title: Text(_statusLabel(s)),
              trailing: selected ? const Icon(Icons.check, color: Colors.deepPurple) : null,
              onTap: () async {
                Navigator.of(ctx).pop();
                try {
                  await onUpdateStatus(s);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
                    );
                  }
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showOrderDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Commande #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel(order.status), style: TextStyle(color: _statusColor(order.status), fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (order.shippingAddress != null) ...[
                const Text('Livraison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                _InfoRow(Icons.person_outline, order.shippingAddress!.fullName),
                _InfoRow(Icons.location_on_outlined, '${order.shippingAddress!.address}, ${order.shippingAddress!.city} ${order.shippingAddress!.postalCode}'),
                _InfoRow(Icons.flag_outlined, order.shippingAddress!.country),
                if (order.shippingAddress!.phone != null)
                  _InfoRow(Icons.phone_outlined, order.shippingAddress!.phone!),
                const SizedBox(height: 16),
              ],
              const Text('Articles', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...order.items.map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.productImage, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => const Icon(Icons.image)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w600)),
                              if (item.size != null || item.color != null)
                                Text('${item.size ?? ''} ${item.color ?? ''}'.trim(), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('x${item.quantity}', style: TextStyle(color: Colors.grey.shade600)),
                            Text('${(item.price * item.quantity).toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  )),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${order.totalAmount.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.deepPurple)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)],
      ),
      child: InkWell(
        onTap: () => _showOrderDetail(context),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: Colors.deepPurple, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('#${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text(
                          order.shippingAddress?.fullName ?? order.userId,
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${order.totalAmount.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      Text('${order.items.length} article(s)', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor(order.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_statusLabel(order.status), style: TextStyle(color: _statusColor(order.status), fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  Text(
                    '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                  TextButton.icon(
                    onPressed: () => _showStatusDialog(context),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Statut'),
                    style: TextButton.styleFrom(foregroundColor: Colors.deepPurple, padding: EdgeInsets.zero),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../providers/products_provider.dart';
import '../../providers/order_provider.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  int _period = 7; // days

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: const Text(
          'Rapports & Statistiques',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Consumer2<ProductsProvider, OrderProvider>(
        builder: (ctx, products, orders, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Period selector
                Row(
                  children: [
                    const Text(
                      'Période :',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 12),
                    ...[7, 14, 30].map((d) {
                      final selected = _period == d;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$d jours'),
                          selected: selected,
                          onSelected: (_) => setState(() => _period = d),
                          selectedColor: Colors.deepPurple.withOpacity(0.2),
                          labelStyle: TextStyle(
                            color: selected
                                ? Colors.deepPurple
                                : Colors.grey.shade700,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),

                // Summary cards
                _buildSummaryRow(orders, products),
                const SizedBox(height: 20),

                // Revenue line chart
                _buildRevenueCard(orders),
                const SizedBox(height: 16),

                // Top products
                _buildTopProductsCard(orders, products),
                const SizedBox(height: 16),

                // Category distribution
                _buildCategoryCard(products),
                const SizedBox(height: 16),

                // Stock alert
                _buildStockAlert(products),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryRow(OrderProvider orders, ProductsProvider products) {
    final deliveredOrders = orders.orders
        .where((o) => o.status == 'delivered')
        .length;
    final cancelRate = orders.orders.isEmpty
        ? 0.0
        : (orders.cancelledCount / orders.orders.length * 100);
    final avgOrder = orders.orders.where((o) => o.status != 'cancelled').isEmpty
        ? 0.0
        : orders.totalRevenue /
              orders.orders.where((o) => o.status != 'cancelled').length;

    final stats = [
      _StatCard(
        label: 'Chiffre d\'affaires',
        value: '${orders.totalRevenue.toStringAsFixed(0)} €',
        icon: Icons.trending_up,
        color: Colors.deepPurple,
      ),
      _StatCard(
        label: 'Commandes livrées',
        value: '$deliveredOrders',
        icon: Icons.check_circle_outline,
        color: Colors.green,
      ),
      _StatCard(
        label: 'Panier moyen',
        value: '${avgOrder.toStringAsFixed(2)} €',
        icon: Icons.shopping_cart_outlined,
        color: Colors.blue,
      ),
      _StatCard(
        label: 'Taux annulation',
        value: '${cancelRate.toStringAsFixed(1)}%',
        icon: Icons.cancel_outlined,
        color: Colors.red,
      ),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: stats.map((s) => _buildStatCard(s)).toList(),
    );
  }

  Widget _buildStatCard(_StatCard s) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: s.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(s.icon, color: s.color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  s.value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  s.label,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(OrderProvider orders) {
    final data = orders.revenueByDay;
    final entries = data.entries.toList();
    final maxY = data.values.fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Évolution des revenus',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: entries.isEmpty
                ? const Center(child: Text('Aucune donnée'))
                : LineChart(
                    LineChartData(
                      maxY: maxY == 0 ? 100 : maxY * 1.2,
                      minY: 0,
                      lineBarsData: [
                        LineChartBarData(
                          spots: entries
                              .asMap()
                              .entries
                              .map(
                                (e) => FlSpot(e.key.toDouble(), e.value.value),
                              )
                              .toList(),
                          isCurved: true,
                          color: Colors.deepPurple,
                          barWidth: 2.5,
                          dotData: const FlDotData(show: true),
                          belowBarData: BarAreaData(
                            show: true,
                            color: Colors.deepPurple.withOpacity(0.08),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, _) {
                              final i = value.toInt();
                              if (i < 0 || i >= entries.length)
                                return const SizedBox.shrink();
                              return Text(
                                entries[i].key,
                                style: const TextStyle(fontSize: 10),
                              );
                            },
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        getDrawingHorizontalLine: (_) =>
                            FlLine(color: Colors.grey.shade100, strokeWidth: 1),
                      ),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProductsCard(
    OrderProvider orders,
    ProductsProvider products,
  ) {
    // Count product occurrences in orders
    final Map<String, int> countMap = {};
    final Map<String, String> nameMap = {};
    for (final order in orders.orders) {
      if (order.status == 'cancelled') continue;
      for (final item in order.items) {
        countMap[item.productId] =
            (countMap[item.productId] ?? 0) + item.quantity;
        nameMap[item.productId] = item.productName;
      }
    }
    final sorted = countMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Top produits vendus',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          if (top.isEmpty)
            Text(
              'Aucune vente enregistrée',
              style: TextStyle(color: Colors.grey.shade500),
            )
          else
            ...top.asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final maxVal = top.first.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: [
                          Colors.amber,
                          Colors.grey.shade400,
                          Colors.brown.shade300,
                          Colors.grey.shade300,
                          Colors.grey.shade200,
                        ][i],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nameMap[e.key] ?? e.key,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: e.value / maxVal,
                              backgroundColor: Colors.grey.shade100,
                              color: Colors.deepPurple,
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${e.value} ventes',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(ProductsProvider products) {
    final Map<String, int> catCount = {};
    for (final p in products.products) {
      if (p.category.isNotEmpty) {
        catCount[p.category] = (catCount[p.category] ?? 0) + 1;
      }
    }
    final total = catCount.values.fold<int>(0, (a, b) => a + b);
    final colors = [
      Colors.deepPurple,
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Répartition par catégorie',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 16),
          if (catCount.isEmpty)
            Text('Aucun produit', style: TextStyle(color: Colors.grey.shade500))
          else
            ...catCount.entries.toList().asMap().entries.map((entry) {
              final i = entry.key;
              final e = entry.value;
              final pct = total == 0 ? 0.0 : e.value / total;
              final color = colors[i % colors.length];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(e.key, style: const TextStyle(fontSize: 13)),
                    ),
                    Text(
                      '${e.value} produits',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(pct * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildStockAlert(ProductsProvider products) {
    final lowStock = products.products
        .where((p) => p.stockQuantity <= 5 && p.inStock)
        .toList();
    final outOfStock = products.products.where((p) => !p.inStock).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_outlined,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Alertes stock',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (outOfStock.isNotEmpty) ...[
            Text(
              'Rupture de stock (${outOfStock.length})',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            ...outOfStock.map(
              (p) => _AlertRow(name: p.name, qty: 0, color: Colors.red),
            ),
            const SizedBox(height: 12),
          ],
          if (lowStock.isNotEmpty) ...[
            Text(
              'Stock faible ≤5 (${lowStock.length})',
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            ...lowStock.map(
              (p) => _AlertRow(
                name: p.name,
                qty: p.stockQuantity,
                color: Colors.orange,
              ),
            ),
          ],
          if (outOfStock.isEmpty && lowStock.isEmpty)
            Row(
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Tous les stocks sont corrects',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _AlertRow extends StatelessWidget {
  final String name;
  final int qty;
  final Color color;
  const _AlertRow({required this.name, required this.qty, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(name, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              qty == 0 ? 'Épuisé' : '$qty restants',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard {
  final String label, value;
  final IconData icon;
  final Color color;
  _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
}

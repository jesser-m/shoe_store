import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesProvider>(
      builder: (ctx, favorites, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Favoris')),
          body: favorites.favorites.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Aucun favori pour le moment',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Ajoutez des produits à vos favoris !',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(10),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                  ),
                  itemCount: favorites.favorites.length,
                  itemBuilder: (ctx, i) =>
                      ProductCard(product: favorites.favorites[i]),
                ),
        );
      },
    );
  }
}


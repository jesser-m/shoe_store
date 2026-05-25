import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './models/product.dart';
import './widgets/product_card.dart';
import './widgets/shimmer_loading.dart';
import './providers/cart_provider.dart';
import './providers/favorites_provider.dart';
import './providers/auth_provider.dart';
import './providers/products_provider.dart';
import './providers/order_provider.dart';
import './providers/category_provider.dart';
import './providers/payment_provider.dart';
import './providers/settings_provider.dart';
import './screens/cart_screen.dart';
import './screens/favorites_screen.dart';
import './screens/profile_screen.dart';
import './screens/login_screen.dart';
import './config/stripe_config.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import './l10n/app_localizations.dart';
import './config/api_config.dart';

// Only import Stripe for mobile platforms
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init API config (read saved server IP)
  await ApiConfig.init();

  // Initialize Stripe (Mobile only)
  if (!kIsWeb) {
    Stripe.publishableKey = StripeConfig.publishableKey;
    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      try {
        await Stripe.instance.applySettings();
      } catch (e) {
        debugPrint('Stripe applySettings failed: $e');
      }
    }
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (ctx) => AuthProvider()),
        ChangeNotifierProvider(create: (ctx) => ProductsProvider()),
        ChangeNotifierProvider(create: (ctx) => CartProvider()),
        ChangeNotifierProvider(create: (ctx) => FavoritesProvider()),
        ChangeNotifierProvider(create: (ctx) => PaymentProvider()),
        ChangeNotifierProvider(create: (ctx) => OrderProvider()),
        ChangeNotifierProvider(create: (ctx) => CategoryProvider()),
        ChangeNotifierProvider(create: (ctx) => SettingsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (ctx, settings, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Shoe Store',
          themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.blue,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          locale: settings.locale,
          supportedLocales: const [
            Locale('en', 'US'),
            Locale('fr', 'FR'),
            Locale('es', 'ES'),
            Locale('ar', 'AE'),
          ],
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Consumer<AuthProvider>(
            builder: (ctx, auth, _) {
              return auth.isAuthenticated
                  ? const MainScreen()
                  : const LoginScreen();
            },
          ),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _animationController;
  late List<Animation<double>> _iconAnimations;

  static final List<Widget> _screens = [
    const HomeScreen(),
    const FavoritesScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _iconAnimations = List.generate(
      4,
      (index) => Tween<double>(begin: 1.0, end: 1.2).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.1,
            (index + 1) * 0.1,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      setState(() {
        _selectedIndex = index;
      });
      _animationController.forward(from: 0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _iconAnimations[0],
                builder: (context, child) => Transform.scale(
                  scale: _selectedIndex == 0 ? _iconAnimations[0].value : 1.0,
                  child: const Icon(Icons.home),
                ),
              ),
              label: context.tr('home'),
            ),
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _iconAnimations[1],
                builder: (context, child) => Transform.scale(
                  scale: _selectedIndex == 1 ? _iconAnimations[1].value : 1.0,
                  child: const Icon(Icons.favorite),
                ),
              ),
              label: context.tr('favorites'),
            ),
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _iconAnimations[2],
                builder: (context, child) => Transform.scale(
                  scale: _selectedIndex == 2 ? _iconAnimations[2].value : 1.0,
                  child: const Icon(Icons.shopping_cart),
                ),
              ),
              label: context.tr('cart'),
            ),
            BottomNavigationBarItem(
              icon: AnimatedBuilder(
                animation: _iconAnimations[3],
                builder: (context, child) => Transform.scale(
                  scale: _selectedIndex == 3 ? _iconAnimations[3].value : 1.0,
                  child: const Icon(Icons.person),
                ),
              ),
              label: context.tr('profile'),
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _InnerHomeScreenState();
}

class _InnerHomeScreenState extends State<HomeScreen> {
  String selectedCategory = 'Tout';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final productsProvider = Provider.of<ProductsProvider>(
        context,
        listen: false,
      );
      final favoritesProvider = Provider.of<FavoritesProvider>(
        context,
        listen: false,
      );

      await productsProvider.loadProducts();

      if (productsProvider.products.isEmpty && productsProvider.error == null) {
        await productsProvider.seedInitialData();
        await productsProvider.loadProducts();
      }

      await favoritesProvider.loadFavorites();
      favoritesProvider.updateFavoritesFromProducts(productsProvider.products);
    });
  }

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    return allProducts.where((product) {
      final matchesSearch =
          product.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.brand.toLowerCase().contains(searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(searchQuery.toLowerCase());
      final matchesCategory =
          selectedCategory == 'Tout' || product.category == selectedCategory;
      return matchesSearch && matchesCategory;
    }).toList();
  }

  void _filterProducts(String query) {
    setState(() => searchQuery = query);
  }

  void _selectCategory(String category) {
    setState(() => selectedCategory = category);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      builder: (ctx, productsProvider, _) {
        final displayedProducts = _getFilteredProducts(
          productsProvider.products,
        );
        final colorScheme = Theme.of(context).colorScheme;

        if (productsProvider.isLoading && productsProvider.products.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.tr('app_title')),
              centerTitle: true,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  ShimmerLoading(
                    width: double.infinity,
                    height: 50,
                    borderRadius: BorderRadius.circular(25),
                    margin: const EdgeInsets.only(bottom: 16),
                  ),
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 4,
                      itemBuilder: (context, index) => ShimmerLoading(
                        width: 80,
                        height: 40,
                        borderRadius: BorderRadius.circular(20),
                        margin: const EdgeInsets.only(right: 8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                      itemCount: 6,
                      itemBuilder: (context, index) =>
                          const ProductCardShimmer(),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (productsProvider.error != null &&
            productsProvider.products.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Shoe Store'), centerTitle: true),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    context.tr('loading_error'),
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    productsProvider.error!,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => productsProvider.loadProducts(),
                    child: Text(context.tr('retry')),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(context.tr('app_title')),
            centerTitle: true,
            actions: [
              Consumer<CartProvider>(
                builder: (_, cart, ch) => Badge(
                  label: Text(cart.itemCount.toString()),
                  isLabelVisible: cart.itemCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (ctx) => const CartScreen()),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 15),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('premium_sneakers'),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.tr('find_ideal_pair'),
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: TextField(
                  onChanged: _filterProducts,
                  decoration: InputDecoration(
                    hintText: context.tr('search_hint'),
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: productsProvider.categories.length,
                  separatorBuilder: (ctx, index) => const SizedBox(width: 10),
                  itemBuilder: (ctx, i) {
                    final category = productsProvider.categories[i];
                    final selected = category == selectedCategory;
                    return ChoiceChip(
                      label: Text(
                        category == 'Tout' ? context.tr('all') : category,
                      ),
                      selected: selected,
                      selectedColor: colorScheme.primary,
                      backgroundColor: Colors.grey[200],
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black87,
                      ),
                      onSelected: (_) => _selectCategory(category),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: displayedProducts.isEmpty && !productsProvider.isLoading
                    ? Center(
                        child: Text(
                          context.tr('no_results'),
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 15,
                              mainAxisSpacing: 15,
                            ),
                        itemCount: displayedProducts.length,
                        itemBuilder: (ctx, i) =>
                            ProductCard(product: displayedProducts[i]),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'app_title': 'Shoe Store',
      'home': 'Accueil',
      'favorites': 'Favoris',
      'cart': 'Panier',
      'profile': 'Profil',
      'search_hint': 'Rechercher une chaussure, marque...',
      'no_results': 'Aucun résultat trouvé 👟',
      'loading_error': 'Erreur de chargement',
      'retry': 'Réessayer',
      'premium_sneakers': 'Des baskets haut de gamme',
      'find_ideal_pair': 'Trouve ta paire idéale avec style et performance.',
      'all': 'Tout',
      'my_profile': 'Mon Profil',
      'user': 'Utilisateur',
      'admin': 'Administrateur',
      'customer': 'Client',
      'email': 'Email',
      'not_available': 'Non disponible',
      'account_status': 'Statut du compte',
      'verified': 'Vérifié',
      'unverified': 'Non vérifié',
      'member_since': 'Membre depuis',
      'dark_mode': 'Mode sombre',
      'language': 'Langue',
      'admin_panel': 'Panneau d\'administration',
      'logout': 'Se déconnecter',
      'empty_cart': 'Votre panier est vide',
      'total': 'Total',
      'checkout': 'PAIEMENT',
      'clear_cart': 'Vider le panier',
      'clear_cart_confirm': 'Êtes-vous sûr de vouloir vider votre panier ?',
      'cancel': 'Annuler',
      'clear': 'Vider',
      'cart_cleared': 'Panier vidé',
      'add_products_prompt': 'Ajoutez des produits pour commencer vos achats',
      'continue_shopping': 'Continuer mes achats',
      'removed_from_cart': 'retiré du panier',
      'no_favorites': 'Aucun favori pour le moment',
      'add_favorites_prompt': 'Ajoutez des produits à vos favoris !',
    },
    'en': {
      'app_title': 'Shoe Store',
      'home': 'Home',
      'favorites': 'Favorites',
      'cart': 'Cart',
      'profile': 'Profile',
      'search_hint': 'Search for a shoe, brand...',
      'no_results': 'No results found 👟',
      'loading_error': 'Loading error',
      'retry': 'Retry',
      'premium_sneakers': 'Premium sneakers',
      'find_ideal_pair': 'Find your ideal pair with style and performance.',
      'all': 'All',
      'my_profile': 'My Profile',
      'user': 'User',
      'admin': 'Administrator',
      'customer': 'Customer',
      'email': 'Email',
      'not_available': 'Not available',
      'account_status': 'Account status',
      'verified': 'Verified',
      'unverified': 'Unverified',
      'member_since': 'Member since',
      'dark_mode': 'Dark mode',
      'language': 'Language',
      'admin_panel': 'Admin Panel',
      'logout': 'Logout',
      'empty_cart': 'Your cart is empty',
      'total': 'Total',
      'checkout': 'CHECKOUT',
      'clear_cart': 'Clear cart',
      'clear_cart_confirm': 'Are you sure you want to clear your cart?',
      'cancel': 'Cancel',
      'clear': 'Clear',
      'cart_cleared': 'Cart cleared',
      'add_products_prompt': 'Add products to start shopping',
      'continue_shopping': 'Continue shopping',
      'removed_from_cart': 'removed from cart',
      'no_favorites': 'No favorites yet',
      'add_favorites_prompt': 'Add some products to your favorites!',
    },
    'es': {
      'app_title': 'Shoe Store',
      'home': 'Inicio',
      'favorites': 'Favoritos',
      'cart': 'Carrito',
      'profile': 'Perfil',
      'search_hint': 'Buscar un zapato, marca...',
      'no_results': 'No se encontraron resultados 👟',
      'loading_error': 'Error de carga',
      'retry': 'Reintentar',
      'premium_sneakers': 'Zapatillas premium',
      'find_ideal_pair': 'Encuentra tu par ideal con estilo y rendimiento.',
      'all': 'Todo',
      'my_profile': 'Mi Perfil',
      'user': 'Usuario',
      'admin': 'Administrador',
      'customer': 'Cliente',
      'email': 'Correo electrónico',
      'not_available': 'No disponible',
      'account_status': 'Estado de la cuenta',
      'verified': 'Verificado',
      'unverified': 'No verificado',
      'member_since': 'Miembro desde',
      'dark_mode': 'Modo oscuro',
      'language': 'Idioma',
      'admin_panel': 'Panel de administración',
      'logout': 'Cerrar sesión',
      'empty_cart': 'Tu carrito está vacío',
      'total': 'Total',
      'checkout': 'PAGAR',
      'clear_cart': 'Vaciar carrito',
      'clear_cart_confirm': '¿Estás seguro de que quieres vaciar tu carrito?',
      'cancel': 'Cancelar',
      'clear': 'Vaciar',
      'cart_cleared': 'Carrito vaciado',
      'add_products_prompt': 'Añade productos para empezar a comprar',
      'continue_shopping': 'Continuar comprando',
      'removed_from_cart': 'eliminado del carrito',
      'no_favorites': 'Aún no hay favoritos',
      'add_favorites_prompt': '¡Añade productos a tus favoritos!',
    },
    'ar': {
      'app_title': 'متجر الأحذية',
      'home': 'الرئيسية',
      'favorites': 'المفضلة',
      'cart': 'عربة التسوق',
      'profile': 'الملف الشخصي',
      'search_hint': 'ابحث عن حذاء، ماركة...',
      'no_results': 'لم يتم العثور على نتائج 👟',
      'loading_error': 'خطأ في التحميل',
      'retry': 'إعادة المحاولة',
      'premium_sneakers': 'أحذية رياضية فاخرة',
      'find_ideal_pair': 'اعثر على زوجك المثالي بأناقة وأداء.',
      'all': 'الكل',
      'my_profile': 'ملفي الشخصي',
      'user': 'مستخدم',
      'admin': 'مسؤول',
      'customer': 'عميل',
      'email': 'البريد الإلكتروني',
      'not_available': 'غير متوفر',
      'account_status': 'حالة الحساب',
      'verified': 'تم التحقق',
      'unverified': 'غير متحقق',
      'member_since': 'عضو منذ',
      'dark_mode': 'الوضع الداكن',
      'language': 'اللغة',
      'admin_panel': 'لوحة الإدارة',
      'logout': 'تسجيل الخروج',
      'empty_cart': 'عربة التسوق فارغة',
      'total': 'المجموع',
      'checkout': 'الدفع',
      'clear_cart': 'إفراغ العربة',
      'clear_cart_confirm': 'هل أنت متأكد أنك تريد إفراغ العربة؟',
      'cancel': 'إلغاء',
      'clear': 'إفراغ',
      'cart_cleared': 'تم إفراغ العربة',
      'add_products_prompt': 'أضف منتجات لبدء التسوق',
      'continue_shopping': 'متابعة التسوق',
      'removed_from_cart': 'تمت الإزالة من العربة',
      'no_favorites': 'لا توجد مفضلة بعد',
      'add_favorites_prompt': 'أضف بعض المنتجات إلى مفضلتك!',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'fr', 'es', 'ar'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }
}

import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const Map<String, Map<String, String>> _localizedValues = {
    'fr': {
      'home': 'Accueil',
      'favorites': 'Favoris',
      'cart': 'Panier',
      'profile': 'Profil',
      'searchHint': 'Rechercher une chaussure, marque...',
      'myProfile': 'Mon Profil',
      'darkMode': 'Mode sombre',
      'language': 'Langue',
      'french': 'Francais',
      'english': 'Anglais',
      'logout': 'Se deconnecter',
      'adminPanel': 'Panneau d\'administration',
      'email': 'Email',
      'accountStatus': 'Statut du compte',
      'verified': 'Verifie',
      'notVerified': 'Non verifie',
      'memberSince': 'Membre depuis',
      'admin': 'Administrateur',
      'client': 'Client',
      'changePhoto': 'Changer la photo',
      'takePhoto': 'Prendre une photo',
      'chooseGallery': 'Choisir depuis la galerie',
      'cancel': 'Annuler',
      'productImage': 'Image du produit',
      'pickImage': 'Choisir une image',
      'uploading': 'Telechargement...',
    },
    'en': {
      'home': 'Home',
      'favorites': 'Favorites',
      'cart': 'Cart',
      'profile': 'Profile',
      'searchHint': 'Search for shoes, brand...',
      'myProfile': 'My Profile',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'french': 'French',
      'english': 'English',
      'logout': 'Logout',
      'adminPanel': 'Admin Dashboard',
      'email': 'Email',
      'accountStatus': 'Account Status',
      'verified': 'Verified',
      'notVerified': 'Not Verified',
      'memberSince': 'Member Since',
      'admin': 'Administrator',
      'client': 'Client',
      'changePhoto': 'Change Photo',
      'takePhoto': 'Take a Photo',
      'chooseGallery': 'Choose from Gallery',
      'cancel': 'Cancel',
      'productImage': 'Product Image',
      'pickImage': 'Pick an Image',
      'uploading': 'Uploading...',
    },
  };

  String get(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['fr', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

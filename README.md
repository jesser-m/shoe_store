# Shoe Store - Mobile E-Commerce App

A professional Flutter e-commerce application for shoe shopping with modern UI and Firebase authentication.

## Features

### ✅ Completed Features
- **Product Catalog**: Browse shoes with search and category filtering
- **Product Details**: Image carousel, size/color selection, reviews
- **Shopping Cart**: Add/remove items, quantity management, persistent storage
- **Favorites**: Save favorite products with local persistence
- **User Authentication**: Firebase Auth with login/signup
- **Bottom Navigation**: Seamless navigation between screens
- **Material Design 3**: Modern, professional UI

### 🚧 Future Features
- Backend integration (Firebase Firestore)
- Payment processing (Stripe)
- Push notifications
- Order history
- User profiles enhancement

## Setup Instructions

### Prerequisites
- Flutter SDK (^3.11.4)
- Firebase account
- Android Studio / VS Code

### Firebase Setup

1. **Create Firebase Project**:
   ```bash
   # Install Firebase CLI
   npm install -g firebase-tools

   # Login to Firebase
   firebase login

   # Create new project
   firebase projects:create shoe-store-app
   ```

2. **Configure FlutterFire**:
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli

   # Configure Firebase for your Flutter app
   flutterfire configure --project=shoe-store-app
   ```

3. **Enable Authentication**:
   - Go to Firebase Console → Authentication
   - Enable Email/Password sign-in method

4. **Update Firebase Configuration**:
   - Replace the demo values in `lib/firebase_options.dart` with your actual Firebase config
   - The FlutterFire CLI will generate the correct configuration

### Installation

1. **Clone and setup**:
   ```bash
   git clone <repository-url>
   cd shoe_store
   flutter pub get
   ```

2. **Configure Firebase** (see Firebase Setup above)

3. **Run the app**:
   ```bash
   flutter run
   ```

## App Architecture

### State Management
- **Provider Pattern**: Clean separation of business logic
- **AuthProvider**: Firebase authentication state
- **CartProvider**: Shopping cart management
- **FavoritesProvider**: Favorite products with persistence

### Project Structure
```
lib/
├── main.dart                 # App entry point with providers
├── models/
│   └── product.dart          # Product data model
├── providers/
│   ├── auth_provider.dart    # Firebase authentication
│   ├── cart_provider.dart    # Shopping cart logic
│   └── favorites_provider.dart # Favorites management
├── screens/
│   ├── login_screen.dart     # User login
│   ├── signup_screen.dart    # User registration
│   ├── cart_screen.dart      # Shopping cart
│   ├── favorites_screen.dart # Favorite products
│   └── profile_screen.dart   # User profile
├── widgets/
│   └── product_card.dart     # Reusable product display
└── firebase_options.dart     # Firebase configuration
```

## Key Features Implementation

### Authentication Flow
- Login/Signup screens with form validation
- Firebase Auth integration
- Automatic navigation based on auth state
- User profile with logout functionality

### Shopping Experience
- Product grid with search and filtering
- Detailed product view with image carousel
- Add to cart with quantity management
- Persistent favorites across app sessions
- Professional Material Design 3 UI

### Data Persistence
- SharedPreferences for local storage
- Firebase Auth for user management
- Provider pattern for state management

## Development Roadmap

1. ✅ **Step 1-3**: Core e-commerce features (Products, Cart, Favorites)
2. ✅ **Step 4**: User Authentication (Firebase Auth)
3. 🔄 **Step 5**: Backend Integration (Firebase Firestore)
4. 🔄 **Step 6**: Payment Processing (Stripe)
5. 🔄 **Step 7**: UX Enhancements (Animations, Performance)
6. 🔄 **Step 8**: Testing & Deployment

## Technologies Used

- **Flutter**: Cross-platform mobile development
- **Firebase**: Authentication & Backend services
- **Provider**: State management
- **SharedPreferences**: Local data persistence
- **Material Design 3**: Modern UI components

## Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License.

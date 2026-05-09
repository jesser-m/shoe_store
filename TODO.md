# Firebase Removal TODO

## Current Progress
- [x] Analyzed project structure and Firebase remnants
- [x] Confirmed no Firebase dependencies/configs
- [x] Backend already fully functional with REST API/JWT
- [x] Remove legacy Firestore methods from models

## Steps to Complete
1. ~~Create this TODO.md~~
2. Edit `lib/models/user_model.dart` - Remove `fromFirestore()`, `toFirestore()`, Firebase comments/aliases
3. Edit `lib/models/category.dart` - Remove `fromFirestore()`, `toFirestore()`
4. Edit `lib/models/product.dart` - Remove `fromFirestore()`, `toFirestore()`, comments
5. Edit `lib/models/order.dart` - Remove `fromFirestore()`, `toFirestore()`
6. Search codebase for any `fromFirestore` usages: `grep -r "fromFirestore" lib/`
7. Run `flutter pub get`
8. Test app: `flutter run` - verify auth, products, cart, orders
9. Final search: No more `firebase|firestore|Firebase|Firestore` references
10. ~~attempt_completion~~

**Next step: Edit model files**


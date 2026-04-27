# Error Fixes Plan

## Errors Found
1. **ambiguous_import for Category** in `lib/providers/category_provider.dart`
2. **ambiguous_import for Order** in `lib/providers/order_provider.dart`
3. **uri_does_not_exist** in `lib/screens/admin/admin_dashbord_screen.dart` (3 missing imports)
4. **invalid_assignment** (num -> int) in `lib/screens/admin/admin_raports_screen.dart`
5. **uri_does_not_exist** in `web_entrypoint.dart`

## Fix Steps
- [x] Fix Category ambiguous import in category_provider.dart
- [x] Fix Order ambiguous import in order_provider.dart
- [x] Fix missing imports in admin_dashbord_screen.dart
- [x] Create missing admin_categories_screen.dart
- [x] Fix num->int assignment in admin_raports_screen.dart
- [x] Fix firebase_options import in web_entrypoint.dart
- [x] Run flutter analyze to verify

## Result
All **errors** fixed. Flutter analyze now reports **0 errors**. Remaining 61 issues are warnings/infos only (deprecated `withOpacity`, unused variables, type hints, etc.).


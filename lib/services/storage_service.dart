import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class StorageService {
  // Upload product image from bytes (web compatible)
  Future<String> uploadProductImageBytes(
    Uint8List bytes, {
    String? fileName,
  }) async {
    try {
      final name =
          fileName ?? 'product_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final streamedResponse = await ApiService.uploadBytes(
        '/upload/image',
        bytes,
        filename: name,
      );
      final response = await http.Response.fromStream(streamedResponse);
      final data = ApiService.handleResponse(response);
      return data['imageUrl'];
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Upload product image from file (mobile/desktop)
  Future<String> uploadProductImageFile(File file, {String? fileName}) async {
    try {
      final streamedResponse = await ApiService.uploadFile(
        '/upload/image',
        file,
      );
      final response = await http.Response.fromStream(streamedResponse);
      final data = ApiService.handleResponse(response);
      return data['imageUrl'];
    } catch (e) {
      throw Exception('Erreur lors de l\'upload de l\'image: $e');
    }
  }

  // Upload user avatar
  Future<String> uploadUserAvatar(String userId, Uint8List bytes) async {
    return uploadProductImageBytes(bytes, fileName: 'avatar_$userId.jpg');
  }

  // Delete product image (no-op for local storage, could delete file on server)
  Future<void> deleteProductImage(String imageUrl) async {
    try {
      debugPrint('Delete image: $imageUrl');
      // In production, call backend to delete
    } catch (e) {
      debugPrint('Error deleting image: $e');
    }
  }

  // Delete user avatar
  Future<void> deleteUserAvatar(String userId) async {
    try {
      debugPrint('Delete avatar: $userId');
    } catch (e) {
      debugPrint('Error deleting avatar: $e');
    }
  }
}

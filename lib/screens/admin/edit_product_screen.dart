import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/product.dart';
import '../../providers/products_provider.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class EditProductScreen extends StatefulWidget {
  final Product? product;
  const EditProductScreen({super.key, this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late String _name;
  late String _description;
  late double _price;
  late String _imageUrl;
  late String _category;
  late String _brand;
  late int _stockQuantity;
  late bool _inStock;
  late List<String> _sizes;
  late List<String> _colors;

  final _sizeCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _imageUrlCtrl = TextEditingController();

  static const _predefinedSizes = ['36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46'];
  static const _predefinedColors = ['Noir', 'Blanc', 'Rouge', 'Bleu', 'Vert', 'Gris', 'Multicolore', 'Beige'];

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = p?.name ?? '';
    _description = p?.description ?? '';
    _price = p?.price ?? 0.0;
    _imageUrl = p?.imageUrl ?? '';
    _category = p?.category ?? '';
    _brand = p?.brand ?? '';
    _stockQuantity = p?.stockQuantity ?? 0;
    _inStock = p?.inStock ?? true;
    _sizes = List<String>.from(p?.sizes ?? []);
    _colors = List<String>.from(p?.colors ?? []);
    _imageUrlCtrl.text = _imageUrl;
  }

  @override
  void dispose() {
    _sizeCtrl.dispose();
    _colorCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    
    if (pickedFile != null) {
      setState(() => _isLoading = true);
      try {
        final token = await ApiService.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('Session expirée. Veuillez vous reconnecter.');
        }

        final bytes = await pickedFile.readAsBytes();
        final response = await ApiService.uploadBytes(
          '/upload',
          bytes,
          filename: pickedFile.name,
        );
        
        final responseData = await response.stream.bytesToString();
        dynamic jsonResponse;
        try {
          jsonResponse = json.decode(responseData);
        } catch (e) {
          debugPrint('Failed to decode response: $responseData');
        }
        
        if (response.statusCode == 200) {
          setState(() {
            String returnedUrl = jsonResponse['imageUrl'];
            if (returnedUrl.startsWith('/')) {
              final host = ApiConfig.baseUrl.split('/api').first;
              _imageUrl = '$host$returnedUrl';
            } else {
              _imageUrl = returnedUrl;
            }
            _imageUrlCtrl.text = _imageUrl;
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Image uploadée avec succès !'), backgroundColor: Colors.green)
            );
          }
        } else {
          String errorMsg = 'Erreur lors de l\'upload (${response.statusCode})';
          if (jsonResponse != null && jsonResponse['msg'] != null) {
            errorMsg = jsonResponse['msg'];
          } else if (jsonResponse != null && jsonResponse['message'] != null) {
            errorMsg = jsonResponse['message'];
          } else if (responseData.contains('<!DOCTYPE')) {
            errorMsg = 'Le serveur a retourné une erreur HTML (404 ou 500).';
          }
          throw Exception(errorMsg);
        }
      } catch (e) {
        debugPrint('Upload error: $e');
        if (mounted) {
          String finalMsg = e.toString().replaceFirst('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur d\'upload: $finalMsg'), backgroundColor: Colors.red, duration: const Duration(seconds: 5))
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    setState(() => _isLoading = true);
    final provider = context.read<ProductsProvider>();

    try {
      if (widget.product != null) {
        await provider.updateProduct(widget.product!.copyWith(
          name: _name,
          description: _description,
          price: _price,
          imageUrl: _imageUrl,
          category: _category,
          brand: _brand,
          stockQuantity: _stockQuantity,
          inStock: _inStock,
          sizes: _sizes,
          colors: _colors,
          updatedAt: DateTime.now(),
        ));
      } else {
        await provider.addProduct(Product(
          id: '',
          name: _name,
          description: _description,
          price: _price,
          imageUrl: _imageUrl,
          category: _category,
          brand: _brand,
          stockQuantity: _stockQuantity,
          inStock: _inStock,
          sizes: _sizes,
          colors: _colors,
        ));
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product != null ? 'Produit mis à jour !' : 'Produit ajouté !'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red, behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.product != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier le produit' : 'Nouveau produit', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1), child: Container(color: Colors.grey.shade200, height: 1)),
        actions: [
          if (!_isLoading)
            TextButton.icon(
              onPressed: _saveForm,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Enregistrer'),
              style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image preview
                    _buildImageSection(),
                    const SizedBox(height: 16),

                    // Basic info
                    _buildSection(
                      title: 'Informations générales',
                      children: [
                        _buildField(label: 'Nom du produit', initialValue: _name, onSaved: (v) => _name = v!, validator: (v) => v!.isEmpty ? 'Requis' : null),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(child: _buildField(label: 'Marque', initialValue: _brand, onSaved: (v) => _brand = v!, validator: (v) => v!.isEmpty ? 'Requis' : null)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildField(label: 'Catégorie', initialValue: _category, onSaved: (v) => _category = v!, validator: (v) => v!.isEmpty ? 'Requis' : null)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildField(
                          label: 'Description',
                          initialValue: _description,
                          maxLines: 4,
                          onSaved: (v) => _description = v!,
                          validator: (v) => (v?.length ?? 0) < 10 ? 'Min. 10 caractères' : null,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Price & stock
                    _buildSection(
                      title: 'Prix & Stock',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildField(
                                label: 'Prix (â‚¬)',
                                initialValue: _price.toString(),
                                keyboardType: TextInputType.number,
                                onSaved: (v) => _price = double.parse(v!),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Requis';
                                  if (double.tryParse(v) == null) return 'Nombre invalide';
                                  if (double.parse(v) <= 0) return '> 0 requis';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildField(
                                label: 'Quantité en stock',
                                initialValue: _stockQuantity.toString(),
                                keyboardType: TextInputType.number,
                                onSaved: (v) => _stockQuantity = int.parse(v!),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Requis';
                                  if (int.tryParse(v) == null) return 'Entier requis';
                                  if (int.parse(v) < 0) return '≥ 0';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile.adaptive(
                          value: _inStock,
                          onChanged: (v) => setState(() => _inStock = v),
                          title: const Text('En stock', style: TextStyle(fontWeight: FontWeight.w500)),
                          subtitle: Text(_inStock ? 'Disponible Ã  la vente' : 'Non disponible'),
                          activeColor: Colors.deepPurple,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Sizes
                    _buildSection(
                      title: 'Pointures',
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _predefinedSizes.map((s) {
                            final selected = _sizes.contains(s);
                            return GestureDetector(
                              onTap: () => setState(() => selected ? _sizes.remove(s) : _sizes.add(s)),
                              child: Container(
                                width: 48,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: selected ? Colors.deepPurple : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade300),
                                ),
                                child: Center(
                                  child: Text(s, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 13)),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_sizes.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Sélectionnées: ${_sizes.join(", ")}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Colors
                    _buildSection(
                      title: 'Couleurs',
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _predefinedColors.map((c) {
                            final selected = _colors.contains(c);
                            return GestureDetector(
                              onTap: () => setState(() => selected ? _colors.remove(c) : _colors.add(c)),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: selected ? Colors.deepPurple : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: selected ? Colors.deepPurple : Colors.grey.shade300),
                                ),
                                child: Text(c, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontWeight: selected ? FontWeight.bold : FontWeight.normal, fontSize: 12)),
                              ),
                            );
                          }).toList(),
                        ),
                        if (_colors.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text('Sélectionnées: ${_colors.join(", ")}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveForm,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: Text(
                          isEditing ? 'Mettre à jour le produit' : 'Ajouter le produit',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Image du produit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 12),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 90,
                  height: 90,
                  color: Colors.grey.shade100,
                  child: _imageUrl.isEmpty
                      ? const Icon(Icons.image_outlined, size: 36, color: Colors.grey)
                      : Image.network(_imageUrl, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.broken_image, color: Colors.grey)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: TextFormField(
                  controller: _imageUrlCtrl,
                  decoration: InputDecoration(
                    labelText: 'URL de l\'image',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    prefixIcon: const Icon(Icons.link),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.photo_library),
                      onPressed: _pickAndUploadImage,
                      tooltip: 'Uploader depuis la galerie',
                      color: Colors.deepPurple,
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  onChanged: (v) => setState(() => _imageUrl = v),
                  onSaved: (v) => _imageUrl = v ?? '',
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'URL requise';
                    if (!v.startsWith('http')) return 'URL invalide';
                    return null;
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String initialValue,
    required void Function(String?) onSaved,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      validator: validator,
      onSaved: onSaved,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../../../data/models/product.dart';

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();

  String _selectedCategory = 'Makanan';
  bool _isLoading = false;

  final List<String> _categories = [
    'Makanan',
    'Minuman',
    'Snack',
    'Elektronik',
    'Lainnya',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );

      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        code: 'PRD${DateTime.now().millisecondsSinceEpoch}',
        description: 'Produk ${_nameController.text.trim()}',
        price: double.parse(_priceController.text),
        stock: 50, // Default stock
        category: _selectedCategory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      productProvider.addProduct(newProduct);

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        Navigator.of(context).pop(true); // Return true to indicate success

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newProduct.name} berhasil ditambahkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.add_box,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Tambah Produk Baru',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Nama Produk
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk',
                  hintText: 'Contoh: Kopi Hitam',
                  prefixIcon: Icon(Icons.inventory),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama produk tidak boleh kosong';
                  }
                  if (value.trim().length < 3) {
                    return 'Nama produk minimal 3 karakter';
                  }
                  return null;
                },
                textCapitalization: TextCapitalization.words,
                enabled: !_isLoading,
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items:
                    _categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                onChanged:
                    _isLoading
                        ? null
                        : (value) {
                          setState(() {
                            _selectedCategory = value ?? 'Makanan';
                          });
                        },
              ),
              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  hintText: 'Contoh: 15000',
                  prefixIcon: Icon(Icons.attach_money),
                  prefixText: 'Rp ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Harga tidak boleh kosong';
                  }
                  final price = double.tryParse(value.trim());
                  if (price == null || price <= 0) {
                    return 'Harga harus berupa angka positif';
                  }
                  return null;
                },
                enabled: !_isLoading,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveProduct,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text('Simpan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the dialog
Future<bool?> showAddProductDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const AddProductDialog(),
  );
}

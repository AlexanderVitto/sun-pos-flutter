import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../../../data/models/product.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _descriptionController = TextEditingController();

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
    _stockController.dispose();
    _descriptionController.dispose();
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
        description:
            _descriptionController.text.trim().isEmpty
                ? 'Produk ${_nameController.text.trim()}'
                : _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        stock: int.parse(_stockController.text),
        category: _selectedCategory,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      productProvider.addProduct(newProduct);

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newProduct.name} berhasil ditambahkan'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Lihat',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        );

        // Clear form
        _nameController.clear();
        _priceController.clear();
        _stockController.clear();
        _descriptionController.clear();
        setState(() {
          _selectedCategory = 'Makanan';
        });
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Produk Baru',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProduct,
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text(
                      'SIMPAN',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Isi form di bawah untuk menambahkan produk baru ke inventory',
                        style: TextStyle(fontSize: 14, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Nama Produk
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Produk *',
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
              ),
              const SizedBox(height: 16),

              // Kategori
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Kategori *',
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
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? 'Makanan';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Silakan pilih kategori';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harga
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Harga *',
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
              ),
              const SizedBox(height: 16),

              // Stok
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Stok Awal *',
                  hintText: 'Contoh: 50',
                  prefixIcon: Icon(Icons.inventory_2),
                  suffixText: 'unit',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Stok tidak boleh kosong';
                  }
                  final stock = int.tryParse(value.trim());
                  if (stock == null || stock < 0) {
                    return 'Stok harus berupa angka non-negatif';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Deskripsi (Optional)
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (Opsional)',
                  hintText: 'Masukkan deskripsi produk...',
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Menyimpan...'),
                            ],
                          )
                          : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save),
                              SizedBox(width: 8),
                              Text(
                                'SIMPAN PRODUK',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                ),
              ),
              const SizedBox(height: 16),

              // Reset Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () {
                            _nameController.clear();
                            _priceController.clear();
                            _stockController.clear();
                            _descriptionController.clear();
                            setState(() {
                              _selectedCategory = 'Makanan';
                            });
                          },
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('RESET FORM'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

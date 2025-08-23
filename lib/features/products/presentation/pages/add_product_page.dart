import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class AddProductPage extends StatelessWidget {
  const AddProductPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addProduct)),
      body: const Center(child: Text('Add Product Page - Coming Soon')),
    );
  }
}

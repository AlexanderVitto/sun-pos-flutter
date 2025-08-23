import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class SalesPage extends StatelessWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.sales)),
      body: const Center(child: Text('Sales Page - Coming Soon')),
    );
  }
}

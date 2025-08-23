import 'package:flutter/material.dart';
import '../../../../core/constants/app_strings.dart';

class AddCustomerPage extends StatelessWidget {
  const AddCustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.addCustomer)),
      body: const Center(child: Text('Add Customer Page - Coming Soon')),
    );
  }
}

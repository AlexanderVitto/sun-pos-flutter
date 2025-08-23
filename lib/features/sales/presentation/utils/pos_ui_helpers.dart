import 'package:flutter/material.dart';

class PosUIHelpers {
  /// Format price to Indonesian currency format
  static String formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  /// Get icon for product category
  static IconData getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case 'single rows':
        return Icons.water_drop;
      case 'display cake':
        return Icons.cake;
      case 'snacks':
        return Icons.cookie;
      case 'beverages':
        return Icons.local_drink;
      case 'food':
        return Icons.restaurant;
      default:
        return Icons.shopping_bag;
    }
  }

  /// Get color for product category
  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'single rows':
        return Colors.blue;
      case 'display cake':
        return Colors.pink;
      case 'snacks':
        return Colors.orange;
      case 'beverages':
        return Colors.cyan;
      case 'food':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  /// Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// Show error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error dialog
  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error, color: Colors.red),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text(message),
            ],
          ),
        );
      },
    );
  }
}

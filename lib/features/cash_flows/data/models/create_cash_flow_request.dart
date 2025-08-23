class CreateCashFlowRequest {
  final int storeId;
  final String title;
  final String description;
  final int amount;
  final String type; // 'in' or 'out'
  final String category;
  final String transactionDate; // YYYY-MM-DD format
  final String? notes;

  CreateCashFlowRequest({
    required this.storeId,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.category,
    required this.transactionDate,
    this.notes,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {
      'store_id': storeId.toString(),
      'title': title,
      'description': description,
      'amount': amount.toString(),
      'type': type,
      'category': category,
      'transaction_date': transactionDate,
    };

    if (notes != null && notes!.isNotEmpty) {
      formData['notes'] = notes!;
    }

    return formData;
  }

  // Validation method
  String? validate() {
    if (title.isEmpty) {
      return 'Title is required';
    }
    if (description.isEmpty) {
      return 'Description is required';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (!['in', 'out'].contains(type)) {
      return 'Type must be either "in" or "out"';
    }
    if (category.isEmpty) {
      return 'Category is required';
    }
    // Validate date format YYYY-MM-DD
    final dateRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!dateRegex.hasMatch(transactionDate)) {
      return 'Transaction date must be in YYYY-MM-DD format';
    }
    return null;
  }
}

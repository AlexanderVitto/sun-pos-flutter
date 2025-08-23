class Validators {
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value.trim().replaceAll(RegExp(r'[^0-9]'), ''))) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final number = double.tryParse(value.trim());
    if (number == null) {
      return 'Please enter a valid number';
    }

    if (number < 0) {
      return '$fieldName cannot be negative';
    }

    return null;
  }

  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }

    final price = double.tryParse(value.trim());
    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price <= 0) {
      return 'Price must be greater than 0';
    }

    return null;
  }

  static String? validateStock(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Stock is required';
    }

    final stock = int.tryParse(value.trim());
    if (stock == null) {
      return 'Please enter a valid stock number';
    }

    if (stock < 0) {
      return 'Stock cannot be negative';
    }

    return null;
  }
}

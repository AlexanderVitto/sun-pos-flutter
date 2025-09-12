class PaymentConstants {
  // Payment method options with API values and display labels
  static const Map<String, String> paymentMethods = {
    'cash': 'Tunai',
    'card': 'Kartu (Debit/Kredit)',
    'bank_transfer': 'Transfer Bank',
    'digital_wallet': 'E-Wallet',
    'credit': 'Kredit',
  };

  // Get display name for payment method
  static String getPaymentMethodDisplayName(String methodKey) {
    return paymentMethods[methodKey] ?? methodKey;
  }

  // Get all payment method keys
  static List<String> get paymentMethodKeys => paymentMethods.keys.toList();

  // Get all payment method display names
  static List<String> get paymentMethodDisplayNames =>
      paymentMethods.values.toList();

  // Check if payment method is valid
  static bool isValidPaymentMethod(String methodKey) {
    return paymentMethods.containsKey(methodKey);
  }
}

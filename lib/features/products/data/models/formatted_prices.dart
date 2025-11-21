/// Formatted price strings for display purposes
class FormattedPrices {
  final String finalPrice;
  final String basePrice;
  final String priceDifference;

  const FormattedPrices({
    required this.finalPrice,
    required this.basePrice,
    required this.priceDifference,
  });

  factory FormattedPrices.fromJson(Map<String, dynamic> json) {
    return FormattedPrices(
      finalPrice: json['final_price'] ?? '',
      basePrice: json['base_price'] ?? '',
      priceDifference: json['price_difference'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'final_price': finalPrice,
      'base_price': basePrice,
      'price_difference': priceDifference,
    };
  }

  @override
  String toString() {
    return 'FormattedPrices(finalPrice: $finalPrice, basePrice: $basePrice, difference: $priceDifference)';
  }
}

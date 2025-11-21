/// Customer-specific pricing information for a product variant
class CustomerPricing {
  final double finalPrice;
  final double basePrice;
  final String priceSource;
  final double priceDifference;
  final double priceDifferencePercentage;
  final bool hasCustomerPricing;
  final String? customerGroupName;

  const CustomerPricing({
    required this.finalPrice,
    required this.basePrice,
    required this.priceSource,
    required this.priceDifference,
    required this.priceDifferencePercentage,
    required this.hasCustomerPricing,
    this.customerGroupName,
  });

  factory CustomerPricing.fromJson(Map<String, dynamic> json) {
    return CustomerPricing(
      finalPrice: (json['final_price'] ?? 0).toDouble(),
      basePrice: (json['base_price'] ?? 0).toDouble(),
      priceSource: json['price_source'] ?? 'base',
      priceDifference: (json['price_difference'] ?? 0).toDouble(),
      priceDifferencePercentage: (json['price_difference_percentage'] ?? 0)
          .toDouble(),
      hasCustomerPricing: json['has_customer_pricing'] ?? false,
      customerGroupName: json['customer_group_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'final_price': finalPrice,
      'base_price': basePrice,
      'price_source': priceSource,
      'price_difference': priceDifference,
      'price_difference_percentage': priceDifferencePercentage,
      'has_customer_pricing': hasCustomerPricing,
      'customer_group_name': customerGroupName,
    };
  }

  @override
  String toString() {
    return 'CustomerPricing(finalPrice: $finalPrice, basePrice: $basePrice, source: $priceSource, hasCustomerPricing: $hasCustomerPricing)';
  }
}

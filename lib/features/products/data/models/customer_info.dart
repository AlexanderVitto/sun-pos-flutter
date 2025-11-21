/// Customer information associated with product pricing
class CustomerInfo {
  final int customerId;
  final String customerName;
  final String? customerGroupName;
  final bool hasCustomerPricing;

  const CustomerInfo({
    required this.customerId,
    required this.customerName,
    this.customerGroupName,
    required this.hasCustomerPricing,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      customerId: json['customer_id'] ?? 0,
      customerName: json['customer_name'] ?? '',
      customerGroupName: json['customer_group_name'],
      hasCustomerPricing: json['has_customer_pricing'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'customer_name': customerName,
      'customer_group_name': customerGroupName,
      'has_customer_pricing': hasCustomerPricing,
    };
  }

  @override
  String toString() {
    return 'CustomerInfo(customerId: $customerId, customerName: $customerName, groupName: $customerGroupName)';
  }
}

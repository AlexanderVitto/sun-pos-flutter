class UpdateCustomerRequest {
  final String name;
  final String phone;
  final String? address;
  final int? customerGroupId;

  const UpdateCustomerRequest({
    required this.name,
    required this.phone,
    this.address,
    this.customerGroupId,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{'name': name, 'phone': phone};

    if (address != null) {
      json['address'] = address!;
    }

    if (customerGroupId != null) {
      json['customer_group_id'] = customerGroupId!;
    }

    return json;
  }

  @override
  String toString() {
    return 'UpdateCustomerRequest(name: $name, phone: $phone, address: $address, customerGroupId: $customerGroupId)';
  }
}

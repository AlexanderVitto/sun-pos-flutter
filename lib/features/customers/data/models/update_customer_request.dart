class UpdateCustomerRequest {
  final String name;
  final String phone;

  const UpdateCustomerRequest({required this.name, required this.phone});

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }

  @override
  String toString() {
    return 'UpdateCustomerRequest(name: $name, phone: $phone)';
  }
}

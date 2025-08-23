class CreateCustomerRequest {
  final String name;
  final String phone;

  const CreateCustomerRequest({required this.name, required this.phone});

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone};
  }

  @override
  String toString() {
    return 'CreateCustomerRequest(name: $name, phone: $phone)';
  }
}


class CustomerModel {
  final String id;
  final String name;
  final String email;
  late final String phone;
  final String address;
  final String city;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.address = '',
    required this.city,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['street']?.toString() ?? json['address']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
    );
  }
}

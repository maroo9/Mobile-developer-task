
class CustomerModel {
  final int id;
  final String name;
  final String email;
  String phone;
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
    final rawId = json['id'];
    final parsedId = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');

    String stringValue(dynamic value) {
      if (value == null || value == false) return '';
      return value.toString().trim();
    }

    return CustomerModel(
      // 0 is a parsing sentinel only. The list screen rejects it before use.
      id: parsedId ?? 0,
      name: stringValue(json['name']),
      email: stringValue(json['email']),
      phone: stringValue(json['phone']),
      address: stringValue(json['street']).isNotEmpty
          ? stringValue(json['street'])
          : stringValue(json['address']),
      city: stringValue(json['city']),
    );
  }
}

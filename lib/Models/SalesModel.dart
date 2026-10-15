class SaleOrderModel {
  final int id;
  final String orderNumber;
  final int customerId;
  final String customerName;
  final String orderDate;
  final String status;
  final double total;

  SaleOrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.orderDate,
    required this.status,
    required this.total,
  });

  factory SaleOrderModel.fromJson(Map<String, dynamic> json) {
    final partner = json['partner_id'];
    final orderId = json['id'];
    final customerId = partner is List && partner.isNotEmpty
        ? partner.first
        : null;
    final customerName = partner is List && partner.length > 1
        ? partner[1]
        : null;
    final rawTotal = json['amount_total'];

    return SaleOrderModel(
      id: orderId is int ? orderId : int.tryParse('$orderId') ?? 0,
      orderNumber: json['name']?.toString() ?? '',
      customerId: customerId is int
          ? customerId
          : int.tryParse('$customerId') ?? 0,
      customerName: customerName?.toString() ?? '',
      orderDate: json['date_order']?.toString() ?? '',
      status: json['state']?.toString() ?? '',
      total: rawTotal is num ? rawTotal.toDouble() : double.tryParse('$rawTotal') ?? 0,
    );
  }
}

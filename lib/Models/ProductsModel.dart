class Productsmodel {
  final int productid;
  final String productname;
  final String prodcttype;
  final double productprice;
  final double quantity;
  final double subtotal;

  Productsmodel({
    required this.productid,
    required this.productname,
    required this.prodcttype,
    required this.productprice,
    required this.quantity,
    required this.subtotal,
  });

  factory Productsmodel.fromJson(Map<String, dynamic> json) {
    final product = json['product_id'];

    return Productsmodel(
      productid: product is List && product.isNotEmpty
          ? (product[0] is int ? product[0] as int : int.tryParse('${product[0]}') ?? 0)
          : 0,
      productname: product is List && product.length > 1
          ? product[1].toString()
          : json['name']?.toString() ?? '',
      prodcttype: json['display_type']?.toString() ?? '',
      productprice: json['price_unit'] is num
          ? (json['price_unit'] as num).toDouble()
          : double.tryParse('${json['price_unit']}') ?? 0.0,
      quantity: json['product_uom_qty'] is num
          ? (json['product_uom_qty'] as num).toDouble()
          : double.tryParse('${json['product_uom_qty']}') ?? 0.0,
      subtotal: json['price_subtotal'] is num
          ? (json['price_subtotal'] as num).toDouble()
          : double.tryParse('${json['price_subtotal']}') ?? 0.0,
    );
  }
}

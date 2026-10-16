import 'dart:convert';

import '../../network/odooClint.dart';

class SalesRemoteDataSource {
  SalesRemoteDataSource(this.client);

  final Odooclint client;

   Future<List<Map<String, dynamic>>> getSalesOrders() async {
    final response = await client.callKw(
      model: 'sale.order',
      method: 'search_read',
      args: [[]],
      kwargs: {
        'fields': [
          'id',
          'name',
          'partner_id',
          'date_order',
          'state',
          'amount_total',
        ],
        'limit': 100,
        'order': 'date_order desc',
        },
    );

    if (response is! List) {
      throw Exception('Invalid sales order lines response from Odoo.');
    }
    return response
        .whereType<Map>()
        .map((order) => Map<String, dynamic>.from(order))
        .toList();

  }

   Future<List<Map<String, dynamic>>> getSalesOrderLines({

    required int orderId,
  }) async {
    if (orderId <= 0) throw ArgumentError.value(orderId, 'orderId', 'Must be greater than zero.');
    final response = await client.callKw(
        model: 'sale.order.line'
        , method: 'search_read',
        args: [[[ 'order_id', '=', orderId ], ['display_type', '=', false]]],
        kwargs: {
          'fields': [
            'id',
            'product_id',
            'name',
            'product_uom_qty',
            'price_unit',
            'price_subtotal',
            'price_total',
            'display_type'
          ],
          'limit': 500,
          'order': 'id asc',
        }
    );
    if (response is! List) {
      throw Exception('Invalid sales order lines response from Odoo.');
    }
       return response
        .whereType<Map>()
        .map((line) => Map<String, dynamic>.from(line))
        .toList();
  }

   Future<void> confirmSaleOrder({required int orderId}) async {
    if (orderId <= 0) throw ArgumentError.value(orderId, 'orderId','Must be greater than zero.');
    final result = await client.callKw(
      model: 'sale.order',
      method: 'action_confirm',
      args: [
        [orderId],
      ],
    );

    }

}

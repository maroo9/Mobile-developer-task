
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../../Models/SalesModel.dart';

class Odoo {
  static const String url = 'https://testingsales45464.odoo.com';

  static const String loginApi = '/web/session/authenticate';

  static String? sessionCookie;
  static int? userId;
  static bool? isInternalUser;

  static Future<bool> signIn({
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
        Uri.parse('$url$loginApi'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'db': database,
            'login': username,
            'password': password,
          },
          'id': 1,
        }),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint('Odoo HTTP status: ${response.statusCode}');

      final Map<String, dynamic> data =
      jsonDecode(response.body) as Map<String, dynamic>;

      // Log the response for debugging.
      // Never log passwords, API keys, or session cookies.
      if (data['error'] != null) {
        final error = data['error'];
        debugPrint('Odoo RPC error: ${jsonEncode(error)}');
      } else {
        final result = data['result'];
        debugPrint(
          'Odoo returned a result: ${result is Map}',
        );
      }

      final result = data['result'];

      if (response.statusCode != 200 ||
          result is! Map ||
          result['uid'] == null ||
          result['uid'] == false) {
        userId = null;
        sessionCookie = null;
        return false;
      }

      userId = result['uid'] as int;

      // Extract the session cookie if the server sends it.
      final cookies = response.headers['set-cookie'];

      if (cookies != null) {
        final match =
        RegExp(r'session_id=([^;,\s]+)').firstMatch(cookies);

        if (match != null) {
          sessionCookie = 'session_id=${match.group(1)}';
        }
      }

      debugPrint('Odoo login succeeded. User ID: $userId');

      return true;
    } on Exception catch (e, stackTrace) {
      debugPrint('Odoo connection error: $e');
      debugPrintStack(stackTrace: stackTrace);
      return false;
    }
  }

  static Future<bool> checkInternalUser() async {
    if (sessionCookie == null || sessionCookie!.isEmpty) return false;

    // `has_group` is a supported res.users method and checks the external ID.
    final response = await http.post(
      Uri.parse('$url/web/dataset/call_kw/res.users/has_group'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionCookie!,
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': 'res.users',
          'method': 'has_group',
          // call_kw treats res.users.has_group as a record method on this
          // Odoo endpoint: first provide the record IDs, then the method arg.
          'args': [
            [userId],
            'base.group_user',
          ],
          'kwargs': {},
        },
        'id': 7,
      }),
    );
    if (response.statusCode != 200) {
      throw Exception('Unable to verify Odoo internal user access');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception('Odoo group check failed: ${data['error']}');
    }
    final result = data['result'];
    if (result is! bool) {
      throw Exception('Invalid Odoo group check response');
    }
    isInternalUser = result;
    return result;
  }

  static Future<List<Map<String, dynamic>>> getCustomers() async {
    if (sessionCookie == null) {
      throw Exception('Not logged in to Odoo');
    }

    final response = await http.post(
      Uri.parse('$url/web/dataset/call_kw/res.partner/search_read'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionCookie!,
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': 'res.partner',
          'method': 'search_read',
          'args': [
            [
              ['customer_rank', '>', 0],
            ],
          ],
          'kwargs': {
            'fields': ['id', 'name', 'phone', 'email', 'street', 'city'],
            'limit': 100,
            'order': 'name asc',
          },
        },
        'id': 2,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['error'] != null) {
      throw Exception('Odoo error: ${data['error']}');
    }

    final result = data['result'];

    if (result is! List) {
      throw Exception('Invalid response from Odoo');
    }

    final customers = result
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();

    debugPrint('Customers fetched: ${customers.length}');
    debugPrint('Customer data: $customers');

    return customers;
  }

  static Future<Map<String, dynamic>> getCustomerById({
    required int customerId,
  }) async {
    if (customerId <= 0) {
      throw ArgumentError.value(customerId, 'customerId', 'Must be a real Odoo ID greater than zero');
    }
    if (sessionCookie == null || sessionCookie!.isEmpty) {
      throw Exception('Not logged in to Odoo');
    }

    final response = await http.post(
      Uri.parse('$url/web/dataset/call_kw/res.partner/read'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionCookie!,
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': 'res.partner',
          'method': 'read',
          'args': [[customerId]],
          'kwargs': {
            'fields': ['id', 'name', 'phone', 'email', 'street', 'city'],
          },
        },
        'id': 4,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] != null) {
      throw Exception('Odoo error: ${data['error']}');
    }

    final result = data['result'];
    if (result is! List || result.isEmpty || result.first is! Map) {
      throw Exception('Customer $customerId was not found in Odoo');
    }
    return Map<String, dynamic>.from(result.first as Map);
  }



  static Future<bool> updateCustomerPhone({
    required int customerId,
    required String phone,
  }) async {
    if (customerId <= 0) {
      throw ArgumentError.value(customerId, 'customerId', 'Must be a real Odoo ID greater than zero');
    }
    if (sessionCookie == null || sessionCookie!.isEmpty) {
      throw Exception('Not logged in to Odoo');
    }

    Future<Map<String, dynamic>> callOdoo({
      required String model,
      required String method,
      required List<dynamic> args,
      Map<String, dynamic> kwargs = const {},
    }) async {
      final response = await http.post(
        Uri.parse('$url/web/dataset/call_kw/$model/$method'),
        headers: {
          'Content-Type': 'application/json',
          'Cookie': sessionCookie!,
        },
        body: jsonEncode({
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'model': model,
            'method': method,
            'args': args,
            'kwargs': kwargs,
          },
          'id': 3,
        }),
      );

      debugPrint('$method status: ${response.statusCode}');
      debugPrint('$method response: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (data['error'] != null) {
        throw Exception('Odoo error: ${data['error']}');
      }

      return data;
    }

    // CustomerModel.id comes from the numeric `id` returned by getCustomers.
    // Odoo's write method expects a list of those database record IDs.
    final updateResponse = await callOdoo(
      model: 'res.partner',
      method: 'write',
      args: [
        [customerId],
        {'phone': phone},
      ],
    );

    final result = updateResponse['result'];
    if (result is! bool) {
      throw Exception('Odoo returned an invalid write result');
    }

    if (!result) return false;

    // Confirm the persisted value so the UI only reports success after Odoo
    // returns the updated phone for this exact partner record.
    final verifyResponse = await callOdoo(
      model: 'res.partner',
      method: 'read',
      args: [
        [customerId],
      ],
      kwargs: {
        'fields': ['phone'],
      },
    );
    final verifyResult = verifyResponse['result'];
    if (verifyResult is! List || verifyResult.isEmpty) return false;
    final record = verifyResult.first;
    return record is Map && record['phone']?.toString() == phone;
  }

  static Future<List<Map<String, dynamic>>> getSalesOrders() async {
    if (sessionCookie == null || sessionCookie!.isEmpty) {
      throw Exception('Not logged in to Odoo');
    }

    final response = await http.post(
      Uri.parse('$url/web/dataset/call_kw/sale.order/search_read'),
      headers: {
        'Content-Type': 'application/json',
        'Cookie': sessionCookie!,
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': 'sale.order',
          'method': 'search_read',
          'args': [[]],
          'kwargs': {
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
        },
        'id': 5,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('HTTP error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (data['error'] != null) {
      throw Exception('Odoo error: ${data['error']}');
    }

    final result = data['result'];

    if (result is! List) {
      throw Exception('Invalid Sales Orders response from Odoo');
    }

    return result
        .whereType<Map>()
        .map((order) => Map<String, dynamic>.from(order))
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getSalesOrderLines({
    required int orderId,
  }) async {
    if (orderId <= 0) throw ArgumentError.value(orderId, 'orderId');
    if (sessionCookie == null || sessionCookie!.isEmpty) {
      throw Exception('Not logged in to Odoo');
    }
    final response = await http.post(
      Uri.parse('$url/web/dataset/call_kw/sale.order.line/search_read'),
      headers: {'Content-Type': 'application/json', 'Cookie': sessionCookie!},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': 'sale.order.line',
          'method': 'search_read',
          'args': [[[ 'order_id', '=', orderId ], ['display_type', '=', false]]],
          'kwargs': {
            'fields': ['id', 'product_id', 'name', 'product_uom_qty', 'price_unit', 'price_subtotal', 'price_total', 'display_type'],
            'limit': 500,
            'order': 'id asc',
          },
        },
        'id': 8,
      }),
    );
    if (response.statusCode != 200) throw Exception('HTTP error: ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] != null) throw Exception('Odoo error: ${data['error']}');
    final result = data['result'];
    if (result is! List) throw Exception('Invalid order lines response from Odoo');
    return result.whereType<Map>().map((line) => Map<String, dynamic>.from(line)).toList();
  }

  static Future<void> confirmSaleOrder({required int orderId}) async {
    if (orderId <= 0) throw ArgumentError.value(orderId, 'orderId');
    if (sessionCookie == null || sessionCookie!.isEmpty) {
      throw Exception('Not logged in to Odoo');
    }
    final response = await http.post(
      Uri.parse('$url/web/dataset/call_kw/sale.order/action_confirm'),
      headers: {'Content-Type': 'application/json', 'Cookie': sessionCookie!},
      body: jsonEncode({
        'jsonrpc': '2.0',
        'method': 'call',
        'params': {
          'model': 'sale.order',
          'method': 'action_confirm',
          'args': [[orderId]],
          'kwargs': {},
        },
        'id': 9,
      }),
    );
    if (response.statusCode != 200) throw Exception('HTTP error: ${response.statusCode}');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['error'] != null) throw Exception('Odoo error: ${data['error']}');
  }


}

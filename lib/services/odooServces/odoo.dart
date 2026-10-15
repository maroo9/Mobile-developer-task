
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Odoo {
  static const String url = 'https://testingsales45464.odoo.com';

  static const String loginApi = '/web/session/authenticate';

  static String? sessionCookie;
  static int? userId;

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
            'fields': ['name', 'phone', 'email', 'street', 'city'],
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

  static Future<bool> updateCustomerPhone({
    required String customerId,
    required String phone,
  }) async {
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

    // Find the customer by its reference, e.g. SM2005.
    final searchResponse = await callOdoo(
      model: 'res.partner',
      method: 'search_read',
      args: [
        [
          ['ref', '=', customerId],
        ],
      ],
      kwargs: {
        'fields': ['id', 'name', 'ref'],
        'limit': 1,
      },
    );

    final result = searchResponse['result'];

    if (result is! List || result.isEmpty) {
      throw Exception('Customer reference $customerId was not found.');
    }

    final customer = Map<String, dynamic>.from(result.first as Map);
    final int databaseId = customer['id'] as int;

    // Update using Odoo's actual integer record ID.
    final updateResponse = await callOdoo(
      model: 'res.partner',
      method: 'write',
      args: [
        [databaseId],
        {'phone': phone},
      ],
    );

    return updateResponse['result'] == true;
  }



}

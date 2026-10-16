
import 'dart:convert';

import 'package:dio/dio.dart';

class Odooclint {
  Odooclint({Dio? dio})
      : dio = dio ??
      Dio(
        BaseOptions(
          baseUrl: 'https://testingsales45464.odoo.com',
          connectTimeout: 15000,
          receiveTimeout: 30000,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

  final Dio dio;

  static const String loginApi = '/web/session/authenticate';

  String? sessionCookie;
  int? userId;

  bool get isAuthenticated => sessionCookie != null && userId != null;

  /// Authenticate the user and save the Odoo session.
  Future<bool> signIn({
    required String database,
    required String username,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        loginApi,
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'db': database,
            'login': username,
            'password': password,
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
        options: Options(
          extra: {'withCredentials': true},
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);
      final result = data['result'];

      if (data['error'] != null || result is! Map || result['uid'] == null) {
        userId = null;
        sessionCookie = null;
        return false;
      }

      userId = (result['uid'] as num).toInt();

      // Extract the Odoo session_id cookie from the response.
      final setCookie = response.headers['set-cookie'] ?? [];

      for (final cookieHeader in setCookie) {
        final match = RegExp(
          r'(?:^|;\s*)session_id=([^;]+)',
        ).firstMatch(cookieHeader);

        if (match != null) {
          sessionCookie = 'session_id=${match.group(1)}';
          break;
        }
      }

      // Dio may expose cookies differently depending on the platform.
      // Do not report a successful login if the session is unavailable.
      if (sessionCookie == null) {
        userId = null;
        return false;
      }

      return true;
    } on DioError catch (e) {
      userId = null;
      sessionCookie = null;
      throw Exception(
        'Odoo login failed: ${e.response?.statusCode ?? e.message}',
      );
    } catch (e) {
      userId = null;
      sessionCookie = null;
      throw Exception('Unexpected Odoo login error: $e');
    }
  }

  /// Execute an Odoo model method using JSON-RPC.
  Future<dynamic> callKw({
    required String model,
    required String method,
    required List<dynamic> args,
    Map<String, dynamic>? kwargs,
  }) async {
    if (!isAuthenticated) {
      throw Exception('You must sign in to Odoo first.');
    }

    try {
      final response = await dio.post(
        '/web/dataset/call_kw/$model/$method',
        data: {
          'jsonrpc': '2.0',
          'method': 'call',
          'params': {
            'model': model,
            'method': method,
            'args': args,
            'kwargs': kwargs ?? <String, dynamic>{},
          },
          'id': DateTime.now().millisecondsSinceEpoch,
        },
        options: Options(
          headers: {
            'Cookie': sessionCookie!,
          },
        ),
      );

      final data = Map<String, dynamic>.from(response.data as Map);

      if (data['error'] != null) {
        final error = data['error'];
        throw Exception(
          error is Map
              ? error['data']?['message'] ??
              error['message'] ??
              'Odoo API error'
              : 'Odoo API error'
              : 'Odoo API error',
        );
      }

      if (!data.containsKey('result')) {
        throw Exception('Odoo response does not contain a result.');
      }

      return data['result'];
    } on DioError catch (e) {
      throw Exception(
        'Odoo request failed: ${e.response?.statusCode ?? e.message}',
      );
    }
  }

  /// Check whether the signed-in user is an internal Odoo user.
  Future<bool> checkInternalUser() async {
    if (userId == null) return false;

    final result = await callKw(
      model: 'res.users',
      method: 'has_group',
      args: [
        [userId],
        'base.group_user',
      ],
    );

    if (result is! bool) {
      throw Exception('Invalid Odoo group-check response.');
    }

    return result;
  }

  /// Clear the current session.
  void logout() {
    sessionCookie = null;
    userId = null;
  }

  /// Close the Dio client when it is no longer needed.
  void dispose() {
    dio.close();
  }
}

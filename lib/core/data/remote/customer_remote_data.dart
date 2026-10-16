
import 'package:mobile_developer_task/core/network/odooClint.dart';

class CoustmetRemoteDataSource {
  CoustmetRemoteDataSource(this.client);

  final Odooclint client;

  Future<List<Map<String, dynamic>>> getCustomers() async {
    final result = await client.callKw(
      model: 'res.partner',
      method: 'search_read',
      args: [
        [
          ['customer_rank', '>', 0],
        ],
      ],
      kwargs: {
        'fields': [
          'id',
          'name',
          'phone',
          'email',
          'street',
          'city',
        ],
        'limit': 100,
        'order': 'name asc',
      },
    );

    if (result is! List) {
      throw Exception('Invalid customer response from Odoo.');
    }

    return result
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
  }

  Future<Map<String, dynamic>> getCustomerById({
    required int customerId,
  }) async {
    if (customerId <= 0) {
      throw ArgumentError.value(
        customerId,
        'customerId',
        'Must be greater than zero.',
      );
    }

    final result = await client.callKw(
      model: 'res.partner',
      method: 'read',
      args: [
        [customerId],
      ],
      kwargs: {
        'fields': [
          'id',
          'name',
          'phone',
          'email',
          'street',
          'city',
        ],
      },
    );

    if (result is! List || result.isEmpty || result.first is! Map) {
      throw Exception('Customer $customerId was not found.');
    }

    return Map<String, dynamic>.from(result.first as Map);
  }

  Future<bool> updateCustomerPhone({
    required int customerId,
    required String phone,
  }) async {
    if (customerId <= 0) {
      throw ArgumentError.value(
        customerId,
        'customerId',
        'Must be greater than zero.',
      );
    }

    final result = await client.callKw(
      model: 'res.partner',
      method: 'write',
      args: [
        [customerId],
        {'phone': phone},
      ],
    );

    if (result is! bool) {
      throw Exception('Invalid response when updating customer phone.');
    }

    if (!result) return false;

    // Verify the saved value in Odoo.
    final updatedCustomer = await getCustomerById(
      customerId: customerId,
    );

    return updatedCustomer['phone']?.toString() == phone;
  }
}

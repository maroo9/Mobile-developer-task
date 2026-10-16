import '../remote/customer_remote_data.dart';
import 'package:mobile_developer_task/core/data/remote/customer_remote_data.dart';
class CustomerRepository {
  CustomerRepository({
    required this.customerRemoteDataSource,
  });

  final CoustmetRemoteDataSource customerRemoteDataSource;

  Future<List<Map<String, dynamic>>> getCustomers() {
    return customerRemoteDataSource.getCustomers();
  }

  Future<Map<String, dynamic>> getCustomerById({
    required int customerId,
  }) {
    return customerRemoteDataSource.getCustomerById(
      customerId: customerId,
    );
  }

  Future<bool> updateCustomerPhone({
    required int customerId,
    required String phone,
  }) {
    return customerRemoteDataSource.updateCustomerPhone(
      customerId: customerId,
      phone: phone,
    );
  }
}
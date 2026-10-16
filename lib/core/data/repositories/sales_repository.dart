
import '../remote/auth_remote_data.dart';
import '../remote/sales_remote_data.dart';

class SalesRepository {
  SalesRepository({
    required this.salesRemoteDataSource,
    required this.authRemoteDataSource,
  });

  final SalesRemoteDataSource salesRemoteDataSource;
  final AuthRemoteDataSource authRemoteDataSource;

  Future<bool> checkInternalUser() {
    return authRemoteDataSource.checkInternalUser();
  }

  Future<List<Map<String, dynamic>>> getSalesOrders() {
    return salesRemoteDataSource.getSalesOrders();
  }

  Future<List<Map<String, dynamic>>> getSalesOrderLines({
    required int orderId,
  }) {
    return salesRemoteDataSource.getSalesOrderLines(
      orderId: orderId,
    );
  }

  Future<void> confirmSaleOrder({
    required int orderId,
  }) {
    return salesRemoteDataSource.confirmSaleOrder(
      orderId: orderId,
    );
  }
}

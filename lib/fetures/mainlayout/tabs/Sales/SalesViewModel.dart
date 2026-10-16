
import 'package:flutter/foundation.dart';

import '../../../../Models/ProductsModel.dart';
import '../../../../Models/SalesModel.dart';
import '../../../../core/data/repositories/sales_repository.dart';

class SalesViewModel extends ChangeNotifier {
  SalesViewModel(this.repository);

  final SalesRepository repository;

  List<SaleOrderModel> orders = [];
  bool isLoading = true;
  bool isInternalUser = false;
  String? errorMessage;

  bool _disposed = false;

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    if (_disposed) return;

    isLoading = true;
    errorMessage = null;
    _notify();

    try {
      isInternalUser = await repository.checkInternalUser();

      if (_disposed) return;

      if (!isInternalUser) {
        orders = [];
        return;
      }

      final rows = await repository.getSalesOrders();

      if (_disposed) return;

      orders = rows
          .map(SaleOrderModel.fromJson)
          .where((order) => order.id > 0)
          .toList();
    } catch (e) {
      if (!_disposed) {
        errorMessage = e.toString();
      }
    } finally {
      if (!_disposed) {
        isLoading = false;
        _notify();
      }
    }
  }

  Future<List<Productsmodel>> loadOrderLines(int orderId) async {
    final rows = await repository.getSalesOrderLines(
      orderId: orderId,
    );

    return rows.map(Productsmodel.fromJson).toList();
  }

  Future<void> confirmOrder(SaleOrderModel order) async {
    if (order.id <= 0) {
      throw ArgumentError.value(order.id, 'orderId');
    }

    if (!{'draft', 'sent'}.contains(order.status)) {
      throw StateError('Only quotations can be confirmed.');
    }

    await repository.confirmSaleOrder(orderId: order.id);

    // Reload orders so the UI reflects the latest state.
    await loadOrders();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

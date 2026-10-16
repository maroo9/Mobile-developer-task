
import 'package:flutter/material.dart';
import '../../../../../core/data/repositories/coustomer_repository.dart';

class CustomerListViewModel extends ChangeNotifier {
  CustomerListViewModel(this.repository);

  final CustomerRepository repository;

  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  bool isLoading = false;
  bool _requestInProgress = false;

  String? errorMessage;
  String searchQuery = '';

  Future<void> loadCustomers() async {
    if (_requestInProgress) return;

    _requestInProgress = true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      customers = await repository.getCustomers();
      _filterCustomers();
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      _requestInProgress = false;
      isLoading = false;
      notifyListeners();
    }
  }

  void searchCustomers(String query) {
    searchQuery = query;
    _filterCustomers();
    notifyListeners();
  }

  void _filterCustomers() {
    final query = searchQuery.trim().toLowerCase();

    filteredCustomers = customers.where((customer) {
      final name = (customer['name'] ?? '')
          .toString()
          .toLowerCase();

      return name.contains(query);
    }).toList();
  }
}

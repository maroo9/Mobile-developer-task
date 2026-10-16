
import 'package:flutter/material.dart';

import '../../../../../Models/CustomerModel.dart';
import '../../../../../core/Di/app_dependencies.dart';
import '../Customer_Details_Screen/CustomerDetailsScreenUI.dart';
import 'CustomerListScreenVM.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() =>
      _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  late final CustomerListViewModel viewModel;

  final TextEditingController searchController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    // Dependency -> Repository -> ViewModel
    viewModel = CustomerListViewModel(
      AppDependencies.customerRepository,
    );

    viewModel.addListener(_refresh);
    viewModel.loadCustomers();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  String _displayValue(
      dynamic value, {
        required String fallback,
      }) {
    if (value == null || value == false) return fallback;

    final text = value.toString().trim();

    return text.isEmpty || text.toLowerCase() == 'false'
        ? fallback
        : text;
  }

  Future<void> _openCustomer(
      Map<String, dynamic> customerData,
      ) async {
    final selectedCustomer =
    CustomerModel.fromJson(customerData);

    if (selectedCustomer.id <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot open customer: invalid Odoo ID.',
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailsScreen(
          customer: selectedCustomer,
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewModel.removeListener(_refresh);
    viewModel.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        actions: [
          IconButton(
            onPressed: viewModel.isLoading
                ? null
                : viewModel.loadCustomers,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              onChanged: viewModel.searchCustomers,
              decoration: InputDecoration(
                hintText: 'Search customers by name',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          Expanded(
            child: viewModel.isLoading
                ? const Center(
              child: CircularProgressIndicator(),
            )
                : viewModel.errorMessage != null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Failed to load customers',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: viewModel.loadCustomers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : viewModel.filteredCustomers.isEmpty
                ? const Center(
              child: Text('No customers found'),
            )
                : ListView.builder(
              itemCount:
              viewModel.filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer =
                viewModel.filteredCustomers[index];

                return Card(
                  margin:
                  const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: ListTile(
                    onTap: () =>
                        _openCustomer(customer),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      _displayValue(
                        customer['name'],
                        fallback: 'No name',
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone: ${_displayValue(customer['phone'], fallback: 'Not provided')}',
                        ),
                        Text(
                          'City: ${_displayValue(customer['city'], fallback: 'Not provided')}',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

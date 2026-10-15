
import 'package:flutter/material.dart';

import '../../../../../Models/CustomerModel.dart';
import '../../../../../services/odooServces/odoo.dart';
import '../Customer_Details_Screen/CustomerDetailsScreenUI.dart';

class CustomerListScreen extends StatefulWidget {
  const CustomerListScreen({super.key});

  @override
  State<CustomerListScreen> createState() =>
      _CustomerListScreenState();
}

class _CustomerListScreenState extends State<CustomerListScreen> {
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> filteredCustomers = [];

  final TextEditingController searchController =
  TextEditingController();

  bool isLoading = true;
  String? errorMessage;

  String _displayValue(dynamic value, {required String fallback}) {
    if (value == null || value == false) return fallback;
    final text = value.toString().trim();
    return text.isEmpty || text.toLowerCase() == 'false' ? fallback : text;
  }

  @override
  void initState() {
    super.initState();
    loadCustomers();
    searchController.addListener(searchCustomers);
  }

  Future<void> loadCustomers() async {
    try {
      final result = await Odoo.getCustomers();

      if (!mounted) return;

      final query = searchController.text.trim().toLowerCase();
      setState(() {
        customers = result;
        filteredCustomers = result.where((customer) {
          final name = _displayValue(customer['name'], fallback: '').toLowerCase();
          return name.contains(query);
        }).toList();
        isLoading = false;
        errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  void searchCustomers() {
    if (!mounted) return;
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredCustomers = customers.where((customer) {
        final name = _displayValue(customer['name'], fallback: '').toLowerCase();

        return name.contains(query);
      }).toList();
    });
  }

  Future<void> _openCustomer(Map<String, dynamic> customerData) async {
    final selectedCustomer = CustomerModel.fromJson(customerData);
    debugPrint('Selected Odoo customer ID: ${selectedCustomer.id}');

    if (selectedCustomer.id <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Cannot open customer: invalid Odoo ID.')),
        );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CustomerDetailsScreen(customer: selectedCustomer),
      ),
    );
  }

  @override
  void dispose() {
    searchController.removeListener(searchCustomers);
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
            onPressed: loadCustomers,
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
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : errorMessage != null
                ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Failed to load customers',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      if (!mounted) return;
                      setState(() {
                        isLoading = true;
                        errorMessage = null;
                      });
                      loadCustomers();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
                : filteredCustomers.isEmpty
                ? const Center(
              child: Text('No customers found'),
            )
                : ListView.builder(
              itemCount: filteredCustomers.length,
              itemBuilder: (context, index) {
                final customer =
                filteredCustomers[index];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 5,
                  ),
                  child: ListTile(
                    onTap: () => _openCustomer(customer),
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      _displayValue(customer['name'], fallback: 'No name'),
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

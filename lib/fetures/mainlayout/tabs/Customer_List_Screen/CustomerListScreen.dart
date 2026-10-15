
import 'package:flutter/material.dart';

import '../../../../Models/CustomerModel.dart';
import '../../../../services/odooServces/odoo.dart';
import '../Customer_Details_Screen/Customer_Details _Screen.dart';

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

      setState(() {
        customers = result;
        filteredCustomers = result;
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
    final query = searchController.text.trim().toLowerCase();

    setState(() {
      filteredCustomers = customers.where((customer) {
        final name =
        (customer['name'] ?? '').toString().toLowerCase();

        return name.contains(query);
      }).toList();
    });
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
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => CustomerDetailsScreen(
                            customer: CustomerModel.fromJson(customer),
                          ),
                        ),
                      );
                    },
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(
                      customer['name']?.toString() ??
                          'No name',
                    ),
                    subtitle: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Phone: ${customer['phone'] ?? 'Not provided'}',
                        ),
                        Text(
                          'City: ${customer['city'] ?? 'Not provided'}',
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

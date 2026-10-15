import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../Models/ProductsModel.dart';
import '../../../../Models/SalesModel.dart';
import 'SalesViewModel.dart';

class Sales extends StatefulWidget {
  const Sales({super.key});

  @override
  State<Sales> createState() => _SalesState();
}

class _SalesState extends State<Sales> {
  late final SalesViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = SalesViewModel()..addListener(_refresh);
    viewModel.loadOrders();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    viewModel.removeListener(_refresh);
    viewModel.dispose();
    super.dispose();
  }

  String _date(String value) {
    if (value.isEmpty) return '—';
    try {
      return DateFormat.yMMMd().format(DateTime.parse(value).toLocal());
    } catch (_) {
      return value;
    }
  }

  String _status(String value) => switch (value) {
        'draft' => 'Quotation',
        'sent' => 'Quotation Sent',
        'sale' => 'Sales Order',
        'done' => 'Locked',
        'cancel' => 'Cancelled',
        _ => value.isEmpty ? 'Unknown' : value,
      };

  Future<void> _showDetails(SaleOrderModel order) async {
    final linesFuture = viewModel.loadOrderLines(order.id);
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => FutureBuilder<List<Productsmodel>>(
        future: linesFuture,
        builder: (context, snapshot) {
          final canConfirm = order.status == 'draft' || order.status == 'sent';
          return AlertDialog(
            title: Text(order.orderNumber),
            content: SizedBox(
              width: 440,
              child: snapshot.connectionState != ConnectionState.done
                  ? const SizedBox(
                      height: 100,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : snapshot.hasError
                      ? Text('Could not load products: ${snapshot.error}')
                      : SingleChildScrollView(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Customer: ${order.customerName}'),
                              Text('Order date: ${_date(order.orderDate)}'),
                              Text('Status: ${_status(order.status)}'),
                              const Divider(height: 24),
                              const Text(
                                'Products',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              ...snapshot.data!.map(_productRow),
                              const Divider(height: 24),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  'Total: ${order.total.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Close'),
              ),
              if (canConfirm && !snapshot.hasError)
                FilledButton.icon(
                  onPressed: snapshot.connectionState == ConnectionState.done
                      ? () => _confirm(order, dialogContext)
                      : null,
                  icon: const Icon(Icons.check),
                  label: const Text('Confirm order'),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _productRow(Productsmodel product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.inventory_2_outlined, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '${product.productname}\n${product.quantity} × ${product.productprice.toStringAsFixed(2)}',
            ),
          ),
          Text(product.subtotal.toStringAsFixed(2)),
        ],
      ),
    );
  }

  Future<void> _confirm(SaleOrderModel order, BuildContext dialogContext) async {
    try {
      await viewModel.confirmOrder(order);
      if (!mounted) return;
      Navigator.of(dialogContext).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sale order confirmed.')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not confirm sale order: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Orders'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: viewModel.isLoading ? null : viewModel.loadOrders,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.errorMessage != null
              ? _messageState(
                  icon: Icons.error_outline,
                  message: 'Could not load sales orders.\n${viewModel.errorMessage}',
                  action: FilledButton.icon(
                    onPressed: viewModel.loadOrders,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                )
              : !viewModel.isInternalUser
                  ? _messageState(
                      icon: Icons.lock_outline,
                      message: 'Sales Orders are available to internal users only.',
                    )
                  : viewModel.orders.isEmpty
                      ? _messageState(
                          icon: Icons.receipt_long_outlined,
                          message: 'No sales orders found.',
                        )
                      : RefreshIndicator(
                          onRefresh: viewModel.loadOrders,
                          child: ListView.separated(
                            padding: const EdgeInsets.all(16),
                            itemCount: viewModel.orders.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final order = viewModel.orders[index];
                              return Card(
                                child: ListTile(
                                  onTap: () => _showDetails(order),
                                  leading: const CircleAvatar(
                                    child: Icon(Icons.receipt_long_outlined),
                                  ),
                                  title: Text(order.orderNumber),
                                  subtitle: Text(
                                    '${order.customerName.isEmpty ? 'Customer unavailable' : order.customerName}\n${_date(order.orderDate)}',
                                  ),
                                  isThreeLine: true,
                                  trailing: _statusChip(order.status),
                                ),
                              );
                            },
                          ),
                        ),
    );
  }

  Widget _statusChip(String status) {
    final isConfirmed = status == 'sale' || status == 'done';
    return Chip(
      label: Text(_status(status)),
      visualDensity: VisualDensity.compact,
      backgroundColor: isConfirmed ? Colors.green.shade100 : Colors.blueGrey.shade100,
    );
  }

  Widget _messageState({
    required IconData icon,
    required String message,
    Widget? action,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: Colors.blueGrey),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            if (action != null) ...[
              const SizedBox(height: 16),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

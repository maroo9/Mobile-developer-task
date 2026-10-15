
import 'package:flutter/material.dart';

import '../../../../../Models/CustomerModel.dart';
import '../../../../../services/odooServces/odoo.dart';

class CustomerDetailsViewModel extends ChangeNotifier {
  CustomerModel customer;

  late final TextEditingController phoneController;

  bool isSaving = false;
  bool isLoading = false;

  String? errorMessage;
  String? loadErrorMessage;
  String? loadErrorDetails;
  String? successMessage;

  bool _isDisposed = false;

  CustomerDetailsViewModel({
    required this.customer,
  }) {
    phoneController = TextEditingController(
      text: customer.phone,
    );

    phoneController.addListener(_onPhoneChanged);

    // Load fresh customer details from Odoo.
    loadCustomer();
  }

  // Safely notify listeners only while the ViewModel is active.
  void _notifyListenersSafely() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  // Load the latest details for this customer.
  Future<void> loadCustomer() async {
    if (_isDisposed || isLoading) return;

    if (customer.id <= 0) {
      loadErrorMessage = 'customer_load_failed';
      loadErrorDetails = 'Invalid Odoo customer ID: ${customer.id}';
      isLoading = false;
      _notifyListenersSafely();
      return;
    }

    isLoading = true;
    loadErrorMessage = null;
    loadErrorDetails = null;
    errorMessage = null;
    successMessage = null;

    _notifyListenersSafely();

    try {
      final data = await Odoo.getCustomerById(
        customerId: customer.id,
      );

      if (_isDisposed) return;

      final loadedCustomer = CustomerModel.fromJson(data);

      // Make sure Odoo returned the requested record.
      if (loadedCustomer.id != customer.id) {
        throw Exception('The returned customer ID does not match.');
      }

      customer = loadedCustomer;

      // Refresh the phone field only after successful loading.
      phoneController.value = TextEditingValue(
        text: customer.phone,
        selection: TextSelection.collapsed(
          offset: customer.phone.length,
        ),
      );
    } catch (e, stackTrace) {
      if (_isDisposed) return;

      loadErrorMessage = 'customer_load_failed';
      loadErrorDetails = e.toString();

      debugPrint('CUSTOMER LOAD FAILED: $e');
      debugPrintStack(stackTrace: stackTrace);
    } finally {
      if (!_isDisposed) {
        isLoading = false;
        _notifyListenersSafely();
      }
    }
  }

  void _onPhoneChanged() {
    if (_isDisposed) return;

    if (errorMessage != null || successMessage != null) {
      errorMessage = null;
      successMessage = null;
      _notifyListenersSafely();
    }
  }

  // Save the updated phone number to Odoo.
  Future<bool> savePhone() async {
    if (_isDisposed || isSaving || isLoading) {
      return false;
    }

    if (customer.id <= 0) {
      _setError('phone_update_failed');
      return false;
    }

    if (loadErrorMessage != null) {
      _setError('customer_load_failed');
      return false;
    }

    final phone = phoneController.text.trim();

    debugPrint('========== CUSTOMER PHONE UPDATE ==========');
    debugPrint('Customer ID: ${customer.id}');

    // Validate the phone number.
    if (phone.isEmpty) {
      _setError('phone_required');
      return false;
    }

    if (phone == customer.phone.trim()) {
      _setError('phone_unchanged');
      return false;
    }

    isSaving = true;
    errorMessage = null;
    successMessage = null;

    _notifyListenersSafely();

    try {
      debugPrint('Sending phone update request to Odoo...');

      final success = await Odoo.updateCustomerPhone(
        customerId: customer.id,
        phone: phone,
      );

      if (_isDisposed) return false;

      debugPrint('Odoo update result: $success');

      if (!success) {
        _setError(
          'phone_update_not_confirmed',
          notify: false,
        );
        return false;
      }

      customer.phone = phone;
      successMessage = 'phone_updated';
      errorMessage = null;

      debugPrint('Customer phone updated successfully.');

      return true;
    } catch (e, stackTrace) {
      if (!_isDisposed) {
        errorMessage = 'phone_update_failed';
        successMessage = null;
      }

      debugPrint('CUSTOMER UPDATE FAILED: $e');
      debugPrintStack(stackTrace: stackTrace);

      return false;
    } finally {
      if (!_isDisposed) {
        isSaving = false;
        _notifyListenersSafely();
      }

      debugPrint('===========================================');
    }
  }

  void _setError(
      String message, {
        bool notify = true,
      }) {
    if (_isDisposed) return;

    errorMessage = message;
    successMessage = null;

    if (notify) {
      _notifyListenersSafely();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;

    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();

    super.dispose();
  }
}

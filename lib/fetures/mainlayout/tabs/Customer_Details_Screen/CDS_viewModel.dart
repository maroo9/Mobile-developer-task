
import 'package:flutter/material.dart';

import '../../../../Models/CustomerModel.dart';
import '../../../../services/odooServces/odoo.dart';

class CustomerDetailsViewModel extends ChangeNotifier {
  final CustomerModel customer;

  late final TextEditingController phoneController;

  bool isSaving = false;
  String? errorMessage;
  String? successMessage;

  CustomerDetailsViewModel({
    required this.customer,
  }) {
    phoneController = TextEditingController(
      text: customer.phone,
    );

    phoneController.addListener(_onPhoneChanged);
  }

  void _onPhoneChanged() {
    if (errorMessage != null || successMessage != null) {
      errorMessage = null;
      successMessage = null;
      notifyListeners();
    }
  }

  Future<bool> savePhone() async {
    if (isSaving) return false;

    final phone = phoneController.text.trim();

    debugPrint('========== CUSTOMER PHONE UPDATE ==========');
    debugPrint('Customer reference: ${customer.id}');
    debugPrint('Current phone: ${customer.phone}');
    debugPrint('New phone: $phone');

    // Validate empty input.
    if (phone.isEmpty) {
      _setError('phone_required');
      return false;
    }

    // Validate unchanged input.
    if (phone == customer.phone.trim()) {
      _setError('phone_unchanged');
      return false;
    }

    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      debugPrint('Sending phone update request to Odoo...');

      final success = await Odoo.updateCustomerPhone(
        customerId: customer.id,
        phone: phone,
      );

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
      errorMessage = 'phone_update_failed';
      successMessage = null;

      debugPrint('CUSTOMER UPDATE FAILED: $e');
      debugPrintStack(stackTrace: stackTrace);

      return false;
    } finally {
      isSaving = false;
      notifyListeners();
      debugPrint('===========================================');
    }
  }

  void _setError(String message, {bool notify = true}) {
    errorMessage = message;
    successMessage = null;

    if (notify) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    phoneController.removeListener(_onPhoneChanged);
    phoneController.dispose();
    super.dispose();
  }
}

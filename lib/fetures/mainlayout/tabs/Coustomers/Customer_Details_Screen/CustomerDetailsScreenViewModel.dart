
import 'package:flutter/material.dart';
import '../../../../../core/data/repositories/coustomer_repository.dart';

class CustomerDetailsScreenViewModel extends ChangeNotifier {
  CustomerDetailsScreenViewModel({
    required this.repository,
    required this.customerId,
  });

  final CustomerRepository repository;
  final int customerId;

  Map<String, dynamic>? customer;

  bool isLoading = false;
  bool isSaving = false;

  String? errorMessage;
  String? successMessage;

  String phone = '';
  String originalPhone = '';

  bool get hasPhoneChanged =>
      phone.trim() != originalPhone.trim();

  Future<void> loadCustomer() async {
    isLoading = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      customer = await repository.getCustomerById(
        customerId: customerId,
      );

      originalPhone = (customer?['phone'] ?? '').toString();
      phone = originalPhone;
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Called whenever the user types in the phone field.
  void phoneChanged(String value) {
    phone = value;
    errorMessage = null;
    successMessage = null;
    notifyListeners();
  }

  // Save the changed phone number to Odoo through the repository.
  Future<bool> savePhone() async {
    if (isSaving) return false;

    if (phone.trim().isEmpty) {
      errorMessage = 'Please enter a phone number.';
      notifyListeners();
      return false;
    }

    if (!hasPhoneChanged) {
      errorMessage = 'The phone number has not changed.';
      notifyListeners();
      return false;
    }

    isSaving = true;
    errorMessage = null;
    successMessage = null;
    notifyListeners();

    try {
      final newPhone = phone.trim();

      final saved = await repository.updateCustomerPhone(
        customerId: customerId,
        phone: newPhone,
      );

      if (!saved) {
        errorMessage = 'Could not save the phone number.';
        return false;
      }

      originalPhone = newPhone;
      phone = newPhone;

      customer = {
        ...?customer,
        'phone': newPhone,
      };

      successMessage = 'Phone number updated successfully.';
      return true;
    } catch (e) {
      errorMessage = e.toString();
      return false;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Models/CustomerModel.dart';
import '../../../../l10n/app_localizations.dart';
import 'CDS_viewModel.dart';

class CustomerDetailsScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerDetailsScreen({
    super.key,
    required this.customer,
  });

  @override
  State<CustomerDetailsScreen> createState() =>
      _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState
    extends State<CustomerDetailsScreen> {
  late final CustomerDetailsViewModel viewModel;

  @override
  void initState() {
    super.initState();

    viewModel = CustomerDetailsViewModel(
      customer: widget.customer,
    );

    viewModel.addListener(_refreshUI);
  }

  void _refreshUI() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    viewModel.removeListener(_refreshUI);
    viewModel.dispose();
    super.dispose();
  }

  Future<void> _savePhone() async {
    FocusScope.of(context).unfocus();

    final success = await viewModel.savePhone();

    if (!mounted) return;

    final local = AppLocalizations.of(context)!;
    final messageKey = success
        ? 'phone_updated'
        : viewModel.errorMessage ?? 'phone_update_failed';
    final message = switch (messageKey) {
      'phone_required' => local.phone_required,
      'phone_unchanged' => local.phone_unchanged,
      'phone_update_not_confirmed' => local.phone_update_not_confirmed,
      'phone_updated' => local.phone_updated,
      _ => local.phone_update_failed,
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: success
              ? Colors.green.shade700
              : Colors.red.shade700,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final customer = viewModel.customer;
    final customerName = customer.name.trim();
    final phone = viewModel.phoneController.text.trim();
    final email = customer.email.trim();
    final addressParts = [customer.address.trim(), customer.city.trim()]
        .where((part) => part.isNotEmpty)
        .toSet()
        .toList();
    final address = addressParts.join(', ');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17365D),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          local.customer_details,
          style: GoogleFonts.dmSerifDisplay(
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // CUSTOMER PROFILE HEADER
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFF17365D),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  local.customer_profile,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 17,
                    color: const Color(0xFFDCE6F1),
                  ),
                ),

                const SizedBox(height: 16),

                // AVATAR AND NAME
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            Color(0xFFB8D4FF),
                            Colors.white,
                          ],
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.white,
                        child: Text(
                          customerName.isNotEmpty
                              ? customerName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Color(0xFF17365D),
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    Expanded(
                      child: Text(
                        customerName.isNotEmpty
                            ? customerName
                            : local.unnamed_customer,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSerifDisplay(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                // PHONE
                _buildHeaderInfo(
                  icon: Icons.phone_outlined,
                  value: phone,
                ),

                const SizedBox(height: 13),

                // EMAIL
                _buildHeaderInfo(
                  icon: Icons.email_outlined,
                  value: email,
                ),

                const SizedBox(height: 13),

                // ADDRESS
                _buildHeaderInfo(
                  icon: Icons.location_on_outlined,
                  value: address,
                  fallback: local.not_provided,
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // CUSTOMER INFORMATION CARD
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  local.customer_information,
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF17365D),
                  ),
                ),

                const SizedBox(height: 22),

                // CUSTOMER NAME
                _buildFieldLabel(
                  icon: Icons.person_outline,
                  label: local.customer_name,
                ),

                const SizedBox(height: 10),

                _buildReadOnlyField(
                  value: customerName,
                  icon: Icons.person_outline,
                  hint: local.no_customer_name,
                ),

                const SizedBox(height: 20),

                // EDITABLE PHONE NUMBER
                _buildFieldLabel(
                  icon: Icons.phone_outlined,
                  label: local.phone,
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: viewModel.phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.done,
                  enabled: !viewModel.isSaving,
                  onSubmitted: (_) {
                    if (!viewModel.isSaving) {
                      _savePhone();
                    }
                  },
                  decoration: _inputDecoration(
                    hint: local.enter_phone,
                    icon: Icons.phone_outlined,
                  ),
                ),

                const SizedBox(height: 20),

                // EMAIL
                _buildFieldLabel(
                  icon: Icons.email_outlined,
                  label: local.email,
                ),

                const SizedBox(height: 10),

                _buildReadOnlyField(
                  value: email,
                  icon: Icons.email_outlined,
                  hint: local.no_email,
                ),

                const SizedBox(height: 20),

                // ADDRESS
                _buildFieldLabel(
                  icon: Icons.location_on_outlined,
                  label: local.address,
                ),

                const SizedBox(height: 10),

                _buildReadOnlyField(
                  value: address,
                  icon: Icons.location_on_outlined,
                  hint: local.no_address,
                ),

                const SizedBox(height: 28),

                // SAVE BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: viewModel.isSaving
                        ? null
                        : _savePhone,
                    icon: viewModel.isSaving
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(Icons.save_outlined),
                    label: Text(
                      viewModel.isSaving
                          ? local.saving
                          : local.save_phone,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF17365D),
                      disabledBackgroundColor:
                      const Color(0xFF7B8DA5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                Center(
                  child: Text(
                    local.only_phone_editable,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // PROFILE HEADER INFORMATION ROW
  Widget _buildHeaderInfo({
    required IconData icon,
    required String value,
    String fallback = '',
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 21,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value.isNotEmpty
                ? value
                : (fallback.isNotEmpty
                    ? fallback
                    : AppLocalizations.of(context)!.not_provided),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  // FIELD LABEL
  Widget _buildFieldLabel({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF17365D),
          size: 22,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF17365D),
            ),
          ),
        ),
      ],
    );
  }

  // READ-ONLY CUSTOMER INFORMATION
  Widget _buildReadOnlyField({
    required String value,
    required IconData icon,
    required String hint,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF17365D),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : hint,
              style: TextStyle(
                fontSize: 14,
                color: value.isNotEmpty
                    ? Colors.black87
                    : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // REUSABLE TEXT FIELD DECORATION
  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF17365D),
      ),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 15,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFF17365D),
          width: 1.5,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFE0E0E0),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../../Models/CustomerModel.dart';
import '../../../../../core/Coloursmanger/ColorsManger.dart';
import '../../../../../core/Di/app_dependencies.dart';
import '../../../../../l10n/app_localizations.dart';
import 'package:mobile_developer_task/providers/localeProvider.dart';
import 'CustomerDetailsScreenViewModel.dart';

const _profileBlue = Colorsmanger.Blue;
const _pageBackground = Color(0xFFF3F6FB);
const _cardBlue = Color(0xFF17365D);

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

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  late final CustomerDetailsScreenViewModel viewModel;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();

    _phoneController = TextEditingController(
      text: widget.customer.phone,
    );

    viewModel = CustomerDetailsScreenViewModel(
      repository: AppDependencies.customerRepository,
      customerId: widget.customer.id,
    );

    viewModel.addListener(_refreshUI);
    viewModel.loadCustomer();
  }

  void _refreshUI() {
    if (!mounted) return;

    // Keep the text field in sync after the customer is loaded or saved.
    // Do not reset the cursor when the user is typing the same value.
    if (_phoneController.text != viewModel.phone) {
      _phoneController.value = TextEditingValue(
        text: viewModel.phone,
        selection: TextSelection.collapsed(
          offset: viewModel.phone.length,
        ),
      );
    }

    setState(() {});
  }

  @override
  void dispose() {
    viewModel.removeListener(_refreshUI);
    viewModel.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _text(dynamic value) => (value ?? '').toString().trim();

  String _errorText(AppLocalizations local, String? error) {
    switch (error) {
      case 'phone_required':
        return local.phone_required;
      case 'phone_unchanged':
        return local.phone_unchanged;
      case 'phone_update_not_confirmed':
        return local.phone_update_not_confirmed;
      case 'phone_update_failed':
        return local.phone_update_failed;
      default:
      // The ViewModel may provide a server exception string.
        return error?.isNotEmpty == true
            ? error!
            : local.phone_update_failed;
    }
  }

  Future<void> _savePhone() async {
    FocusScope.of(context).unfocus();

    final success = await viewModel.savePhone();
    if (!mounted) return;

    final local = AppLocalizations.of(context)!;
    final message = success
        ? local.phone_updated
        : _errorText(local, viewModel.errorMessage);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor:
          success ? Colors.green.shade700 : Colors.red.shade700,
        ),
      );
  }

  Future<void> _loadCustomer() async {
    await viewModel.loadCustomer();
  }

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final local = AppLocalizations.of(context)!;
    final customer = viewModel.customer;

    final customerName = _text(customer?['name']);
    final phone = viewModel.phone.trim();
    final email = _text(customer?['email']);

    final addressParts = <String>[
      _text(customer?['street']),
      _text(customer?['city']),
    ].where((part) => part.isNotEmpty).toSet().toList();

    final address = addressParts.join(', ');

    return Scaffold(
      backgroundColor: _pageBackground,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: _profileBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          local.customer_details,
          style: GoogleFonts.dmSerifDisplay(fontSize: 22),
        ),
      ),
      body: SafeArea(
        child: viewModel.isLoading && customer == null
            ? const Center(child: CircularProgressIndicator())
            : viewModel.errorMessage != null && customer == null
            ? _buildLoadError(local)
            : GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: ListView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              // Profile header
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: _profileBlue,
                  borderRadius: BorderRadius.circular(22),
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
                            radius: 28,
                            backgroundColor: Colors.white,
                            child: Text(
                              customerName.isNotEmpty
                                  ? customerName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: _profileBlue,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            customerName.isNotEmpty
                                ? customerName
                                : local.unnamed_customer,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSerifDisplay(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: () async {
                            await localeProvider.toggleLocale();
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                localeProvider.isArabic ? 'EN' : 'AR',
                                style: GoogleFonts.dmSerifDisplay(
                                  fontSize: 15,
                                  color: Colorsmanger.darkblue,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    _buildHeaderInfo(
                      icon: Icons.phone_outlined,
                      value: phone,
                    ),
                    const SizedBox(height: 12),
                    _buildHeaderInfo(
                      icon: Icons.email_outlined,
                      value: email,
                    ),
                    const SizedBox(height: 12),
                    _buildHeaderInfo(
                      icon: Icons.location_on_outlined,
                      value: address,
                      fallback: local.not_provided,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Customer information card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
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
                        color: _cardBlue,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildFieldLabel(
                      icon: Icons.person_outline,
                      label: local.customer_name,
                    ),
                    const SizedBox(height: 8),
                    _buildReadOnlyField(
                      value: customerName,
                      icon: Icons.person_outline,
                      hint: local.no_customer_name,
                    ),
                    const SizedBox(height: 18),
                    _buildFieldLabel(
                      icon: Icons.phone_outlined,
                      label: local.phone,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.done,
                      textDirection: TextDirection.ltr,
                      enabled: !viewModel.isSaving,
                      onChanged: viewModel.phoneChanged,
                      onSubmitted: (_) {
                        if (!viewModel.isSaving &&
                            !viewModel.isLoading) {
                          _savePhone();
                        }
                      },
                      decoration: _inputDecoration(
                        hint: local.enter_phone,
                        icon: Icons.phone_outlined,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildFieldLabel(
                      icon: Icons.email_outlined,
                      label: local.email,
                    ),
                    const SizedBox(height: 8),
                    _buildReadOnlyField(
                      value: email,
                      icon: Icons.email_outlined,
                      hint: local.no_email,
                    ),
                    const SizedBox(height: 18),
                    _buildFieldLabel(
                      icon: Icons.location_on_outlined,
                      label: local.address,
                    ),
                    const SizedBox(height: 8),
                    _buildReadOnlyField(
                      value: address,
                      icon: Icons.location_on_outlined,
                      hint: local.no_address,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: viewModel.isSaving ||
                            viewModel.isLoading
                            ? null
                            : _savePhone,
                        icon: viewModel.isSaving
                            ? const SizedBox(
                          width: 19,
                          height: 19,
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
                          backgroundColor: _cardBlue,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                          const Color(0xFF7B8DA5),
                          padding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
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
        ),
      ),
    );
  }

  Widget _buildLoadError(AppLocalizations local) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 44,
            ),
            const SizedBox(height: 12),
            Text(
              local.customer_update_failed,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.errorMessage ?? 'Unable to load customer details.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: viewModel.isLoading ? null : _loadCustomer,
              icon: const Icon(Icons.refresh),
              label: Text(local.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo({
    required IconData icon,
    required String value,
    String fallback = '',
  }) {
    final displayValue = value.isNotEmpty
        ? value
        : fallback.isNotEmpty
        ? fallback
        : AppLocalizations.of(context)!.not_provided;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            displayValue,
            softWrap: true,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldLabel({
    required IconData icon,
    required String label,
  }) {
    return Row(
      children: [
        Icon(icon, color: _cardBlue, size: 21),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _profileBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField({
    required String value,
    required IconData icon,
    required String hint,
  }) {
    final hasValue = value.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E5ED)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: _profileBlue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              hasValue ? value : hint,
              softWrap: true,
              style: TextStyle(
                fontSize: 14,
                color: hasValue ? Colors.black87 : Colors.grey.shade500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: _profileBlue),
      filled: true,
      fillColor: const Color(0xFFF5F6FA),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5ED)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _cardBlue, width: 1.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE0E5ED)),
      ),
    );
  }
}

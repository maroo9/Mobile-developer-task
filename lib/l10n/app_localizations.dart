import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @username.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get username;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @login_success.
  ///
  /// In en, this message translates to:
  /// **'Login successful'**
  String get login_success;

  /// No description provided for @login_failed.
  ///
  /// In en, this message translates to:
  /// **'Invalid username or password'**
  String get login_failed;

  /// No description provided for @connection_error.
  ///
  /// In en, this message translates to:
  /// **'Unable to connect to Odoo'**
  String get connection_error;

  /// No description provided for @required_username.
  ///
  /// In en, this message translates to:
  /// **'Please enter your username'**
  String get required_username;

  /// No description provided for @required_password.
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get required_password;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @customer_details.
  ///
  /// In en, this message translates to:
  /// **'Customer Details'**
  String get customer_details;

  /// No description provided for @customer_name.
  ///
  /// In en, this message translates to:
  /// **'Customer Name'**
  String get customer_name;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get city;

  /// No description provided for @search_customers.
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get search_customers;

  /// No description provided for @no_customers.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get no_customers;

  /// No description provided for @update_customer.
  ///
  /// In en, this message translates to:
  /// **'Update Customer'**
  String get update_customer;

  /// No description provided for @save_changes.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get save_changes;

  /// No description provided for @customer_updated.
  ///
  /// In en, this message translates to:
  /// **'Customer updated successfully'**
  String get customer_updated;

  /// No description provided for @customer_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to update customer'**
  String get customer_update_failed;

  String get customer_profile;
  String get customer_information;
  String get unnamed_customer;
  String get no_customer_name;
  String get no_phone;
  String get no_email;
  String get no_address;
  String get enter_phone;
  String get saving;
  String get save_phone;
  String get phone_updated;
  String get phone_update_failed;
  String get phone_required;
  String get phone_unchanged;
  String get phone_update_not_confirmed;
  String get only_phone_editable;
  String get not_provided;

  /// No description provided for @sales_orders.
  ///
  /// In en, this message translates to:
  /// **'Sales Orders'**
  String get sales_orders;

  /// No description provided for @order_number.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get order_number;

  /// No description provided for @order_date.
  ///
  /// In en, this message translates to:
  /// **'Order Date'**
  String get order_date;

  /// No description provided for @customer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customer;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// No description provided for @unit_price.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get unit_price;

  /// No description provided for @subtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get subtotal;

  /// No description provided for @tax.
  ///
  /// In en, this message translates to:
  /// **'Tax'**
  String get tax;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @quotation.
  ///
  /// In en, this message translates to:
  /// **'Quotation'**
  String get quotation;

  /// No description provided for @confirm_quotation.
  ///
  /// In en, this message translates to:
  /// **'Confirm Quotation'**
  String get confirm_quotation;

  /// No description provided for @quotation_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Quotation confirmed successfully'**
  String get quotation_confirmed;

  /// No description provided for @draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get draft;

  /// No description provided for @sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get sent;

  /// No description provided for @sale.
  ///
  /// In en, this message translates to:
  /// **'Sales Order'**
  String get sale;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @no_data.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get no_data;

  /// No description provided for @access_denied.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission'**
  String get access_denied;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You are offline'**
  String get offline;

  /// No description provided for @syncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncing;

  /// No description provided for @sync_completed.
  ///
  /// In en, this message translates to:
  /// **'Synchronization completed'**
  String get sync_completed;

  /// No description provided for @sync_failed.
  ///
  /// In en, this message translates to:
  /// **'Synchronization failed'**
  String get sync_failed;

  /// No description provided for @edit_customer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get edit_customer;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @my_profile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get my_profile;

  /// No description provided for @user_information.
  ///
  /// In en, this message translates to:
  /// **'User Information'**
  String get user_information;

  /// No description provided for @full_name.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get full_name;

  /// No description provided for @company.
  ///
  /// In en, this message translates to:
  /// **'Company'**
  String get company;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @account_settings.
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get account_settings;

  /// No description provided for @change_password.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get change_password;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @logout_confirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get logout_confirmation;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @profile_load_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile'**
  String get profile_load_failed;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_updated;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}

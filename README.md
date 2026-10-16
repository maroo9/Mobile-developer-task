# Mobile Developer Task

A Flutter application that connects to an Odoo instance. Users sign in with their Odoo account, browse customer records, update a customer's phone number, and view sales orders (including order details and confirmation actions when permitted).

## Requirements

- Flutter SDK compatible with Dart `^3.8.1` (see `pubspec.yaml`)
- An Odoo server, database name, and user account with the required access rights
- Android Studio, VS Code, or another Flutter development environment

## Run the app

```bash
flutter pub get
flutter run
```

To build an Android APK:

```bash
flutter build apk
```

The app starts on a short splash screen, then opens the login screen. Enter your Odoo username and password. The database name is currently configured in `lib/fetures/Auth/login/login.dart`; the Odoo server URL is configured in `lib/core/network/odooClint.dart`.

## Features

- Odoo login using a session cookie
- Customer list with name search
- Customer details and phone number editing
- Sales order list with order details
- Confirmation of eligible quotations
- English and Arabic localization

Sales data is shown only when the signed-in Odoo user belongs to the internal users group. Odoo access rights also determine which records and actions are available.

## Project structure

```text
lib/
├── main.dart                       App entry point and global providers
├── config/                         Validation and app configuration helpers
├── core/
│   ├── Di/                          Shared dependency setup (`AppDependencies`)
│   ├── data/
│   │   ├── remote/                  Odoo requests grouped by feature/data type
│   │   └── repositories/            Data operations exposed to ViewModels
│   ├── network/                     Odoo HTTP client, authentication, and JSON-RPC
│   ├── RoutesManger/                Named navigation routes
│   ├── Widget/                      Reusable form and button widgets
│   ├── Utilits/                     Shared UI helpers (loading dialog and toast)
│   ├── AssetsManger/                Asset references
│   └── Coloursmanger/               Shared color definitions
├── fetures/
│   ├── Auth/login/                  Login screen and login ViewModel
│   └── mainlayout/                  Splash screen, main layout, and feature tabs
│       └── tabs/
│           ├── Coustomers/          Customer list/details UI and ViewModels
│           └── Sales/               Sales order UI and ViewModel
├── l10n/                            English and Arabic localization resources
├── Models/                          Customer, sales order, and product models
├── providers/                       App-wide state, including locale selection
└── services/                        Additional/legacy service code
```

Some directory names retain their original spelling in the code (`fetures`, `Coustomers`, and `Utilits`). Keep those names in import paths unless you rename the directories and update all references.

## Data and dependency flow

```text
Screen → ViewModel → Repository → Remote data source → Odooclint → Odoo
```

After a successful login, `LoginViewModel` passes the authenticated `Odooclint` client to `AppDependencies.initialize()`. The dependency container creates the customer and sales repositories and their remote data sources around that same client, so requests share the authenticated session. Screens pass a repository to their ViewModel; the ViewModel handles loading and screen state, while the remote data source builds the Odoo operation.

For example, the customer screen asks `CustomerListViewModel` to load records. The ViewModel calls `CustomerRepository`, which delegates to `CoustmetRemoteDataSource`; that data source makes a JSON-RPC call through `Odooclint`.

## Configuration notes

- Odoo base URL: `lib/core/network/odooClint.dart`
- Odoo database name: `lib/fetures/Auth/login/login.dart`
- Localization source files: `lib/l10n/app_en.arb` and `lib/l10n/app_ar.arb`
- Logo asset: `assets/images/2slogo.png`

The current server URL and database name are set in source code. Update them for your environment before using the app with another Odoo instance. Do not commit real passwords, session cookies, or other credentials.

## Useful Flutter commands

```bash
flutter analyze
flutter test
flutter pub outdated
```


import 'package:flutter/material.dart';


import '../../../core/RoutesManger/Routesmanger.dart';
import '../../../core/Utilits/Uitills.dart';
import '../../../core/Di/app_dependencies.dart';
import '../../../core/network/odooClint.dart';

class LoginViewModel extends ChangeNotifier {
  Future<void> Login({
    required BuildContext context,
    required String username,
    required String password,
    required String database,
  }) async {
    final odooClient = Odooclint();
    var loadingShown = false;
    try {
      UiUtils.Showloading(context);
      loadingShown = true;

      final success = await odooClient.signIn(
        database: database,
        username: username,
        password: password,
      );

      if (loadingShown && context.mounted) {
        UiUtils.hidediaolog(context);
        loadingShown = false;
      }

      if (success) {
        AppDependencies.initialize(authenticatedClient: odooClient);
        UiUtils.showToastmassage(
          'Success',
          Colors.green,
        );

        Navigator.pushReplacementNamed(
          context,
          RoutesManager.Mainlayouts,
        );
      } else {
        odooClient.dispose();
        UiUtils.showToastmassage(
          'Invalid username or password',
          Colors.red,
        );
      }
    } catch (e) {
      odooClient.dispose();
      if (loadingShown && context.mounted) {
        UiUtils.hidediaolog(context);
      }

      UiUtils.showToastmassage(
        'Failed to login to Odoo: $e',
        Colors.red,
      );
    }
  }
}

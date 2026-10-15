
import 'package:flutter/material.dart';


import '../../../core/RoutesManger/Routesmanger.dart';
import '../../../core/Utilits/Uitills.dart';
import '../../../services/odooServces/odoo.dart';
import '../../mainlayout/mainLayout.dart';

class LoginViewModel extends ChangeNotifier {
  Future<void> Login({
    required BuildContext context,
    required String username,
    required String password,
    required String database,
  }) async {
    try {
      UiUtils.Showloading(context);

      final success = await Odoo.signIn(
        database: database,
        username: username,
        password: password,
      );

      UiUtils.hidediaolog(context);

      if (success) {
        UiUtils.showToastmassage(
          'Success',
          Colors.green,
        );

        Navigator.pushReplacementNamed(
          context,
          RoutesManager.Mainlayouts,
        );
      } else {
        UiUtils.showToastmassage(
          'Invalid username or password',
          Colors.red,
        );
      }
    } catch (e) {
      UiUtils.hidediaolog(context);

      UiUtils.showToastmassage(
        'Failed to login to Odoo',
        Colors.red,
      );
    }
  }
}

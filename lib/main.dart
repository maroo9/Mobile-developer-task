
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobile_developer_task/providers/localeProvider.dart';
import 'package:provider/provider.dart';

import 'core/RoutesManger/Routesmanger.dart';
import 'l10n/app_localizations.dart';
void main()async {
  WidgetsFlutterBinding.ensureInitialized(); // VERY IMPOR
  //await Firebase.initializeApp();
  final localeProvider = await LocaleProvider.create();
  runApp(MultiProvider(
      providers: [
      //  ChangeNotifierProvider(create: (context)=>UserProvider()),
        ChangeNotifierProvider<LocaleProvider>.value(value: localeProvider),
    //    ChangeNotifierProvider<HomeViewModel>(create: (context)=>HomeViewModel()),


      ],

      child: const MyApp()
  ),
  );
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();

    return ScreenUtilInit(
      designSize: Size(393, 841),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child)=> MaterialApp(
        debugShowCheckedModeBanner: false,
        locale: localeProvider.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: RoutesManager.routes,
        initialRoute:RoutesManager.splashscreen,
        // FirebaseAuth.instance.currentUser==null ?RoutesManager.Logins:RoutesManager.Mainlayout,
      ),
    );

  }
}

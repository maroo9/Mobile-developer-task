
import 'package:flutter/cupertino.dart';

import '../../fetures/Auth/login/login.dart';
import '../../fetures/mainlayout/Splashscreen/splashScreen.dart';
import '../../fetures/mainlayout/mainLayout.dart';
import '../../fetures/mainlayout/tabs/Coustomers/Customer_List_Screen/CustomerListScreenUI.dart';
import '../../fetures/mainlayout/tabs/Sales/SalesUI.dart';

abstract class RoutesManager {
   static const String splashscreen="/Splashscreen/";
  static const String Mainlayouts="/mainlayout/";
  static const String Logins="/Login/";
  static const String CoustomerListscreens="/Customerlistscreen/";
  static const String Salese="/Sales/";
  static Map<String,WidgetBuilder> routes={
     splashscreen:(context)=>Splashscreen(),
    Mainlayouts:(context)=>MainLayout(),
    Logins :(context)=>Login(),
    CoustomerListscreens :(context)=>CustomerListScreen(),
    Salese :(context)=>Sales(),


  };
}

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UiUtils{
  static void Showloading(BuildContext context){

    showDialog(
      barrierDismissible: false,
      context: context, builder: (context)=>AlertDialog(content:Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: CircularProgressIndicator(),
        ),
      ],
    )

    ),
    );

  }
  static void hidediaolog(BuildContext context){
    Navigator.pop(context);

  }
  static  void showToastmassage(String massage,Color bgcolour) {
    Fluttertoast.showToast(
        msg: massage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: bgcolour,
        textColor: Colors.white,
        fontSize: 16.0
    );
  }
}
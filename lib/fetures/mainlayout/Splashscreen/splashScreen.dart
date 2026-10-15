import 'package:flutter/material.dart';

import '../../../core/AssetsManger/Assets_manger/Assets_manger.dart';
import '../../../core/Coloursmanger/ColorsManger.dart';
import '../../../core/RoutesManger/Routesmanger.dart';

class Splashscreen extends StatefulWidget {
  const Splashscreen({super.key});

  @override
  State<Splashscreen> createState() => _SplashscreenState();
}

class _SplashscreenState extends State<Splashscreen> {
  @override
  void initState() {
    super.initState();
    nevigatestate();
  }

  Future<void> nevigatestate() async {
    await Future.delayed(Duration(seconds: 3));
    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context
      , RoutesManager.Logins
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colorsmanger.White,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 250,
          ),
          Container(
            width: 200,
            height: 200,
            child: Image(
              image: AssetImage(
                Imagemanger.logoimage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

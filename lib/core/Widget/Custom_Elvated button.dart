import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Coloursmanger/ColorsManger.dart';
class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({super.key,required this.text,required this.onPress});
  final String text;
  final VoidCallback onPress;

  @override
  Widget build(BuildContext context) {
    return   ElevatedButton(

        style: ElevatedButton.styleFrom(
          backgroundColor: Colorsmanger.lightgrey,
          foregroundColor: Colorsmanger.Whiteblue,
        ),
        onPressed: onPress,
        child: Text(text,style:GoogleFonts.inter(fontSize: 20,fontWeight: FontWeight.w500,color: Colorsmanger.darkblue),)
    );
  }

}

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../Coloursmanger/ColorsManger.dart';


class CustomTextButton extends StatelessWidget {
  const CustomTextButton({super.key,required this.texts, required this.onTap});
  final String? texts;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context){
    return    GestureDetector(
      onTap:onTap,
      child:      Text(texts!,style: GoogleFonts.inter(fontSize: 16.sp,fontWeight: FontWeight.w500, decoration: TextDecoration.underline,color: Colorsmanger.Blue),),

    );
  }
}

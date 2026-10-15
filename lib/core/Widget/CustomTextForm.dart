// this made for shortcuts as assets manager and routes manager:
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
class CustomTextForm extends StatelessWidget {
  //  write all the variables  in constartor to be  use it
  CustomTextForm({super.key,  this.labelText,
    this.hintText,
    required this.controller,
    this.prefixIcon,
    this.suffixIcon,
    this.isObscure = false,
    this.keyboardType = TextInputType.text,
    required this.validator,
    this.Lines=1,
    this.textStyle = const TextStyle(color: Colors.white),
  });
  // makes the variable
  final String? labelText;   /// as String "Name"
  final String? hintText;   /// as String "Hint name"
  final IconData?prefixIcon; /// as (IconData) that holds all icons
  final Widget? suffixIcon;     /// as widget to  use  IconButton
  final TextInputType? keyboardType;
  final bool isObscure;
  final TextStyle textStyle;
  String? Function(String?)? validator;  /// work as the condition of the inputs by user
  final TextEditingController controller;

  // final bool isSecure;
  //final String? Function(String?) validator;
  //final TextEditingController controller;
  final int Lines;

  @override
  Widget build(BuildContext context) {
    return   TextFormField(
      maxLines: Lines,
      controller:controller ,
      validator: validator,
      obscureText: isObscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon:prefixIcon == null? null:Icon(prefixIcon),
        suffixIcon: suffixIcon,
        labelText: labelText,
        hintText: hintText,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue),
        ),



      ),
    );
  }
}

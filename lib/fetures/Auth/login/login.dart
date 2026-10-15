
import 'package:flutter/material.dart';

import '../../../config/resoursecs/isvalidate.dart';
import '../../../core/AssetsManger/Assets_manger/Assets_manger.dart';
import '../../../core/Coloursmanger/ColorsManger.dart';
import '../../../core/RoutesManger/Routesmanger.dart';
import '../../../core/Widget/CustomTextForm.dart';
import '../../../core/Widget/Custom_Elvated button.dart';
import '../../../core/Widget/Custom_Text_Button.dart';
import 'LoginViewModel.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final LoginViewModel viewModel = LoginViewModel();

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  late final TextEditingController _usernamecontroller;
  late final TextEditingController _passwordcontroller;

  bool securePassword = true;
  bool isLoading = false;

  // Replace with your actual Odoo database name.
  static const String databaseName = 'testingsales45464';

  @override
  void initState() {
    super.initState();

    _usernamecontroller = TextEditingController();
    _passwordcontroller = TextEditingController();
  }

  @override
  void dispose() {
    _usernamecontroller.dispose();
    _passwordcontroller.dispose();
    viewModel.dispose();

    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 21,
            vertical: 20,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formkey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image(
                    image: AssetImage(Imagemanger.logoimage),
                    width: 136,
                    height: 150,
                  ),

                  const SizedBox(height: 24),

                  // Odoo username
                  CustomTextForm(
                    controller: _usernamecontroller,
                    validator: (input) {
                      if (input == null || input.trim().isEmpty) {
                        return 'Please enter your Odoo username';
                      }

                      return null;
                    },
                    isObscure: false,
                    keyboardType: TextInputType.text,
                    labelText: 'Odoo Username',
                    prefixIcon: Icons.person,
                  ),

                  const SizedBox(height: 16),

                  // Odoo password
                  CustomTextForm(
                    controller: _passwordcontroller,
                    validator: (input) {
                      if (input == null || input.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                    isObscure: securePassword,
                    labelText: 'Password',
                    prefixIcon: Icons.lock,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          securePassword = !securePassword;
                        });
                      },
                      icon: Icon(
                        securePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                    ),
                    keyboardType: TextInputType.visiblePassword,
                  ),

                  const SizedBox(height: 24),

                  CustomElevatedButton(
                    text: isLoading ? 'Please wait...' : 'Login',
                    onPress: ()async {
                      if (isLoading) return;

                      if (!_formkey.currentState!.validate()) {
                        return;
                      }
                      await viewModel.Login(context: context, username: _usernamecontroller.text, password: _passwordcontroller.text, database: databaseName);
                    },
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colorsmanger.Blue,
                          thickness: 1,
                          indent: 20,
                          endIndent: 20,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

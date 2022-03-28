import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clon/pages/homePage.dart';
import 'package:flutter_instagram_clon/pages/signIn_Page.dart';
import 'package:flutter_instagram_clon/servises/auth_servise.dart';

import '../servises/pref_servise.dart';
import '../utils/theme.dart';
import '../utils/utilServise.dart';
import '../views/button widget.dart';
import '../views/textfield_widget.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);
static const String id = "/signUpPage";
  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void _openSignInPage() async {
    String fullName = fullNameController.text.trim().toString();
    String email = emailController.text.trim().toString();
    String confirmPassword = confirmPasswordController.text.trim().toString();
    String password = passwordController.text.trim().toString();

    if((email.isEmpty || password.isEmpty || fullName.isEmpty || confirmPassword.isEmpty) && password == confirmPassword) {
      Utils.fireSnackBar("Please complete all the fields", context);
      return;
    }

    setState(() {
      isLoading = true;
    });

    await AuthService.signUpUser(fullName, email, password).then((response) {
      _getFirebaseUser(response);
    });
  }

  void _getFirebaseUser(User? user) async {
    setState(() {
      isLoading = false;
    });

    if(user != null) {
      Prefs.store(StorageKeys.UID, user.uid);
      Navigator.pushReplacementNamed(context, SignInPage.id);
    } else {
      Utils.fireSnackBar("Check Your Information", context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              decoration: ThemeService.backgroundGradient,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // #app_name
                        Text("Instagram", style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: ThemeService.fontHeader),),
                        SizedBox(height: 20,),

                        // #fullname
                        textField(hintText: "FullName", controller: fullNameController),
                        SizedBox(height: 10,),

                        // #email
                        textField(hintText: "Email", controller: emailController),
                        SizedBox(height: 10,),

                        // #password
                        textField(hintText: "Password", controller: passwordController),
                        SizedBox(height: 10,),

                        // #password
                        textField(hintText: "Confirm Password", controller: confirmPasswordController),
                        SizedBox(height: 10,),

                        // #signin
                        button(title: "Sign Up", onPressed: _openSignInPage),
                      ],
                    ),
                  ),
                  RichText(text: TextSpan(
                      text: "Already have an account? ",
                      style: const TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: "Sign In",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()..onTap = () {
                            Navigator.pushReplacementNamed(context, SignInPage.id);
                          },
                        )
                      ]
                  ),)
                ],
              ),
            ),
          ),

          isLoading ? Center(
            child: CircularProgressIndicator(),
          ) : SizedBox.shrink(),
        ],
      ),
    );
  }
}
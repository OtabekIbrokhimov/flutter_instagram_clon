import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clon/pages/signIn_Page.dart';
import 'package:flutter_instagram_clon/servises/pref_servise.dart';
import 'package:flutter_instagram_clon/utils/theme.dart';

import 'homePage.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({Key? key}) : super(key: key);
static const String id = "/splashPage";
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  Widget _starterPage() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if(snapshot.hasData) {
          Prefs.store(StorageKeys.UID, snapshot.data!.uid);
          return HomePage();
        } else {
          Prefs.remove(StorageKeys.UID);
          return SignInPage();
        }
      },
    );
  }

  void _openSignInPage() => Timer(const Duration(seconds: 2), () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => _starterPage())));

  @override
  void initState() {
    super.initState();
    _openSignInPage();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.only(top: 20, bottom: 40),
        decoration: ThemeService.backgroundGradient,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: const [
            Expanded(
              child: Center(child: Text("Instagram", style: TextStyle(color: Colors.white, fontSize: 45, fontFamily: ThemeService.fontHeader),)),
            ),
            Text("All rights reserved", style: TextStyle(color: Colors.white, fontSize: 16),),
          ],
        ),
      ),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_instagram_clon/pages/signIn_Page.dart';
import 'package:flutter_instagram_clon/pages/signUp_Page.dart';
import 'package:flutter_instagram_clon/utils/utilServise.dart';

import 'pref_servise.dart';
class AuthService {
  static final FirebaseAuth auth = FirebaseAuth.instance;

  static Future<User?> signUpUser(String name, String email, String password) async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      if (kDebugMode) {
        print(user.toString());
      }
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print("ERROR $e");
    }

    return null;
  }

  static Future<User?> signInUser(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;
      return user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      print(e);
    }

    return null;
  }

  static void signOutUser(BuildContext context) async {
    await auth.signOut();
    Prefs.remove(StorageKeys.UID).then((value) {
      Navigator.pushReplacementNamed(context, SignInPage.id);
    });
  }

  static void deleteAccount(BuildContext context) async {
    try {
      auth.currentUser!.delete();
      Prefs.remove(StorageKeys.UID);
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SignUpPage()), (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        Utils.fireSnackBar('The user must re-authenticate before this operation can be executed.', context);
      }
    }
  }

}
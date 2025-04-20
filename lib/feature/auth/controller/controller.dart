import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_cloud_firestore/firebase_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webrtc_calling/feature/auth/screen/home.dart';
import 'package:webrtc_calling/feature/home/controller/web_rtc_controller.dart';

class HomeController extends GetxController {
  final TextEditingController email = TextEditingController();
  final TextEditingController pass = TextEditingController();
  final TextEditingController semail = TextEditingController();
  final TextEditingController spass = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> signUpWithEmailAndPassword() async {
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: semail.text,
        password: spass.text,
      );
      await _firestore.collection('user').doc(userCredential.user?.uid).set({
        "email": semail.text,
        "password": spass.text,
      });
      Get.to(() => Home());
      Get.snackbar(
        "Success",
        "Account created successfully!",
        colorText: Colors.white,
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
      );
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred";

      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already in use. Try logging in instead.";
      } else if (e.code == 'weak-password') {
        errorMessage = "Your password is too weak. Try a stronger one!";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format!";
      }

      Get.snackbar(
        "Error",
        errorMessage,
        snackPosition: SnackPosition.TOP,
        colorText: Colors.white,
        backgroundColor: Colors.red,
      );
    } catch (e) {
      debugPrint("===========>>$e");
      Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
    } finally {}
  }

  Future<void> login2() async {
    debugPrint("====Login api hitted");
    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: email.text,
      password: pass.text,
    );
    if (userCredential.user != null) {
      Get.offAll(() => Calling());
      debugPrint("=======${userCredential.user?.uid}");
      debugPrint("=======${userCredential.user?.email}");
    }
  }
}

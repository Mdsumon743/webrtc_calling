import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webrtc_calling/core/global/custom_text.dart';
import 'package:webrtc_calling/core/global/custom_textfeild.dart';
import 'package:webrtc_calling/feature/auth/controller/controller.dart';
import 'package:webrtc_calling/feature/auth/screen/home.dart';

class Singup extends StatelessWidget {
  const Singup({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomTextPopins(
                text: "Sing Up",
                size: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
              SizedBox(height: 40),
              CustomTextfeild(controller: controller.semail, lebel: "Email"),
              SizedBox(height: 10),
              CustomTextfeild(controller: controller.spass, lebel: "Password"),

              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                ),

                onPressed: () {
                  controller.signUpWithEmailAndPassword();
                },
                child: Text(
                  "Singup",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
              ),

              TextButton(
                onPressed: () {
                  Get.to(() => Home());
                },
                child: CustomTextPopins(
                  text: 'Login',
                  fontWeight: FontWeight.w500,
                  size: 20,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

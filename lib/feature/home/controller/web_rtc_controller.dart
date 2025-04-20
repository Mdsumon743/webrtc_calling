import 'package:flutter/material.dart';
import 'package:webrtc_calling/core/global/custom_text.dart';

class Calling extends StatelessWidget {
  const Calling({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CustomTextPopins(text: "Call"),
      ),
    );
  }
}
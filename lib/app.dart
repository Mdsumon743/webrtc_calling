import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:webrtc_calling/feature/home/screen/home.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(title: "Web Rtc",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true),
    home: Home(),
    );
  }
}

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:webrtc_calling/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCiR0vBfO48sPrpQmst6Hwn7L8MBr7xTF0",
        authDomain: "web-rtc-2b1c7.firebaseapp.com",
        projectId: "web-rtc-2b1c7",
        storageBucket: "web-rtc-2b1c7.firebasestorage.app",
        messagingSenderId: "737437296770",
        appId: "1:737437296770:web:756d8e3284855096dc6c9b",
        measurementId: "G-5GFQ8KNXXS",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }
  runApp(MyApp());
}

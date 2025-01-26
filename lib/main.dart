import 'package:chat_app/view/chat.dart';
import 'package:chat_app/view/home.dart';
import 'package:chat_app/view/login.dart';
import 'package:chat_app/view/settings.dart';
import 'package:chat_app/view/splash_screen.dart';
import 'package:chat_app/view/users.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(GetMaterialApp(
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: ThemeMode.system,
    debugShowCheckedModeBanner: false,
    getPages: [
      GetPage(name: "/", page: () => SplashScreen()),
      GetPage(name: "/login", page: () => Login()),
      GetPage(name: "/home", page: () => Home()),
      GetPage(name: "/settings", page: () => SettingsPage()),
      GetPage(name: "/users", page: () => Users()),
      GetPage(name: "/chat", page: () => ChatPage()),
    ],
  ));
}

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class HomeController extends GetxController {
  var menuIndex = 0.obs;
  PageController pageController = PageController();
  late AppLifecycleListener appLifecycleListener;

  void setMenuIndex(int index) {
    menuIndex.value = index;
    pageController.jumpToPage(index);
  }

  @override
  void onInit() {
    super.onInit();
    appLifecycleListener = AppLifecycleListener(
      onStateChange: (value) {
        print("AppLifecycleListener $value");
        if (value == AppLifecycleState.resumed) {
          // FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid ?? "").get().then((value) {
          //   var data = value.data();
          //   print("user Data $data");
          // });

          FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update({
            "isOnline": true,
          });
          // user is onLine
        } else if (value == AppLifecycleState.paused) {
          FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid).update({
            "isOnline": false,
          });
          // user is offLine
        }
      },
    );
    updateFirebaseToken();
    // appLifecycleListener.dispose();
  }

  Future<void> updateFirebaseToken() async {
    String? token = await FirebaseMessaging.instance.getToken();
    print("Token =====> $token");
    FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser?.uid ?? "").update(
      {
        "fcmToken": token,
      },
    );
  }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }
}
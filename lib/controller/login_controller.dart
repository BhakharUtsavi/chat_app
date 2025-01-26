import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class LoginController extends GetxController {
  final email = TextEditingController();
  final password = TextEditingController();

  RxBool isLoad = false.obs;

  Future<void> login() async {
    isLoad.value = true;
    try {
      UserCredential user = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: email.text, password: password.text);
      //Get.toNamed("home");
      Get.offAllNamed("home");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.code);
    } catch (e) {
      print(e);
    }
    isLoad.value = false;
  }

  Future<void> register() async {
    isLoad.value = true;
    try {
      UserCredential userCred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: email.text, password: password.text);

      if (userCred.user != null) {
        await FirebaseFirestore.instance.collection("users").add({
          "id": userCred.user?.uid,
          "email": userCred.user?.email ?? "",
        });
        // Get.toNamed("home");
        Get.offAllNamed("home");
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.code);
    } catch (e) {
      print(e);
    }
    isLoad.value = false;
  }
}

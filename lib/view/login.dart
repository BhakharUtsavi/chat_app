import 'package:chat_app/controller/login_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  LoginController loginController = Get.put(LoginController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Obx(() {
              if (loginController.isLoad.value) {
                return CupertinoActivityIndicator(
                  radius: 20,
                );
              } else {
                return SizedBox.shrink();
              }
            }),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: loginController.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                  label: Text(
                    "Email",
                    style: GoogleFonts.roboto(fontSize: 12),
                  ),
                  hintText: "Email",
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: loginController.password,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              obscureText: true,
              decoration: InputDecoration(
                  label: Text(
                    "Password",
                    style: GoogleFonts.roboto(fontSize: 12),
                  ),
                  hintText: "Password",
                  border: OutlineInputBorder()),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        loginController.login();
                      },
                      child: Text(
                        "Login",
                        style: GoogleFonts.roboto(),
                      )),
                ),
                Expanded(
                  child: TextButton(
                      onPressed: () {
                        loginController.register();
                      },
                      child: Text(
                        "Register",
                        style: GoogleFonts.roboto(),
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              onTap: () async {
                GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ["email"]);
                try {
                  var act = await _googleSignIn.signIn();
                  print("act =======> ${act?.email}");
                  print("act =======> ${act?.id}");
                } catch (e) {
                  print("google Error =======> $e");
                }
              },
              child: Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.network(
                      "https://ouch-cdn2.icons8.com/VGHyfDgzIiyEwg3RIll1nYupfj653vnEPRLr0AeoJ8g/rs:fit:456:456/czM6Ly9pY29uczgu/b3VjaC1wcm9kLmFz/c2V0cy9wbmcvODg2/LzRjNzU2YThjLTQx/MjgtNGZlZS04MDNl/LTAwMTM0YzEwOTMy/Ny5wbmc.png",
                      height: 30,
                      width: 30,
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      "Log in with Google",
                      style: GoogleFonts.roboto(),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
//import 'package:timezone/data/latest_all.dart' as tz;
//import 'package:timezone/timezone.dart' as tz;
import 'package:http/http.dart' as http;
import '../view/chat.dart';

class ChatController extends GetxController {
  late Map<String, dynamic> arg;
  TextEditingController msgController = TextEditingController();

  ScrollController scrollController = ScrollController();

  void jumpToEnd() {
    Future.delayed(
      Duration(milliseconds: 200),
          () {
        var maxScrollExtent = scrollController.position.maxScrollExtent;
        scrollController.jumpTo(maxScrollExtent);
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    arg = Get.arguments;
    FirebaseFirestore.instance.collection("chat_room").doc(arg["chat_room_id"]).update({
      "unread": 0,
    });
  }

  // Future<void> sendNotification(String text) async {
  //   Map<String, dynamic> payload = {
  //     "token": arg["fcmToken"],
  //     "title": "New chat Message",
  //     "msg": text,
  //   };
  //   print("sendNotification $payload");
  //
  //   http.Response res = await http.post(
  //     Uri.parse("http://192.168.200.217:3000/notificaiton"),
  //     headers: {'Content-Type': 'application/json'},
  //     body: jsonEncode(payload),
  //   );
  //   print("sendNotification $res");
  // }

  // void showAppNotification(String title, String desc) async {
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     desc,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         "Chat",
  //         "ChatApp",
  //       ),
  //     ),
  //   );
  // }
  //
  // void showScheduleAppNotification(String title, String desc) async {
  //   flutterLocalNotificationsPlugin.zonedSchedule(
  //     0,
  //     title,
  //     desc,
  //     tz.TZDateTime.now(tz.local).add(Duration(minutes: 2)),
  //     // tz.TZDateTime(tz.local, 2025,1,20,10,30),
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         "Chat",
  //         "ChatApp",
  //         icon: "@mipmap/ic_launcher",
  //       ),
  //     ),
  //     uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
  //     androidScheduleMode: AndroidScheduleMode.alarmClock,
  //   );
  // }
  //
  // void showBigPictureAppNotification(String title, String desc) async {
  //   var uint8List =
  //   await _getByteArrayFromUrl("https://cdn.prod.website-files.com/654366841809b5be271c8358/659efd7c0732620f1ac6a1d6_why_flutter_is_the_future_of_app_development%20(1).webp");
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     desc,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         "Chat",
  //         "ChatApp",
  //         styleInformation: BigPictureStyleInformation(ByteArrayAndroidBitmap(uint8List)),
  //       ),
  //     ),
  //   );
  // }
  //
  // void showMediaAppNotification(String title, String desc) async {
  //   flutterLocalNotificationsPlugin.show(
  //     0,
  //     title,
  //     desc,
  //     NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         "Chat",
  //         "ChatApp",
  //         styleInformation: MediaStyleInformation(
  //           htmlFormatContent: true,
  //           htmlFormatTitle: true,
  //         ),
  //       ),
  //     ),
  //   );
  // }

  Future<Uint8List> _getByteArrayFromUrl(String url) async {
    final http.Response response = await http.get(Uri.parse(url));
    return response.bodyBytes;
  }
}
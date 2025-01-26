import 'package:chat_app/controller/chat_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
//import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

// FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  ChatController controller = Get.put(ChatController());

  // void iniNotification() {
  //   flutterLocalNotificationsPlugin.initialize(InitializationSettings(
  //       android: AndroidInitializationSettings("@mipmap/ic_launcher")));
  //}

  @override
  void initState() {
    super.initState();
   // iniNotification();
    FirebaseMessaging.onMessage.listen((event) {
      print("FirebaseMessaging title => ${event.notification?.title}");
      print("FirebaseMessaging body  => ${event.notification?.body}");
      // controller.showAppNotification(
      //     event.notification?.title ?? "", event.notification?.body ?? "");
      // controller.showScheduleAppNotification(
      //     event.notification?.title ?? "", event.notification?.body ?? "");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${controller.arg["email"]}"),
        actions: [
          // Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: StreamBuilder<DocumentSnapshot>(
          //       stream: FirebaseFirestore.instance
          //           .collection("users")
          //           .doc(controller.arg["receiver_id"])
          //           .snapshots(),
          //       builder: (context, snapshot) {
          //         if (snapshot.hasData) {
          //           var otherUser =
          //               snapshot.data?.data() as Map<String, dynamic>;
          //           print("snapshot.data.runtimeType ${otherUser}");
          //           return Row(
          //             mainAxisSize: MainAxisSize.min,
          //             children: [
          //               Text(
          //                 (otherUser["isOnline"] == true)
          //                     ? "Online"
          //                     : "Offline",
          //                 style: GoogleFonts.roboto(),
          //               ),
          //               Icon(
          //                 Icons.circle,
          //                 size: 12,
          //                 color: (otherUser["isOnline"] == true)
          //                     ? Colors.green
          //                     : Colors.red,
          //               ),
          //             ],
          //           );
          //         } else {
          //           return SizedBox.shrink();
          //         }
          //       }),
          // ),

          IconButton(
              onPressed: () {
                // controller.showScheduleAppNotification("hello ${DateTime.now()}", "All good morning");
                // controller.showBigPictureAppNotification("hello", "Flutter Image");
                // controller.showMediaAppNotification(
                //     "Hello <b>Utsavi</b>", "Hello <b>Flutter</b>");
              },
              icon: Icon(Icons.notifications))
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("message")
                    .orderBy('time')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var msgList = snapshot.data?.docs ?? [];
                    controller.jumpToEnd();
                    return ListView.builder(
                      itemCount: msgList.length,
                      controller: controller.scrollController,
                      itemBuilder: (context, index) {
                        var msg = msgList[index];
                        Map<String, dynamic> data =
                            msg.data() as Map<String, dynamic>;

                        bool isSender = data["sender"] ==
                            FirebaseAuth.instance.currentUser?.uid;
                        if (data["chat_room_id"] !=
                            controller.arg["chat_room_id"]) {
                          return SizedBox.shrink();
                        }
                        return Align(
                          alignment: isSender
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(color: Colors.black54),
                            constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.sizeOf(context).width / 1.2),
                            margin: EdgeInsets.only(
                                top: 10, right: 10, bottom: 10, left: 10),
                            padding: EdgeInsets.only(
                                top: 10, right: 10, bottom: 10, left: 10),
                            child: Text(
                              "${data["msg"]}",
                              style: GoogleFonts.roboto(),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller.msgController,
                  decoration: InputDecoration(
                      hintText: "Message",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20))),
                ),
              ),
              IconButton(
                  onPressed: () async {
                    if (controller.msgController.text.trim().isNotEmpty) {
                      await FirebaseFirestore.instance
                          .collection("message")
                          .add({
                        "msg": controller.msgController.text,
                        "time": DateTime.now(),
                        "chat_room_id": controller.arg["chat_room_id"],
                        "sender": FirebaseAuth.instance.currentUser?.uid,
                        "receiver": controller.arg["receiver_id"]
                      });
                      await FirebaseFirestore.instance
                          .collection("chat_room")
                          .doc(controller.arg["chat_room_id"])
                          .update({
                        "last_msg": controller.msgController.text,
                        "unread": FieldValue.increment(1),
                      });
                      //controller.sendNotification(controller.msgController.text);
                      controller.msgController.clear();
                    }
                  },
                  icon: Icon(Icons.send))
            ],
          ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("${controller.arg["email"]}"),
    //     actions: [
    //       Padding(
    //         padding: const EdgeInsets.all(12.0),
    //         child: StreamBuilder<DocumentSnapshot>(
    //             stream: FirebaseFirestore.instance
    //                 .collection("users")
    //                 .doc(controller.arg["receiver_id"])
    //                 .snapshots(),
    //             builder: (context, snapshot) {
    //               if (snapshot.hasData) {
    //                 var otherUser =
    //                     snapshot.data?.data() as Map<String, dynamic>;
    //                 print("snapshot.data.runtimeType ${otherUser}");
    //                 return Row(
    //                   mainAxisSize: MainAxisSize.min,
    //                   children: [
    //                     Text((otherUser["isOnline"]==true) ? "Online" : "Offline"),
    //                     Icon(
    //                       Icons.circle,
    //                       size: 12,
    //                       color:
    //                           (otherUser["isOnline"]==true) ? Colors.green : Colors.red,
    //                     ),
    //                   ],
    //                 );
    //               } else {
    //                 return SizedBox.shrink();
    //               }
    //             }),
    //       ),
    //       IconButton(
    //           onPressed: () {}, icon: Icon(Icons.video_camera_back_outlined)),
    //       IconButton(onPressed: () {}, icon: Icon(Icons.phone)),
    //     ],
    //   ),
    //   body: Column(
    //     children: [
    //       Expanded(
    //         child: StreamBuilder<QuerySnapshot>(
    //           stream: FirebaseFirestore.instance
    //               .collection("message")
    //               .orderBy("time")
    //               .snapshots(),
    //           builder: (context, snapshot) {
    //             if (snapshot.hasData) {
    //               var msgList = snapshot.data?.docs ?? [];
    //               controller.jumpToEnd();
    //               return ListView.builder(
    //                 controller: controller.scrollController,
    //                 itemBuilder: (context, index) {
    //                   var msg = msgList[index];
    //                   Map<String, dynamic> data =
    //                       msg.data() as Map<String, dynamic>;
    //                   bool isSending = data['sender'] ==
    //                       FirebaseAuth.instance.currentUser?.uid;
    //                   if (data['chat_room_id'] !=
    //                       controller.arg['chat_room_id']){
    //                     return SizedBox.shrink();
    //                   }
    //                   return Align(
    //                     alignment: isSending
    //                         ? Alignment.centerRight
    //                         : Alignment.centerLeft,
    //                     child: Container(
    //                       margin: EdgeInsets.only(
    //                           top: 10, right: 10, bottom: 10, left: 10),
    //                       padding: EdgeInsets.only(
    //                           top: 10, right: 10, bottom: 10, left: 10),
    //                       constraints: BoxConstraints(
    //                           maxWidth:
    //                               MediaQuery.of(context).size.width / 1.2),
    //                       decoration: BoxDecoration(
    //                           color: Colors.black54,
    //                           borderRadius: BorderRadius.circular(8)),
    //                       child: Text(
    //                         "${data['msg']}",
    //                         style: GoogleFonts.roboto(),
    //                       ),
    //                     ),
    //                   );
    //                 },
    //                 itemCount: msgList.length,
    //               );
    //             } else {
    //               return Center(
    //                 child: CircularProgressIndicator(),
    //               );
    //             }
    //           },
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Row(
    //           children: [
    //             Expanded(
    //                 child: TextFormField(
    //               controller: controller.msgController,
    //               decoration: InputDecoration(
    //                 hintText: "Message",
    //                 border: OutlineInputBorder(
    //                     borderRadius: BorderRadius.circular(30)),
    //               ),
    //             )),
    //             IconButton(
    //                 onPressed: () async {
    //                   if (controller.msgController.text.trim().isNotEmpty) {
    //                     await FirebaseFirestore.instance
    //                         .collection("message")
    //                         .add({
    //                       "msg": controller.msgController.text,
    //                       "time": DateTime.now(),
    //                       "chat_room_id": controller.arg["chat_room_id"],
    //                       "sender": FirebaseAuth.instance.currentUser?.uid,
    //                       "receiver": controller.arg["receiver_id"],
    //                     });
    //                     await FirebaseFirestore.instance.collection("chat_room").doc(controller.arg["chat_room_id"]).update({
    //                       "last_msg": controller.msgController.text,
    //                       "unread": FieldValue.increment(1),
    //                     });
    //                     controller.msgController.clear();
    //                   }
    //                   // controller.showScheduleAppNotification("hello ${DateTime.now()}", "All good morning");
    //                   // controller.showBigPictureAppNotification("hello", "Flutter Image");
    //                   // controller.showMediaAppNotification(
    //                   //     "Hello <b>Utsavi</b>", "Hello <b>Good Morning</b>");
    //                 },
    //                 icon: Icon(Icons.send))
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }
}

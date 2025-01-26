import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controller/usercontroller.dart';

class Users extends StatefulWidget {
  const Users({super.key});

  @override
  State<Users> createState() => _UsersState();
}

class _UsersState extends State<Users> {
  final UserController usersController = Get.put(UserController());

  @override
  void initState() {
    super.initState();
    usersController.fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: StreamBuilder<QuerySnapshot>(
          stream:
              FirebaseFirestore.instance.collection("users").get().asStream(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List users = snapshot.data?.docs ?? [];
              print("User $users");
              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  var user = users[index];
                  return ListTile(
                    title: Text(
                      "${user["email"]}",
                      style: GoogleFonts.roboto(),
                    ),
                    onTap: () async {
                      var chatRoom = await FirebaseFirestore.instance
                          .collection("chat_room")
                          .where("user_a",
                              isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                          .where("user_b", isEqualTo: user["id"]);

                      QuerySnapshot<Map<String, dynamic>> data =
                          await chatRoom.get();
                      String chatRoomId = "";
                      if (data.docs.isEmpty) {
                        DocumentReference dataAdded = await FirebaseFirestore
                            .instance
                            .collection("chat_room")
                            .add({
                          "user_a": FirebaseAuth.instance.currentUser?.uid,
                          "user_b": user["id"],
                          "user_a_email":
                              FirebaseAuth.instance.currentUser?.email ?? "",
                          "user_b_email": user["email"],
                          "users": [
                            FirebaseAuth.instance.currentUser?.uid,
                            user["id"]
                          ],
                          "last_msg": "",
                        });
                        var chatRef = await dataAdded.get();
                        chatRoomId = chatRef.id;
                      } else {
                        chatRoomId = data.docs.first.id;
                      }

                      Get.toNamed("/chat", arguments: {
                        "email": "${user["email"]}",
                        "chat_room_id": chatRoomId,
                        "receiver_id": user["id"],
                        "fcmToken": user["fcmToken"],
                      });
                    },
                  );
                },
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(
    //       "Select Contact",
    //       style: GoogleFonts.roboto(),
    //     ),
    //     bottom: PreferredSize(
    //       preferredSize: Size.fromHeight(70),
    //       child: Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: TextFormField(
    //           decoration: InputDecoration(
    //             prefixIcon: Icon(Icons.search),
    //             hintText: "Search by email",
    //             border: OutlineInputBorder(
    //               borderRadius: BorderRadius.circular(30),
    //             ),
    //           ),
    //           onChanged: (value) {
    //             usersController.searchEmail(value);
    //           },
    //         ),
    //       ),
    //     ),
    //   ),
    //   body: Obx(() {
    //     if (usersController.isLoading.value) {
    //       return Center(child: CircularProgressIndicator());
    //     }
    //
    //     if (usersController.filteredUsers.isEmpty) {
    //       return Center(child: Text("No users found"));
    //     }
    //
    //     return ListView.builder(
    //       itemBuilder: (context, index) {
    //         var user = usersController.filteredUsers[index];
    //         return ListTile(
    //           title: Text("${user["email"]}"),
    //           subtitle: Text("${user["id"]}"),
    //           leading: CircleAvatar(
    //             child: Image.network(
    //               "https://www.creativefabrica.com/wp-content/uploads/2023/04/13/Cute-And-Adorable-Baby-Cheetah-Cartoon-Character-67072763-1.png",
    //             ),
    //           ),
    //           onTap: () async {
    //             var chatRoom = await FirebaseFirestore.instance
    //                 .collection("chat")
    //                 .where("user_a",
    //                     isEqualTo: FirebaseAuth.instance.currentUser?.uid)
    //                 .where("user_b", isEqualTo: user['id']);
    //
    //             QuerySnapshot<Map<String, dynamic>> data = await chatRoom.get();
    //
    //             String chatRoomId = "";
    //
    //             if (data.docs.isEmpty) {
    //               DocumentReference dataAdded =
    //                   await FirebaseFirestore.instance.collection("chat").add({
    //                 "user_a": FirebaseAuth.instance.currentUser?.uid,
    //                 "user_b": user['id'],
    //                 "users": [
    //                   FirebaseAuth.instance.currentUser?.uid,
    //                   user['id']
    //                 ],
    //                 "last_msg": "",
    //               });
    //               var chatRef = await dataAdded.get();
    //               chatRoomId = chatRef.id;
    //             } else {
    //               chatRoomId = data.docs.first.id;
    //             }
    //             Get.toNamed("/chat", arguments: {
    //               "email": "${user["email"]}",
    //               "chat_room_id": chatRoomId,
    //               "receiver_id": user["id"],
    //             });
    //           },
    //         );
    //       },
    //       itemCount: usersController.filteredUsers.length,
    //     );
    //   }),
    // );
  }
}

import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/controller/homeController.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:status_view/status_view.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  HomeController homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Obx(() {
          return BottomNavigationBar(
              currentIndex: homeController.menuIndex.value,
              onTap: (index) {
                homeController.setMenuIndex(index);
              },
              selectedLabelStyle: GoogleFonts.roboto(),
              type: BottomNavigationBarType.fixed,
              items: [
                BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Chat"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.update), label: "Update"),
                BottomNavigationBarItem(
                    icon: Icon(Icons.person), label: "Communites"),
                BottomNavigationBarItem(icon: Icon(Icons.call), label: "Calls"),
              ]);
        }),
        body: PageView(
          controller: homeController.pageController,
          onPageChanged: (val) {
            homeController.menuIndex.value = val;
          },
          children: [
            Chats(),
            Update(),
            Communites(),
            Calls(),
          ],
        ));
  }
}

class Chats extends StatefulWidget {
  const Chats({super.key});

  @override
  State<Chats> createState() => _ChatsState();
}

class _ChatsState extends State<Chats> {
  final TextEditingController searchController = TextEditingController();

  // final List<Map<String, String>> chatData = [
  //   {"name": "Alice", "lastMsg": "Hey!", "time": "10:00 AM"},
  //   {"name": "Bob", "lastMsg": "See you soon.", "time": "9:30 AM"},
  //   {"name": "Charlie", "lastMsg": "Let's meet.", "time": "Yesterday"},
  //   {"name": "Diana", "lastMsg": "Okay.", "time": "2 days ago"},
  //   {"name": "Eve", "lastMsg": "Got it.", "time": "3 days ago"},
  // ];

  List<Map<String, String>> filteredChatData = [];

  // @override
  // void initState() {
  //   super.initState();
  //   filteredChatData = chatData;
  //   searchController.addListener(() {
  //     filterChats();
  //   });
  // }

  // void filterChats() {
  //   final query = searchController.text.toLowerCase();
  //   setState(() {
  //     filteredChatData = chatData
  //         .where((chat) =>
  //             chat["name"]!.toLowerCase().contains(query) ||
  //             chat["lastMsg"]!.toLowerCase().contains(query))
  //         .toList();
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "WhatsApp",
          style: GoogleFonts.roboto(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  Get.changeThemeMode(
                      Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
                },
                icon: Icon(Get.isDarkMode ? Icons.dark_mode : Icons.light),
              ),
              IconButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushReplacementNamed(context, "/");
                },
                icon: Icon(Icons.logout),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search by name or message",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection("chat_room")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<QueryDocumentSnapshot<Map<String, dynamic>>> chatRooms =
                      snapshot.data?.docs ?? [];
                  return ListView.builder(
                    itemCount: chatRooms.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> room = chatRooms[index].data();
                      var chatRoomId = chatRooms[index].id;
                      return ListTile(
                        onTap: () {
                          Get.toNamed("chat", arguments: {
                            "email": "${room["email"]}",
                            "chat_room_id": chatRoomId,
                            "receiver_id": room["id"],
                            "fcmToken": room["fcmToken"],
                          });
                        },
                        title: Text(
                          "${room["user_b_email"]}",
                          style: GoogleFonts.roboto(),
                        ),
                        subtitle: Text("${room["last_msg"]}",
                            style: GoogleFonts.roboto()),
                        trailing: ((int.tryParse("${room["unread"]}") ?? 0) > 0)
                            ? CircleAvatar(
                                child: Text("${room["unread"]}",
                                    style: GoogleFonts.roboto()),
                              )
                            : null,
                      );
                    },
                  );
                } else {
                  return CircularProgressIndicator();
                }
              }),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15, bottom: 15),
              child: FloatingActionButton(
                backgroundColor: Colors.green.shade400,
                onPressed: () {
                  Get.toNamed("/users");
                },
                child: Icon(
                  Icons.add_comment_rounded,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Update extends StatefulWidget {
  const Update({super.key});

  @override
  State<Update> createState() => _UpdateState();
}

class _UpdateState extends State<Update> {

  final ImagePicker _picker = ImagePicker();
  final List<Map<String, dynamic>> statuses = [
    {
      "name": "Alice",
      "centerImageUrl": "https://picsum.photos/id/1/200/300",
      "updates": [
        {"type": "text", "content": "Hello from Alice!"},
        {"type": "image", "content": "https://picsum.photos/id/2/400/300"},
      ],
    },
    {
      "name": "Bob",
      "centerImageUrl": "https://picsum.photos/id/3/200/300",
      "updates": [
        {"type": "text", "content": "Enjoying the weekend!"},
        {"type": "image", "content": "https://picsum.photos/id/4/400/300"},
      ],
    },
  ];

  Future<void> pickImages() async {
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      final List<Map<String, String>> newUpdates = [];

      for (var pickedFile in pickedFiles) {
        newUpdates.add({"type": "image", "content": pickedFile.path});
      }

      setState(() {
        statuses.insert(0, {
          "name": "You",
          "centerImageUrl": newUpdates.first["content"]!,
          "updates": newUpdates,
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Updates", style: GoogleFonts.roboto()),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.document_scanner_outlined)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.camera_alt_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.search)),
              PopupMenuButton(onSelected: (value) {
                if (value == "Settings") {
                  Get.toNamed("settings");
                }
              }, itemBuilder: (context) {
                return [
                  PopupMenuItem(value: "Settings", child: Text("Settings")),
                ];
              })
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 14.0, right: 14.0),
                child: Text("Status", style: GoogleFonts.roboto()),
              ),
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: pickImages,
                      child: CircleAvatar(
                        radius: 30,
                        backgroundImage:
                        statuses.isNotEmpty
                            ? FileImage(File(statuses.first["centerImageUrl"]))
                            : const NetworkImage('https://picsum.photos/200')
                                as ImageProvider,
                        backgroundColor: Colors.grey[200],
                      ),
                    ),
                    SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("My Status", style: GoogleFonts.roboto()),
                        Text("Tap to add status update",
                            style: GoogleFonts.roboto()),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(left: 14.0),
                child: Text("Recent updates", style: GoogleFonts.roboto()),
              ),
              SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) {
                    return SizedBox(height: 25);
                  },
                  itemCount: statuses.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: StatusView(
                        radius: 30,
                        spacing: 10,
                        strokeWidth: 3,
                        indexOfSeenStatus: 1,
                        numberOfStatus: statuses[index]['updates'].length,
                        padding: 4,
                        centerImageUrl: statuses[index]['centerImageUrl'],
                        seenColor: Colors.grey,
                        unSeenColor: Colors.green,
                      ),
                      title: Text(statuses[index]['name']),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatusDetailView(
                              name: statuses[index]['name'],
                              updates: statuses[index]['updates'],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15, bottom: 15),
              child: FloatingActionButton(
                backgroundColor: Colors.green.shade400,
                onPressed: () {
                  
                },
                child: Icon(
                  Icons.photo_camera,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text("Status",style: GoogleFonts.roboto(),),
    //   ),
    //   body: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       Padding(
    //         padding: const EdgeInsets.all(14.0),
    //         child: Row(
    //            children: [
    //              GestureDetector(
    //                onTap: () {
    //                  _pickImage();
    //                },
    //                child: CircleAvatar(
    //                  radius: 30,
    //                  backgroundImage: _imageFile != null
    //                      ? FileImage(_imageFile!)
    //                      : const NetworkImage(
    //                      'https://picsum.photos/200') as ImageProvider,
    //                  backgroundColor: Colors.grey[200],
    //                ),
    //              ),
    //              SizedBox(width: 15,),
    //              Column(
    //                crossAxisAlignment: CrossAxisAlignment.start,
    //                children: [
    //                  Text("My Status",style: GoogleFonts.roboto(),),
    //                  Text("Tap to add status update",style: GoogleFonts.roboto(),),
    //                ],
    //              )
    //            ],
    //         ),
    //       ),
    //       SizedBox(height: 10,),
    //       Padding(
    //         padding: const EdgeInsets.only(left: 14.0),
    //         child: Text("Recent updates",style: GoogleFonts.roboto(),),
    //       ),
    //       SizedBox(height: 20,),
    //       Expanded(
    //         child: ListView.separated(
    //           separatorBuilder: (context,index){
    //             return SizedBox(height: 25,);
    //           },
    //           itemCount: statuses.length,
    //           itemBuilder: (context, index) {
    //             return ListTile(
    //               leading: StatusView(
    //                 radius: 30,
    //                 spacing: 10,
    //                 strokeWidth: 3,
    //                 indexOfSeenStatus: 1,
    //                 numberOfStatus: statuses[index]['updates'].length,
    //                 padding: 4,
    //                 centerImageUrl: statuses[index]['centerImageUrl'],
    //                 seenColor: Colors.grey,
    //                 unSeenColor: Colors.green,
    //               ),
    //               title: Text(statuses[index]['name']),
    //               onTap: () {
    //                 Navigator.push(
    //                   context,
    //                   MaterialPageRoute(
    //                     builder: (context) => StatusDetailView(
    //                       name: statuses[index]['name'],
    //                       updates: statuses[index]['updates'],
    //                     ),
    //                   ),
    //                 );
    //               },
    //             );
    //           },
    //         ),
    //       ),
    //     ],
    //   ),
    // );
  }
}

class StatusDetailView extends StatefulWidget {
  final String name;
  final List<Map<String, String>> updates;

  const StatusDetailView({
    super.key,
    required this.name,
    required this.updates,
  });

  @override
  State<StatusDetailView> createState() => _StatusDetailViewState();
}

class _StatusDetailViewState extends State<StatusDetailView> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              itemCount: widget.updates.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final update = widget.updates[index];
                if (update["type"] == "text") {
                  return Center(
                    child: Text(
                      update["content"]!,
                      style: TextStyle(color: Colors.white, fontSize: 24),
                      textAlign: TextAlign.center,
                    ),
                  );
                } else if (update["type"] == "image") {
                  return Center(
                    child: Image.network(
                      update["content"]!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  );
                }
                return SizedBox();
              },
            ),
            Positioned(
              top: 40,
              left: 20,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  Text(
                    widget.name,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: Row(
                children: List.generate(
                  widget.updates.length,
                  (index) => Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      height: 5,
                      color: index <= _currentIndex
                          ? Colors.green
                          : Colors.grey.shade800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Communites extends StatefulWidget {
  const Communites({super.key});

  @override
  State<Communites> createState() => _CommunitesState();
}

class _CommunitesState extends State<Communites> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Communities", style: GoogleFonts.roboto()),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.document_scanner_outlined)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.camera_alt_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade500),
                  child: Icon(
                    Icons.person,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "New Community",
                  style: GoogleFonts.roboto(),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              thickness: 8,
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade500),
                  child: Icon(
                    Icons.ac_unit,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Aditya Jewellers",
                  style: GoogleFonts.roboto(),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade500),
                  child: Icon(
                    Icons.announcement,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Announcements",
                      style: GoogleFonts.roboto(),
                    ),
                    Text(
                      "~ Aditya Jewellers:",
                      style: GoogleFonts.roboto(),
                    ),
                  ],
                ),
                SizedBox(
                  width: 110,
                ),
                Text("10:46")
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              thickness: 8,
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade500),
                  child: Icon(
                    Icons.color_lens,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Text(
                  "Painted lady",
                  style: GoogleFonts.roboto(),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            SizedBox(
              height: 10,
            ),
            Row(
              children: [
                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade500),
                  child: Icon(
                    Icons.announcement,
                    size: 30,
                  ),
                ),
                SizedBox(
                  width: 15,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Announcements",
                      style: GoogleFonts.roboto(),
                    ),
                    Text(
                      "Uru: Starting from 550/-",
                      style: GoogleFonts.roboto(),
                    ),
                  ],
                ),
                SizedBox(
                  width: 70,
                ),
                Text("6/5/24"),
                SizedBox(
                  height: 15,
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Divider(
              thickness: 8,
            ),
          ],
        ),
      ),
    );
  }
}

class Calls extends StatefulWidget {
  const Calls({super.key});

  @override
  State<Calls> createState() => _CallsState();
}

class _CallsState extends State<Calls> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calls", style: GoogleFonts.roboto()),
        actions: [
          Row(
            children: [
              IconButton(
                  onPressed: () {},
                  icon: Icon(Icons.document_scanner_outlined)),
              IconButton(
                  onPressed: () {}, icon: Icon(Icons.camera_alt_outlined)),
              IconButton(onPressed: () {}, icon: Icon(Icons.search)),
              IconButton(onPressed: () {}, icon: Icon(Icons.menu)),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Favorites",
                  style: GoogleFonts.roboto(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      height: 45,
                      width: 45,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.green.shade400),
                      child: Icon(
                        Icons.favorite,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Text(
                      "Add favorite",
                      style: GoogleFonts.roboto(),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Recent",
                  style: GoogleFonts.roboto(),
                ),
              ),
              Expanded(
                  child: ListView.builder(
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(
                            "Name",
                            style: GoogleFonts.roboto(),
                          ),
                          subtitle: Text(
                            "Date & Time",
                            style: GoogleFonts.roboto(),
                          ),
                          leading: CircleAvatar(),
                          trailing: IconButton(
                              onPressed: () {},
                              icon: Icon(Icons.video_camera_back_outlined)),
                        );
                      }))
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 15.0, bottom: 15.0),
              child: FloatingActionButton(
                backgroundColor: Colors.green.shade400,
                onPressed: () {},
                child: Icon(
                  Icons.phone,
                  color: Colors.black,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

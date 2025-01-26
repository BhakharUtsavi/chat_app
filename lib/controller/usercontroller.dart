import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var users = <Map<String, dynamic>>[].obs;
  var filteredUsers = <Map<String, dynamic>>[].obs;
  var isLoading = false.obs;

  Future<void> fetchUsers() async {
    isLoading.value = true;
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection("users").get();
      users.value = snapshot.docs
          .map((doc) => {"id": doc["id"], "email": doc["email"]})
          .toList();
      filteredUsers.value = users;
    } catch (e) {
      print("Error fetching users: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void searchEmail(String query) {
    if (query.isEmpty) {
      filteredUsers.value = users;
    } else {
      filteredUsers.value = users
          .where((user) => user['email']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
  }
}

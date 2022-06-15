import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  var userMap = <String, dynamic>{}.obs;
  Future getUsername(String? username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get()
        .then(
      (value) {
        userMap.value = value.docs[0].data();
      },
    );
  }
}

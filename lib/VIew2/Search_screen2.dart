import 'package:chat_app/controller/serachController.dart';
import 'package:chat_app/service/const.dart';
import 'package:chat_app/view/ChatRoom.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ss extends SearchDelegate {
  final List userList;

  ss(this.userList);
  // Map<String, dynamic>? userMap;
  SearchController searchController = Get.put(SearchController());

  String chatRoomId(String? user1, String? user2) {
    if (user1![0].toLowerCase().codeUnits[0] >
        user2!.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  // Future getUsername(String? username) async {
  //   return await FirebaseFirestore.instance
  //       .collection("users")
  //       .where("username", isEqualTo: username)
  //       .get()
  //       .then(
  //     (value) {
  //       userMap = value.docs[0].data();
  //     },
  //   );
  // }

  @override
  List<Widget>? buildActions(BuildContext context) {
    [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.close))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
        onPressed: () {
          close(context, "");
        },
        icon: Icon(Icons.arrow_back_ios));
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container();
    // var result = chatRoomId(
    //     kFirebaseAuth.currentUser!.displayName, userMap!['username']);
    // return ChatRoom(
    //   userMap: userMap,
    //   chatRoomId: result,
    // );
  }

  // SearchController searchController = Get.put(SearchController());
  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestion = query.isEmpty
        ? userList
        : userList
            .where((element) =>
                element['username'].toString().toLowerCase().startsWith(query))
            .toList();
    return ListView.builder(
      itemCount: suggestion.length,
      itemBuilder: (BuildContext context, int index) {
        return ListTile(
          onTap: () {
            print(
                "==============>>>>>>>>>>>>>>>>>>${searchController.userMap.values}");
            query = suggestion[index]['username'];

            searchController.getUsername(suggestion[index]['username']);
            var result = chatRoomId(kFirebaseAuth.currentUser!.displayName,
                searchController.userMap['username']);
            // showResults(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatRoom(
                    chatRoomId: result, userMap: searchController.userMap),
              ),
            );
          },
          title: Text(
            "${suggestion[index]['username']}",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        );
      },
    );
  }
}

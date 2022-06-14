import 'package:chat_app/main.dart';
import 'package:chat_app/view/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../service/const.dart';

class SearchScreen3 extends SearchDelegate {
  final List userList;
  // final Map<String, dynamic> userMap;

  SearchScreen3(this.userList);
  Map<String, dynamic>? userMap;

  String chatRoomId(String? user1, String? user2) {
    if (user1![0].toLowerCase().codeUnits[0] >
        user2!.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future getUsername() async {
    return await FirebaseFirestore.instance.collection("users").get().then(
      (value) {
        userMap = value.docs[0].data();
      },
    );
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData(appBarTheme: AppBarTheme(backgroundColor: comColor));
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: Icon(Icons.close))
    ];
    return null;
  }

  @override
  Widget? buildLeading(BuildContext context) {
    IconButton(
        onPressed: () {
          close(context, "");
        },
        icon: Icon(Icons.arrow_back_ios));
    return null;
  }

  @override
  Widget buildResults(BuildContext context) {
    var roomId = chatRoomId(
        kFirebaseAuth.currentUser?.displayName, userMap!['username']);
    return ChatRoom(
      chatRoomId: roomId,
      userMap: userMap,
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestion = query.isEmpty
        ? userList
        : userList
            .where((element) =>
                element['username'].toString().toLowerCase().startsWith(query))
            .toList();
    return Container(
      color: Colors.black,
      child: ListView.builder(
        itemCount: suggestion.length,
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            onTap: () {
              showResults(context);
              query = suggestion[index]['username'];
            },
            title: Text(
              "${suggestion[index]['username']}",
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          );
        },
      ),
    );
  }
}

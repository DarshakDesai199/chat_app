import 'package:chat_app/service/const.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'Search_screen2.dart';

class Search extends StatefulWidget {
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List? usersData;
  Map<String, dynamic>? userMap;

  Future getUserData() async {
    await FirebaseFirestore.instance.collection("users").get().then((value) {
      setState(() {
        usersData = value.docs;
        // userMap = value.docs[0].data();
      });
    });
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            print("${kFirebaseAuth.currentUser!.displayName}");
            print("userData ==> ${usersData.toString()}");
            setState(() {
              showSearch(context: context, delegate: ss(usersData!));
            });
          },
          child: Icon(Icons.search),
        ),
      ),
    );
  }
}

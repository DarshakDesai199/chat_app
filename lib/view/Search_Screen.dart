import 'package:chat_app/service/const.dart';
import 'package:chat_app/view/ChatRoom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import '../service/internet_controller.dart';

class Search_Screen extends StatefulWidget {
  const Search_Screen({Key? key}) : super(key: key);

  @override
  State<Search_Screen> createState() => _Search_ScreenState();
}

class _Search_ScreenState extends State<Search_Screen> {
  final search = TextEditingController();
  ConnectivityProvider connectivityProvider = Get.put(ConnectivityProvider());

  Map<String, dynamic>? userMap;

  Future getUsername(String? username) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .where("username", isEqualTo: username)
        .get()
        .then(
      (value) {
        setState(
          () {
            userMap = value.docs[0].data();
          },
        );
      },
    );
  }

  String chatRoomId(String? user1, String? user2) {
    if (user1![0].toLowerCase().codeUnits[0] >
        user2!.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  @override
  void initState() {
    connectivityProvider.startMonitoring();
    super.initState();
  }

  ///  search username
  Widget searchList() {
    return userMap != null
        ? ListTile(
            onTap: () {
              var roomId = chatRoomId(
                  kFirebaseAuth.currentUser?.displayName, userMap!['username']);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatRoom(chatRoomId: roomId, userMap: userMap),
                ),
              );
            },
            title: Text(
              "${userMap!['username']}",
              style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            leading: Icon(Icons.person, color: Color(0xffA5D6A7), size: 4.h),
            subtitle: Text(
              "${userMap!['email']}",
              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
            ),
            trailing: Container(
              alignment: Alignment.center,
              height: 5.5.h,
              width: 20.w,
              decoration: BoxDecoration(
                color: Color(0xff004D40),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Text(
                "Message",
                style: TextStyle(color: Colors.white),
              ),
            ),
          )
        : Center(
            child: Container(),
          );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          title: Text(
            'QuickChat',
            style: GoogleFonts.satisfy(
              textStyle: TextStyle(
                  fontSize: 24.sp, color: Colors.white, letterSpacing: .5),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back_ios),
          )),
      body: GetBuilder<ConnectivityProvider>(
        builder: (controller) {
          return controller.isOnline
              ? SafeArea(
                  child: SingleChildScrollView(
                    child: Column(children: [
                      SizedBox(
                        height: 1.h,
                      ),
                      Container(
                        height: 7.h,
                        width: 100.w,
                        color: Color(0xff004D40).withOpacity(0.4),
                        child: Row(children: [
                          Expanded(
                              child: TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: search,
                            decoration: const InputDecoration(
                              contentPadding:
                                  EdgeInsets.symmetric(horizontal: 20),
                              hintText: "Search username ...",
                              hintStyle: TextStyle(color: Colors.white),
                              errorBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.red),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff004D40),
                                ),
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xff004D40),
                                ),
                              ),
                              border: UnderlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                          )),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Container(
                              alignment: Alignment.center,
                              height: 6.h,
                              width: 6.h,
                              decoration: BoxDecoration(
                                  color: Color(0xff004D40),
                                  shape: BoxShape.circle),
                              child: IconButton(
                                onPressed: () {
                                  print("${userMap!.values}");
                                  getUsername(search.text);
                                },
                                icon: Icon(Icons.search,
                                    color: Colors.white, size: 25),
                              ),
                            ),
                          )
                        ]),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      Divider(color: Colors.white, thickness: 1.5),
                      SizedBox(
                        height: 2.5.h,
                      ),
                      searchList()
                    ]),
                  ),
                )
              : Center(
                  child: Text(
                    "No Internet",
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                );
        },
      ),
    );
  }
}

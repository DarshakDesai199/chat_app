import 'package:chat_app/main.dart';
import 'package:chat_app/service/LocalNotificationServices.dart';
import 'package:chat_app/service/const.dart';
import 'package:chat_app/service/google_service.dart';
import 'package:chat_app/view/Search_Screen.dart';
import 'package:chat_app/view/settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../service/Firebase_service.dart';
import 'ChatRoom.dart';
import 'SignUp.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isSwitch = false;
  List? usersData;
  Map<String, dynamic>? userMap;
  String? img;

  Future getUsername() async {
    await FirebaseFirestore.instance.collection("users").get().then((value) {
      setState(() {
        usersData = value.docs;
        userMap = value.docs[0].data();
      });
    });
  }

  String chatRoomId(String? user1, String? user2) {
    if (user1![0].toLowerCase().codeUnits[0] >
        user2!.toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  Future getUserdata(int index) async {
    return await FirebaseFirestore.instance.collection("users").get().then(
      (value) {
        setState(
          () {
            userMap = value.docs[index].data();
          },
        );
      },
    );
  }

  void getUserImg() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .doc('${FirebaseAuth.instance.currentUser!.uid}')
        .get();
    Map<String, dynamic>? getUserData = user.data() as Map<String, dynamic>?;
    setState(() {
      img = getUserData!['userImage'];
    });
  }

  String deviceTokenToSendPushNotification = "";
  @override
  void initState() {
    // 1. This method call when app in terminated state and you get a notification
    // when you click on notification app open from terminated state and you can get notification data in this method

    FirebaseMessaging.instance.getInitialMessage().then(
      (message) {
        print("FirebaseMessaging.instance.getInitialMessage");
        if (message != null) {
          print("New Notification");
          if (message.data['_id'] != null) {
            // Navigator.of(context).push(
            //   MaterialPageRoute(
            //     builder: (context) => DemoScreen(
            //       id: message.data['_id'],
            //     ),
            //   ),
            // );
          }
        }
      },
    );

    // 2. This method only call when App in forground it mean app must be opened
    FirebaseMessaging.onMessage.listen(
      (message) {
        print("FirebaseMessaging.onMessage.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data11 ${message.data}");
          LocalNotificationService.createanddisplaynotification(message);
        }
      },
    );

    // 3. This method only call when App in background and not terminated(not closed)
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        print("FirebaseMessaging.onMessageOpenedApp.listen");
        if (message.notification != null) {
          print(message.notification!.title);
          print(message.notification!.body);
          print("message.data22 ${message.data['_id']}");
        }
      },
    );

    getUserImg();
    getUsername();
    super.initState();
  }

  Future<void> getDeviceTokenToSendNotification() async {
    final FirebaseMessaging _fcm = FirebaseMessaging.instance;
    final token = await _fcm.getToken();
    deviceTokenToSendPushNotification = token.toString();
    print("Token Value $deviceTokenToSendPushNotification");
  }

  @override
  Widget build(BuildContext context) {
    getDeviceTokenToSendNotification();
    // print("Image === > $img");
    return Scaffold(
      body: Column(
        children: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection("users").snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                return Expanded(
                  child: ListView.builder(
                    itemCount: snapshot.data?.docs.length,
                    itemBuilder: (context, index) {
                      var data = snapshot.data?.docs[index];
                      if (kFirebaseAuth.currentUser?.email == data!['email']) {
                        return SizedBox();
                      } else {
                        return ListTile(
                          onTap: () {
                            var roomId = chatRoomId(
                                kFirebaseAuth.currentUser?.displayName,
                                data['username']);
                            getUserdata(index);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoom(
                                    chatRoomId: roomId, userMap: userMap),
                              ),
                            );
                          },
                          title: Text(
                            "${data['username']}",
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                          leading: Icon(Icons.person,
                              color: Color(0xffA5D6A7), size: 4.h),
                          subtitle: Text(
                            "${data['email']}",
                            style:
                                TextStyle(fontSize: 10.sp, color: Colors.grey),
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
                        );
                      }
                    },
                  ),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          )
        ],
      ),
      appBar: AppBar(
        title: Text(
          'QuickChat',
          style: GoogleFonts.satisfy(
            textStyle: TextStyle(
                fontSize: 24.sp, color: Colors.white, letterSpacing: .5),
          ),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Setting(),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Icon(Icons.settings, color: comColor),
                      SizedBox(
                        width: 2.w,
                      ),
                      Text(
                        "settings",
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
              )
            ],
          )
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color(0xff004D40),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 7.h,
              ),
              Container(
                height: 14.h,
                width: 14.h,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: Image.network(
                      img ??
                          "https://image.shutterstock.com/image-photo/head-shot-portrait-close-smiling-260nw-1714666150.jpg",
                      fit: BoxFit.cover,
                    )),
              ),
              SizedBox(
                height: 2.h,
              ),
              Text(
                kFirebaseAuth.currentUser?.displayName == null
                    ? name.toString()
                    : kFirebaseAuth.currentUser!.displayName.toString(),
                style: TextStyle(fontSize: 16.sp, color: Colors.white),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
                kFirebaseAuth.currentUser?.email == null
                    ? email.toString()
                    : kFirebaseAuth.currentUser!.email.toString(),
                style: TextStyle(fontSize: 10.sp, color: Colors.white),
              ),
              SizedBox(
                height: 3.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
                  ),
                  IconButton(
                    onPressed: () async {
                      SharedPreferences _prefs =
                          await SharedPreferences.getInstance();
                      _prefs.remove("email");
                      await FirebaseAuthService.logOut()
                          .whenComplete(
                            () => ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("LogOut with Google"),
                              ),
                            ),
                          )
                          .then(
                            (value) => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUp(),
                              ),
                            ),
                          );
                    },
                    icon: Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 3.h,
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.black,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SizedBox(
          height: 8.h,
          width: 8.h,
          child: FloatingActionButton(
            backgroundColor: comColor,
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Search_Screen(),
                  ));
            },
            child: Icon(
              Icons.search,
              size: 3.5.h,
            ),
          ),
        ),
      ),
    );
  }
}

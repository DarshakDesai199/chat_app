import 'dart:io';

import 'package:chat_app/main.dart';
import 'package:chat_app/service/const.dart';
import 'package:chat_app/service/google_service.dart';
import 'package:chat_app/widget/textfiled.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';

class Setting extends StatefulWidget {
  const Setting({Key? key}) : super(key: key);

  @override
  State<Setting> createState() => _SettingState();
}

class _SettingState extends State<Setting> {
  final picker = ImagePicker();
  File? _image;
  bool isLoading = false;

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(
        () {
          _image = File(pickedFile.path);
        },
      );
    }
  }

  Future<String?> uploadFile({File? file, String? filename}) async {
    print("File path:$file");

    try {
      var response = await FirebaseStorage.instance
          .ref("user_image/$filename")
          .putFile(file!);

      return response.storage.ref("user_image/$filename").getDownloadURL();
    } on firebase_storage.FirebaseException catch (e) {
      print("ERROR===>>$e");
    }
    return null;
  }

  Future addUserData() async {
    String? userImage = await uploadFile(
        file: _image, filename: "${kFirebaseAuth.currentUser!.email}");
    FirebaseFirestore.instance
        .collection('users')
        .doc(kFirebaseAuth.currentUser!.uid)
        .set({
      "userImage": userImage,
    }).catchError(
      (e) {
        print("ERROR==<<$e");
      },
    );
  }

  final _username = TextEditingController();

  String? img;

  void getUserData() async {
    final user = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic>? getUserData = user.data() as Map<String, dynamic>?;
    _username.text = getUserData!['username'];
    setState(
      () {
        img = getUserData['userImage'];
      },
    );
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios)),
        title: Text(
          'QuickChat',
          style: GoogleFonts.satisfy(
            textStyle: TextStyle(
                fontSize: 24.sp, color: Colors.white, letterSpacing: .5),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            children: [
              SizedBox(
                height: 5.h,
              ),
              Center(
                child: Stack(
                  children: [
                    Container(
                      height: 18.h,
                      width: 18.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                      child: _image == null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: img != null
                                  ? Image.network(
                                      "$img",
                                      fit: BoxFit.cover,
                                    )
                                  : Center(
                                      child:
                                          CircularProgressIndicator.adaptive(),
                                    ),
                            )
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Image.file(
                                _image!,
                                fit: BoxFit.cover,
                              )),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 3.w,
                      child: GestureDetector(
                        onTap: () {
                          getImage();
                        },
                        child: Container(
                          height: 4.h,
                          width: 4.h,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: comColor.withOpacity(0.6)),
                          child: Icon(Icons.camera_alt,
                              color: Colors.white, size: 2.h),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8.h,
              ),
              TextFormField(
                controller: _username,
                style: TextStyle(color: Colors.white),
                decoration: buildInputDecoration().copyWith(
                  label: Text("username"),
                ),
              ),
              SizedBox(
                height: 3.h,
              ),
              Container(
                alignment: Alignment.center,
                height: 7.h,
                width: 100.w,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(9)),
                child: email != null
                    ? Text("$email")
                    : Text(
                        "${kFirebaseAuth.currentUser!.email}",
                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                      ),
              ),
              SizedBox(
                height: 10.h,
              ),
              isLoading
                  ? LinearProgressIndicator(color: comColor)
                  : GestureDetector(
                      onTap: () async {
                        setState(() {
                          isLoading = true;
                        });
                        var userImage = await uploadFile(
                            file: _image,
                            filename: kFirebaseAuth.currentUser!.email);

                        FirebaseFirestore.instance
                            .collection("users")
                            .doc(kFirebaseAuth.currentUser!.uid)
                            .update(
                          {"username": _username.text, 'userImage': userImage},
                        ).then(
                          (value) => ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Updated !!"),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: 7.h,
                        width: 100.w,
                        decoration: BoxDecoration(
                          color: Color(0xff004D40),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          "UPDATE",
                          style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

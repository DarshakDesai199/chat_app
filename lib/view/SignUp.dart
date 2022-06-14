import 'package:chat_app/main.dart';
import 'package:chat_app/service/Firebase_service.dart';
import 'package:chat_app/service/const.dart';
import 'package:chat_app/service/google_service.dart';
import 'package:chat_app/service/internet_controller.dart';
import 'package:chat_app/view/ChatRoom.dart';
import 'package:chat_app/view/LogIn.dart';
import 'package:chat_app/widget/appbar.dart';
import 'package:chat_app/widget/textfiled.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'Home.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool isObscure = true;

  setSharedPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("email", _email.text);
  }

  setGoogleSharedPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    _prefs.setString("email", email!);
  }

  ConnectivityProvider connectivityProvider = Get.put(ConnectivityProvider());

  @override
  void initState() {
    connectivityProvider.startMonitoring();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: buildAppBar(),
      body: GetBuilder<ConnectivityProvider>(
        builder: (controller) {
          if (controller.isOnline) {
            return controller.isOnline
                ? SafeArea(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                height: 5.h,
                              ),
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text(
                                  'SignUp',
                                  style: GoogleFonts.dancingScript(
                                    textStyle: TextStyle(
                                        fontSize: 30.sp,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: .5),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6.h,
                              ),
                              TextFormField(
                                cursorColor: Color(0xff004D40),
                                mouseCursor: MouseCursor.defer,
                                controller: _username,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return "Enter a Username";
                                  }
                                },
                                style: TextStyle(color: Colors.white),
                                decoration: buildInputDecoration().copyWith(
                                  label: Text("Username"),
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              TextFormField(
                                cursorColor: Color(0xff004D40),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  RegExp regex = RegExp(
                                      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$');
                                  if (value!.isEmpty) {
                                    return "please Enter an Email";
                                  } else if (!regex.hasMatch(value)) {
                                    return "Enter valid Email ";
                                  }
                                },
                                controller: _email,
                                style: TextStyle(color: Colors.white),
                                decoration: buildInputDecoration().copyWith(
                                  label: Text("email"),
                                ),
                              ),
                              SizedBox(
                                height: 3.h,
                              ),
                              TextFormField(
                                cursorColor: Color(0xff004D40),
                                obscureText: isObscure,
                                keyboardType: TextInputType.visiblePassword,
                                validator: (value) {
                                  RegExp regex = RegExp(
                                      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                                  if (value!.isEmpty) {
                                    return "Please Enter a valid password";
                                  } else if (!regex.hasMatch(value)) {
                                    return "include both lower and upper case character.\n"
                                        "include at least one number or symbol.\n"
                                        "be a at least 8 character long.";
                                  }
                                },
                                controller: _password,
                                style: TextStyle(color: Colors.white),
                                decoration: buildInputDecoration().copyWith(
                                  label: Text("password"),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isObscure = !isObscure;
                                      });
                                    },
                                    icon: isObscure
                                        ? Icon(
                                            Icons.visibility,
                                            color: Colors.white,
                                          )
                                        : Icon(
                                            Icons.visibility_off,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6.h,
                              ),
                              GestureDetector(
                                onTap: () async {
                                  if (_formKey.currentState!.validate()) {
                                    bool status =
                                        await FirebaseAuthService.signUp(
                                                _email.text, _password.text)
                                            .catchError(
                                      (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: Color(0xff004D40),
                                            behavior: SnackBarBehavior.floating,
                                            content: Text("$e"),
                                          ),
                                        );
                                      },
                                    );

                                    if (status == true) {
                                      setSharedPref();
                                      showModalBottomSheet(
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                        context: context,
                                        builder: (BuildContext context) {
                                          return Container(
                                            height: Get.height,
                                            width: Get.width,
                                            color: Colors.transparent,
                                            child: Center(
                                                child:
                                                    CircularProgressIndicator(
                                              color: comColor,
                                            )),
                                          );
                                        },
                                      );
                                      kFirebaseAuth.currentUser!.updateProfile(
                                          displayName: _username.text);
                                      FirebaseFirestore.instance
                                          .collection("users")
                                          .doc(kFirebaseAuth.currentUser!.uid)
                                          .set(
                                        {
                                          "username": _username.text,
                                          "email": _email.text,
                                          "uid": kFirebaseAuth.currentUser!.uid,
                                          "userImage":
                                              "https://t3.ftcdn.net/jpg/03/46/83/96/360_F_346839683_6nAPzbhpSkIpb8pmAwufkC7c5eD7wYws.jpg"
                                        },
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                            SnackBar(
                                              content:
                                                  Text("Successfully SignUp"),
                                            ),
                                          )
                                          .closed
                                          .then(
                                            (value) =>
                                                Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Home(),
                                              ),
                                            ),
                                          );
                                    }
                                  }
                                },
                                child: Container(
                                  height: 7.h,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(30)),
                                  child: Center(
                                    child: Text(
                                      "SignUp",
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xff004D40)),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 2.h,
                              ),
                              GestureDetector(
                                onTap: () {
                                  setGoogleSharedPref();
                                  signInWithGoogle().whenComplete(
                                      () => Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ChatRoom(),
                                            ),
                                          ));
                                },
                                child: Container(
                                  height: 7.h,
                                  width: 100.w,
                                  decoration: BoxDecoration(
                                    color: Color(0xff004D40),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          height: 4.h,
                                          width: 8.w,
                                          decoration: BoxDecoration(
                                              image: DecorationImage(
                                                  image: AssetImage(
                                                    "assets/google.png",
                                                  ),
                                                  fit: BoxFit.fill)),
                                        ),
                                        SizedBox(
                                          width: 3.w,
                                        ),
                                        Text(
                                          "GOOGLE",
                                          style: TextStyle(
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 6.h,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Already Have an Account?",
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.white),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LogIn(),
                                        ),
                                      );
                                    },
                                    child: Text(
                                      " LogIn",
                                      style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(
                    "No Internet",
                    style: TextStyle(color: Colors.white, fontSize: 15.sp),
                  ));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

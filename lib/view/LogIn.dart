import 'package:chat_app/main.dart';
import 'package:chat_app/service/Firebase_service.dart';
import 'package:chat_app/service/google_service.dart';
import 'package:chat_app/view/ChatRoom.dart';
import 'package:chat_app/view/ForgetPassword.dart';
import 'package:chat_app/view/Home.dart';
import 'package:chat_app/view/SignUp.dart';
import 'package:chat_app/widget/appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../widget/textfiled.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  final _formKey = GlobalKey<FormState>();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: buildAppBar(),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(
                      height: 15.h,
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        'Log In',
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
                      keyboardType: TextInputType.emailAddress,
                      cursorColor: Color(0xff004D40),
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
                      decoration:
                          buildInputDecoration().copyWith(label: Text("email")),
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    TextFormField(
                      obscureText: isObscure,
                      cursorColor: Color(0xff004D40),
                      keyboardType: TextInputType.visiblePassword,
                      controller: _password,
                      validator: (value) {
                        RegExp regex = RegExp(
                            r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
                        if (value!.isEmpty) {
                          return "Please Enter a valid password";
                        } else if (!regex.hasMatch(value)) {
                          return "include both lower and upper case character"
                              "include at least one number or symbol"
                              "be a at least 8 character long.";
                        }
                      },
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
                      height: 3.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => Forget(),
                                ),
                              );
                            },
                            child: Text(
                              "Forget password ?",
                              style: TextStyle(
                                  fontSize: 13.sp, color: Colors.white),
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 3.h,
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          bool status = await FirebaseAuthService.logIn(
                                  _email.text, _password.text)
                              .catchError(
                            (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Color(0xff004D40),
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
                                      child: CircularProgressIndicator(
                                    color: comColor,
                                  )),
                                );
                              },
                            );
                            ScaffoldMessenger.of(context)
                                .showSnackBar(
                                  SnackBar(
                                    content: Text("Successfully Login"),
                                  ),
                                )
                                .closed
                                .then(
                                  (value) => Navigator.pushReplacement(
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
                            "LogIn",
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
                        signInWithGoogle()
                            .whenComplete(() => Navigator.pushReplacement(
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
                            mainAxisAlignment: MainAxisAlignment.center,
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
                          "Create an Account?",
                          style:
                              TextStyle(fontSize: 12.sp, color: Colors.white),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignUp(),
                              ),
                            );
                          },
                          child: Text(
                            " SignUp",
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
        ));
  }
}

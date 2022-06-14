import 'dart:async';

import 'package:chat_app/view/Home.dart';
import 'package:chat_app/view/SignUp.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  var data;

  void initState() {
    getSharedPref().then(
      (value) => Timer(
        Duration(seconds: 3),
        () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => data == null ? SignUp() : Home(),
          ),
        ),
      ),
    );
  }

  Future getSharedPref() async {
    SharedPreferences _prefs = await SharedPreferences.getInstance();
    var results = _prefs.get("email");

    setState(() {
      data = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff004D40),
      body: SafeArea(
        child: Container(
          alignment: Alignment.center,
          height: 100.h,
          width: 100.w,
          child: Text(
            'QuickChat',
            style: GoogleFonts.satisfy(
              textStyle: TextStyle(
                  fontSize: 50.sp, color: Colors.white, letterSpacing: .5),
            ),
          ),
        ),
      ),
    );
  }
}

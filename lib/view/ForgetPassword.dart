import 'package:chat_app/service/Firebase_service.dart';
import 'package:chat_app/view/LogIn.dart';
import 'package:chat_app/widget/textfiled.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class Forget extends StatefulWidget {
  const Forget({Key? key}) : super(key: key);

  @override
  State<Forget> createState() => _ForgetState();
}

class _ForgetState extends State<Forget> {
  final formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
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
            icon: Icon(Icons.arrow_back_ios),
          )),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: formKey,
          child: Column(children: [
            SizedBox(
              height: 15.h,
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Reset Password',
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
              decoration: buildInputDecoration().copyWith(label: Text("email")),
            ),
            SizedBox(
              height: 6.h,
            ),
            GestureDetector(
              onTap: () async {
                if (formKey.currentState!.validate()) {
                  await FirebaseAuthService.forgetPassword(_email.text)
                      .whenComplete(
                        () => ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content:
                                Text("Reset Password link send on your email."),
                          ),
                        ),
                      )
                      .then(
                        (value) => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LogIn(),
                          ),
                        ),
                      );
                }
              },
              child: Container(
                height: 7.h,
                width: 100.w,
                decoration: BoxDecoration(
                    color: Color(0xff004D40),
                    borderRadius: BorderRadius.circular(30)),
                child: Center(
                  child: Text(
                    "Reset Password",
                    style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.white),
                  ),
                ),
              ),
            )
          ]),
        ),
      ),
    );
  }
}

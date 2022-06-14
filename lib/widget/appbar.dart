import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

AppBar buildAppBar() {
  return AppBar(
    // automaticallyImplyLeading: false,
    title: Text(
      'QuickChat',
      style: GoogleFonts.satisfy(
        textStyle:
            TextStyle(fontSize: 24.sp, color: Colors.white, letterSpacing: .5),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

InputDecoration buildInputDecoration() {
  return InputDecoration(
    labelStyle: TextStyle(color: Colors.white, fontSize: 13.sp),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.white, width: 1.5.sp),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xff004D40), width: 1.5.sp),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Colors.red, width: 1.5.sp),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: Color(0xff558B2F), width: 1.5.sp),
    ),
  );
}

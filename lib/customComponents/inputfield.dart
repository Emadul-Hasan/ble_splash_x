import 'package:ble_splash_x/constants/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Inputfield extends StatelessWidget {
  Inputfield(
      {required this.margin,
      required this.function,
      required this.obscuretext,
      required this.keyBoardtype,
      required this.controller});

  final double margin;
  final bool obscuretext;
  final void Function(String) function;
  final TextEditingController controller;
  final TextInputType keyBoardtype;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: margin),
      width: KFieldWidth,
      height: KFieldHeight,
      decoration: BoxDecoration(
        color: Color(0xFFEDEDED),
        border: Border.all(
          color: Color(0xFFEDEDED),
        ),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: TextField(
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16.0),
        controller: controller,
        keyboardType: keyBoardtype,
        obscureText: obscuretext,
        onChanged: function,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(2.0)),
          ),
          contentPadding:
              EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
          // prefixIcon: prefixicon,
          enabledBorder: KoutlineInputBorder,
          focusedBorder: KoutlineInputBorder,
        ),
      ),
    );
  }
}

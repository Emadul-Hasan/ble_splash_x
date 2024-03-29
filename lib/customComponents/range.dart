import 'package:ble_splash_x/constants/constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RangeContainer extends StatelessWidget {
  RangeContainer({
    Key? key,
    required this.min,
    required this.function,
    required this.color,
    required this.controller,
    required this.hint,
  }) : super(key: key);

  final double min;
  final void Function(String) function;

  final Color color;
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: color,
          ),
          SizedBox(
            width: 10.0,
          ),
          Container(
              width: 110.0,
              height: 45.0,
              padding: EdgeInsets.only(
                  left: 20.0, right: 20.0, top: 13.0, bottom: 10.0),
              child: Text(
                "${min.round()}",
                textAlign: TextAlign.start,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFEDEDED),
                border: Border.all(
                  color: Color(0xFFEDEDED),
                ),
                borderRadius: BorderRadius.circular(10.0),
              )),
          Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                '-',
                style: TextStyle(fontSize: 20.0),
              )),
          Container(
              width: 110.0,
              height: 45.0,
              child: TextField(
                  style: TextStyle(fontWeight: FontWeight.bold),
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.start,
                  controller: controller,
                  onChanged: function,
                  decoration: InputDecoration(
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    labelText: hint,
                    labelStyle: TextStyle(fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(2.0)),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0.0, horizontal: 20.0),
                    enabledBorder: KoutlineInputBorder,
                    focusedBorder: KoutlineInputBorder,
                  )),
              decoration: BoxDecoration(
                color: Color(0xFFEDEDED),
                border: Border.all(
                  color: Color(0xFFEDEDED),
                ),
                borderRadius: BorderRadius.circular(10.0),
              )),
        ],
      ),
    );
  }
}

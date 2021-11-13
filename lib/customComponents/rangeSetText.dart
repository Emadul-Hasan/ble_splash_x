import 'dart:ui';

import 'package:flutter/material.dart';

class RangeSetHeading extends StatelessWidget {
  const RangeSetHeading({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 300.0,
        height: 40.0,
        // padding:
        //     EdgeInsets.only(top: 10.0, bottom: 10.0, left: 70.0, right: 70.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.white,
              width: 0.0,
            ),
          ),
        ),
        child: Center(
          child: Text("CO₂ werte einstellen",
              style: TextStyle(
                fontSize: 18.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              )),
        ),
      ),
    );
  }
}

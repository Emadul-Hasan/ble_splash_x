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
        padding:
            EdgeInsets.only(top: 10.0, bottom: 10.0, left: 70.0, right: 70.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: Colors.black38,
              width: 3.0,
            ),
          ),
        ),
        child: RichText(
          text: TextSpan(children: [
            TextSpan(
                text: "Set CO",
                style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                )),
            TextSpan(
              text: '2',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                fontFeatures: [
                  FontFeature.subscripts(),
                ],
              ),
            ),
            TextSpan(
                text: ' ranges',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ))
          ]),
        ),
      ),
    );
  }
}

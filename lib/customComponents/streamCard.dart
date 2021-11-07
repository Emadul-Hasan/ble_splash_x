import 'dart:ui';

import 'package:flutter/material.dart';

class StreamCard extends StatelessWidget {
  const StreamCard(
      {Key? key,
      required this.barColor,
      required this.co2,
      required this.calibrationFlag})
      : super(key: key);

  final Color barColor;
  final String co2;
  final bool calibrationFlag;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 300.0,
        padding:
            EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0, bottom: 20.0),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: barColor,
              width: 3.0,
            ),
          ),
        ),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    text: "Live CO",
                    style: TextStyle(
                      fontSize: 28.0,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    )),
                TextSpan(
                  text: '2',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w500,
                    fontFeatures: [
                      FontFeature.subscripts(),
                    ],
                  ),
                ),
                TextSpan(
                    text: 'Value',
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ))
              ]),
            ),
            SizedBox(height: 15.0),
            !calibrationFlag
                ? RichText(
                    text: TextSpan(children: [
                      TextSpan(
                          text: double.parse(co2) == 0.0 ? "..." : co2,
                          style: TextStyle(
                            fontSize: 40.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          )),
                      TextSpan(
                        text: 'ppm',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.0,
                          fontWeight: FontWeight.w500,
                          fontFeatures: [
                            FontFeature.subscripts(),
                          ],
                        ),
                      ),
                    ]),
                  )
                : Text(
                    "Calibrating....",
                    style:
                        TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
          ],
        ),
      ),
    );
  }
}

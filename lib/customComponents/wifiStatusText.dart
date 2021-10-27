import 'dart:ui';

import 'package:flutter/material.dart';

class WiFiStatusText extends StatelessWidget {
  const WiFiStatusText({
    Key? key,
    required this.connected,
    required this.network,
  }) : super(key: key);

  final bool connected;
  final String network;

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          height: 30.0,
          width: double.infinity,
        ),
        Icon(
          connected ? Icons.wifi_outlined : Icons.signal_wifi_off_outlined,
          size: 60.0,
          color: Colors.black38,
        ),
        Container(
          width: 200.0,
          padding:
              EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
          child: RichText(
            text: TextSpan(children: [
              TextSpan(
                  text: "CO",
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.black,
                    fontWeight: FontWeight.w400,
                  )),
              TextSpan(
                text: '2',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 14.0,
                  fontWeight: FontWeight.w500,
                  fontFeatures: [
                    FontFeature.subscripts(),
                  ],
                ),
              ),
              TextSpan(
                  text: connected
                      ? ' Device is connected to the internet'
                      : ' Device is not connected to the internet',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ))
            ]),
          ),
        ),
        Container(
          width: 200.0,
          padding:
              EdgeInsets.only(left: 15.0, right: 10.0, top: 10.0, bottom: 20.0),
          child: Text(
            "Network Status: $network",
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

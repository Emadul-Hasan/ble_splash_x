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
          size: 50.0,
          color: connected ? Colors.blue : Colors.black38,
        ),
        Container(
          width: 300.0,
          padding:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 15.0, bottom: 20.0),
          child: Text(
            connected
                ? 'Die Ampel ist mit dem Internet verbunden'
                : 'Die Ampel ist NICHT mit dem Internet verbunden',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
        Container(
          width: 200.0,
          padding:
              EdgeInsets.only(left: 15.0, right: 10.0, top: 00.0, bottom: 10.0),
          child: Text(
            "Netzwerkstatus",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
            margin: EdgeInsets.only(top: 10.0),
            width: 220.0,
            height: 50.0,
            padding: EdgeInsets.only(
                left: 20.0, right: 20.0, top: 10.0, bottom: 10.0),
            child: Center(
              child: Text(
                "$network",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            decoration: BoxDecoration(
              color: Color(0xFFEDEDED),
              border: Border.all(
                color: Color(0xFFEDEDED),
              ),
              borderRadius: BorderRadius.circular(10.0),
            )),
      ],
    );
  }
}

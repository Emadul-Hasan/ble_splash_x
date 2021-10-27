import 'dart:ui';

import 'package:ble_splash_x/screen/Calibration.dart';
import 'package:ble_splash_x/screen/ConfigWifi.dart';
import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DrawerCustom extends StatefulWidget {
  final BluetoothDevice device;
  const DrawerCustom({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  _DrawerCustomState createState() => _DrawerCustomState();
}

class _DrawerCustomState extends State<DrawerCustom> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        child: ListView(
          children: [
            DrawerHeader(
              child: Column(
                children: [
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(
                    child: Text(
                      "SplashX",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Configure CO",
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                    TextSpan(
                      text: '2',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12.0,
                        fontFeatures: [
                          FontFeature.subscripts(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10, color: Colors.black12, spreadRadius: 2)
                  ],
                ),
                child: CircleAvatar(
                  child: Icon(
                    MdiIcons.fire,
                    color: Colors.black,
                    size: 25.0,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, Homepage.id,
                    arguments: widget.device);
              },
            ),
            ListTile(
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Configure Wifi",
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10, color: Colors.black12, spreadRadius: 2)
                  ],
                ),
                child: CircleAvatar(
                  child: Icon(
                    MdiIcons.wifiSync,
                    color: Colors.black,
                    size: 25.0,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, ConfigWiFiPage.id,
                    arguments: widget.device);
              },
            ),
            ListTile(
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "Device Calibration",
                      style: TextStyle(color: Colors.black, fontSize: 16.0),
                    ),
                  ],
                ),
              ),
              leading: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10, color: Colors.black12, spreadRadius: 2)
                  ],
                ),
                child: CircleAvatar(
                  child: Icon(
                    MdiIcons.reload,
                    color: Colors.black,
                    size: 25.0,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushReplacementNamed(context, CalibrationPage.id,
                    arguments: widget.device);
              },
            ),
          ],
        ),
      ),
    );
  }
}

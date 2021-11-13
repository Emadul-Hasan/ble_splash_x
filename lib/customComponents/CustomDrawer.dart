import 'package:ble_splash_x/screen/Calibration.dart';
import 'package:ble_splash_x/screen/ConfigWifi.dart';
import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:ble_splash_x/screen/discover.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class DrawerCustom extends StatefulWidget {
  final BluetoothDevice device;
  final bool request;
  const DrawerCustom({
    Key? key,
    required this.device,
    required this.request,
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
                    height: 60.0,
                  ),
                  Center(
                    child: Text(
                      "SPLASH X",
                      style: TextStyle(fontSize: 20.0),
                    ),
                  )
                ],
              ),
            ),
            ListTile(
              title: Text(
                "CO₂-Werte konfigurieren",
                style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                    color: Colors.blue,
                    size: 25.0,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, Homepage.id,
                    arguments: widget.device);
              },
            ),
            ListTile(
              title: Text(
                "Wi-Fi konfigurieren",
                style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                    color: Colors.blue,
                    size: 25.0,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, ConfigWiFiPage.id,
                    arguments: widget.device);
              },
            ),
            ListTile(
              title: Text(
                "Gerät kalibrieren",
                style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                    color: Colors.blue,
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
            ListTile(
              title: Text(
                "Abmelden",
                style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                    MdiIcons.logout,
                    color: Colors.blue,
                    size: 25.0,
                  ),
                  backgroundColor: Colors.white,
                ),
              ),
              onTap: () {
                widget.device.disconnect();
                Navigator.pushNamedAndRemoveUntil(
                    context, DiscoverPage.id, (Route<dynamic> route) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}

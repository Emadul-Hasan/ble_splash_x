import 'dart:ui';

import 'package:ble_splash_x/constants/constant.dart';
import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:ble_splash_x/customComponents/inputfield.dart';
import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ConfigWiFiPage extends StatelessWidget {
  const ConfigWiFiPage({Key? key}) : super(key: key);
  static const String id = 'ConfigWifi';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String;
    return WifiConfigPage();
  }
}

class WifiConfigPage extends StatefulWidget {
  const WifiConfigPage({Key? key}) : super(key: key);

  @override
  _WifiConfigPageState createState() => _WifiConfigPageState();
}

class _WifiConfigPageState extends State<WifiConfigPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      bottomNavigationBar: Container(
        color: Colors.white30,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white38),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Homepage.id,
                      arguments: 'Device');
                },
                child: Text(
                  "Config CO2",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
            Divider(
              thickness: 2.0,
              height: 10.0,
              indent: 0.5,
              color: Colors.redAccent,
            ),
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {},
                child: Text(
                  "Conf.Wifi",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text("Wifi Config"),
        backgroundColor: Colors.black38,
      ),
      drawer: DrawerCustom(),
      body: SingleChildScrollView(
        reverse: true,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              // mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 30.0,
                  width: double.infinity,
                ),
                Icon(
                  Icons.signal_wifi_off_outlined,
                  size: 60.0,
                  color: Colors.black38,
                ),
                Container(
                  width: 200.0,
                  padding: EdgeInsets.only(
                      left: 20.0, right: 20.0, top: 20.0, bottom: 20.0),
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
                          text: ' Device not connected to the internet',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ))
                    ]),
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Text(
                    "Connected SSID",
                    style: TextStyle(fontSize: KTextSizeofWifiConfig),
                  ),
                ),
                Inputfield(
                  obscuretext: false,
                  margin: 10.0,
                  keyBoardtype: TextInputType.emailAddress,
                  function: (value) {
                    print(value);
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Text("New SSID",
                      style: TextStyle(fontSize: KTextSizeofWifiConfig)),
                ),
                Inputfield(
                  obscuretext: false,
                  margin: 10.0,
                  keyBoardtype: TextInputType.emailAddress,
                  function: (value) {
                    print(value);
                  },
                ),
                Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Text("New Password",
                      style: TextStyle(fontSize: KTextSizeofWifiConfig)),
                ),
                Inputfield(
                  obscuretext: false,
                  margin: 10.0,
                  keyBoardtype: TextInputType.emailAddress,
                  function: (value) {
                    print(value);
                  },
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(
                      MdiIcons.qrcodeScan,
                      size: 30.0,
                    ),
                    onPressed: () {},
                  ),
                  TextButton(
                    child: Text(
                      "Scan QR Code",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            ElevatedButton(onPressed: () {}, child: Text("Save")),
          ],
        ),
      ),
    );
  }
}

import 'dart:ui';

import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DiscoverPage extends StatefulWidget {
  static const String id = 'DiscoverPage';
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List scannedDevicesName = [];
  List<BluetoothDevice> scannedDevice = [];
  FlutterBlue flutterBlue = FlutterBlue.instance;

  void scanForBluetoothDevice() {
    // Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));

// Listen to scan results
    var subscription = flutterBlue.scanResults.listen((results) {
      if (results.length == 0) {
        setState(() {});
      }
      // do something with scan results
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');
        setState(() {
          if (r.device.name == '') {
          } else {
            scannedDevicesName.add(r.device.name);
            scannedDevicesName = scannedDevicesName.toSet().toList();
            scannedDevice.add(r.device);
            scannedDevice = scannedDevice.toSet().toList();
          }
        });
      }
    });

// Stop scanning
    flutterBlue.stopScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 110.0,
            ),
            Text(
              "SplashX",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10.0,
            ),
            ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                Icons.bluetooth,
                size: 40.0,
                color: Colors.black,
              ),
              title: Text(
                "Switch on Bluetooth",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                Icons.lightbulb_outlined,
                size: 40.0,
                color: Colors.black,
              ),
              title: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Hold the push button on the CO",
                      style: TextStyle(fontSize: 16.0, color: Colors.black)),
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
                  TextSpan(
                      text: ' button for 5 seconds',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ))
                ]),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => Colors.black)),
                onPressed: () {
                  setState(() {
                    scanForBluetoothDevice();
                  });
                },
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Scan CO", style: TextStyle(fontSize: 14.0)),
                    TextSpan(
                      text: '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontFeatures: [
                          FontFeature.subscripts(),
                        ],
                      ),
                    ),
                    TextSpan(text: ' Device', style: TextStyle(fontSize: 14.0))
                  ]),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 30.0, left: 30.0, bottom: 0.0),
                  child: Text(
                    'Available devices',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      margin: EdgeInsets.only(left: 5.0, right: 5.0),
                      child: ListTile(
                        title: Text(scannedDevicesName[index]),
                        trailing: StreamBuilder<BluetoothDeviceState>(
                            stream: scannedDevice[index].state,
                            builder: (c, snapshot) {
                              if (snapshot.data ==
                                  BluetoothDeviceState.connected) {
                                return ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.resolveWith(
                                                (states) => Colors.black)),
                                    onPressed: () async {
                                      print("Navigate");
                                      await scannedDevice[index].disconnect();
                                    },
                                    child: Text("Connected"));
                              }
                              return ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.black)),
                                  onPressed: () async {
                                    await scannedDevice[index].connect();
                                  },
                                  child: Text("Tap to Connect"));
                            }),
                        onTap: () async {
                          await scannedDevice[index].connect();
                          Navigator.pushReplacementNamed(context, Homepage.id,
                              arguments: scannedDevice[index]);
                        },
                      ));
                },
                itemCount: scannedDevicesName.length,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "CO",
                      style: TextStyle(fontSize: 15.0, color: Colors.black)),
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
                  TextSpan(
                      text: ' device name starts with sp',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

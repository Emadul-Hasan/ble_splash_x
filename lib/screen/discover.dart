import 'dart:async';
import 'dart:ui';

import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:location/location.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

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
  var subscription;
  late bool _serviceEnabled;

  Location location = new Location();

  void loadingIgnite() async {
    EasyLoading.instance.maskType = EasyLoadingMaskType.black;
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.custom;
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.circle;
    EasyLoading.instance.maskColor = Colors.blue;
    await EasyLoading.show(status: 'Laden...');
  }

  Future<bool> _checkDeviceBluetoothIsOn() async {
    return await flutterBlue.isOn;
  }

  Future<void> scanForBluetoothDevice() async {
    scannedDevice.clear();
    scannedDevicesName.clear();
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    if (connectedDevices.isNotEmpty) {
      // print("COnnexrtesfafasjkfhjk:");
      // print(connectedDevices[0]);
      await connectedDevices[0].disconnect();
    }

// Start scanning
    flutterBlue.startScan(timeout: Duration(seconds: 5));

// Listen to scan results
    subscription = flutterBlue.scanResults.listen((results) {
      if (results.length == 0) {
        setState(() {});
      }

      // // do something with scan results
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
    // subscription.cancel();
  }

  Future<void> turnOnLocation() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
    }
  }

  @override
  void initState() {
    turnOnLocation();
    super.initState();
  }

  @override
  void dispose() {
    scannedDevice.clear();
    scannedDevicesName.clear();
    subscription.cancel();
    super.dispose();
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
              height: 80.0,
            ),
            Text(
              "SPLASH-X",
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
                color: Colors.blue,
              ),
              title: Text(
                "Bitte auf dem Mobilgerät Bluetooth aktivieren",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(
              height: 3.0,
            ),
            ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                MdiIcons.trafficLightOutline,
                size: 40.0,
                color: Colors.blue,
              ),
              title: Text(
                "Bitte drücken Sie den schwarzen Taster der CO₂-Ampel einmal.",
                style: TextStyle(fontSize: 16.0),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(
              height: 3.0,
            ),
            ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                Icons.lightbulb_outlined,
                size: 40.0,
                color: Colors.blue,
              ),
              title: Text(
                  "Das Licht wird blinken & die Bluetooth-Funktion ist eingeschaltet.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: 16.0, color: Colors.black)),
            ),
            SizedBox(
              height: 3.0,
            ),
            ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                MdiIcons.gestureTap,
                size: 40.0,
                color: Colors.blue,
              ),
              title: Text(
                "Tippen Sie nun auf die \"CO₂-Ampel suchen\"",
                style: TextStyle(fontSize: 16.0, color: Colors.black),
                textAlign: TextAlign.justify,
              ),
            ),
            SizedBox(
              height: 7.0,
            ),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith(
                      (states) => Colors.blue)),
              onPressed: () async {
                _serviceEnabled = await location.serviceEnabled();
                if (!_serviceEnabled) {
                  _serviceEnabled = await location.requestService();
                } else if (_serviceEnabled) {
                  var checkS = await _checkDeviceBluetoothIsOn();
                  if (!checkS) {
                    await EasyLoading.showInfo("Bluetooth aktivieren");
                  } else {
                    loadingIgnite();
                    setState(() {
                      scanForBluetoothDevice();
                      Timer(Duration(seconds: 4), () {
                        EasyLoading.dismiss();
                      });
                    });
                  }
                }
              },
              child: Text(
                "CO₂ Ampel suchen",
                style: TextStyle(color: Colors.white),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 15.0, left: 30.0, bottom: 0.0),
                  child: Text(
                    'Die CO₂ Ampel  beginnt mit "SP-..."',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 40.0, left: 30.0, bottom: 0.0),
                  child: Text(
                    'Verfügbare Geräte',
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                      padding: EdgeInsets.zero,
                      margin:
                          EdgeInsets.only(top: 0.0, left: 10.0, right: 10.0),
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
                                                (states) => Colors.blue)),
                                    onPressed: () async {
                                      loadingIgnite();
                                      Timer(Duration(seconds: 2), () {
                                        Navigator.pushNamed(
                                            context, Homepage.id,
                                            arguments: scannedDevice[index]);
                                        EasyLoading.dismiss();
                                      });
                                    },
                                    child: Text("Öffnen"));
                              }
                              return ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => Colors.blue)),
                                  onPressed: () {
                                    loadingIgnite();
                                    Timer(Duration(seconds: 2), () async {
                                      await scannedDevice[index].connect();
                                      EasyLoading.dismiss();
                                    });
                                  },
                                  child: Text("Verbinden"));
                            }),
                        onTap: () async {
                          // loadingIgnite();
                          // await scannedDevice[index].connect();
                          // EasyLoading.dismiss();
                        },
                      ));
                },
                itemCount: scannedDevicesName.length,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:ble_splash_x/constants/constant.dart';
import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:ble_splash_x/customComponents/inputfield.dart';
import 'package:ble_splash_x/customComponents/wifiStatusText.dart';
import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:ble_splash_x/screen/qr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'discover.dart';

class ConfigWiFiPage extends StatelessWidget {
  const ConfigWiFiPage({Key? key}) : super(key: key);
  static const String id = 'ConfigWifi';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as BluetoothDevice;
    return WifiConfigPage(
      device: args,
    );
  }
}

class WifiConfigPage extends StatefulWidget {
  const WifiConfigPage({Key? key, required this.device}) : super(key: key);

  final BluetoothDevice device;

  @override
  _WifiConfigPageState createState() => _WifiConfigPageState();
}

class _WifiConfigPageState extends State<WifiConfigPage> {
  final String serviceUUId = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUId = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  bool isReady = false;
  late Stream<List> stream;

  late BluetoothCharacteristic targetCharacteristics;
  bool connected = false;

  String network = "Unknown";
  late String oldSSID = "";
  late String oldSSIDInput;

  late String newSSID;
  late String newPass;

  int wifiDataController = 0;

  List<String> wifiCred = [];

  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();

  void loadingIgnite() async {
    await EasyLoading.showInfo("Sending....");
  }

  connectToDevice() async {
    if (widget.device == null) {
      _pop();
      return;
    }
    discoverServices();
    new Timer(const Duration(seconds: 3), () {
      if (!isReady) {
        disconnectFromDevice();
        _pop();
      }
    });

    await widget.device.connect();
    discoverServices();
  }

  disconnectFromDevice() {
    if (widget.device == null) {
      _pop();
      return;
    }
    widget.device.disconnect();
  }

  discoverServices() async {
    if (widget.device == null) {
      _pop();
      return;
    }
    widget.device.connect();

    List<BluetoothService> services = await widget.device.discoverServices();
    services.forEach((service) {
      if (service.uuid.toString() == serviceUUId) {
        service.characteristics.forEach((characteristic) {
          if (characteristic.uuid.toString() == characteristicUUId) {
            characteristic.setNotifyValue(!characteristic.isNotifying);
            stream = characteristic.value;
            targetCharacteristics = characteristic;

            setState(() {
              isReady = true;
              print("Trying.........");
            });
          }
        });
      }
    });

    if (!isReady) {
      // _pop()
    }
  }

  _pop() {
    Navigator.of(context).pop(true);
  }

  //

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  sendData(String data) async {
    if (targetCharacteristics == null) return;
    List<int> bytes = utf8.encode(data);
    await targetCharacteristics.write(bytes);
  }

  void checkConnectionState() {
    widget.device.state.listen((event) async {
      if (event == BluetoothDeviceState.disconnected) {
        EasyLoading.showInfo("Device Disconnected");
        Timer(Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
              context, DiscoverPage.id, (Route<dynamic> route) => false);
        });
      }
    });
  }

  void scanData() async {
    var result = await Navigator.pushNamed(context, QRViewExample.id,
        arguments: widget.device);

    wifiCred = result.toString().split(";");

    String ssid = wifiCred[2];
    List<String> getSSID = ssid.split(":");
    print("SSID: $getSSID");
    newSSID = getSSID[1];

    String pass = wifiCred[1];
    List<String> getPASS = pass.split(":");
    print("PASS: $getPASS");
    newPass = getPASS[1];

    controller2.text = newSSID;
    controller3.text = newPass;
  }

  @override
  void initState() {
    super.initState();
    discoverServices();
    // connectToDevice();
  }

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
                  backgroundColor: MaterialStateProperty.all(Colors.black26),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, Homepage.id,
                      arguments: widget.device);
                },
                child: Text(
                  "Config CO2",
                  style: TextStyle(color: Colors.white),
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
                  "Config Wifi",
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(widget.device.name),
        backgroundColor: Colors.black38,
      ),
      drawer: DrawerCustom(
        device: widget.device,
      ),
      body: isReady == false
          ? Center(
              child: Text("Reading Data...."),
            )
          : Container(
              child: StreamBuilder<List>(
                stream: stream,
                builder: (BuildContext context, AsyncSnapshot<List> snapshot) {
                  if (snapshot.hasError) {
                    Timer(Duration(seconds: 4), () {
                      print('done');
                    });
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.lightBlueAccent,
                      ),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.active) {
                    try {
                      while (wifiDataController < 3) {
                        Timer(Duration(seconds: 2), () async {
                          await sendData("SSID+");
                          print("Asking for Data");
                        });
                        wifiDataController++;
                      }

                      var x = _dataParser(snapshot.data as List<int>);
                      var _data = x.split('+');
                      if (_data.length > 1) {
                        if (_data[0] == '1') {
                          controller1.text = _data[1];
                          oldSSID = _data[1];
                          connected = true;
                        } else if (_data[0] == "0") {
                          oldSSID = _data[1];
                          connected = false;
                        }
                        if (_data[2] == "OK") {
                          network = "OK";
                        } else if (_data[2] == "NOK") {
                          network = "NOT OK";
                        }
                      }
                      // print(_data);

                    } catch (e) {
                      print(e);
                    }
                  }
                  checkConnectionState();

                  return SingleChildScrollView(
                    reverse: true,
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WiFiStatusText(connected: connected, network: network),
                        Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: Text(
                                "Connected SSID",
                                style:
                                    TextStyle(fontSize: KTextSizeofWifiConfig),
                              ),
                            ),
                            Container(
                                margin: EdgeInsets.only(top: 10.0),
                                width: 220.0,
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                child: Text(
                                  "$oldSSID",
                                  style: TextStyle(fontSize: 16.0),
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFEDEDED),
                                  border: Border.all(
                                    color: Color(0xFFEDEDED),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: Text("New SSID",
                                  style: TextStyle(
                                      fontSize: KTextSizeofWifiConfig)),
                            ),
                            Inputfield(
                              controller: controller2,
                              obscuretext: false,
                              margin: 10.0,
                              keyBoardtype: TextInputType.emailAddress,
                              function: (value) {
                                newSSID = value;
                              },
                            ),
                            Container(
                              margin: EdgeInsets.only(top: 10.0),
                              child: Text("New Password",
                                  style: TextStyle(
                                      fontSize: KTextSizeofWifiConfig)),
                            ),
                            Inputfield(
                              controller: controller3,
                              obscuretext: false,
                              margin: 10.0,
                              keyBoardtype: TextInputType.emailAddress,
                              function: (value) {
                                newPass = value;
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
                                onPressed: scanData,
                              ),
                              TextButton(
                                child: Text(
                                  "Scan QR Code",
                                  style: TextStyle(color: Colors.black),
                                ),
                                onPressed: scanData,
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                            onPressed: () async {
                              loadingIgnite();
                              print(newSSID);
                              print(newPass);
                              if (newSSID.length <= 14) {
                                String text = "S+1+$newSSID+";
                                await sendData(text);
                              } else if (newSSID.length > 14) {
                                String halfSSID = "";
                                for (int i = 0; i < 14; i++) {
                                  halfSSID += newSSID[i];
                                }
                                String newHalfSSID = "S+2+$halfSSID+";
                                print("half: $newHalfSSID");
                                await sendData(newHalfSSID);
                                Timer(const Duration(seconds: 1), () async {
                                  var secondHalfSSID = "";
                                  for (int i = 14; i < newSSID.length; i++) {
                                    secondHalfSSID += newSSID[i];
                                  }
                                  String newSecondHalfSSID =
                                      "S+2+$secondHalfSSID+";
                                  print("half: $newSecondHalfSSID");
                                  await sendData(newSecondHalfSSID);
                                });
                              }
                              Timer(const Duration(seconds: 2), () async {
                                if (newPass.length <= 14) {
                                  String text = "P+1+$newPass+";
                                  await sendData(text);
                                } else if (newPass.length > 14) {
                                  String halfPass = "";
                                  for (int i = 0; i < 14; i++) {
                                    halfPass += newPass[i];
                                  }
                                  String newHalfPass = "P+2+$halfPass+";
                                  await sendData(newHalfPass);
                                  Timer(const Duration(seconds: 1), () async {
                                    var secondHalfPass = "";
                                    for (int i = 14; i < newPass.length; i++) {
                                      secondHalfPass += newPass[i];
                                    }
                                    String newSecondHalfPass =
                                        "P+2+$secondHalfPass+";
                                    await sendData(newSecondHalfPass);
                                  });
                                }
                              });

                              controller1.clear();
                              controller2.clear();
                              controller3.clear();
                              EasyLoading.showSuccess("SUCCESS");
                            },
                            child: Text("Save")),
                      ],
                    ),
                  );
                  //
                },
              ),
            ),
    );
  }
}

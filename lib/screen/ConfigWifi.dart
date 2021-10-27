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
  late String oldSSID = "";
  late String oldSSIDInput;
  late String newSSID;
  late String newPass;

  List<String> WifiCred = [];
  TextEditingController controller1 = TextEditingController();
  TextEditingController controller2 = TextEditingController();
  TextEditingController controller3 = TextEditingController();

  void loadingIgnite() async {
    await EasyLoading.showInfo("Done");
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

  String _dataParser(List<int> datafromdevice) {
    return utf8.decode(datafromdevice);
  }

  sendData(String data) async {
    if (targetCharacteristics == null) return;
    List<int> bytes = utf8.encode(data);
    await targetCharacteristics.write(bytes);
  }

  void checkConnectionState() {
    widget.device.state.listen((event) async {
      if (event == BluetoothDeviceState.disconnected) {
        print("disconnected");
        EasyLoading.showInfo("Device Disconnected");
        Timer(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, DiscoverPage.id);
        });
      }
    });
  }

  void scanData() async {
    var result = await Navigator.pushNamed(context, QRViewExample.id,
        arguments: widget.device);
    WifiCred = result.toString().split(";");
    String ssid = WifiCred[1];
    List<String> getSSID = ssid.split(":");
    newSSID = getSSID[1];
    String pass = WifiCred[2];
    List<String> getPASS = pass.split(":");
    newPass = getPASS[1];
    controller2.text = newPass;
    controller3.text = newSSID;
  }

  @override
  void initState() {
    super.initState();
    discoverServices();
    xt = 0;

    // connectToDevice();
  }

  int xt = 0;
  String network = "Unknown";
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
                      Future.delayed(Duration(seconds: 4), () {
                        sendData("SSID+Pass");
                      });

                      var x = _dataParser(snapshot.data as List<int>);
                      var _data = x.split('+');
                      print(_data);
                      if (_data[0] == '1') {
                        controller1.text = _data[1];
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
                            Inputfield(
                              controller: controller1,
                              obscuretext: false,
                              margin: 10.0,
                              keyBoardtype: TextInputType.emailAddress,
                              function: (value) {
                                oldSSIDInput = value;
                              },
                            ),
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
                            onPressed: () {
                              loadingIgnite();
                              // print(oldSSID);
                              // print(oldSSIDInput);
                              String text = "S+$newSSID";
                              sendData(text);
                              // try {
                              //   if (text.length > 16) {
                              //     print("text length: ${text.length}");
                              //     int loopCounter = (text.length / 16).round();
                              //     // print("Loop counter without: $loopCounter");
                              //     if (text.length % 16 != 0) {
                              //       loopCounter += 1;
                              //       // print("Loop counter with: $loopCounter");
                              //     }
                              //     int i = 0;
                              //     int j = 0;
                              //     while (j < loopCounter) {
                              //       String dataText = "";
                              //       i = j * 16;
                              //       while (i < text.length) {
                              //         dataText += text[i];
                              //         i++;
                              //         if (dataText.length == 16) {
                              //           break;
                              //         }
                              //       }
                              //       print(dataText);
                              //       String finalSSIDPass = "#+$dataText";
                              //       print(finalSSIDPass);
                              //       sendData(finalSSIDPass);
                              //       dataText = "";
                              //       print(j);
                              //       j++;
                              //     }
                              //   }
                              //   sendData("#+#");
                              // } catch (e) {
                              //   print('Exception: $e');
                              // }

                              // sendData("$newSSID+$newPass");

                              Future.delayed(Duration(seconds: 4), () {
                                String text = "P+$newPass";
                                sendData(text);
                                EasyLoading.showSuccess("SUCCESS");
                              });
                              controller1.clear();
                              controller2.clear();
                              controller3.clear();
                              xt = 0;
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

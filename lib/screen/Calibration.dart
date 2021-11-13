import 'dart:async';
import 'dart:convert';

import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'discover.dart';

class CalibrationPage extends StatelessWidget {
  const CalibrationPage({Key? key}) : super(key: key);
  static const id = "Calibration";

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as BluetoothDevice;
    return CalibrationPage1(device: args);
  }
}

class CalibrationPage1 extends StatefulWidget {
  final BluetoothDevice device;
  const CalibrationPage1({Key? key, required this.device}) : super(key: key);

  @override
  _CalibrationPage1State createState() => _CalibrationPage1State();
}

class _CalibrationPage1State extends State<CalibrationPage1>
    with SingleTickerProviderStateMixin {
  var controller;
  final String serviceUUId = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUId = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady = false;
  late Stream<List> stream;
  late BluetoothCharacteristic targetCharacteristics;
  String message = 'N';
  String date = "Never";
  int calibrationDataController = 0;

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

  bool calibrationFlag = false;

  @override
  void initState() {
    discoverServices();
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  void checkConnectionState() {
    widget.device.state.listen((event) async {
      if (event == BluetoothDeviceState.disconnected) {
        EasyLoading.showInfo("CO₂ - Ampel entkoppelt!");
        Timer(Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
              context, DiscoverPage.id, (Route<dynamic> route) => false);
        });
      }
    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.pushReplacementNamed(context, Homepage.id,
        arguments: widget.device);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.device.name),
          backgroundColor: Colors.black38,
        ),
        drawer: DrawerCustom(
          request: false,
          device: widget.device,
        ),
        body: Center(
          child: Container(
            child: isReady == false
                ? Center(
                    child: Text("Daten Lesen...."),
                  )
                : Container(
                    child: StreamBuilder<List>(
                      stream: stream,
                      builder:
                          (BuildContext context, AsyncSnapshot<List> snapshot) {
                        if (snapshot.hasError) {
                          Timer(Duration(seconds: 30), () {
                            print('done');
                          });
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.lightBlueAccent,
                            ),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          try {
                            while (calibrationDataController < 15) {
                              Timer(Duration(seconds: 3), () async {
                                await sendData("FC+");
                                print("Asking for Data");
                              });
                              calibrationDataController++;
                            }
                            var x = _dataParser(snapshot.data as List<int>);
                            var _data = x.split('+');
                            if (_data[0] == 'CM') {
                              calibrationFlag = true;
                              message = _data[1];
                            } else if (_data[0] == 'FC') {
                              date = _data[1];
                              message = _data[2];
                              if (message == 'Y') {
                                calibrationFlag = true;
                              } else {
                                calibrationFlag = false;
                              }
                            }
                          } catch (e) {
                            print(e);
                          }
                        }
                        checkConnectionState();

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 250.0,
                              height: 300.0,
                              child: Text(
                                "Gerät kalibrieren",
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black54,
                                ),
                              ),
                              alignment: Alignment.center,
                            ),
                            SizedBox(
                              height: 30.0,
                            ),
                            Container(
                                padding: EdgeInsets.only(top: 10.0),
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => calibrationFlag
                                                  ? Colors.black26
                                                  : Colors.blueAccent)),
                                  onPressed: calibrationFlag
                                      ? () {}
                                      : () {
                                          Alert(
                                              context: context,
                                              desc: " Kalibrierung starten?",
                                              buttons: [
                                                DialogButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      await sendData("C+");
                                                      EasyLoading.showInfo(
                                                          "Kalibrierung starten");
                                                    },
                                                    child: Text("Ja")),
                                                DialogButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("Nein")),
                                              ]).show();
                                        },
                                  child: Text(message == 'Y'
                                      ? "kalibrierend......"
                                      : "Kalibrierung starten"),
                                )),
                            SizedBox(
                              height: 30.0,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    "Das Gerät ist erfolgreich kalibriert auf $date!!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black54,
                                    ),
                                  ),
                                )
                              ],
                            )
                          ],
                        );
                      },
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}

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
  String message = '';
  String date = "Never";

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
        EasyLoading.showInfo("Device Disconnected");
        Timer(Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
              context, DiscoverPage.id, (Route<dynamic> route) => false);
        });
      }
    });
  }

  Future<bool> _onBackPressed() async {
    Navigator.pushReplacementNamed(context, Homepage.id, arguments: widget.device);
    return true;
    // final shouldPop = await showDialog(
    //   context: context,
    //   builder: (context) {
    //     return AlertDialog(
    //       title: Text('Confirm'),
    //       content: Text('Do you want to exit the App'),
    //       actions: <Widget>[
    //         TextButton(
    //           child: Text('No'),
    //           onPressed: () {
    //             Navigator.of(context).pop(false); //Will not exit the App
    //           },
    //         ),
    //         TextButton(
    //           child: Text('Yes'),
    //           onPressed: () {
    //             if (Platform.isAndroid) {
    //               SystemNavigator.pop();
    //             } else {
    //               exit(0);
    //             }
    //           },
    //         )
    //       ],
    //     );
    //   },
    // );
    // return shouldPop ?? false;
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
                    child: Text("Reading Data...."),
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
                            var x = _dataParser(snapshot.data as List<int>);
                            var _data = x.split('+');
                            if (_data[0] == 'CM') {
                              message = _data[1];
                            } else if (_data[0] == 'C') {
                              calibrationFlag = true;
                            }
                          } catch (e) {
                            print(e);
                          }
                        }
                        checkConnectionState();

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 250.0,
                              child: Text(
                                "Calibrate Your Device",
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
                                              (states) => Colors.blueAccent)),
                                  onPressed: () {

                                    Alert(
                                        context: context,
                                        title: "Confirmation",
                                        desc:
                                            "Are you sure to start calibration?",
                                        buttons: [
                                          DialogButton(
                                              onPressed: () async {
                                                Navigator.pop(context);
                                                await sendData("C+");
                                                EasyLoading.showInfo(
                                                    "Calibration Starting");
                                              },
                                              child: Text("Yes")),
                                          DialogButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No")),
                                        ]).show();
                                  },
                                  child: Text(calibrationFlag
                                      ? "Calibration On process"
                                      : "Start Calibration"),
                                )),
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

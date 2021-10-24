import 'dart:async';
import 'dart:convert';

import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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
  late String message;

  void loadingIgnite() async {
    await EasyLoading.showInfo(message);
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
              // writeData('1');
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
        print("disconnected");
        EasyLoading.showInfo("Device Disconnected");
        Timer(Duration(seconds: 2), () {
          Navigator.pushReplacementNamed(context, DiscoverPage.id);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.name),
        backgroundColor: Colors.black38,
      ),
      drawer: DrawerCustom(
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

                      if (snapshot.connectionState == ConnectionState.active) {
                        try {
                          var x = _dataParser(snapshot.data as List<int>);
                          var _data = x.split('+');
                          print(_data);

                          if (_data[0] == 'C') {
                            message = _data[1];
                            loadingIgnite();
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
                            child: GestureDetector(
                              onTapDown: (_) => controller.forward(),
                              onTapUp: (_) async {
                                if (controller.status ==
                                    AnimationStatus.completed) {
                                  controller.value = 0.0;
                                  sendData("C+C");
                                }
                                if (controller.status ==
                                    AnimationStatus.forward) {
                                  controller.reverse();
                                }
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  SizedBox(
                                    height: 120,
                                    width: 120,
                                    child: CircularProgressIndicator(
                                      semanticsLabel: 'Tap here',
                                      strokeWidth: 8.0,
                                      value: controller.value,
                                      backgroundColor: Colors.black38,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.blueGrey),
                                    ),
                                  ),
                                  Text("Tap & Hold",
                                      style: TextStyle(
                                          color: Colors.black54,
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold))
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  ),
                ),
        ),
      ),
    );
  }
}

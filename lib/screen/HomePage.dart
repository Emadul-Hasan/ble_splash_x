import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:ble_splash_x/customComponents/range.dart';
import 'package:ble_splash_x/customComponents/rangeSetText.dart';
import 'package:ble_splash_x/customComponents/streamCard.dart';
import 'package:ble_splash_x/screen/ConfigWifi.dart';
import 'package:ble_splash_x/screen/discover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  static const String id = 'HomePage';

  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as BluetoothDevice;
    print(args);
    return AppHomePage(
      device: args,
    );
  }
}

class AppHomePage extends StatefulWidget {
  const AppHomePage({Key? key, required this.device}) : super(key: key);
  final BluetoothDevice device;
  @override
  _AppHomePageState createState() => _AppHomePageState();
}

class _AppHomePageState extends State<AppHomePage> {
  final String serviceUUId = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUId = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady = false;
  late Stream<List> stream;
  late BluetoothCharacteristic targetCharacteristics;

  String co2 = "400";
  double greenMin = 400;
  double greenMax = 1000;
  double greenMaxRange = 2000;
  double yellowF = 1001.0;
  double yellowMax = 1500;
  double yellowMaxRange = 3000.0;
  double redMin = 1501.0;
  double redMaxRange = 10000;
  double redMax = 5000;
  String greenMaxHint = "1000";
  String yellowMaxHint = "1500";
  int ColorFlag = 0;
  TextEditingController controllerGreen = TextEditingController();
  TextEditingController controllerYellow = TextEditingController();
  TextEditingController controllerRed = TextEditingController();
  String calibrationMode = "Calibrating..";
  int calibrationFlag = 0;
  Color barColor = Colors.green;

  late String state;
  int flag = 0;
  connectToDevice() async {
    if (widget.device == null) {
      _pop();
      return;
    }
    // await widget.device.connect();
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
            });
          }
        });
      }
    });
  }

  _pop() {
    Navigator.of(context).pop(true);
  }

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

  @override
  void initState() {
    super.initState();
    // discoverServices();
    connectToDevice();
  }

  void loadingIgnite() async {
    EasyLoading.instance.maskType = EasyLoadingMaskType.black;
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.dark;
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.circle;
    await EasyLoading.show(status: 'loading...');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        color: Colors.white30,
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  // Do nothing
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
                  backgroundColor: MaterialStateProperty.all(Colors.black26),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, ConfigWiFiPage.id,
                      arguments: widget.device);
                },
                child: Text("Config Wifi"),
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
                      Future.delayed(Duration(seconds: 4), () {
                        sendData("CO2");
                      });

                      var x = _dataParser(snapshot.data as List<int>);
                      var _data = x.split('+');
                      // print(_data);

                      greenMaxHint = double.parse(_data[1]).round().toString();
                      yellowMaxHint = double.parse(_data[2]).round().toString();
                      double value = double.parse(co2);
                      if (_data[0] == "C") {
                        calibrationFlag = 1;
                      } else {
                        co2 = _data[0];
                      }
                      if (value < yellowF) {
                        barColor = Colors.green;
                      } else if (value < redMin) {
                        barColor = Colors.yellow;
                      } else {
                        barColor = Colors.red;
                      }

                      if (greenMax != 1000.0 ||
                          redMax != 5000.0 ||
                          yellowMax != 1500) {
                        ColorFlag = 1;
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
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 20.0,
                        ),
                        StreamCard(
                          barColor: barColor,
                          co2: co2,
                          calibrationFlag: calibrationFlag,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        RangeSetHeading(),
                        SizedBox(
                          height: 20.0,
                        ),
                        Range(
                          Hint: greenMaxHint,
                          min: 400,
                          color: Colors.green,
                          function: (value) {
                            if (value == null) {
                              flag = 0;
                              greenMax = 1000;
                            } else if (double.parse(value) < greenMaxRange) {
                              greenMax = double.parse(value);
                              flag = 1;
                              ColorFlag = 0;
                            } else {
                              EasyLoading.showInfo(
                                  "Expected Value within 400-2000");
                            }
                          },
                          controller: controllerGreen,
                        ),
                        Range(
                          Hint: yellowMaxHint,
                          min: (greenMax > 400 && greenMax < 2000)
                              ? greenMax + 1
                              : yellowF,
                          color: Colors.yellow,
                          function: (value) {
                            if (value == null) {
                              flag = 0;
                              yellowMax = yellowF + 500;
                            } else if (double.parse(value) <
                                yellowMaxRange + 1) {
                              yellowMax = double.parse(value);
                              flag = 1;
                              ColorFlag = 0;
                            } else {
                              EasyLoading.showInfo(
                                  "Expected Value within ${greenMax + 1}-3000");
                            }
                          },
                          controller: controllerYellow,
                        ),
                        Range(
                          Hint: redMax.round().toString(),
                          min: (yellowMax > 1500 && yellowMax < 3001)
                              ? yellowMax + 1
                              : redMin,
                          color: Colors.red,
                          function: (value) {
                            if (value == null) {
                              redMax = yellowMax + 500;

                              flag = 0;
                            } else if (double.parse(value) < redMaxRange + 1) {
                              redMax = double.parse(value);
                              flag = 1;
                              ColorFlag = 0;
                            } else {
                              EasyLoading.showInfo(
                                  "Expected Value within ${yellowMax + 1}-10000");
                            }
                          },
                          controller: controllerRed,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 3.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    String limit = 'R+$greenMax+$yellowMax';
                                    sendData(limit);
                                    ColorFlag = 1;
                                    EasyLoading.showSuccess("Success");
                                  },
                                  child: Text("Save"),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => flag == 0
                                                  ? Colors.black26
                                                  : Colors.blueAccent)),
                                ),
                              ),
                              SizedBox(
                                width: 10.0,
                              ),
                              Expanded(
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => ColorFlag == 0
                                                  ? Colors.black26
                                                  : Colors.blueAccent)),
                                  onPressed: () {
                                    flag = 0;
                                    greenMax = 1000;
                                    yellowF = 1001.0;
                                    yellowMax = 1500;
                                    redMin = 1501.0;
                                    redMaxRange = 10000;
                                    ColorFlag = 0;
                                    EasyLoading.showSuccess("Success");
                                  },
                                  child: Text("Factory Default"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // widget.device.disconnect();
  }
}

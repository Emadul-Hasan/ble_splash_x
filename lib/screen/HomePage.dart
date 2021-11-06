import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:ble_splash_x/customComponents/range.dart';
import 'package:ble_splash_x/customComponents/rangeSetText.dart';
import 'package:ble_splash_x/customComponents/streamCard.dart';
import 'package:ble_splash_x/screen/ConfigWifi.dart';
import 'package:ble_splash_x/screen/discover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'Calibration.dart';

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

  String co2 = "0.0";
  double greenMin = 400;
  double greenMax = 1000;
  double greenMaxRange = 2000;

  double yellowMin = 1001.0;
  double yellowMax = 1500;
  double yellowMaxRange = 3000.0;

  double redMin = 1501.0;
  double redMax = 5000;
  double redMaxRange = 10000;

  String greenMaxHint = "1000";
  String yellowMaxHint = "1500";
  String redMaxHint = "5000";

  int colorFlag = 0;
  late double value;

  TextEditingController controllerGreen = TextEditingController();
  TextEditingController controllerYellow = TextEditingController();
  TextEditingController controllerRed = TextEditingController();

  String calibrationMode = "Calibrating..";
  int calibrationFlag = 0;

  Color barColor = Colors.green;
  int i = 0;

  late String state;
  int flag = 0;

  late var greenCache;
  late var yellowCache;

  int rangeController = 0;

  bool request = true;

  late List<BluetoothService> services;

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

    services = await widget.device.discoverServices();

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
        EasyLoading.showInfo("Device Disconnected");
        Timer(Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
              context, DiscoverPage.id, (Route<dynamic> route) => false);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
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
                  setState(() {
                    request = false;
                  });
                  Timer(Duration(seconds: 3), () async {
                    await sendData("SSID+");
                  });

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
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: Text(
                        "SplashX",
                        style: TextStyle(fontSize: 20.0),
                      ),
                    )
                  ],
                ),
              ),
              ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Configure CO",
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
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
                    ],
                  ),
                ),
                leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          spreadRadius: 2)
                    ],
                  ),
                  child: CircleAvatar(
                    child: Icon(
                      MdiIcons.fire,
                      color: Colors.black,
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
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Configure Wifi",
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          spreadRadius: 2)
                    ],
                  ),
                  child: CircleAvatar(
                    child: Icon(
                      MdiIcons.wifiSync,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                onTap: () {
                  setState(() {
                    request = false;
                  });
                  Navigator.pushNamed(context, ConfigWiFiPage.id,
                      arguments: widget.device);
                },
              ),
              ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Device Calibration",
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          spreadRadius: 2)
                    ],
                  ),
                  child: CircleAvatar(
                    child: Icon(
                      MdiIcons.reload,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                onTap: () {
                  setState(() {
                    request = false;
                  });
                  Navigator.pushReplacementNamed(context, CalibrationPage.id,
                      arguments: widget.device);
                },
              ),
              ListTile(
                title: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Logout",
                        style: TextStyle(color: Colors.black, fontSize: 16.0),
                      ),
                    ],
                  ),
                ),
                leading: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                          blurRadius: 10,
                          color: Colors.black12,
                          spreadRadius: 2)
                    ],
                  ),
                  child: CircleAvatar(
                    child: Icon(
                      MdiIcons.logout,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                onTap: () {
                  widget.device.disconnect();
                  Navigator.pushNamedAndRemoveUntil(context, DiscoverPage.id,
                      (Route<dynamic> route) => false);
                },
              ),
            ],
          ),
        ),
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
                      while (rangeController < 15) {
                        Timer(Duration(seconds: 2), () async {
                          await sendData("RR+");
                        });
                        rangeController++;
                      }
                      if (request) {
                        Timer(Duration(seconds: 2), () async {
                          await sendData("CO2+");
                        });
                      }

                      var x = _dataParser(snapshot.data as List<int>);
                      var _data = x.split('+');
                      print(_data);

                      if (_data[0] == "C") {
                        calibrationFlag = 1;
                      } else if (_data[0] == "RR") {
                        print("Got Data");
                        greenCache = double.parse(_data[1]);
                        yellowCache = double.parse(_data[2]);
                        yellowMin = greenCache + 1;
                        greenMax = greenCache;
                        yellowMax = yellowCache;
                        redMin = yellowCache + 1;
                        greenMaxHint =
                            double.parse(_data[1]).round().toString();
                        yellowMaxHint =
                            double.parse(_data[2]).round().toString();
                      } else if (double.tryParse(_data[0]) != null) {
                        co2 = _data[0];
                        value = double.parse(co2);
                      }
                      if (value < yellowMin) {
                        barColor = Colors.green;
                      } else if (value < redMin) {
                        barColor = Colors.yellow;
                      } else {
                        barColor = Colors.red;
                      }

                      if (greenMax != 1000.0 ||
                          redMax != 5000.0 ||
                          yellowMax != 1500) {
                        colorFlag = 1;
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
                            if (value == "") {
                              flag = 0;
                              greenMax = greenCache;
                            } else if (double.parse(value) < greenMaxRange) {
                              greenMax = double.parse(value);
                              flag = 1;
                              colorFlag = 0;
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
                              : yellowMin,
                          color: Colors.yellow,
                          function: (value) {
                            if (value == '') {
                              flag = 0;
                              greenMax = greenCache;
                            } else if (double.parse(value) <
                                yellowMaxRange + 1) {
                              yellowMax = double.parse(value);
                              flag = 1;
                              colorFlag = 0;
                            } else {
                              EasyLoading.showInfo(
                                  "Expected Value within ${greenMax.round() + 1}-3000");
                            }
                          },
                          controller: controllerYellow,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.red,
                            ),
                            SizedBox(
                              width: 10.0,
                            ),
                            Container(
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                child: Text("Value"),
                                decoration: BoxDecoration(
                                  color: Color(0xFFEDEDED),
                                  border: Border.all(
                                    color: Color(0xFFEDEDED),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            Container(
                                padding: EdgeInsets.all(10.0),
                                child: Text(
                                  '-',
                                  style: TextStyle(fontSize: 20.0),
                                )),
                            Container(
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                child: Text("10000"),
                                decoration: BoxDecoration(
                                  color: Color(0xFFEDEDED),
                                  border: Border.all(
                                    color: Color(0xFFEDEDED),
                                  ),
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                          ],
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
                                    if (greenMax < greenMin) {
                                      EasyLoading.showInfo(
                                          "Green maximum Value cannot be lower than minimum");
                                      greenMax = greenCache;
                                      yellowMax = yellowCache;
                                      controllerGreen.clear();
                                      controllerYellow.clear();
                                      controllerRed.clear();
                                    } else if (yellowMax < yellowMin) {
                                      EasyLoading.showInfo(
                                          "Yellow maximum Value cannot be lower than minimum");
                                      greenMax = greenCache;
                                      yellowMax = yellowCache;
                                      controllerGreen.clear();
                                      controllerYellow.clear();
                                      controllerRed.clear();
                                    } else if (redMax < redMin) {
                                      EasyLoading.showInfo(
                                          "Red maximum Value cannot be lower than minimum");
                                      greenMax = greenCache;
                                      yellowMax = yellowCache;
                                      controllerGreen.clear();
                                      controllerYellow.clear();
                                      controllerRed.clear();
                                    } else {
                                      Alert(
                                          closeFunction: () {
                                            Navigator.pop(context);
                                            greenMax = greenCache;
                                            yellowMax = yellowCache;
                                            controllerRed.clear();
                                            controllerYellow.clear();
                                            controllerGreen.clear();
                                          },
                                          context: context,
                                          title: "Confirmation",
                                          desc:
                                              "Are you sure to change the value to\n Green:${greenMin.round()} - ${greenMax.round()}\nYellow:${greenMax.round() + 1}-${yellowMax.round()}\nRed:${yellowMax.round() + 1} - ${redMax.round()}",
                                          buttons: [
                                            DialogButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  String limit =
                                                      'R+$greenMax+$yellowMax+';
                                                  sendData(limit);
                                                  colorFlag = 1;

                                                  EasyLoading.showSuccess(
                                                      "Success");
                                                },
                                                child: Text("Yes")),
                                            DialogButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  greenMax = greenCache;
                                                  yellowMax = yellowCache;
                                                  controllerRed.clear();
                                                  controllerYellow.clear();
                                                  controllerGreen.clear();
                                                },
                                                child: Text("No")),
                                          ]).show();
                                    }
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
                                              (states) => colorFlag == 0
                                                  ? Colors.black26
                                                  : Colors.blueAccent)),
                                  onPressed: () {
                                    Alert(
                                        context: context,
                                        title: "Confirmation",
                                        desc:
                                            "Are you sure to change the value to default value",
                                        buttons: [
                                          DialogButton(
                                              onPressed: () {},
                                              child: Text("Yes")),
                                          DialogButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text("No")),
                                        ]).show();
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
  }
}

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

String greenValueCache = "1000";
String yellowValueCache = "1500";

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
  FocusNode focusMessage = FocusNode();
  final String serviceUUId = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  final String characteristicUUId = "beb5483e-36e1-4688-b7f5-ea07361b26a8";
  bool isReady = false;
  late Stream<List> stream;
  late BluetoothCharacteristic targetCharacteristics;

  String co2 = "0.0";
  double greenMin = 400;
  double greenMax = 2000;
  double greenMaxRange = 2000;
  int greenCurrentValue = 0;

  double yellowMin = 1001.0;
  double yellowMax = 3000;
  double yellowMaxRange = 3000.0;
  int yellowMaxCurrentValue = 0;
  double redMin = 1501.0;

  bool saveButtonColorFlag = false;
  bool saveButtonColorFlagForYellow = false;
  bool factoryButtonColorFlag = false;
  late double value;

  TextEditingController controllerGreen = TextEditingController();
  TextEditingController controllerYellow = TextEditingController();

  String calibrationMode = "Calibrating..";
  bool calibrationFlag = false;

  Color barColor = Colors.green;
  int i = 0;

  late String state;
  int flag = 0;

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
                        calibrationFlag = true;
                      } else if (_data[0] == "RR") {
                        // Got Range value
                        greenValueCache = _data[1];
                        yellowValueCache = _data[2];
                        greenMax = double.parse(_data[1]);
                        yellowMin = double.parse(_data[1]) + 1;
                        yellowMax = double.parse(_data[2]);
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
                      //
                      if (greenMax != 1000.0 || yellowMax != 1500) {
                        factoryButtonColorFlag = true;
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
                        //################## Green Container ####################
                        RangeContainer(
                          Hint: greenValueCache,
                          min: 400,
                          color: Colors.green,
                          function: (value) {
                            if (double.parse(value) < greenMaxRange + 1 &&
                                double.parse(value) > greenMin) {
                              greenCurrentValue = 0;
                              greenMax = double.parse(value);
                            } else if (double.parse(value) > greenMaxRange) {
                              greenCurrentValue = 0;
                              EasyLoading.showInfo(
                                  "Green Value expected 400-2000");
                            } else if (double.parse(value) > 9.0 &&
                                double.parse(value) <= 400) {
                              greenCurrentValue = 1;
                            } else {
                              greenCurrentValue = 0;
                              greenMax = double.parse(greenValueCache);
                            }

                            saveButtonColorFlag = true;
                          },
                          controller: controllerGreen,
                        ),
                        // ########## Yellow Container #############
                        RangeContainer(
                          Hint: yellowValueCache,
                          min: (greenMax > 400 && greenMax < 2001)
                              ? greenMax + 1
                              : yellowMin,
                          color: Colors.yellow,
                          function: (value) {
                            if (double.parse(value) > greenMax + 1 &&
                                double.parse(value) < 3001) {
                              yellowMaxCurrentValue = 0;
                              yellowMax = double.parse(value);
                              redMin = yellowMax + 1;
                            } else if (double.parse(value) > 3000) {
                              yellowMaxCurrentValue = 0;
                              EasyLoading.showInfo(
                                  "Green Value expected ${greenMax.round() + 1}-3000");
                            } else if (double.parse(value) > 9.0 &&
                                double.parse(value) <= greenMax + 1) {
                              yellowMaxCurrentValue = 1;
                            } else {
                              yellowMaxCurrentValue = 0;
                              yellowMax = double.parse(yellowValueCache);
                              redMin = yellowMax + 1;
                            }
                            saveButtonColorFlag = true;
                          },
                          controller: controllerYellow,
                        ),
                        SizedBox(
                          height: 20.0,
                        ),
                        // ######################### RED CONTAINER ###############
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
                                child: Text(redMin.round().toString()),
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
                                width: 110.0,
                                height: 40.0,
                                padding: EdgeInsets.only(
                                    left: 20.0,
                                    right: 20.0,
                                    top: 10.0,
                                    bottom: 10.0),
                                child: Text(
                                  '10000',
                                  textAlign: TextAlign.center,
                                ),
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
                                  onPressed: saveButtonColorFlag
                                      ? () {
                                          print(
                                              "Yellow Current Value=$yellowMaxCurrentValue**");
                                          if (greenCurrentValue == 1) {
                                            EasyLoading.showInfo(
                                                "Green Maximum value cannot be lower or equal to minimum value");
                                          } else if (yellowMaxCurrentValue ==
                                              1) {
                                            EasyLoading.showInfo(
                                                "Yellow Maximum value cannot be lower or equal to minimum value");
                                          } else if (greenCurrentValue == 0 &&
                                              yellowMaxCurrentValue == 0) {
                                            Alert(
                                                closeFunction: () {
                                                  Navigator.pop(context);
                                                  redMin = double.parse(
                                                          yellowValueCache) +
                                                      1;
                                                },
                                                context: context,
                                                title: "Confirmation",
                                                desc:
                                                    "Are you sure to change the value to\n Green:${greenMin.round()} - ${greenMax.round()}\nYellow:${greenMax.round() + 1}-${yellowMax.round()}\nRed:${yellowMax.round() + 1}- 10000",
                                                buttons: [
                                                  DialogButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        print(greenMax);
                                                        print(yellowMax);
                                                        String limit =
                                                            'R+$greenMax+$yellowMax+';
                                                        // sendData(limit);

                                                        EasyLoading.showSuccess(
                                                            "Success");
                                                      },
                                                      child: Text("Yes")),
                                                  DialogButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                        // controllerYellow
                                                        //     .clear();
                                                        // controllerGreen.clear();
                                                        // redMin = double.parse(
                                                        //         yellowValueCache) +
                                                        //     1;
                                                      },
                                                      child: Text("No")),
                                                ]).show();
                                          }
                                        }
                                      // else {
                                      //   EasyLoading.showInfo(
                                      //       "Maximum Value Cannot be Lower Than Minimum");
                                      // }

                                      : () {},
                                  child: Text("Save"),
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty
                                          .resolveWith((states) =>
                                              (saveButtonColorFlag ||
                                                      saveButtonColorFlagForYellow)
                                                  ? Colors.blueAccent
                                                  : Colors.black26)),
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
                                              (states) =>
                                                  !factoryButtonColorFlag
                                                      ? Colors.black26
                                                      : Colors.blueAccent)),
                                  onPressed: factoryButtonColorFlag
                                      ? () {
                                          Alert(
                                              context: context,
                                              title: "Confirmation",
                                              desc:
                                                  "Are you sure to change the value to default value",
                                              buttons: [
                                                DialogButton(
                                                    onPressed: () async {
                                                      Navigator.pop(context);
                                                      factoryButtonColorFlag =
                                                          false;
                                                      // await sendData(
                                                      //     "R+1000+1500");
                                                      greenValueCache = '1000';
                                                      yellowValueCache = '1500';
                                                      greenMax = 1000.0;
                                                      yellowMax = 1500.0;
                                                      yellowMin = 10001.0;
                                                      redMin = 1501.0;
                                                      controllerGreen.clear();
                                                      controllerYellow.clear();
                                                    },
                                                    child: Text("Yes")),
                                                DialogButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: Text("No")),
                                              ]).show();
                                        }
                                      : () {},
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

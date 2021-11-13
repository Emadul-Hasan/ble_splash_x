import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:ble_splash_x/customComponents/range.dart';
import 'package:ble_splash_x/customComponents/rangeSetText.dart';
import 'package:ble_splash_x/customComponents/streamCard.dart';
import 'package:ble_splash_x/screen/ConfigWifi.dart';
import 'package:ble_splash_x/screen/discover.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  String calibrationMode = "kalibrierend...";
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
        EasyLoading.showInfo("CO₂ - Ampel entkoppelt!");
        Timer(Duration(seconds: 2), () {
          Navigator.pushNamedAndRemoveUntil(
              context, DiscoverPage.id, (Route<dynamic> route) => false);
        });
      }
    });
  }

  Future<bool> _onBackPressed() async {
    // return true;
    final shouldPop = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text(
            'App verlassen?',
            style: TextStyle(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Ja'),
              onPressed: () {
                if (Platform.isAndroid) {
                  widget.device.disconnect();
                  SystemNavigator.pop();
                } else {
                  widget.device.disconnect();
                  exit(0);
                }
              },
            ),
            TextButton(
              child: Text('Nein'),
              onPressed: () {
                Navigator.of(context).pop(false); //Will not exit the App
              },
            )
          ],
        );
      },
    );
    return shouldPop ?? false;
  }

  @override
  void initState() {
    super.initState();
    connectToDevice();
  }

  void loadingIgnite() async {
    EasyLoading.instance.maskType = EasyLoadingMaskType.black;
    EasyLoading.instance.loadingStyle = EasyLoadingStyle.custom;
    EasyLoading.instance.indicatorType = EasyLoadingIndicatorType.circle;
    EasyLoading.instance.maskColor = Colors.blue;
    await EasyLoading.show(status: 'Laden...');
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
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
                    "Konfig. CO2 Werte",
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
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
                  child: Text(
                    "Konfig. Wi-Fi",
                    style: TextStyle(fontSize: 14.0),
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
        drawer: Drawer(
          child: Container(
            child: ListView(
              children: [
                DrawerHeader(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 60.0,
                      ),
                      Center(
                        child: Text(
                          "SPLASH X",
                          style: TextStyle(fontSize: 20.0),
                        ),
                      )
                    ],
                  ),
                ),
                ListTile(
                  title: Text(
                    "CO₂-Werte konfigurieren",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                        color: Colors.blue,
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
                  title: Text(
                    "Wi-Fi konfigurieren",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                        color: Colors.blue,
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
                  title: Text(
                    "Gerät kalibrieren",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                        color: Colors.blue,
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
                  title: Text(
                    "Abmelden",
                    style: TextStyle(color: Colors.black, fontSize: 16.0),
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
                        color: Colors.blue,
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
                child: Text("Daten Lesen...."),
              )
            : Container(
                child: StreamBuilder<List>(
                  stream: stream,
                  builder:
                      (BuildContext context, AsyncSnapshot<List> snapshot) {
                    if (snapshot.hasError) {
                      Timer(Duration(seconds: 30), () {
                        // print('done');
                        // just Wait
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

                        if (_data[0] == "C") {
                          calibrationFlag = true;
                        } else if (_data[0] == "RR") {
                          // Got Range value
                          greenValueCache = _data[1];
                          yellowValueCache = _data[2];
                          greenMax = double.parse(_data[1]);
                          yellowMin = double.parse(_data[1]) + 1;
                          yellowMax = double.parse(_data[2]);
                          redMin = yellowMax + 1;
                        } else if (double.tryParse(_data[0]) != null) {
                          co2 = _data[0];
                          value = double.parse(co2);
                        }
                        if (value < greenMax + 1) {
                          barColor = Colors.green;
                        } else if (value <= yellowMax && value > greenMax) {
                          barColor = Colors.yellow;
                        } else {
                          barColor = Colors.red;
                        }
                        //
                        if (greenMax != 1000.0 || yellowMax != 1500) {
                          factoryButtonColorFlag = true;
                        } else {
                          factoryButtonColorFlag = false;
                        }
                      } catch (e) {
                        // DO nothing just ignore & if you want any debug then just print error
                        // print(e);
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
                            hint: greenValueCache,
                            min: 400,
                            color: Colors.green,
                            function: (value) {
                              if (double.parse(value) < greenMaxRange + 1 &&
                                  double.parse(value) > greenMin) {
                                greenCurrentValue = 0;
                                greenMax = double.parse(value);
                              } else if (double.parse(value) > greenMaxRange) {
                                greenCurrentValue = 0;
                                // Green Vlaue upper limit notice
                                EasyLoading.showInfo(
                                    "Der Höchstwert für grünes Licht kann nicht größer sein als der Höchstwert für gelbes Licht. Bitte geben Sie einen größeren Maximalwert für gelbes Licht ein");

                                greenMax = double.parse(greenValueCache);
                                controllerGreen.clear();
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
                            hint: yellowValueCache,
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
                                controllerYellow.clear();
                                yellowMax = double.parse(yellowValueCache);
                                //Yello Value upper limit notice
                                EasyLoading.showInfo(
                                    "Der Höchstwert für grünes Licht kann nicht größer sein als der Höchstwert für gelbes Licht. Bitte geben Sie einen größeren Maximalwert für gelbes Licht ein");
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
                                  child: Text(
                                    redMin.round().toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.start,
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
                                            if (greenCurrentValue == 1) {
                                              EasyLoading.showInfo(
                                                  "Der Höchstwert für grünes Licht kann nicht größer sein als der Höchstwert für gelbes Licht. Bitte geben Sie einen größeren Maximalwert für gelbes Licht ein");
                                            } else if (yellowMaxCurrentValue ==
                                                1) {
                                              EasyLoading.showInfo(
                                                  "Der Höchstwert für grünes Licht kann nicht größer sein als der Höchstwert für gelbes Licht. Bitte geben Sie einen größeren Maximalwert für gelbes Licht ein");
                                            } else if (greenCurrentValue == 0 &&
                                                yellowMaxCurrentValue == 0) {
                                              if (greenMax.round() + 1 >
                                                  yellowMax) {
                                                EasyLoading.showInfo(
                                                    "Der Höchstwert für grünes Licht kann nicht größer sein als der Höchstwert für gelbes Licht. Bitte geben Sie einen größeren Maximalwert für gelbes Licht ein");
                                              } else {
                                                Alert(
                                                    closeFunction: () {
                                                      Navigator.pop(context);
                                                      redMin = double.parse(
                                                              yellowValueCache) +
                                                          1;
                                                    },
                                                    context: context,
                                                    title:
                                                        "Sind Sie sicher, dass Sie die folgenden CO2-Werte einstellen\?",
                                                    style: AlertStyle(
                                                        titleTextAlign:
                                                            TextAlign.start,
                                                        descStyle: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal),
                                                        titleStyle: TextStyle(
                                                            fontSize: 16.0,
                                                            fontWeight:
                                                                FontWeight
                                                                    .normal)),
                                                    desc:
                                                        "Grün: ${greenMin.round()} - ${greenMax.round()}\nGelb: ${greenMax.round() + 1}-${yellowMax.round()}\nRot: ${yellowMax.round() + 1}- 10000",
                                                    buttons: [
                                                      DialogButton(
                                                          onPressed: () async {
                                                            Navigator.pop(
                                                                context);

                                                            String limit =
                                                                'R+$greenMax+$yellowMax+';
                                                            await sendData(
                                                                limit);

                                                            EasyLoading.showSuccess(
                                                                "Erfolgreich!");
                                                            saveButtonColorFlag =
                                                                false;
                                                          },
                                                          child: Text("Ja")),
                                                      DialogButton(
                                                          onPressed: () {
                                                            Navigator.pop(
                                                                context);
                                                          },
                                                          child: Text("Nein")),
                                                    ]).show();
                                              }
                                            }
                                          }
                                        : () {},
                                    child: Text(
                                      "Speichern",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
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
                                //todo: size adjust
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
                                                title:
                                                    "Möchten Sie die CO2-Werte auf die Werkseinstellung zurücksetzen?",
                                                style: AlertStyle(
                                                    titleTextAlign:
                                                        TextAlign.justify,
                                                    titleStyle: TextStyle(
                                                        fontSize: 15.0)),
                                                buttons: [
                                                  DialogButton(
                                                      onPressed: () async {
                                                        Navigator.pop(context);
                                                        controllerGreen.clear();
                                                        controllerYellow
                                                            .clear();
                                                        factoryButtonColorFlag =
                                                            false;
                                                        await sendData(
                                                            "R+1000+1500");
                                                        greenValueCache =
                                                            '1000';
                                                        yellowValueCache =
                                                            '1500';

                                                        greenMax = 1000.0;
                                                        yellowMax = 1500.0;
                                                        yellowMin = 10001.0;
                                                        redMin = 1501.0;
                                                      },
                                                      child: Text("Ja")),
                                                  DialogButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child: Text("Nein")),
                                                ]).show();
                                          }
                                        : () {},
                                    child: Text(
                                      "Werkseinstellung",
                                      style: TextStyle(fontSize: 14.0),
                                    ),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:ble_splash_x/screen/ConfigWifi.dart';
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

  String co2 = "000.00";
  double greenMin = 400;
  double greenMax = 1000.0;
  double greenMaxRange = 2000.0;
  double yellowF = 1001.0;
  double yellowMax = 1500;
  double yellowMaxRange = 3000.0;
  double redMin = 1501.0;
  double redMaxRange = 10000;
  double redMax = 10000;

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
    if (isReady == false) {
      setState(() {
        loadingIgnite();
      });
    } else {
      setState(() {
        EasyLoading.dismiss();
      });
    }
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
                  backgroundColor: MaterialStateProperty.all(Colors.white38),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, ConfigWiFiPage.id,
                      arguments: widget.device);
                },
                child: Text("Conf.Wifi"),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text(widget.device.name),
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
                      var x = _dataParser(snapshot.data as List<int>);
                      var _data = x.split('+');
                      print(_data);
                      setState(() {
                        co2 = _data[0];
                        double value = double.parse(co2);
                        if (value < yellowF) {
                          barColor = Colors.green;
                        } else if (value < redMin) {
                          barColor = Colors.yellow;
                        } else {
                          barColor = Colors.red;
                        }
                      });
                    } catch (e) {
                      print(e);
                    }
                  } else {
                    isReady = false;
                    widget.device.connect(
                        timeout: Duration(seconds: 6), autoConnect: true);
                    discoverServices();
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 10.0,
                        width: double.infinity,
                      ),
                      Expanded(
                        flex: 4,
                        child: Card(
                          child: Container(
                            width: 300.0,
                            padding: EdgeInsets.only(
                                top: 30.0, left: 20.0, right: 20.0),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: Colors.green,
                                  width: 3.0,
                                ),
                              ),
                            ),
                            child: Column(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: "Live CO",
                                        style: TextStyle(
                                          fontSize: 28.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        )),
                                    TextSpan(
                                      text: '2',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 22.0,
                                        fontWeight: FontWeight.w500,
                                        fontFeatures: [
                                          FontFeature.subscripts(),
                                        ],
                                      ),
                                    ),
                                    TextSpan(
                                        text: ' Value',
                                        style: TextStyle(
                                          fontSize: 28.0,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.black,
                                        ))
                                  ]),
                                ),
                                SizedBox(height: 15.0),
                                RichText(
                                  text: TextSpan(children: [
                                    TextSpan(
                                        text: co2,
                                        style: TextStyle(
                                          fontSize: 40.0,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400,
                                        )),
                                    TextSpan(
                                      text: 'ppm',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w500,
                                        fontFeatures: [
                                          FontFeature.subscripts(),
                                        ],
                                      ),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.only(
                                  top: 10.0,
                                  bottom: 10.0,
                                  left: 70.0,
                                  right: 70.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color: Colors.black38,
                                    width: 3.0,
                                  ),
                                ),
                              ),
                              child: RichText(
                                text: TextSpan(children: [
                                  TextSpan(
                                      text: "Set CO",
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      )),
                                  TextSpan(
                                    text: '2',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.w500,
                                      fontFeatures: [
                                        FontFeature.subscripts(),
                                      ],
                                    ),
                                  ),
                                  TextSpan(
                                      text: ' ranges',
                                      style: TextStyle(
                                        fontSize: 24.0,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ))
                                ]),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Green .................
                            Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.green,
                                  ),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 12.0,
                                          disabledThumbRadius: 12.0),
                                      overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 12.0),
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white38,
                                      disabledThumbColor: Colors.white,
                                      // disabledActiveTickMarkColor: Colors.green,
                                      // disabledActiveTrackColor: Colors.green,
                                      activeTrackColor: Colors.green,
                                      // inactiveTrackColor: Colors.blue,
                                      trackHeight: 3.0,
                                      showValueIndicator:
                                          ShowValueIndicator.always,
                                      // valueIndicatorShape: SliderComponentShape.noThumb,
                                      valueIndicatorColor: Colors.green,
                                    ),
                                    child: Slider(
                                      divisions: 1600,
                                      label: greenMax.toString(),
                                      autofocus: true,
                                      value: greenMax,
                                      // activeColor: Colors.green,
                                      onChanged: (value) {
                                        setState(() {
                                          flag = 1;
                                          greenMax = value;
                                        });
                                      },
                                      min: 400.0,
                                      max: greenMaxRange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 0.0,
                                      width: 0.0,
                                    ),
                                    flex: 2,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '400',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      greenMaxRange.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Yellow ...........
                            Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.yellow,
                                  ),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 12.0,
                                          disabledThumbRadius: 12.0),
                                      overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 12.0),
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white38,
                                      disabledThumbColor: Colors.white,
                                      // disabledActiveTickMarkColor: Colors.green,
                                      // disabledActiveTrackColor: Colors.green,
                                      activeTrackColor: Colors.yellow,
                                      // inactiveTrackColor: Colors.blue,
                                      trackHeight: 3.0,
                                      showValueIndicator:
                                          ShowValueIndicator.always,
                                      // valueIndicatorShape: SliderComponentShape.noThumb,
                                      valueIndicatorColor: Colors.yellow,
                                      // valueIndicatorTextStyle: TextStyle(color: Colors.white)
                                    ),
                                    child: Slider(
                                      divisions: 3000 - yellowF.round(),
                                      label: yellowMax.toString(),
                                      autofocus: true,
                                      value: yellowMax,
                                      // activeColor: Colors.green,
                                      onChanged: (value) {
                                        setState(() {
                                          flag = 1;
                                          yellowMax = value;
                                        });
                                      },
                                      min: yellowF,
                                      max: yellowMaxRange,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 0.0,
                                      width: 0.0,
                                    ),
                                    flex: 2,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      "$yellowF",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      yellowMaxRange.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            //Red
                            Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.red,
                                  ),
                                  SliderTheme(
                                    data: SliderThemeData(
                                      thumbShape: RoundSliderThumbShape(
                                          enabledThumbRadius: 12.0,
                                          disabledThumbRadius: 12.0),
                                      overlayShape: RoundSliderOverlayShape(
                                          overlayRadius: 12.0),
                                      thumbColor: Colors.white,
                                      overlayColor: Colors.white38,
                                      disabledThumbColor: Colors.white,
                                      // disabledActiveTickMarkColor: Colors.green,
                                      // disabledActiveTrackColor: Colors.green,
                                      activeTrackColor: Colors.red,
                                      // inactiveTrackColor: Colors.blue,
                                      trackHeight: 3.0,
                                      showValueIndicator:
                                          ShowValueIndicator.always,
                                      // valueIndicatorShape: SliderComponentShape.noThumb,
                                      valueIndicatorColor: Colors.red,
                                    ),
                                    child: Slider(
                                      divisions: 10000 - redMin.round(),
                                      label: redMax.toString(),
                                      autofocus: true,
                                      value: redMax,
                                      // activeColor: Colors.green,
                                      onChanged: (value) {
                                        setState(() {
                                          flag = 1;
                                          redMax = value;
                                        });
                                      },
                                      min: redMin,
                                      max: redMaxRange,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: SizedBox(
                                      height: 0.0,
                                      width: 0.0,
                                    ),
                                    flex: 2,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      '$redMin',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      redMaxRange.toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.0, vertical: 3.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      yellowF = greenMax + 1;
                                      redMin = yellowMax + 1;
                                      String limit = 'R+$greenMax+$yellowMax';
                                      sendData(limit);
                                    });
                                  },
                                  child: Text("Save"),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.resolveWith(
                                              (states) => flag == 0
                                                  ? Colors.black12
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
                                              (states) => flag == 0
                                                  ? Colors.black12
                                                  : Colors.blueAccent)),
                                  onPressed: () {
                                    flag = 0;
                                    greenMax = 1000.0;
                                    yellowF = 1001.0;
                                    yellowMax = 1500;
                                    redMin = 1501.0;
                                    redMaxRange = 10000;
                                  },
                                  child: Text("Factory Default"),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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

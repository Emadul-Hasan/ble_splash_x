import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:ble_splash_x/screen/ConfigWifi.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class Homepage extends StatelessWidget {
  const Homepage({Key? key}) : super(key: key);

  static const String id = 'HomePage';
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
  bool isReady = true;
  late Stream<List> stream;
  late BluetoothCharacteristic targetCharacteristics;

  late String state;

  connectToDevice() async {
    if (widget.device == null) {
      _pop();
      return;
    }

    new Timer(const Duration(seconds: 15), () {
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
    super.initState();
    discoverServices();
    // connectToDevice();
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
                  backgroundColor: MaterialStateProperty.all(Colors.white38),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, ConfigWiFiPage.id,
                      arguments: 'Device');
                },
                child: Text("Conf.Wifi"),
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        title: Text('SplashX'),
      ),
      drawer: DrawerCustom(),
      body: Container(
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
                // print(.runtimeType);
                List<int> c = snapshot.data as List<int>;

                var x = _dataParser(snapshot.data as List<int>);
                print(x);
              } catch (e) {
                print(e);
              }
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
                      padding:
                          EdgeInsets.only(top: 30.0, left: 20.0, right: 20.0),
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
                                  text: "700",
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
                            top: 10.0, bottom: 10.0, left: 70.0, right: 70.0),
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
                                showValueIndicator: ShowValueIndicator.always,
                                // valueIndicatorShape: SliderComponentShape.noThumb,
                                valueIndicatorColor: Colors.green,
                              ),
                              child: Slider(
                                label: "770.0",
                                autofocus: true,
                                value: 770.0,
                                // activeColor: Colors.green,
                                onChanged: (value) {
                                  // setState(() {
                                  //   delay = value.toInt();
                                  //   sendData(delay.toString());
                                  //   print(delay);
                                  // });
                                },
                                min: 400.0,
                                max: 2000.0,
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
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '2000',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                showValueIndicator: ShowValueIndicator.always,
                                // valueIndicatorShape: SliderComponentShape.noThumb,
                                valueIndicatorColor: Colors.yellow,
                                // valueIndicatorTextStyle: TextStyle(color: Colors.white)
                              ),
                              child: Slider(
                                label: "1300.0",
                                autofocus: true,
                                value: 1300.0,
                                // activeColor: Colors.green,
                                onChanged: (value) {
                                  // setState(() {
                                  //   delay = value.toInt();
                                  //   sendData(delay.toString());
                                  //   print(delay);
                                  // });
                                },
                                min: 1001.0,
                                max: 3000.0,
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
                                '1001',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '3000',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                          ],
                        ),
                      ),
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
                                showValueIndicator: ShowValueIndicator.always,
                                // valueIndicatorShape: SliderComponentShape.noThumb,
                                valueIndicatorColor: Colors.red,
                              ),
                              child: Slider(
                                label: "2000.0",
                                autofocus: true,
                                value: 2000.0,
                                // activeColor: Colors.green,
                                onChanged: (value) {
                                  // setState(() {
                                  //   delay = value.toInt();
                                  //   sendData(delay.toString());
                                  //   print(delay);
                                  // });
                                },
                                min: 1501.0,
                                max: 2500.0,
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
                                '1501',
                                style: TextStyle(fontWeight: FontWeight.w400),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                '10000',
                                style: TextStyle(fontWeight: FontWeight.w400),
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
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 3.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              //
                            },
                            child: Text("Save"),
                          ),
                        ),
                        SizedBox(
                          width: 10.0,
                        ),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              //
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
            //   Container(
            //   child: snapshot.hasData == null
            //       ? Center(
            //           child: CircularProgressIndicator(
            //             backgroundColor: Colors.lightBlueAccent,
            //           ),
            //         )
            //       : Column(
            //           children: [],
            //         ),
            // );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    widget.device.disconnect();
  }
}

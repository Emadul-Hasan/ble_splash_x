import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:flutter/material.dart';

class CalibrationPage extends StatefulWidget {
  static const id = "ClockOut";
  @override
  _CalibrationPageState createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage>
    with SingleTickerProviderStateMixin {
  var controller;

  @override
  void initState() {
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
    controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  List<String> monthString = [
    'Month',
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Calibrate Device"),
        backgroundColor: Colors.black38,
      ),
      drawer: DrawerCustom(),
      body: Center(
        child: Container(
          child: Column(
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
                    if (controller.status == AnimationStatus.completed) {
                      controller.value = 0.0;
                    }
                    if (controller.status == AnimationStatus.forward) {
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
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.blueGrey),
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
          ),
        ),
      ),
    );
  }
}

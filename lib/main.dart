import 'package:ble_splash_x/screen/HomePage.dart';
import 'package:ble_splash_x/screen/discover.dart';
import 'package:ble_splash_x/screen/splash.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: SplashScreen.id,
      routes: {
        SplashScreen.id: (context) => SplashScreen(),
        DiscoverPage.id: (context) => DiscoverPage(),
        Homepage.id: (context) => Homepage(),
        // ClockOut.id: (context) => ClockOut(),
        // DashBoard.id: (context) => DashBoard(),
      },
    );
  }
}

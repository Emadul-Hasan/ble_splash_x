import 'dart:ui';

import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static const String id = 'HomePage';
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SplashX'),
      ),
      drawer: Drawer(
        child: Container(
          child: ListView(
            children: [
              DrawerHeader(
                child: Column(
                  children: [
                    Image.asset(
                      "images/credologo.png",
                      height: 90.0,
                      width: 90.0,
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      "SplashX",
                      style: TextStyle(fontSize: 20.0),
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
                      Icons.assistant_navigation,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, HomePage.id);
                },
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
                      Icons.assistant_navigation,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, HomePage.id);
                },
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
                      Icons.assistant_navigation,
                      color: Colors.black,
                      size: 25.0,
                    ),
                    backgroundColor: Colors.white,
                  ),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(context, HomePage.id);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

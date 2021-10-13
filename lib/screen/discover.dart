import 'dart:ui';

import 'package:flutter/material.dart';

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  @override
  _DiscoverPageState createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  List device = [
    'Device1',
    'Device2',
    'Device3',
    'Device4',
    'Device5',
    'Device6',
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 110.0,
            ),
            Text(
              "SplashX",
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
            ),
            SizedBox(
              height: 10.0,
            ),
            ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                Icons.bluetooth,
                size: 40.0,
                color: Colors.black,
              ),
              title: Text(
                "Switch on Bluetooth",
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            ListTile(
              minLeadingWidth: 2.0,
              horizontalTitleGap: 5.0,
              leading: Icon(
                Icons.lightbulb_outlined,
                size: 40.0,
                color: Colors.black,
              ),
              title: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "Hold the push button on the CO",
                      style: TextStyle(fontSize: 16.0, color: Colors.black)),
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
                  TextSpan(
                      text: ' button for 5 seconds',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ))
                ]),
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            ElevatedButton(
                onPressed: () {
                  //Do Scan here
                },
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(text: "Scan CO", style: TextStyle(fontSize: 14.0)),
                    TextSpan(
                      text: '2',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.0,
                        fontFeatures: [
                          FontFeature.subscripts(),
                        ],
                      ),
                    ),
                    TextSpan(text: ' Device', style: TextStyle(fontSize: 14.0))
                  ]),
                )),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.only(top: 30.0, left: 30.0, bottom: 0.0),
                  child: Text(
                    'Available devices',
                    style: TextStyle(fontSize: 15.0),
                  ),
                ),
              ],
            ),
            Expanded(
              child: ListView.builder(
                itemBuilder: (BuildContext context, int index) {
                  return Container(
                    margin: EdgeInsets.only(left: 5.0, right: 5.0),
                    child: ListTile(
                      onTap: () {
                        // Navigator.pushNamed(context, RemainingSubTask.id,
                        //     arguments: listOfTask[index].id);
                      },
                      minLeadingWidth: 2.0,
                      horizontalTitleGap: 5.0,
                      leading: Icon(
                        Icons.bluetooth,
                        color: Colors.black,
                      ),
                      title: Text(
                        device[index],
                        style: TextStyle(fontSize: 15.0, color: Colors.black),
                      ),
                    ),
                  );
                },
                itemCount: device.length,
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "CO",
                      style: TextStyle(fontSize: 15.0, color: Colors.black)),
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
                  TextSpan(
                      text: ' device name starts with sp',
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.black,
                      ))
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

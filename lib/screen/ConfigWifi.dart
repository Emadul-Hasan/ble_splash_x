import 'package:ble_splash_x/customComponents/CustomDrawer.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class ConfigWiFiPage extends StatelessWidget {
  const ConfigWiFiPage({Key? key}) : super(key: key);
  static const String id = 'ConfigWifi';

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as String;
    return WifiConfigPage();
  }
}

class WifiConfigPage extends StatefulWidget {
  const WifiConfigPage({Key? key}) : super(key: key);

  @override
  _WifiConfigPageState createState() => _WifiConfigPageState();
}

class _WifiConfigPageState extends State<WifiConfigPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wifi Config"),
      ),
      drawer: DrawerCustom(),
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  SizedBox(
                    height: 30.0,
                    width: double.infinity,
                  ),
                  Icon(
                    MdiIcons.wifiCancel,
                    size: 60.0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

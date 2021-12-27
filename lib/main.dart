import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock/wakelock.dart';

import 'game_page.dart';

void main() {
  runApp(QwixxGameSheet());
}

class QwixxGameSheet extends StatelessWidget {
  final _key = GlobalKey();
  QwixxGameSheet({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    Wakelock.enable();

    return MaterialApp(
      title: 'Qwixx Game Sheet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    home: GamePage(key: _key),
    );
  }
}

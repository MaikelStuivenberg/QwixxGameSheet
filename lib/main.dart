import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'pages/game_page.dart';

void main() {
  runApp(const QwixxGameSheet());
}

class QwixxGameSheet extends StatelessWidget {
  const QwixxGameSheet({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    WakelockPlus.enable();

    return MaterialApp(
      title: 'Qwixx Game Sheet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GamePage(),
    );
  }
}

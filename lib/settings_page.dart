import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  static const SHOW_CURRENT_POINTS = "show_current_points";
  static const DARK_MODE = "dark_mode";
  static const HIGHSCORE = "highscore";

  // Not settings, but needed a place to store some variables
  static const CURRENT_HIGHSCORE = "current_highscore";
  static const CURRENT_SCORE_RED = "current_score_red";
  static const CURRENT_SCORE_YELLOW = "current_score_yellow";
  static const CURRENT_SCORE_GREEN = "current_score_green";
  static const CURRENT_SCORE_BLUE = "current_score_blue";
  static const CURRENT_MISSES = "current_misses";
  static const CURRENT_ROWS_LOCKED = "current_rows_locked";

  SettingsPage({Key key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _showCurrentPoints = true;
  bool _useDarkMode = false;
  bool _useHighscore = true;

  @override
  void initState() {
    super.initState();
    loadCurrentSettings();
  }

  void loadCurrentSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCurrentPoints =
          prefs.getBool(SettingsPage.SHOW_CURRENT_POINTS) ?? true;
      _useDarkMode = prefs.getBool(SettingsPage.DARK_MODE) ?? false;
      _useHighscore = prefs.getBool(SettingsPage.HIGHSCORE) ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 240, 240, 240),
      body: Container(
        width: double.infinity,
        margin: EdgeInsets.all(25),
        child: Column(
          children: [
            // SHOW CURRENT POINTS
            SwitchListTile(
                value: _showCurrentPoints,
                title: Text("Show current points"),
                secondary: Icon(Icons.score_outlined),
                onChanged: (val) async {
                  setState(() {
                    _showCurrentPoints = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(SettingsPage.SHOW_CURRENT_POINTS, val);
                }),

            // DARK MODE
            SwitchListTile(
                value: _useDarkMode,
                title: Text("Dark mode"),
                secondary: Icon(Icons.nightlight_round),
                onChanged: (val) async {
                  setState(() {
                    _useDarkMode = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(SettingsPage.DARK_MODE, val);
                }),

            // HIGHSCORES
            SwitchListTile(
                value: _useHighscore,
                title: Text("Show/Save highscore"),
                secondary: Icon(Icons.emoji_events),
                onChanged: (val) async {
                  setState(() {
                    _useHighscore = val;
                  });

                  final prefs = await SharedPreferences.getInstance();
                  prefs.setBool(SettingsPage.HIGHSCORE, val);
                }),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, 'resume');
                    },
                    child: Text('Back'),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, 'reset');
                    },
                    child: Text('New Game'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

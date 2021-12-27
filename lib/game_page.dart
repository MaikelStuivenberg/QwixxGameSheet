import 'dart:convert';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:qwixx_scoreboard/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/settings.dart';

class GamePage extends StatefulWidget {
  const GamePage({required Key key}) : super(key: key);

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  var points = [1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78];

  List<int> choosenRed = [];
  List<int> choosenYellow = [];
  List<int> choosenGreen = [];
  List<int> choosenBlue = [];

  int missedThrows = 0;

  var redNumbers = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  var yellowNumbers = [2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
  var greenNumbers = [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];
  var blueNumbers = [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2];

  List<bool> rowsLocked = [false, false, false, false];
  List<Color> rowsColors = [
    Colors.red,
    const Color.fromARGB(255, 245, 200, 66),
    const Color.fromARGB(255, 0, 125, 0),
    const Color.fromARGB(255, 41, 72, 143)
  ];

  // Settings (with default values, async loaded)
  var showScore = true;
  var darkMode = false;
  var highscore = true;
  var sounds = false;

  int? currentHighscore; // Initialized when existing in memory

  @override
  void initState() {
    super.initState();
    loadSettings();
    loadGame();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkMode
          ? const Color.fromARGB(255, 30, 30, 30)
          : const Color.fromARGB(255, 240, 240, 240),
      body: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(15, 5, 15, 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              getHeader(),
              Column(
                children: [
                  getGameRow(1, redNumbers, choosenRed),
                  getGameRow(2, yellowNumbers, choosenYellow),
                  getGameRow(3, greenNumbers, choosenGreen),
                  getGameRow(4, blueNumbers, choosenBlue)
                ],
              ),
              getBottom()
            ],
          )),
    );
  }

  Widget getHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Container(),
        ),
        Expanded(
          flex: 1,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: (currentHighscore != null && highscore)
                ? [
                    Container(
                      child: Icon(
                        Icons.emoji_events,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                      padding: const EdgeInsets.only(right: 10),
                    ),
                    Text(
                      "Highscore: " + currentHighscore.toString(),
                      style: TextStyle(
                          fontSize: 16,
                          color: darkMode ? Colors.white : Colors.black),
                    ),
                  ]
                : [],
          ),
        ),
        Expanded(
          flex: 1,
          child: Row(
            children: [
              const Spacer(),
              ElevatedButton(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Icon(Icons.settings, color: Colors.white),
                    Text(
                      "Settings",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsPage(key: GlobalKey())),
                  ).then((value) => {
                        if (value == 'reset') resetGame(),
                        loadSettings(),
                      });
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget getBottom() {
    return Row(
      children: [
        Row(
          children: [
            getPointsColumn(rowsColors[0], choosenRed),
            getTextColumn("+"),
            getPointsColumn(rowsColors[1], choosenYellow),
            getTextColumn("+"),
            getPointsColumn(rowsColors[2], choosenGreen),
            getTextColumn("+"),
            getPointsColumn(rowsColors[3], choosenBlue),
            getTextColumn("-"),
            getMinPoints(),
            getTextColumn("="),
            getTotalPointsColumn()
          ],
        ),
        getMissedThrowRow(),
      ],
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
    );
  }

  Widget getMissedThrowRow() {
    List<Widget> columns = [];

    for (int i = 1; i <= 4; i++) {
      columns.add(getMissedThrowColumn(i));
    }

    return Row(
      children: columns,
    );
  }

  Widget getMissedThrowColumn(int position) {
    return GestureDetector(
      child: Container(
        width: 50,
        height: 40,
        margin: position == 1
            ? const EdgeInsets.all(0)
            : const EdgeInsets.fromLTRB(10, 0, 0, 0),
        decoration: BoxDecoration(
          border: Border.all(
              color: darkMode ? Colors.white : Colors.black, width: 1.25),
          borderRadius: const BorderRadius.all(Radius.circular(5)),
          color: darkMode
              ? const Color.fromARGB(225, 30, 30, 30)
              : const Color.fromARGB(225, 255, 255, 255),
        ),
        child: Center(
          child: Text(
            missedThrows >= position ? "X" : "",
            style: TextStyle(
              color: darkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          // Check if it is possible to click on current item
          if (missedThrows < position - 1) return;

          // When current item is already clicked, remove this missed throw
          if (missedThrows >= position) {
            playClickSound();
            missedThrows -= 1;
            return;
          }

          // Never be able to get more then 4 X's.
          if (missedThrows > 3) return;

          //Otherwise add an X
          missedThrows += 1;

          // Finish game when 4 misses
          if (missedThrows == 4) {
            gameFinished();
          }

          saveCurrentView();
          playClickSound();
        });
      },
    );
  }

  Widget getTextColumn(String text) {
    return Container(
      height: 40,
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              fontSize: 20, color: darkMode ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Widget getPointsColumn(Color color, List<int> choosenNumbers) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.25),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: darkMode
            ? const Color.fromARGB(225, 30, 30, 30)
            : const Color.fromARGB(225, 255, 255, 255),
      ),
      child: Center(
        child: Text(
          showScore
              ? choosenNumbers.isEmpty
                  ? "0"
                  : points[choosenNumbers.length - 1].toString()
              : "?",
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget getMinPoints() {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(
            color: darkMode ? Colors.white : Colors.black, width: 1.25),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: darkMode
            ? const Color.fromARGB(225, 30, 30, 30)
            : const Color.fromARGB(225, 255, 255, 255),
      ),
      child: Center(
        child: Text(
          showScore ? (missedThrows * 5).toString() : "?",
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget getTotalPointsColumn() {
    return Container(
      width: 50,
      height: 40,
      decoration: BoxDecoration(
        border: Border.all(
            color: darkMode ? Colors.white : Colors.black, width: 1.25),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: darkMode
            ? const Color.fromARGB(225, 30, 30, 30)
            : const Color.fromARGB(225, 255, 255, 255),
      ),
      child: Center(
        child: Text(
          showScore ? getTotalPoints().toString() : "?",
          style: TextStyle(
            color: darkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
    );
  }

  Container getGameRow(
      int rowNr, List<int> numberList, List<int> choosenNumbers) {
    List<Widget> numbers = [];

    // Add the nummbers 2 till 12
    for (var i = 0; i < 11; i++) {
      var blocked = false;
      var clicked = false;

      if (choosenNumbers.where((element) => (element > i)).isNotEmpty) {
        blocked = true;
      }

      if (rowsLocked[rowNr - 1]) blocked = true;

      if (choosenNumbers.contains(i)) clicked = true;

      numbers.add(
        GestureDetector(
          child: Container(
            width: 50,
            height: 40,
            decoration: BoxDecoration(
              border:
                  Border.all(color: const Color.fromARGB(255, 100, 100, 100)),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: darkMode
                  ? const Color.fromARGB(225, 30, 30, 30)
                  : const Color.fromARGB(225, 255, 255, 255),
            ),
            child: Center(
              child: Text(
                clicked ? "X" : numberList[i].toString(),
                style: TextStyle(
                  color: clicked
                      ? darkMode
                          ? Colors.white
                          : Colors.black
                      : blocked
                          ? const Color.fromARGB(255, 200, 200, 200)
                          : rowsColors[rowNr - 1],
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          onTap: () {
            if (blocked && i < 10) return;

            // When last item (pos 10), check if possible
            if (i >= 10 && choosenNumbers.length < 5) return;

            setState(() {
              if (choosenNumbers.contains(i)) {
                // When last item, also unlock row
                if (i == 10) {
                  choosenNumbers.remove(i + 1);
                  rowsLocked[rowNr - 1] = false;
                }

                choosenNumbers.remove(i);
                playClickSound();
              } else {
                // Check if row isn't locked
                if (rowsLocked[rowNr - 1]) return;

                choosenNumbers.add(i);

                // When last item, also lock row
                if (i == 10) {
                  choosenNumbers.add(i + 1);
                  rowsLocked[rowNr - 1] = true;

                  if (rowsLocked.where((element) => element).length == 2) {
                    gameFinished();
                    return;
                  }
                }
                playClickSound();
              }

              saveCurrentView();
            });
          },
        ),
      );
    }

    // Add extra column when people want to close/lock the row
    numbers.add(
      GestureDetector(
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 100, 100, 100)),
            borderRadius: const BorderRadius.all(Radius.circular(25)),
            color: darkMode
                ? const Color.fromARGB(225, 30, 30, 30)
                : const Color.fromARGB(225, 255, 255, 255),
          ),
          child: Center(
            child: Icon(
              rowsLocked[rowNr - 1] ? Icons.lock : Icons.lock_open,
              color: rowsColors[rowNr - 1],
              size: 20,
            ),
          ),
        ),
        onTap: () {
          setState(() {
            if (rowsLocked[rowNr - 1]) {
              rowsLocked[rowNr - 1] = false;
            } else {
              rowsLocked[rowNr - 1] = true;
            }

            saveCurrentView();
          });

          if (rowsLocked.where((element) => element).length == 2) {
            gameFinished();
            return;
          }
          playClickSound();
        },
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: rowsColors[rowNr - 1]),
      child: Row(
        children: numbers,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  int getTotalPoints() {
    var pointsRed = choosenRed.isEmpty ? 0 : points[choosenRed.length - 1];
    var pointsYellow =
        choosenYellow.isEmpty ? 0 : points[choosenYellow.length - 1];
    var pointsGreen =
        choosenGreen.isEmpty ? 0 : points[choosenGreen.length - 1];
    var pointsBlue = choosenBlue.isEmpty ? 0 : points[choosenBlue.length - 1];

    var minPoints = missedThrows * 5;

    return pointsRed + pointsYellow + pointsGreen + pointsBlue - minPoints;
  }

  void gameFinished() {
    playWinSound();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Finished!'),
        content: Text('You finished the game with ' +
            getTotalPoints().toString() +
            ' points!'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, 'Cancel'),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => {
              resetGame(),
              Navigator.pop(context, 'Ok'),
            },
            child: const Text('Start new game'),
          ),
        ],
      ),
    );
  }

  void resetGame() async {
    // Save highscore when enabled
    if (highscore &&
        (currentHighscore == null || currentHighscore! < getTotalPoints())) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setInt(Settings.currentHighscore, getTotalPoints());
    }

    setState(() {
      if (highscore &&
          (currentHighscore == null || currentHighscore! < getTotalPoints())) {
        currentHighscore = getTotalPoints();
      }

      // Reset choosen numbers
      choosenRed = [];
      choosenYellow = [];
      choosenGreen = [];
      choosenBlue = [];

      // Reset missed throws
      missedThrows = 0;

      // Reset locked rows
      rowsLocked = [false, false, false, false];

      saveCurrentView();
    });
  }

  void loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      showScore = prefs.getBool(Settings.showCurrentPoints) ?? true;
      darkMode = prefs.getBool(Settings.darkMode) ?? false;
      highscore = prefs.getBool(Settings.highscore) ?? true;
      sounds = prefs.getBool(Settings.sounds) ?? false;

      currentHighscore = prefs.getInt(Settings.currentHighscore);
    });
  }

  void loadGame() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      var memRed = prefs.getString(Settings.currentScoreRed) ?? "[]";
      var memYel = prefs.getString(Settings.currentScoreYellow) ?? "[]";
      var memGreen = prefs.getString(Settings.currentScoreGreen) ?? "[]";
      var memBlue = prefs.getString(Settings.currentScoreBlue) ?? "[]";

      choosenRed =
          (const JsonDecoder().convert(memRed) as List<dynamic>).cast<int>();
      choosenYellow =
          (const JsonDecoder().convert(memYel) as List<dynamic>).cast<int>();
      choosenGreen =
          (const JsonDecoder().convert(memGreen) as List<dynamic>).cast<int>();
      choosenBlue =
          (const JsonDecoder().convert(memBlue) as List<dynamic>).cast<int>();

      missedThrows = prefs.getInt(Settings.currentMisses) ?? 0;

      rowsLocked = (const JsonDecoder().convert(
              prefs.getString(Settings.currentRowsLocked) ??
                  "[false, false, false, false]") as List<dynamic>)
          .cast<bool>();
    });
  }

  void saveCurrentView() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset choosen numbers
    prefs.setString(
        Settings.currentScoreRed, const JsonEncoder().convert(choosenRed));
    prefs.setString(Settings.currentScoreYellow,
        const JsonEncoder().convert(choosenYellow));
    prefs.setString(
        Settings.currentScoreGreen, const JsonEncoder().convert(choosenGreen));
    prefs.setString(
        Settings.currentScoreBlue, const JsonEncoder().convert(choosenBlue));

    // Reset missed throws
    prefs.setInt(Settings.currentMisses, missedThrows);

    // Reset locked rows
    prefs.setString(
        Settings.currentRowsLocked, const JsonEncoder().convert(rowsLocked));
  }

  void playWinSound() {
    if (!sounds) return;
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/win.wav"),
      autoStart: true,
      showNotification: false,
    );
  }

  void playClickSound() {
    if (!sounds) return;
    AssetsAudioPlayer.newPlayer().open(
      Audio("assets/audios/click.wav"),
      autoStart: true,
      showNotification: false,
    );
  }
}

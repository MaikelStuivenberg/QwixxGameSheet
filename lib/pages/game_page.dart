import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:qwixx_gamesheet/cards/level_1.dart';
import 'package:qwixx_gamesheet/cards/level_2.dart';
import 'package:qwixx_gamesheet/cards/level_3.dart';
import 'package:qwixx_gamesheet/pages/settings_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/box_colors.dart';
import '../constants/settings.dart';
import '../models/box_color.dart';
import '../models/card_box.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  var points = [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78];

  int missedThrows = 0;

  var lvl = "1";
  var card = Level1Card().getCard();

  List<bool> rowsLocked = [false, false, false, false];

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
      body: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 5, 20, 5),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              getHeader(),
              const SizedBox(height: 12),
              Column(
                children: [
                  for (int i = 0; i < card.length; i++)
                    getGameRow(i + 1, card[i]),
                ],
              ),
              const SizedBox(height: 12),
              getBottom()
            ],
          ),
        ),
      ),
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
                      padding: const EdgeInsets.only(right: 10),
                      child: Icon(
                        Icons.emoji_events,
                        color: darkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      "Highscore: $currentHighscore",
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.settings),
                    SizedBox(width: 4),
                    Text(
                      "Settings",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.of(context)
                      .push(
                        MaterialPageRoute(
                            builder: (context) => const SettingsPage()),
                      )
                      .then((value) => {
                            if (value!.isNotEmpty && value[0] != "resume")
                              {
                                setState(() {
                                  lvl = value[0];
                                  resetGame();
                                }),
                              },

                            // Always load the new settings (can be changed without starting a new game)
                            loadSettings(),
                            // loadSettings(),
                            // if (value != 'cancel')
                            //   resetGame(value),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            getPointsBoxByColor(BoxColors.redBox),
            getTextColumn("+"),
            getPointsBoxByColor(BoxColors.yellowBox),
            getTextColumn("+"),
            getPointsBoxByColor(BoxColors.greenBox),
            getTextColumn("+"),
            getPointsBoxByColor(BoxColors.blueBox),
            getTextColumn("-"),
            getMinPoints(),
            getTextColumn("="),
            getTotalPointsColumn()
          ],
        ),
        getMissedThrowRow(),
      ],
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

  Widget getPointsBoxByColor(BoxColor color) {
    return Container(
      width: 40,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(color: color.color, width: 1.25),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        color: darkMode
            ? const Color.fromARGB(225, 30, 30, 30)
            : const Color.fromARGB(225, 255, 255, 255),
      ),
      child: Center(
        child: Text(
          showScore ? getPointsByColor(color).toString() : "?",
          style: TextStyle(
            color: color.color,
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
      width: 75,
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

  SizedBox getGameRow(int rowNr, List<CardBox> columnList) {
    List<Widget> numbers = [];

    // Add the nummbers 2 till 12
    for (var i = 0; i < 11; i++) {
      var blocked = false;
      var clicked = columnList[i].checked;

      for (var column in columnList.reversed) {
        if (column == columnList[i]) {
          break;
        }

        if (column.checked) {
          blocked = true;
          break;
        }
      }

      if (rowsLocked[rowNr - 1]) blocked = true;

      numbers.add(
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: columnList[i].color.color),
            width: double.infinity,
            child: GestureDetector(
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 40,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: const Color.fromARGB(255, 100, 100, 100)),
                      borderRadius: const BorderRadius.all(Radius.circular(5)),
                      color: darkMode
                          ? const Color.fromARGB(225, 30, 30, 30)
                          : const Color.fromARGB(225, 255, 255, 255),
                    ),
                    child: Center(
                      child: Text(
                        clicked ? "X" : columnList[i].number.toString(),
                        style: TextStyle(
                          color: clicked
                              ? darkMode
                                  ? Colors.white
                                  : Colors.black
                              : blocked
                                  ? const Color.fromARGB(255, 200, 200, 200)
                                  : columnList[i].color.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
              onTap: () {
                if (blocked && i < 10) return;

                // When last item (pos 10), check if possible
                if (i >= 10 &&
                    columnList.where((element) => element.checked).length < 5) {
                  return;
                }

                setState(() {
                  playClickSound();
                  // columnList[i].checked = !columnList[i].checked;

                  if (columnList[i].checked) {
                    // When last item, also unlock row
                    if (i == 10) {
                      rowsLocked[rowNr - 1] = false;
                    }

                    columnList[i].checked = !columnList[i].checked;
                    playClickSound();
                  } else {
                    // Check if row isn't locked
                    if (rowsLocked[rowNr - 1]) return;

                    columnList[i].checked = !columnList[i].checked;

                    // When last item, also lock row
                    if (i == 10) {
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
          ),
        ),
      );
    }

    // Add extra column when people want to close/lock the row
    numbers.add(
      Expanded(
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: columnList.last.color.color),
          width: double.infinity,
          child: GestureDetector(
            child: Column(children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 100, 100, 100)),
                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                  color: darkMode
                      ? const Color.fromARGB(225, 30, 30, 30)
                      : const Color.fromARGB(225, 255, 255, 255),
                ),
                child: Center(
                  child: Icon(
                    rowsLocked[rowNr - 1] ? Icons.lock : Icons.lock_open,
                    color: columnList.last.color.color,
                    size: 20,
                  ),
                ),
              ),
            ]),
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
        ),
      ),
    );

    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: numbers,
      ),
    );
  }

  int getPointsByColor(BoxColor color) {
    var columnPoints = 0;

    for (var row in card) {
      columnPoints += row
          .where((e) => e.color == color && e.checked)
          .map((e) => 1)
          .fold<int>(0, (previousValue, element) => previousValue + element);

      if (row.last.color == color && row.last.checked) {
        columnPoints++;
      }
    }

    return points[columnPoints];
  }

  int getTotalPoints() {
    var pointsRed = getPointsByColor(BoxColors.redBox);
    var pointsYellow = getPointsByColor(BoxColors.yellowBox);
    var pointsGreen = getPointsByColor(BoxColors.greenBox);
    var pointsBlue = getPointsByColor(BoxColors.blueBox);

    var minPoints = missedThrows * 5;

    return pointsRed + pointsYellow + pointsGreen + pointsBlue - minPoints;
  }

  void updateAmountOfPlayedGames() async {
    final prefs = await SharedPreferences.getInstance();
    var amountOfPlayedGames = prefs.getInt(Settings.amountOfPlayedGames) ?? 0;
    amountOfPlayedGames++;
    prefs.setInt(Settings.amountOfPlayedGames, amountOfPlayedGames);
  }

  Future<bool> isSecondGame() async {
    var amountOfPlayedGames = (await SharedPreferences.getInstance())
        .getInt(Settings.amountOfPlayedGames);

    return amountOfPlayedGames != null && amountOfPlayedGames == 2;
  }

  void gameFinished() {
    updateAmountOfPlayedGames();

    playWinSound();

    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Finished!'),
        content: Text('You finished the game with ${getTotalPoints()} points!'),
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              if (await InAppReview.instance.isAvailable() &&
                  await isSecondGame()) {
                InAppReview.instance.requestReview();
              }

              if (!context.mounted) return;

              Navigator.pop(context, "Cancel");
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              resetGame();

              if (await InAppReview.instance.isAvailable() &&
                  await isSecondGame()) {
                InAppReview.instance.requestReview();
              }

              if (!context.mounted) return;

              Navigator.pop(context, 'Ok');
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

      // Reset card
      if (lvl == "1") {
        card = Level1Card().getCard();
      }
      if (lvl == "2") {
        card = Level2Card().getCard();
      }
      if (lvl == "3") {
        card = Level3Card().getCard();
      }

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
    // final prefs = await SharedPreferences.getInstance();

    // setState(() {
    //   var memRed = prefs.getString(Settings.currentScoreRed) ?? "[]";
    //   var memYel = prefs.getString(Settings.currentScoreYellow) ?? "[]";
    //   var memGreen = prefs.getString(Settings.currentScoreGreen) ?? "[]";
    //   var memBlue = prefs.getString(Settings.currentScoreBlue) ?? "[]";

    //   choosenRed =
    //       (const JsonDecoder().convert(memRed) as List<dynamic>).cast<int>();
    //   choosenYellow =
    //       (const JsonDecoder().convert(memYel) as List<dynamic>).cast<int>();
    //   choosenGreen =
    //       (const JsonDecoder().convert(memGreen) as List<dynamic>).cast<int>();
    //   choosenBlue =
    //       (const JsonDecoder().convert(memBlue) as List<dynamic>).cast<int>();

    //   missedThrows = prefs.getInt(Settings.currentMisses) ?? 0;

    //   rowsLocked = (const JsonDecoder().convert(
    //           prefs.getString(Settings.currentRowsLocked) ??
    //               "[false, false, false, false]") as List<dynamic>)
    //       .cast<bool>();
    // });
  }

  void saveCurrentView() async {
    // final prefs = await SharedPreferences.getInstance();

    // // Reset choosen numbers
    // prefs.setString(
    //     Settings.currentScoreRed, const JsonEncoder().convert(choosenRed));
    // prefs.setString(Settings.currentScoreYellow,
    //     const JsonEncoder().convert(choosenYellow));
    // prefs.setString(
    //     Settings.currentScoreGreen, const JsonEncoder().convert(choosenGreen));
    // prefs.setString(
    //     Settings.currentScoreBlue, const JsonEncoder().convert(choosenBlue));

    // // Reset missed throws
    // prefs.setInt(Settings.currentMisses, missedThrows);

    // // Reset locked rows
    // prefs.setString(
    //     Settings.currentRowsLocked, const JsonEncoder().convert(rowsLocked));
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

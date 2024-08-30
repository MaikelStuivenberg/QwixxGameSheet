
import 'package:qwixx_gamesheet/constants/box_colors.dart';
import 'package:qwixx_gamesheet/models/card_box.dart';

class Level1Card {

  final _row1 = [
    CardBox(BoxColors.redBox, 2),
    CardBox(BoxColors.redBox, 3),
    CardBox(BoxColors.redBox, 4),
    CardBox(BoxColors.redBox, 5),
    CardBox(BoxColors.redBox, 6),
    CardBox(BoxColors.redBox, 7),
    CardBox(BoxColors.redBox, 8),
    CardBox(BoxColors.redBox, 9),
    CardBox(BoxColors.redBox, 10),
    CardBox(BoxColors.redBox, 11),
    CardBox(BoxColors.redBox, 12),
  ];

  final _row2 = [
    CardBox(BoxColors.yellowBox, 2),
    CardBox(BoxColors.yellowBox, 3),
    CardBox(BoxColors.yellowBox, 4),
    CardBox(BoxColors.yellowBox, 5),
    CardBox(BoxColors.yellowBox, 6),
    CardBox(BoxColors.yellowBox, 7),
    CardBox(BoxColors.yellowBox, 8),
    CardBox(BoxColors.yellowBox, 9),
    CardBox(BoxColors.yellowBox, 10),
    CardBox(BoxColors.yellowBox, 11),
    CardBox(BoxColors.yellowBox, 12),
  ];

  final _row3 = [
    CardBox(BoxColors.greenBox, 12),
    CardBox(BoxColors.greenBox, 11),
    CardBox(BoxColors.greenBox, 10),
    CardBox(BoxColors.greenBox, 9),
    CardBox(BoxColors.greenBox, 8),
    CardBox(BoxColors.greenBox, 7),
    CardBox(BoxColors.greenBox, 6),
    CardBox(BoxColors.greenBox, 5),
    CardBox(BoxColors.greenBox, 4),
    CardBox(BoxColors.greenBox, 3),
    CardBox(BoxColors.greenBox, 2),
  ];

  final _row4 = [
    CardBox(BoxColors.blueBox, 12),
    CardBox(BoxColors.blueBox, 11),
    CardBox(BoxColors.blueBox, 10),
    CardBox(BoxColors.blueBox, 9),
    CardBox(BoxColors.blueBox, 8),
    CardBox(BoxColors.blueBox, 7),
    CardBox(BoxColors.blueBox, 6),
    CardBox(BoxColors.blueBox, 5),
    CardBox(BoxColors.blueBox, 4),
    CardBox(BoxColors.blueBox, 3),
    CardBox(BoxColors.blueBox, 2),
  ];

  List<List<CardBox>> getCard() {
    return [_row1, _row2, _row3, _row4];
  }
}
import 'package:flutter/material.dart';
import 'package:qwixx_gamesheet/models/box_color.dart';

class BoxColors {
  BoxColors._();

  static var redBox = BoxColor(
      Colors.red,
      const Color.fromRGBO(255, 255, 255, 1),
      Colors.red,
      const Color.fromRGBO(0, 0, 0, 1));

  static var yellowBox = BoxColor(
      const Color.fromARGB(255, 245, 200, 66),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromARGB(255, 245, 200, 66),
      const Color.fromRGBO(0, 0, 0, 1));

  static var greenBox = BoxColor(
      const Color.fromARGB(255, 0, 125, 0),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromARGB(255, 0, 125, 0),
      const Color.fromRGBO(0, 0, 0, 1));

  static var blueBox = BoxColor(
      const Color.fromARGB(255, 41, 72, 143),
      const Color.fromRGBO(255, 255, 255, 1),
      const Color.fromARGB(255, 41, 72, 143),
      const Color.fromRGBO(0, 0, 0, 1));
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:watermeter/model/user.dart';
import 'package:watermeter/page/widget.dart';

class ThemeController extends GetxController {
  late ThemeData apptheme;

  @override
  void onReady() {
    super.onInit();
    onUpdate();
    update();
  }

  void onUpdate() {
    apptheme = ThemeData(
      useMaterial3: true,
      colorSchemeSeed: ColorSeed.values[int.parse(user["color"] ?? "0")].color,
    );
  }
}

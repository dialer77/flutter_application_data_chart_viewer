import 'package:flutter/material.dart';

class CommonUtils {
  static CommonUtils? _instance;
  static CommonUtils get instance => _instance ??= CommonUtils._();

  CommonUtils._();

  Widget blankContainer({int flex = 1, Color color = Colors.white}) {
    return Flexible(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(color: color),
      ),
    );
  }
}

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

  Widget menuTitle({
    required String title,
    required double height,
    required double fontSize,
    required Color color,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: color),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String replaceCountryCode(String countryCode) {
    return countryCode.replaceAll('[', '').replaceAll(']', '');
  }
}

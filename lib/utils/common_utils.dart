import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/models/table_chart_data_model.dart';

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

  double calculateInterval(double maxValue) {
    // maxValue가 0이면 기본값 1 반환
    if (maxValue <= 0) return 0.1;

    // 자릿수 계산을 위해 로그 사용
    final digitCount = (log(maxValue) / ln10).floor();
    final base = pow(10, digitCount - 1).toDouble();

    // 최고 자릿수 추출
    final firstDigit = (maxValue / pow(10, digitCount)).floor();

    if (firstDigit <= 2) return base * 4; // 2배 증가
    if (firstDigit <= 5) return base * 10; // 2배 증가
    return base * 20; // 2배 증가
  }

  List<TableChartDataModel> createTestData() {
    return [
      TableChartDataModel(
        rank: 1,
        name: 'Korea',
        dataInfo: {
          TableDataType.country: 'KR',
        },
        yearDatas: {
          2018: 85.5,
          2019: 87.2,
          2020: 89.1,
          2021: 90.5,
          2022: 92.3,
        },
      ),
      TableChartDataModel(
        rank: 2,
        name: 'Japan',
        dataInfo: {
          TableDataType.country: 'JP',
        },
        yearDatas: {
          2018: 82.1,
          2019: 83.5,
          2020: 85.2,
          2021: 86.8,
          2022: 88.4,
        },
      ),
      TableChartDataModel(
        rank: 3,
        name: 'China',
        dataInfo: {
          TableDataType.country: 'CN',
        },
        yearDatas: {
          2018: 78.3,
          2019: 80.5,
          2020: 82.9,
          2021: 84.7,
          2022: 86.2,
        },
      ),
    ];
  }
}

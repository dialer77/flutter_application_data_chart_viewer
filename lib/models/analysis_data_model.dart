import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class CodeInfo {
  final String code;
  final String codeName;
  final String country;
  final String name;
  final String scode;
  final String market;
  final int year;

  final AnalysisCategory category;
  final AnalysisSubCategory subCategory;
  final TechListType techType;

  CodeInfo({
    required this.code,
    required this.codeName,
    required this.country,
    required this.name,
    required this.scode,
    required this.market,
    required this.year,
    required this.category,
    required this.subCategory,
    required this.techType,
  });
}

class AnalysisDataModel {
  final CodeInfo codeInfo;

  AnalysisDataModel({
    required this.codeInfo,
  });

  factory AnalysisDataModel.fromMap(
      String sheetName, Map<String, dynamic> map) {
    String code = map['CODE'].toString();
    String codeName = map['CODE_NAME'].toString();
    String country = map['COUNTRY'].toString();
    String name = map['NAME'].toString();
    String scode = map['SCODE'].toString();
    String market = map['MARKET'].toString();

    for (var key in map.keys) {
      if (key.contains('_')) {
        final codeInfo = CodeInfo(
          code: code,
          codeName: codeName,
          country: country,
          name: name,
          scode: scode,
          market: market,
          year: int.parse(map['YEAR'].toString()),
          category: AnalysisCategory.industryTech, // 필요에 따라 수정
          subCategory: AnalysisSubCategory.techTrend, // 필요에 따라 수정
          techType: TechListType.lc, // 필요에 따라 수정
        );
      }
    }

    final yearlyValues = <String, double>{};
    map.forEach((key, value) {
      if (!['CODE', 'CODE_NAME', 'COUNTRY', 'NAME'].contains(key) &&
          value != null) {
        yearlyValues[key] = double.tryParse(value.toString()) ?? 0.0;
      }
    });

    return AnalysisDataModel(
      codeInfo: codeInfo,
    );
  }
}

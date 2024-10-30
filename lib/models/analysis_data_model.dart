import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class CodeInfo {
  final String code;
  final String codeName;
  final String country;
  final String name;
  final AnalysisCategory category;
  final AnalysisSubCategory subCategory;

  CodeInfo({
    required this.code,
    required this.codeName,
    required this.country,
    required this.name,
    required this.category,
    required this.subCategory,
  });
}

class AnalysisDataModel {
  final CodeInfo codeInfo;
  final Map<String, double> yearlyValues; // "TCN_00" -> value

  AnalysisDataModel({
    required this.codeInfo,
    required this.yearlyValues,
  });

  double? getValue(String dataCode, int year) {
    final key = '${dataCode}_${year.toString().substring(2)}';
    return yearlyValues[key];
  }

  factory AnalysisDataModel.fromMap(Map<String, dynamic> map) {
    final codeInfo = CodeInfo(
      code: map['CODE'].toString(),
      codeName: map['CODE_NAME'].toString(),
      country: map['COUNTRY'].toString(),
      name: map['NAME'].toString(),
      category: AnalysisCategory.industryTech, // 필요에 따라 수정
      subCategory: AnalysisSubCategory.techTrend, // 필요에 따라 수정
    );

    final yearlyValues = <String, double>{};
    map.forEach((key, value) {
      if (!['CODE', 'CODE_NAME', 'COUNTRY', 'NAME'].contains(key) &&
          value != null) {
        yearlyValues[key] = double.tryParse(value.toString()) ?? 0.0;
      }
    });

    return AnalysisDataModel(
      codeInfo: codeInfo,
      yearlyValues: yearlyValues,
    );
  }
}

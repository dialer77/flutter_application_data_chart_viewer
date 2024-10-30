import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class AnalysisDataModel {
  final String code;
  final String codeName;
  final String country;
  final String name;
  final AnalysisCategory category;
  final AnalysisSubCategory subCategory;
  // ... 기타 필요한 필드들

  AnalysisDataModel({
    required this.code,
    required this.codeName,
    required this.country,
    required this.name,
    required this.category,
    required this.subCategory,
    // ...
  });

  factory AnalysisDataModel.fromMap(Map<String, dynamic> map) {
    return AnalysisDataModel(
      code: map['CODE'].toString(),
      codeName: map['CODE_NAME'].toString(),
      country: map['COUNTRY'].toString(),
      name: map['NAME'].toString(),
      category: AnalysisCategory.industryTech,
      subCategory: AnalysisSubCategory.techTrend,
      // category: AnalysisCategory.values.firstWhere(
      //   (e) => e.toString() == map['CATEGORY'],
      // ),
      // subCategory: AnalysisSubCategory.values.firstWhere(
      //   (e) => e.toString() == map['SUB_CATEGORY'],
      // ),
      // ...
    );
  }
}

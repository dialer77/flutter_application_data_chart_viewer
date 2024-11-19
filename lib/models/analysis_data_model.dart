import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class CodeInfo {
  final String code;
  final String codeName;
  final String country;
  final String name;
  final String scode;
  final String market;
  final String sheetName;

  final TechListType techType;

  CodeInfo({
    required this.code,
    required this.codeName,
    required this.country,
    required this.name,
    required this.scode,
    required this.market,
    required this.sheetName,
    required this.techType,
  });
}

class AnalysisDataModel {
  final CodeInfo codeInfo;
  final Map<String, Map<int, double>> analysisDatas;

  AnalysisDataModel({
    required this.codeInfo,
    required this.analysisDatas,
  });

  factory AnalysisDataModel.fromMap(
      String sheetName, Map<String, dynamic> map) {
    String code = map['CODE'].toString();
    String codeName = map['CODE_NAME'].toString();
    String country = map['COUNTRY'].toString();
    String name = map['NAME'].toString();
    String scode = map['SCODE'].toString();
    String market = map['MARKET'].toString();

    TechListType techType = TechListType.lc;
    List<String> sheetNameSplit = sheetName.split(' ');
    switch (sheetNameSplit[0].substring(1, 3)) {
      case "LC":
        techType = TechListType.lc;
        break;
      case "MC":
        techType = TechListType.mc;
        break;
      case "SC":
        techType = TechListType.sc;
        break;
    }

    String splitSheetName = sheetNameSplit.sublist(1).join('');
    final codeInfo = CodeInfo(
      code: code,
      codeName: codeName,
      country: country,
      name: name,
      scode: scode,
      market: market,
      sheetName: splitSheetName,
      techType: techType,
    );

    final Map<String, Map<int, double>> analysisDatas = {};

    for (var key in map.keys) {
      if (key.contains('_') &&
          key != "CODE_NAME" &&
          (int.tryParse(key) == null)) {
        int year = 0;
        String dataCode = "";
        if (int.tryParse(key) != null) {
          year = int.parse(key);
        } else {
          dataCode = key.split('_').first;
          year = int.parse(key.split('_').last);
        }
        year += 2000;

        if (analysisDatas[dataCode] == null) {
          analysisDatas[dataCode] = {
            year: double.tryParse(map[key].toString()) ?? 0.0
          };
        } else {
          analysisDatas[dataCode]![year] =
              double.tryParse(map[key].toString()) ?? 0.0;
        }
      } else if (int.tryParse(key) != null) {
        int year = int.parse(key);
        String dataCode = "";
        year = int.parse(key);

        if (analysisDatas[dataCode] == null) {
          analysisDatas[dataCode] = {
            year: double.tryParse(map[key].toString()) ?? 0.0
          };
        } else {
          analysisDatas[dataCode]![year] =
              double.tryParse(map[key].toString()) ?? 0.0;
        }
      }
    }

    return AnalysisDataModel(
      codeInfo: codeInfo,
      analysisDatas: analysisDatas,
    );
  }
}

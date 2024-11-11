import 'package:excel/excel.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class AnalysisDataRepository {
  static const String _paperDbPath = 'assets/F_논문DB.xlsx';
  static const String _patentDbPath = 'assets/F_특허DB.xlsx';
  static const String _combinedDbPath = 'assets/F_특허+논문DB.xlsx';

  Future<Map<String, List<Map<String, dynamic>>>> loadAnalysisData(
      AnalysisDataType dataType) async {
    final String path;
    switch (dataType) {
      case AnalysisDataType.paper:
        path = _paperDbPath;
        break;
      case AnalysisDataType.patent:
        path = _patentDbPath;
        break;
      case AnalysisDataType.patentAndPaper:
        path = _combinedDbPath;
        break;
    }

    try {
      final bytes = await rootBundle.load(path);
      final excel = Excel.decodeBytes(bytes.buffer.asUint8List());

      final Map<String, List<Map<String, dynamic>>> sheetResults = {};

      for (var table in excel.tables.entries) {
        final String sheetName = table.key;
        final sheet = table.value;
        final List<Map<String, dynamic>> results = [];

        final headers = sheet.rows[0];

        for (var row in sheet.rows.skip(1)) {
          final Map<String, dynamic> rowData = {};
          for (var i = 0; i < headers.length; i++) {
            if (headers[i]?.value != null && row[i]?.value != null) {
              rowData[headers[i]!.value.toString()] = row[i]!.value;
            }
          }
          if (rowData.isNotEmpty) {
            results.add(rowData);
          }
        }

        sheetResults[sheetName] = results;
      }

      return sheetResults;
    } catch (e) {
      throw Exception(
          'Failed to load ${dataType.name} database: ${e.toString()}');
    }
  }

  // 데이터 코드 목록 추출 (예: TCN, TCI 등)
  Set<String> extractDataCodes(Map<String, List<Map<String, dynamic>>> data) {
    Set<String> codes = {};

    for (var sheetData in data.values) {
      if (sheetData.isNotEmpty) {
        final sampleRow = sheetData.first;
        for (var key in sampleRow.keys) {
          if (key.contains('_')) {
            final code = key.split('_')[0];
            codes.add(code);
          }
        }
      }
    }

    return codes;
  }

  // 연도 범위 추출
  (int, int) extractYearRange(Map<String, List<Map<String, dynamic>>> data) {
    int minYear = 9999;
    int maxYear = 0;

    for (var sheetData in data.values) {
      if (sheetData.isNotEmpty) {
        final sampleRow = sheetData.first;
        for (var key in sampleRow.keys) {
          if (key.contains('_')) {
            final yearStr = key.split('_')[1];
            final year = 2000 + int.parse(yearStr);
            minYear = year < minYear ? year : minYear;
            maxYear = year > maxYear ? year : maxYear;
          }
        }
      }
    }

    return (minYear, maxYear);
  }
}

import 'package:excel/excel.dart';
import 'dart:io'; // File 클래스를 사용하기 위해 추가
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:path/path.dart' as path;

class AnalysisDataRepository {
  late final String _baseDir;

  // 현재 사용중인 경로를 저장할 변수들
  late String _paperDbPath;
  late String _patentDbPath;
  late String _combinedDbPath;

  AnalysisDataRepository() {
    // 실행 파일의 위치를 기준으로 경로 계산
    _baseDir = path.dirname(Platform.resolvedExecutable);

    // 기본 경로로 초기화
    _paperDbPath = path.join(_baseDir, 'Data', 'F_논문DB.xlsx');
    _patentDbPath = path.join(_baseDir, 'Data', 'F_특허DB.xlsx');
    _combinedDbPath = path.join(_baseDir, 'Data', 'F_특허+논문DB.xlsx');
  }

  // 파일 경로 설정을 위한 메서드들
  void setPaperDbPath(String path) => _paperDbPath = path;
  void setPatentDbPath(String path) => _patentDbPath = path;
  void setCombinedDbPath(String path) => _combinedDbPath = path;

  // 현재 설정된 경로 확인을 위한 getter들
  String get paperDbPath => _paperDbPath;
  String get patentDbPath => _patentDbPath;
  String get combinedDbPath => _combinedDbPath;

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
      // File 클래스를 사용하여 외부 파일 읽기
      final file = File(path);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

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
          'Failed to load ${dataType.name} database from $path: ${e.toString()}');
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

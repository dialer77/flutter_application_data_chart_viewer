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
      final stopwatch = Stopwatch()..start();
      final excel = Excel.decodeBytes(bytes.buffer.asUint8List());
      print('Excel decoding took: ${stopwatch.elapsedMilliseconds}ms');

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
      print('Error loading file: $e');
      throw Exception(
          'Failed to load ${dataType.name} database: ${e.toString()}');
    }
  }
}

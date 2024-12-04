import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class TableChartDataModel {
  final int rank;
  final String name;
  final Map<TableDataType, String> dataInfo;
  final Map<int, double> yearDatas;

  TableChartDataModel({
    required this.rank,
    required this.yearDatas,
    required this.name,
    required this.dataInfo,
  });
}

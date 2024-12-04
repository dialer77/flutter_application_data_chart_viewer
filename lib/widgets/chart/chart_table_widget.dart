import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/models/table_chart_data_model.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';

class ChartTableWidget extends StatelessWidget {
  final String title;
  final List<(TableDataType, String)> headerTitles;
  final List<TableChartDataModel> tableChartDataModels;

  Color get headerColor => const Color.fromARGB(255, 0, 32, 96);
  Color get yearColor => const Color.fromARGB(255, 204, 214, 224);
  const ChartTableWidget({
    super.key,
    required this.title,
    required this.headerTitles,
    required this.tableChartDataModels,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();

    final sortTableDataModels = tableChartDataModels..sort((a, b) => a.rank.compareTo(b.rank));

    final columnSizes = [60.px, ...List.generate(headerTitles.length, (index) => 100.px), ...List.generate(sortTableDataModels.first.yearDatas.length, (index) => 1.fr)];
    final rowSizes = [25.px, 25.px, ...List.generate(sortTableDataModels.length, (index) => 30.px)];

    return SizedBox(
      child: LayoutGrid(
        columnSizes: columnSizes, // 3개의 컬럼, 각각 동일한 비율
        rowSizes: rowSizes, // 4개의 행, 첫 행은 절반 크기
        children: [
          // Rank
          Container(
            decoration: BoxDecoration(
              color: headerColor,
              border: const Border(
                right: BorderSide(color: Colors.white),
              ),
            ),
            child: const Center(
              child: Text(
                'RANK',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ).withGridPlacement(
            columnStart: 0,
            columnSpan: 1,
            rowStart: 0,
            rowSpan: 2,
          ),
          // Header
          ...List.generate(headerTitles.length, (index) {
            return Container(
              decoration: BoxDecoration(
                color: headerColor,
                border: const Border(
                  right: BorderSide(color: Colors.white),
                ),
              ),
              child: Center(
                child: Text(
                  headerTitles[index].$2,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ).withGridPlacement(
              columnStart: index + 1,
              columnSpan: 1,
              rowStart: 0,
              rowSpan: 2,
            );
          }),
          // Title
          Container(
            decoration: BoxDecoration(color: headerColor),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ).withGridPlacement(
            columnStart: headerTitles.length + 1,
            columnSpan: columnSizes.length - headerTitles.length - 1,
            rowStart: 0,
            rowSpan: 1,
          ),
          // Years
          ...List.generate(provider.getYearRange().end.toInt() - provider.getYearRange().start.toInt() + 1, (index) {
            return Container(
              decoration: BoxDecoration(
                  color: yearColor,
                  border: const Border(
                    right: BorderSide(color: Colors.white),
                  )),
              child: Center(
                child: Text(
                  (provider.getYearRange().start.toInt() + index).toString(),
                ),
              ),
            ).withGridPlacement(
              columnStart: index + headerTitles.length + 1,
              columnSpan: 1,
              rowStart: 1,
              rowSpan: 1,
            );
          }),
        ],
      ),
    );
  }
}

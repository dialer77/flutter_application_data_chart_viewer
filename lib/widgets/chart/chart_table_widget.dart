import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/models/table_chart_data_model.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';

class ChartTableWidget extends StatefulWidget {
  final String title;
  final List<(TableDataType, String)> headerTitles;
  final List<TableChartDataModel> tableChartDataModels;

  Color get headerColor => const Color.fromARGB(255, 0, 32, 96);
  Color get yearColor => const Color.fromARGB(255, 204, 214, 224);
  Border get border => const Border(
        right: BorderSide(color: Colors.grey),
        bottom: BorderSide(color: Colors.grey),
      );
  const ChartTableWidget({
    super.key,
    required this.title,
    required this.headerTitles,
    required this.tableChartDataModels,
  });

  @override
  _ChartTableWidgetState createState() => _ChartTableWidgetState();
}

class _ChartTableWidgetState extends State<ChartTableWidget> {
  final ScrollController _verticalScrollController = ScrollController();

  @override
  void dispose() {
    _verticalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
    const dataHeight = 30.0;

    final sortTableDataModels = widget.tableChartDataModels..sort((a, b) => a.rank.compareTo(b.rank));

    final columnSizes = [
      60.px,
      ...List.generate(widget.headerTitles.length, (index) {
        switch (widget.headerTitles[index].$1) {
          case TableDataType.country:
            return 100.px;
          case TableDataType.name:
            return 200.px;
          default:
            return 100.px;
        }
      }),
      1.fr,
    ];
    final rowSizes = [
      25.px,
      25.px,
      1.fr,
    ];

    return SizedBox(
      child: LayoutGrid(
        columnSizes: columnSizes, // 3개의 컬럼, 각각 동일한 비율
        rowSizes: rowSizes, // 4개의 행, 첫 행은 절반 크기
        children: [
          // Rank
          Container(
            decoration: BoxDecoration(
              color: widget.headerColor,
              border: widget.border,
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
          ...List.generate(widget.headerTitles.length, (index) {
            return Container(
              decoration: BoxDecoration(
                color: widget.headerColor,
                border: widget.border,
              ),
              child: Center(
                child: Text(
                  widget.headerTitles[index].$2,
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
            decoration: BoxDecoration(color: widget.headerColor),
            child: Center(
              child: Text(
                widget.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ).withGridPlacement(
            columnStart: widget.headerTitles.length + 1,
            columnSpan: 1,
            rowStart: 0,
            rowSpan: 1,
          ),
          // Years
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(
                  provider.getYearRange().end.toInt() - provider.getYearRange().start.toInt() + 1,
                  (index) {
                    return Container(
                      width: 60,
                      decoration: BoxDecoration(
                        color: widget.yearColor,
                        border: widget.border,
                      ),
                      child: Center(
                        child: Text(
                          (provider.getYearRange().start.toInt() + index).toString(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ).withGridPlacement(
            columnStart: widget.headerTitles.length + 1,
            columnSpan: 1,
            rowStart: 1,
            rowSpan: 1,
          ),

          //Rank
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: List.generate(sortTableDataModels.length, (index) {
                  return Container(
                    height: dataHeight,
                    decoration: BoxDecoration(
                      color: index % 2 == 0 ? Colors.white : const Color.fromARGB(175, 220, 220, 220),
                      border: widget.border,
                    ),
                    child: Center(
                      child: Text(
                        sortTableDataModels[index].rank.toString(),
                        style: const TextStyle(fontSize: 12, color: Colors.black),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ).withGridPlacement(
            columnStart: 0,
            columnSpan: 1,
            rowStart: 2,
            rowSpan: 1,
          ),

          //Header Title
          ...List.generate(widget.headerTitles.length, (headerIndex) {
            return ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
              child: SingleChildScrollView(
                controller: _verticalScrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Column(
                  children: List.generate(sortTableDataModels.length, (sortIndex) {
                    final countryCode = CommonUtils.instance.replaceCountryCode(sortTableDataModels[sortIndex].dataInfo[widget.headerTitles[headerIndex].$1].toString());

                    return Container(
                      width: (() {
                        switch (widget.headerTitles[headerIndex].$1) {
                          case TableDataType.country:
                            return 100.0;
                          case TableDataType.name:
                            return 200.0;
                          default:
                            return 100.0;
                        }
                      }()),
                      height: dataHeight,
                      decoration: BoxDecoration(
                        color: sortIndex % 2 == 0 ? Colors.white : const Color.fromARGB(175, 220, 220, 220),
                        border: widget.border,
                      ),
                      child: (() {
                        switch (widget.headerTitles[headerIndex].$1) {
                          case TableDataType.country:
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                CountryFlag.fromCountryCode(countryCode, height: 25, width: 25),
                                Text(
                                  countryCode,
                                ),
                              ],
                            );
                          case TableDataType.name:
                            return Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                sortTableDataModels[sortIndex].name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          default:
                            return const SizedBox();
                        }
                      }()),
                    );
                  }),
                ),
              ),
            ).withGridPlacement(
              columnStart: headerIndex + 1,
              columnSpan: 1,
              rowStart: 2,
              rowSpan: 1,
            );
          }),

          //data
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
              controller: _verticalScrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              child: Column(
                children: List.generate(sortTableDataModels.length, (dataIndex) {
                  return ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          provider.getYearRange().end.toInt() - provider.getYearRange().start.toInt() + 1,
                          (yearIndex) {
                            return Container(
                              height: dataHeight,
                              width: 60,
                              decoration: BoxDecoration(
                                color: dataIndex % 2 == 0 ? Colors.white : const Color.fromARGB(175, 220, 220, 220),
                                border: widget.border,
                              ),
                              child: Center(
                                child: Text(
                                  sortTableDataModels[dataIndex].yearDatas[provider.getYearRange().start.toInt() + yearIndex]?.toStringAsFixed(4) ?? '0.0',
                                  style: const TextStyle(fontSize: 12, color: Colors.black),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ).withGridPlacement(
            columnStart: widget.headerTitles.length + 1,
            columnSpan: 1,
            rowStart: 2,
            rowSpan: 1,
          ),
        ],
      ),
    );
  }
}

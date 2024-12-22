import 'package:country_flags/country_flags.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  State<ChartTableWidget> createState() => _ChartTableWidgetState();
}

class _ChartTableWidgetState extends State<ChartTableWidget> {
  final ScrollController _verticalScrollControllerRank = ScrollController();
  final ScrollController _verticalScrollControllerData = ScrollController();
  List<ScrollController> _verticalScrollControllerHeaderTitle = [];

  final ScrollController _horizontalScrollControllerYears = ScrollController();
  List<ScrollController> _horizontalScrollControllerData = [];

  @override
  void initState() {
    super.initState();
    _verticalScrollControllerHeaderTitle = List.generate(widget.headerTitles.length, (index) => ScrollController());
    _horizontalScrollControllerData = List.generate(widget.tableChartDataModels.length, (index) => ScrollController());
  }

  @override
  void dispose() {
    _verticalScrollControllerRank.dispose();
    for (var controller in _verticalScrollControllerHeaderTitle) {
      controller.dispose();
    }
    _verticalScrollControllerData.dispose();

    _horizontalScrollControllerYears.dispose();
    for (var controller in _horizontalScrollControllerData) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _verticalScrollControllerHeaderTitle = List.generate(widget.headerTitles.length, (index) => ScrollController());
    _horizontalScrollControllerData = List.generate(widget.tableChartDataModels.length, (index) => ScrollController());

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
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {
          _horizontalScrollControllerYears.jumpTo(_horizontalScrollControllerYears.position.pixels - details.delta.dx);
          for (var controller in _horizontalScrollControllerData) {
            controller.jumpTo(controller.position.pixels - details.delta.dx);
          }
        },
        onVerticalDragUpdate: (details) {
          // Check if scrolling up and already at top
          if (details.delta.dy > 0 && _verticalScrollControllerRank.position.pixels <= _verticalScrollControllerRank.position.minScrollExtent) {
            return;
          }
          _verticalScrollControllerRank.jumpTo(_verticalScrollControllerRank.position.pixels - details.delta.dy);
          _verticalScrollControllerData.jumpTo(_verticalScrollControllerData.position.pixels - details.delta.dy);
          for (var controller in _verticalScrollControllerHeaderTitle) {
            controller.jumpTo(controller.position.pixels - details.delta.dy);
          }
        },
        child: Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (event is PointerScrollEvent) {
              if (event.kind == PointerDeviceKind.mouse) {
                if (HardwareKeyboard.instance.isControlPressed) {
                  // Horizontal scroll
                  _horizontalScrollControllerYears.jumpTo(_horizontalScrollControllerYears.position.pixels + event.scrollDelta.dy);
                  for (var controller in _horizontalScrollControllerData) {
                    controller.jumpTo(controller.position.pixels + event.scrollDelta.dy);
                  }
                } else {
                  // Vertical scroll
                  // Check if scrolling up and already at top
                  if (event.scrollDelta.dy < 0 && _verticalScrollControllerRank.position.pixels <= _verticalScrollControllerRank.position.minScrollExtent) {
                    return;
                  }
                  _verticalScrollControllerRank.jumpTo(_verticalScrollControllerRank.position.pixels + event.scrollDelta.dy);
                  _verticalScrollControllerData.jumpTo(_verticalScrollControllerData.position.pixels + event.scrollDelta.dy);
                  for (var controller in _verticalScrollControllerHeaderTitle) {
                    controller.jumpTo(controller.position.pixels + event.scrollDelta.dy);
                  }
                }
              }
            }
          },
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              scrollbars: false,
              physics: const NeverScrollableScrollPhysics(),
            ),
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
                      style: TextStyle(color: Colors.white, fontSize: 13),
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
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                      ),
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
                    controller: _horizontalScrollControllerYears,
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
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 10,
                                ),
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
                  behavior: ScrollConfiguration.of(context).copyWith(
                    scrollbars: false,
                  ),
                  child: SingleChildScrollView(
                    controller: _verticalScrollControllerRank,
                    physics: const NeverScrollableScrollPhysics(),
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
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                              ),
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
                      controller: _verticalScrollControllerHeaderTitle[headerIndex],
                      physics: const NeverScrollableScrollPhysics(),
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
                                      CountryFlag.fromCountryCode(countryCode, height: 20, width: 20),
                                      Text(
                                        countryCode,
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  );
                                case TableDataType.name:
                                  return Container(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      sortTableDataModels[sortIndex].name,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 10,
                                      ),
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
                    controller: _verticalScrollControllerData,
                    physics: const NeverScrollableScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: List.generate(sortTableDataModels.length, (dataIndex) {
                        return ScrollConfiguration(
                          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                          child: SingleChildScrollView(
                            controller: _horizontalScrollControllerData[dataIndex],
                            physics: const NeverScrollableScrollPhysics(),
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
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.black,
                                        ),
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
          ),
        ),
      ),
    );
  }
}

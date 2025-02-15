import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_chart_data.dart';
import 'package:provider/provider.dart';

class ChartWidgetTechCompetition extends StatefulWidget {
  const ChartWidgetTechCompetition({super.key});

  @override
  State<ChartWidgetTechCompetition> createState() => _ChartWidgetTechCompetitionState();
}

class _ChartWidgetTechCompetitionState extends State<ChartWidgetTechCompetition> with SingleTickerProviderStateMixin {
  final double _maxYRatio = 1.6;
  bool _isTableVisible = false;
  bool _isMaxHeightTable = false;

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
    List<String> codes = [];
    if (provider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
      codes = provider.selectedCountries.toList();
      if (codes.isEmpty) {
        codes = provider.getAvailableCountriesFromTechCompetition(provider.selectedTechCode).take(10).toList();
      }
    } else if (provider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
      codes = provider.selectedCompanies.toList();
      if (codes.isEmpty) {
        codes = provider.getAvailableCompaniesFromTechCompetition(provider.selectedTechCode).take(10).toList();
      }
    } else if (provider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
      codes = provider.selectedAcademics.toList();
      if (codes.isEmpty) {
        codes = provider.getAvailableAcademicsFromTechCompetition(provider.selectedTechCode).take(10).toList();
      }
    }
    final chartKey = GlobalKey();
    final tableKey = GlobalKey();
    return RepaintBoundary(
      key: chartKey,
      child: LayoutBuilder(builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            children: [
              Visibility(
                visible: !_isMaxHeightTable,
                child: Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight * 0.1,
                  padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.035,
                  ),
                  child: Row(
                    children: [
                      Container(
                        alignment: Alignment.centerLeft,
                        width: constraints.maxWidth * 0.175,
                        height: constraints.maxHeight * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromARGB(255, 109, 207, 245),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              " ${provider.selectedSubCategory} 기술경쟁력 ",
                              style: TextStyle(
                                fontSize: constraints.maxHeight * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: constraints.maxWidth * 0.2025),
                      Container(
                        alignment: Alignment.centerLeft,
                        width: constraints.maxWidth * 0.175,
                        height: constraints.maxHeight * 0.1,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: const Color.fromARGB(255, 109, 207, 245),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(
                            child: Text(
                              " ${provider.selectedTechCode} ",
                              style: TextStyle(
                                fontSize: constraints.maxHeight * 0.035,
                                fontWeight: FontWeight.bold,
                                color: Colors.brown,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Spacer(), // 중간 공간을 채움
                      CommonUtils.instance.saveMenuPopup(
                        constraints: constraints,
                        chartKey: chartKey,
                        dataProvider: provider,
                        techCodes: [provider.selectedTechCode ?? ''],
                        chartCodes: codes,
                      ),
                    ],
                  ),
                ),
              ),
              Visibility(
                visible: !_isMaxHeightTable,
                child: Expanded(
                  child: _buildChartBarType(codes),
                ),
              ),
              Row(
                children: [
                  Flexible(
                    flex: 18,
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          if (_isMaxHeightTable) {
                            return;
                          }
                          _isTableVisible = !_isTableVisible;
                        });
                      },
                      child: Container(
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center, // 왼쪽 정렬 유지
                          children: [
                            Icon(
                              _isTableVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                              size: 28,
                              color: Colors.blue[700],
                            ),
                            Text(
                              _isTableVisible ? '테이블 닫기' : '테이블 보기',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _isTableVisible,
                    child: Flexible(
                      flex: 1,
                      child: Container(
                        width: constraints.maxWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _isMaxHeightTable = !_isMaxHeightTable;
                            });
                          },
                          child: Center(
                            child: Icon(
                              _isMaxHeightTable ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                              size: 28,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: _isTableVisible,
                    child: Flexible(
                      flex: 2,
                      child: PopupMenuButton<String>(
                        offset: Offset(constraints.maxHeight * 0, constraints.maxHeight * 0.02),
                        position: PopupMenuPosition.under,
                        onSelected: (String value) async {
                          switch (value) {
                            case 'PNG':
                            case 'JPG':
                              CommonUtils.instance.saveImage(format: value, chartKey: chartKey);
                              break;
                            case 'CSV':
                              // _handleCsvExport(chartKey, dataProvider, techCodes, chartCodes);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'PNG',
                            height: constraints.maxHeight * 0.05,
                            padding: EdgeInsets.zero,
                            child: const Center(child: Text('PNG')),
                          ),
                          PopupMenuItem<String>(
                            value: 'JPG',
                            height: constraints.maxHeight * 0.05,
                            padding: EdgeInsets.zero,
                            child: const Center(child: Text('JPG')),
                          ),
                          PopupMenuItem<String>(
                            value: 'CSV',
                            height: constraints.maxHeight * 0.05,
                            padding: EdgeInsets.zero,
                            child: const Center(child: Text('CSV')),
                          ),
                        ],
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.download,
                              size: 28,
                              color: Colors.blue[700],
                            ),
                            Text(
                              ' 저장',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              LayoutBuilder(builder: (context, constraints2) {
                return RepaintBoundary(
                  key: tableKey,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),

                    height: (() {
                      if (_isMaxHeightTable) {
                        return constraints.maxHeight.toDouble() * 0.9;
                      }

                      if (_isTableVisible) {
                        return 300.toDouble();
                      } else {
                        return 0.toDouble();
                      }
                    })(), // 테이블의 최대 높이를 300으로 설정
                    child: const TableChartData(),
                  ),
                );
              }),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLegend(List<String> codes) {
    final provider = context.watch<AnalysisDataProvider>();
    final scrollController = ScrollController();
    return Container(
      constraints: const BoxConstraints(maxWidth: 1500),
      child: MouseRegion(
        cursor: SystemMouseCursors.grab, // 마우스 커서 모양 변경
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            if (scrollController.hasClients) {
              scrollController.position.moveTo(
                scrollController.offset - details.delta.dx,
                clamp: true,
              );
            }
          },
          child: Listener(
            onPointerSignal: (pointerSignal) {
              if (pointerSignal is PointerScrollEvent) {
                final offset = pointerSignal.scrollDelta.dy;
                if (scrollController.hasClients) {
                  scrollController.jumpTo(
                    (scrollController.offset + offset).clamp(
                      0.0,
                      scrollController.position.maxScrollExtent,
                    ),
                  );
                }
              }
            },
            child: SingleChildScrollView(
              controller: scrollController,
              scrollDirection: Axis.horizontal,
              dragStartBehavior: DragStartBehavior.down,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: codes.asMap().entries.map((entry) {
                  final color = provider.getColorForCode(codes[entry.key]);

                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 2,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            (() {
                              if (provider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
                                return CountryFlag.fromCountryCode(
                                  CommonUtils.instance.replaceCountryCode(codes[entry.key]),
                                  height: 16,
                                  width: 16,
                                );
                              } else {
                                return const SizedBox.shrink();
                              }
                            }()),
                            const SizedBox(width: 4),
                            Text(
                              CommonUtils.instance.replaceCountryCode(codes[entry.key]),
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChartBarType(List<String> codes) {
    final provider = context.watch<AnalysisDataProvider>();

    const dataCode = "TC";

    Map<String, double> chartDataList = {};
    for (int i = 0; i < codes.length; i++) {
      final chartData = provider.getTechCompetitionChartData(
        techCode: provider.selectedTechCode,
        dataCode: dataCode,
        country: provider.selectedSubCategory == AnalysisSubCategory.countryDetail ? codes[i] : null,
        targetName: provider.selectedSubCategory != AnalysisSubCategory.countryDetail ? codes[i] : null,
      );
      chartDataList[codes[i]] = chartData[provider.endYear] ?? 0.0;
    }

    // 최소값과 최대값 계산
    final maxValue = chartDataList.values.reduce(max);
    final interval = CommonUtils.instance.calculateInterval(maxValue);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            LayoutBuilder(builder: (context, constraints) {
              return Container(
                margin: EdgeInsets.only(
                  left: constraints.maxWidth * 0.7,
                  bottom: constraints.maxHeight * 0.3,
                ),
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: codes.asMap().entries.map((entry) {
                      final color = provider.getColorForCode(codes[entry.key]);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 2,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            (() {
                              String countryCode = codes[entry.key];
                              if (provider.selectedSubCategory != AnalysisSubCategory.countryDetail) {
                                countryCode = provider.searchCountryCode(codes[entry.key]);
                              }

                              return CountryFlag.fromCountryCode(
                                CommonUtils.instance.replaceCountryCode(countryCode),
                                height: 16,
                                width: 16,
                              );
                            }()),
                            const SizedBox(width: 4),
                            Text(
                              CommonUtils.instance.replaceCountryCode(codes[entry.key]),
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }),
            _buildBarChart(
              chartData: chartDataList,
              maxValue: maxValue,
              interval: interval,
            ),
          ],
        );
      },
    );
  }

  /// 시각화의 막대 차트 컴포넌트를 생성
  Widget _buildBarChart({
    required Map<String, double> chartData,
    required double maxValue,
    required double interval,
  }) {
    final provider = context.watch<AnalysisDataProvider>();
    final barWidth = (MediaQuery.of(context).size.width / (chartData.length * 12)).clamp(8.0, 24.0);

    return LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxValue * _maxYRatio,
              barTouchData: BarTouchData(
                enabled: false, // 터치 기능 비활성화
              ),
              titlesData: _buildTitlesData(chartData.keys.toList(), interval),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  left: BorderSide(color: Colors.grey.shade400),
                  right: const BorderSide(color: Colors.transparent),
                  top: const BorderSide(color: Colors.transparent),
                  bottom: BorderSide(color: Colors.grey.shade400),
                ),
              ),
              barGroups: chartData.keys.toList().asMap().entries.map((entry) {
                final index = entry.key;
                final code = entry.value;
                final value = chartData[code] ?? 0.0;

                final shouldShow = index <= (chartData.length - 1) * _controller.value;

                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: shouldShow ? value : 0,
                      color: provider.getColorForCode(code),
                      width: barWidth,
                      borderRadius: BorderRadius.circular(2),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: shouldShow ? value : 0,
                        color: Colors.transparent,
                      ),
                    ),
                  ],
                  barsSpace: 4,
                );
              }).toList(),
            ),
          ),
          // Add bar value labels
          ...chartData.keys.toList().asMap().entries.map((entry) {
            final index = entry.key;
            final code = entry.value;
            final value = chartData[code] ?? 0.0;
            final shouldShow = index <= (chartData.length - 1) * _controller.value;

            String countryCode = CommonUtils.instance.replaceCountryCode(code);
            if (provider.selectedSubCategory != AnalysisSubCategory.countryDetail) {
              countryCode = CommonUtils.instance.replaceCountryCode(provider.searchCountryCode(code));
            }
            if (!shouldShow) return const SizedBox.shrink();

            // Calculate position for value label
            final barX = (constraints.maxWidth - 42) * (index + 0.5) / chartData.length;
            final barY = (constraints.maxHeight) - (value / (maxValue * _maxYRatio)) * (constraints.maxHeight - 40) - 40; // Adjust for padding

            return Positioned(
              left: barX + 15, // Center align with bar
              top: barY - 26, // Position above bar
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: shouldShow ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: provider.getColorForCode(code),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CountryFlag.fromCountryCode(
                        countryCode,
                        height: 16,
                        width: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        value.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 10,
                          color: provider.getColorForCode(code),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  FlTitlesData _buildTitlesData(List<String> codes, double interval) {
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              '${(value + 1).toInt()}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            );
          },
          reservedSize: 24,
        ),
      ),
      // 좌측 타이틀 (값)
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            // value를 Decimal로 변환하고 소수점 두 자리로 반올림
            final Decimal roundedValue = Decimal.parse(value.toStringAsFixed(2)); // 소수점 두 자리로 반올림
            final Decimal decimalInterval = Decimal.parse(interval.toString()); // interval을 Decimal로 변환

            if (roundedValue % decimalInterval != Decimal.zero) {
              return const SizedBox.shrink(); // 최댓값일 경우 빈 위젯 반환
            }
            // roundedValue가 10 이상이면 정수로 표시
            if (roundedValue >= Decimal.fromInt(10) || decimalInterval >= Decimal.fromInt(10)) {
              return Text(
                roundedValue.toString(), // 정수로 표시
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              );
            }
            // roundedValue가 10보다 작으면 소수점 2자리까지 표시
            return Text(
              roundedValue.toStringAsFixed(2), // 소수점 2자리까지 표시
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            );
          },
          interval: interval,
          reservedSize: 40,
        ),
      ),
      // 오른쪽과 상단은 숨김 유지
      rightTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
      topTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
      ),
    );
  }
}

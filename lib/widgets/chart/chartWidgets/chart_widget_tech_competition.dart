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
  AnalysisCategory get _category => AnalysisCategory.techCompetition;
  final double _maxYRatio = 1.6;
  bool _isTableVisible = false;

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
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          top: constraints.maxHeight * 0.05,
        ),
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Column(
            children: [
              Center(
                child: _buildLegend(codes),
              ),
              Expanded(
                child: _buildChartBarType(codes),
              ),
              InkWell(
                onTap: () {
                  setState(() {
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
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _isTableVisible ? 300 : 0, // 테이블의 최대 높이를 300으로 설정
                child: const SingleChildScrollView(
                  child: SizedBox(
                    height: 300,
                    child: TableChartData(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildTableChart() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.green,
      ),
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
                                fontSize: 15,
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
      chartDataList[codes[i]] = chartData[2023] ?? 0.0;
    }

    // 최소값과 최대값 계산
    final maxValue = chartDataList.values.reduce(max);
    final interval = CommonUtils.instance.calculateInterval(maxValue);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return _buildBarChart(
          chartData: chartDataList,
          maxValue: maxValue,
          interval: interval,
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

    return Container(
      padding: const EdgeInsets.only(
        top: 16,
        left: 40,
        right: 16,
        bottom: 24,
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxValue * _maxYRatio,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.white.withOpacity(0.8),
              tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                try {
                  final codes = chartData.keys.toList();
                  final code = codes[groupIndex];
                  final value = rod.toY;
                  return BarTooltipItem(
                    '$code ${value.toStringAsFixed(4)}',
                    const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    children: const [],
                  );
                } catch (e) {
                  return BarTooltipItem(',', const TextStyle(color: Colors.black));
                }
              },
              fitInsideHorizontally: true,
              fitInsideVertically: true,
            ),
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
    );
  }

  FlTitlesData _buildTitlesData(List<String> codes, double interval) {
    return FlTitlesData(
      show: true,
      bottomTitles: const AxisTitles(
        sideTitles: SideTitles(showTitles: false),
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

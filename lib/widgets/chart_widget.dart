import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_state_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ChartWidget extends StatelessWidget {
  final AnalysisCategory category;
  final AnalysisSubCategory? selectedSubCategory;

  const ChartWidget({
    super.key,
    required this.category,
    this.selectedSubCategory,
  });

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final stateProvider = context.watch<AnalysisStateProvider>();

    // 디버그 출력 추가
    print('ChartWidget - Current LC Code: ${stateProvider.selectedDataCode}');

    // 데이터 로딩 중일 때
    if (dataProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 에러가 있을 때
    if (dataProvider.error != null) {
      return Center(
        child: Text('Error: ${dataProvider.error}'),
      );
    }

    // 서브카테고리가 선택되지 않았을 때
    if (selectedSubCategory == null) {
      return const Center(
        child: Text('서브카테고리를 선택해주세요'),
      );
    }

    // 차트 데이터 가져오기
    final chartData = dataProvider.getChartData(
      category: category,
      subCategory: selectedSubCategory!,
      selectedLcCode: stateProvider.selectedDataCode,
    );

    print('Chart Data for ${stateProvider.selectedDataCode}: $chartData');

    if (chartData.isEmpty) {
      return const Center(
        child: Text('데이터가 없습니다. (PAN 데이터 검색 중)'),
      );
    }

    // 연도 범위 가져오기
    final (minYear, maxYear) = dataProvider.getYearRange();

    // 막대 그래프의 x축 위치 계산
    final barLocations = List.generate(chartData.length, (index) => index);
    final maxX = (chartData.length - 1).toDouble();

    final barTouchData = BarTouchData(
      enabled: true,
      touchTooltipData: BarTouchTooltipData(
        tooltipBgColor: Colors.transparent,
        tooltipPadding: EdgeInsets.zero,
        tooltipMargin: 8,
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          return BarTooltipItem(
            rod.toY.toInt().toString(),
            const TextStyle(
              color: Colors.black,
              fontSize: 12,
            ),
          );
        },
      ),
    );

    // CAGR 추세선 데이터 계산
    final years = chartData.keys.toList()..sort();
    final startYear = years.first;
    final startValue = chartData[startYear]!;

    // 각 연도별 CAGR 12.5% 값 계산
    final cargLineSpots = years.map((year) {
      final yearDiff = year - startYear;
      final expectedValue = startValue * pow(1 + 0.125, yearDiff);
      return FlSpot(year.toDouble(), expectedValue);
    }).toList();

    // Y축 최대값 계산
    final maxY =
        chartData.values.reduce((max, value) => value > max ? value : max) *
            1.2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 40, bottom: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'LC: ${stateProvider.selectedDataCode}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 40,
                  right: 16,
                  bottom: 24,
                ),
                child: BarChart(
                  BarChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            return Text(value.toInt().toString());
                          },
                          interval: 1,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: ((chartData.values.reduce((max, value) =>
                                              value > max ? value : max) *
                                          1.1) /
                                      10)
                                  .ceil() ~/
                              100 *
                              100,
                          getTitlesWidget: (value, meta) {
                            if (value % 100 != 0) {
                              return const SizedBox.shrink();
                            }
                            return SizedBox(
                              width: 40,
                              child: Text(
                                value.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            );
                          },
                          reservedSize: 40,
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    barGroups: chartData.entries
                        .map((e) => BarChartGroupData(
                              x: e.key,
                              barRods: [
                                BarChartRodData(
                                  toY: e.value,
                                  color: Colors.blue,
                                  width: 16,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ],
                              showingTooltipIndicators: [0],
                            ))
                        .toList(),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.transparent,
                        tooltipPadding: EdgeInsets.zero,
                        tooltipMargin: 8,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            rod.toY.toInt().toString(),
                            const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          );
                        },
                      ),
                    ),
                    maxY: maxY, // 막대 그래프 Y축 최대값 설정
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 40,
                  right: 16,
                  bottom: 24,
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: const FlTitlesData(show: false),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: cargLineSpots,
                        isCurved: true, // 부드러운 곡선으로 연결
                        color: Colors.red,
                        dotData: const FlDotData(show: false),
                        dashArray: [5, 5],
                        barWidth: 2,
                      ),
                    ],
                    minX: startYear - 1,
                    maxX: years.last + 1,
                    minY: 0,
                    maxY: maxY, // 라인 차트도 동일한 Y축 최대값 사용
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

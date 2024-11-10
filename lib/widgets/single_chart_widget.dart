import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/enum_defines.dart';
import '../providers/analysis_data_provider.dart';

class SingleChartWidget extends StatelessWidget {
  final AnalysisCategory category;
  final AnalysisSubCategory? selectedSubCategory;
  final String codeTitle;
  final String? dataCode;
  final List<String>? selectedCodes;
  final double height;
  final double maxYRatio;
  final int startYear;
  final int endYear;

  const SingleChartWidget({
    super.key,
    required this.category,
    required this.selectedSubCategory,
    required this.codeTitle,
    required this.dataCode,
    this.selectedCodes,
    this.height = 400,
    this.maxYRatio = 1.2,
    required this.startYear,
    required this.endYear,
  });

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(selectedSubCategory);

    // 차트 데이터를 연도 범위로 필터링
    Map<int, double> filterChartData(Map<int, double> data) {
      return Map.fromEntries(
        data.entries
            .where((entry) => entry.key >= startYear && entry.key <= endYear),
      );
    }

    if (isIndexType && selectedCodes != null) {
      // 여러 코드의 데이터를 모두 가져옴
      double maxValue = 0;
      final allTrendLines = <LineChartBarData>[];
      List<int> years = [];
      final colors = [
        Colors.blue,
        Colors.red,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
      ];

      // 첫 번째 유효한 데이터에서 years 가져오기
      for (final code in selectedCodes!) {
        final chartData = filterChartData(dataProvider.getChartData(
          category: category,
          subCategory: selectedSubCategory!,
          selectedLcCode: code,
        ));
        if (chartData.isNotEmpty) {
          years = chartData.keys.toList()..sort();
          break;
        }
      }

      if (years.isEmpty) {
        return const SizedBox.shrink();
      }

      // 각 코드별 추세선 생성
      for (var i = 0; i < selectedCodes!.length; i++) {
        final code = selectedCodes![i];
        final chartData = filterChartData(dataProvider.getChartData(
          category: category,
          subCategory: selectedSubCategory!,
          selectedLcCode: code,
        ));

        if (chartData.isEmpty) continue;

        final currentMax = chartData.values.reduce(max);
        maxValue = max(maxValue, currentMax);

        final trendLineSpots = calculateTrendLine(chartData, years);
        allTrendLines.add(
          LineChartBarData(
            spots: trendLineSpots,
            isCurved: true,
            color: colors[i % colors.length],
            barWidth: 2,
            dotData: const FlDotData(show: false),
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        );
      }

      final interval = calculateInterval(maxValue);

      return SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 40, bottom: 8),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      codeTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 범례 표시
                  ...selectedCodes!.asMap().entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 12,
                            height: 2,
                            color: colors[entry.key % colors.length],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            entry.value,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.only(
                  top: 16,
                  left: 40,
                  right: 16,
                  bottom: 24,
                ),
                child: LineChart(
                  LineChartData(
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 && index < years.length) {
                              return Text(years[index].toString());
                            }
                            return const Text('');
                          },
                          reservedSize: 24,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            if (value % interval != 0) {
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
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: allTrendLines,
                    minY: 0,
                    maxY: maxValue * maxYRatio,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // 지수 타입이 아닐 때 (기존 Bar 차트)
    final chartData = filterChartData(dataProvider.getChartData(
      category: category,
      subCategory: selectedSubCategory!,
      selectedLcCode: dataCode,
    ));

    if (chartData.isEmpty) {
      return const SizedBox.shrink();
    }

    final years = chartData.keys.toList()..sort();
    final maxValue = chartData.values.reduce(max);
    final interval = calculateInterval(maxValue);

    return SizedBox(
      height: height,
      child: Column(
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
                codeTitle,
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
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxValue * maxYRatio,
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchTooltipData: BarTouchTooltipData(
                          tooltipBgColor: Colors.transparent,
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
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index >= 0 && index < years.length) {
                                return Text(years[index].toString());
                              }
                              return const Text('');
                            },
                            reservedSize: 24,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: interval,
                            getTitlesWidget: (value, meta) {
                              if (value % interval != 0) {
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
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: true),
                      barGroups: List.generate(
                        chartData.length,
                        (index) {
                          final year = years[index];
                          final value = chartData[year]!;
                          return BarChartGroupData(
                            x: index,
                            barRods: [
                              BarChartRodData(
                                toY: value,
                                color: Colors.blue,
                                width: 16,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                            showingTooltipIndicators: [0],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                // CAGR 추세선
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
                          spots: years.map((year) {
                            final yearDiff = year - years.first;
                            final startValue = chartData[years.first]!;
                            final expectedValue =
                                startValue * pow(1 + 0.125, yearDiff);
                            return FlSpot(
                                years.indexOf(year).toDouble(), expectedValue);
                          }).toList(),
                          isCurved: true,
                          color: Colors.red,
                          dotData: const FlDotData(show: false),
                          dashArray: [5, 5],
                          barWidth: 2,
                        ),
                      ],
                      minX: -1,
                      maxX: years.length.toDouble(),
                      minY: 0,
                      maxY: maxValue * maxYRatio,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double calculateInterval(double maxValue) {
    if (maxValue <= 0) return 100;
    final log = (maxValue * 1.1).ceil();
    if (log <= 100) return 20;
    if (log <= 500) return 100;
    if (log <= 1000) return 200;
    return (log / 5).ceil().toDouble();
  }

  // 추세선 계산 함수 추가
  List<FlSpot> calculateTrendLine(Map<int, double> data, List<int> years) {
    if (years.length < 2) return [];

    // 선형 회귀 계산을 위한 변수들
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumX2 = 0;
    int n = years.length;

    // x축을 0부터 시작하는 인덱스로 변환
    for (int i = 0; i < n; i++) {
      double x = i.toDouble();
      double y = data[years[i]]!;

      sumX += x;
      sumY += y;
      sumXY += x * y;
      sumX2 += x * x;
    }

    // 기울기(m)와 y절편(b) 계산
    double m = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX);
    double b = (sumY - m * sumX) / n;

    // 추세선 포인트 생성
    return List.generate(n, (i) {
      return FlSpot(i.toDouble(), m * i + b);
    });
  }
}

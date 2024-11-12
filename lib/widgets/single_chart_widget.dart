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
  final TechListType? selectedTechListType;
  final String? techCode;
  final List<String>? selectedCodes;
  final String? country;
  final List<String>? countries;
  final double height;
  final double width;
  final double maxYRatio;
  final Color? chartColor;
  final CagrCalculationMode cagrMode;

  const SingleChartWidget({
    super.key,
    required this.category,
    required this.selectedSubCategory,
    required this.codeTitle,
    required this.selectedTechListType,
    this.techCode,
    this.selectedCodes,
    this.country,
    this.countries,
    this.height = 400,
    this.width = 400,
    this.maxYRatio = 1.2,
    this.chartColor,
    this.cagrMode = CagrCalculationMode.fullPeriod,
  });

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(selectedSubCategory);

    List<String> chartLoopCodes = [];
    if (selectedCodes != null) {
      chartLoopCodes.addAll(selectedCodes!);
    } else if (countries != null) {
      chartLoopCodes.addAll(countries!);
    }

    if (isIndexType && chartLoopCodes.isNotEmpty) {
      return _buildMultiLineChart(context, dataProvider, chartLoopCodes);
    }
    return _buildBarChartWithTrendLine(context, dataProvider);
  }

  /// 여러 데이터셋을 비교하기 위한 다중 선 차트를 생성
  Widget _buildMultiLineChart(BuildContext context,
      AnalysisDataProvider dataProvider, List<String> chartLoopCodes) {
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
    for (final code in chartLoopCodes) {
      final chartData = _getFilteredChartData(
        context,
        techCode ?? selectedCodes![0],
        category == AnalysisCategory.countryTech ? code : null,
      );
      if (chartData.isNotEmpty) {
        years = chartData.keys.toList()..sort();
        break;
      }
    }

    if (years.isEmpty) return const SizedBox.shrink();

    // 각 코드별 추세선 생성
    for (var i = 0; i < chartLoopCodes.length; i++) {
      final code = chartLoopCodes[i];
      final chartData = _getFilteredChartData(
        context,
        category == AnalysisCategory.countryTech
            ? techCode ?? selectedCodes![0]
            : code,
        category == AnalysisCategory.countryTech ? code : null,
      );

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

    final interval = _calculateInterval(maxValue);

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(codeTitle),
          _buildLegend(chartLoopCodes, colors),
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
                  titlesData: _buildTitlesData(years, interval),
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

  /// 막대 차트와 추세선을 함께 표시하는 차트를 생성
  Widget _buildBarChartWithTrendLine(
      BuildContext context, AnalysisDataProvider dataProvider) {
    final chartData = _getFilteredChartData(
      context,
      techCode ?? selectedCodes![0],
      country,
    );

    if (chartData.isEmpty) return const SizedBox.shrink();

    // CAGR과 추세선 데이터 계산
    final (cagr, trendLineData) = _calculateCagrAndTrendLine(
      context,
      dataProvider,
      chartData,
    );

    final years = chartData.keys.toList()..sort();
    final maxValue = chartData.values.reduce(max);
    final interval = _calculateInterval(maxValue);

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitle(codeTitle),
            Expanded(
              child: Stack(
                children: [
                  _buildBarChart(context, years, chartData, maxValue, interval),
                  _buildTrendLineOverlay(
                      years, trendLineData, maxValue), // 미리 계산된 추세선 데이터 전달
                  _buildCagrOverlay(cagr),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CAGR과 추세선 데이터를 계산
  (double, Map<int, double>) _calculateCagrAndTrendLine(
    BuildContext context,
    AnalysisDataProvider dataProvider,
    Map<int, double> chartData,
  ) {
    switch (cagrMode) {
      case CagrCalculationMode.selectedPeriod:
        // 선택된 기간의 데이터만 사용
        final years = chartData.keys.toList()..sort();
        final cagr = calculateCAGR(
          chartData[years.first] ?? 0,
          chartData[years.last] ?? 0,
          years.last - years.first,
        );

        // 선택된 기간의 추세선 데이터 계산
        final trendLineData = Map.fromEntries(
          years.map((year) {
            final yearDiff = year - years.first;
            final expectedValue =
                chartData[years.first]! * pow(1 + cagr, yearDiff);
            return MapEntry(year, expectedValue);
          }),
        );

        return (cagr, trendLineData);

      case CagrCalculationMode.fullPeriod:
        // 전체 기간의 데이터 사용
        final fullData = dataProvider.getChartData(
          techCode: techCode ?? selectedCodes![0],
          country: country,
        );
        final allYears = fullData.keys.toList()..sort();

        final fullDataCagr = calculateCAGR(
          fullData[allYears.first] ?? 0,
          fullData[allYears.last] ?? 0,
          allYears.last - allYears.first,
        );

        // 전체 기간의 추세선 데이터 계산
        final startValue = fullData[allYears.first] ?? 0;
        final trendLineData = Map.fromEntries(
          allYears.map((year) {
            final yearDiff = year - allYears.first;
            final expectedValue = startValue * pow(1 + fullDataCagr, yearDiff);
            return MapEntry(year, expectedValue);
          }),
        );

        return (fullDataCagr, trendLineData);
    }
  }

  /// 시각화의 막대 차트 컴포넌트를 생성
  Widget _buildBarChart(BuildContext context, List<int> years,
      Map<int, double> chartData, double maxValue, double interval) {
    // 차트의 너비에 따른 막대 두께 계산
    final barWidth = (MediaQuery.of(context).size.width / (years.length * 12))
        .clamp(8.0, 24.0);

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
          maxY: maxValue * maxYRatio,
          barTouchData: BarTouchData(
            enabled: false,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: Colors.transparent,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                try {
                  return BarTooltipItem(
                    rod.toY.toInt().toString(),
                    const TextStyle(color: Colors.black),
                  );
                } catch (e) {
                  return BarTooltipItem(
                      ',', const TextStyle(color: Colors.black));
                }
              },
            ),
          ),
          titlesData: _buildTitlesData(years, interval),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: true),
          barGroups: years.asMap().entries.map((entry) {
            final index = entry.key;
            final year = entry.value;
            final value = chartData[year] ?? 0.0;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: value,
                  color: chartColor ?? Colors.blue,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
              showingTooltipIndicators: [0],
            );
          }).toList(),
        ),
      ),
    );
  }

  /// 추세선 오버레이 컴포넌트를 생성
  Widget _buildTrendLineOverlay(
      List<int> years, Map<int, double> trendLineData, double maxValue) {
    return Container(
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
                getTitlesWidget: (_, __) => const SizedBox(height: 36),
                reservedSize: 36,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (_, __) => const SizedBox(width: 40),
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
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            enabled: false,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
              getTooltipItems: (List<LineBarSpot> touchedSpots) {
                return touchedSpots.map((LineBarSpot touchedSpot) {
                  final year = years[touchedSpot.x.toInt()];
                  return LineTooltipItem(
                    '$year년\n${touchedSpot.y.toStringAsFixed(1)}',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            handleBuiltInTouches: true,
          ),
          lineBarsData: [
            LineChartBarData(
              spots: years.map((year) {
                return FlSpot(
                  years.indexOf(year).toDouble(),
                  trendLineData[year] ?? 0,
                );
              }).toList(),
              isCurved: true,
              color: Colors.red,
              dotData: const FlDotData(show: false),
              dashArray: [5, 5],
              barWidth: 2,
            ),
          ],
          minX: -0.5,
          maxX: years.length.toDouble() - 0.5,
          minY: 0,
          maxY: maxValue * maxYRatio,
        ),
      ),
    );
  }

  /// CAGR 값을 보여주는 오버레이 위젯을 생성
  Widget _buildCagrOverlay(double cagr) {
    return Positioned(
      top: height * 0.1, // 차트 높이의 15% 위치에 배치
      left: width * 0.1, // 차트 너비의 10% 위치에 배치
      right: width * 0.1, // 차트 너비의 10% 위치에 배치
      child: Center(
        child: Text(
          'CAGR ${(cagr * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  /// 최대값을 기준으로 y축의 적절한 간격을 계산
  /// maxValue의 최고 자릿수보다 한 단계 낮은 10의 거듭제곱 값을 반환
  double _calculateInterval(double maxValue) {
    // 자릿수 계산을 위해 로그 사용
    final digitCount = (log(maxValue) / ln10).floor();
    final base = pow(10, digitCount - 1).toDouble();

    // 최고 자릿수 추출
    final firstDigit = (maxValue / pow(10, digitCount)).floor();

    if (firstDigit <= 2) return base * 4; // 2배 증가
    if (firstDigit <= 5) return base * 10; // 2배 증가
    return base * 20; // 2배 증가
  }

  /// 선형 회귀를 사용하여 추세선 포인트를 계산
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

  /// 두 값 사이의 연평균 성장률(CAGR)을 계산
  double calculateCAGR(double startValue, double endValue, int years) {
    return pow((endValue / startValue), 1 / years) - 1;
  }

  /// 차트 제목을 스타일링하여 생성
  Widget _buildTitle(String title) {
    return Container(
      padding: const EdgeInsets.only(left: 80),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[600],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  /// 다중 선 차트를 위한 범례를 생성
  Widget _buildLegend(List<String> codes, List<Color> colors) {
    return Row(
      children: codes.asMap().entries.map((entry) {
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
      }).toList(),
    );
  }

  /// 양쪽 축의 타이틀 데이터를 구성
  FlTitlesData _buildTitlesData(List<int> years, double interval) {
    return FlTitlesData(
      show: true,
      // 하단 타이틀 (연도)
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < years.length) {
              return Transform.rotate(
                angle: -45 * pi / 180,
                child: Text(
                  years[index].toString(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              );
            }
            return const Text('');
          },
          reservedSize: 36,
        ),
      ),
      // 좌측 타이틀 (값)
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            return Text(
              value.toInt().toString(),
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

  /// 선택된 매개변수에 따라 차트 데이터를 검색하고 필터링
  Map<int, double> _getFilteredChartData(
      BuildContext context, String techCode, String? country) {
    // 차트 데이터를 연도 범위로 필터링
    Map<int, double> filterChartData(Map<int, double> data) {
      final provider = context.read<AnalysisDataProvider>();
      return Map.fromEntries(
        data.entries
            .where((entry) =>
                entry.key >= provider.startYear &&
                entry.key <= provider.endYear)
            .toList()
          ..sort((a, b) => a.key.compareTo(b.key)),
      );
    }

    final dataProvider = context.read<AnalysisDataProvider>();
    return filterChartData(dataProvider.getChartData(
      techCode: techCode,
      country: country,
    ));
  }
}

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../models/enum_defines.dart';
import '../providers/analysis_data_provider.dart';
import 'package:decimal/decimal.dart'; // Decimal 패키지 임포트

class SingleChartWidget extends StatelessWidget {
  final AnalysisCategory category;
  final AnalysisSubCategory? selectedSubCategory;
  final String? chartTitle;
  final String? techCode;
  final List<String>? selectedCodes;
  final String? country;
  final List<String>? countries;
  final String? targetName;
  final List<String>? targetNames;
  final double height;
  final double width;
  final double maxYRatio;
  final Color? chartColor;
  final CagrCalculationMode cagrMode;

  const SingleChartWidget({
    super.key,
    required this.category,
    required this.selectedSubCategory,
    this.chartTitle,
    this.techCode,
    this.selectedCodes,
    this.country,
    this.countries,
    this.targetName,
    this.targetNames,
    this.height = 400,
    this.width = 400,
    this.maxYRatio = 1.6,
    this.chartColor,
    this.cagrMode = CagrCalculationMode.selectedPeriod,
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
    } else if (targetNames != null) {
      chartLoopCodes.addAll(targetNames!);
    }

    if ((isIndexType && chartLoopCodes.isNotEmpty) ||
        dataProvider.selectedCategory == AnalysisCategory.techGap) {
      return _buildMultiLineChart(context, dataProvider, chartLoopCodes);
    }
    return _buildBarChartWithTrendLine(context, dataProvider);
  }

  /// 여러 데이터셋을 비교하기 위한 다중 선 차트를 생성
  Widget _buildMultiLineChart(BuildContext context,
      AnalysisDataProvider dataProvider, List<String> chartLoopCodes) {
    double maxValue = 0;
    double minValue = double.infinity;
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
        category == AnalysisCategory.countryTech
            ? code
            : dataProvider.selectedSubCategory ==
                    AnalysisSubCategory.countryDetail
                ? code
                : null,
        category == AnalysisCategory.companyTech ||
                category == AnalysisCategory.academicTech ||
                dataProvider.selectedSubCategory ==
                    AnalysisSubCategory.companyDetail ||
                dataProvider.selectedSubCategory ==
                    AnalysisSubCategory.academicDetail
            ? code
            : null,
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
        category == AnalysisCategory.countryTech ||
                category == AnalysisCategory.companyTech ||
                category == AnalysisCategory.academicTech ||
                category == AnalysisCategory.techGap
            ? techCode ?? selectedCodes![0]
            : code,
        category == AnalysisCategory.countryTech ||
                (category == AnalysisCategory.techGap &&
                    dataProvider.selectedSubCategory ==
                        AnalysisSubCategory.countryDetail)
            ? code
            : null,
        category == AnalysisCategory.companyTech ||
                category == AnalysisCategory.academicTech
            ? code
            : null,
      );

      if (chartData.isEmpty) continue;

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

      final currentMax = trendLineSpots.map((spot) => spot.y).reduce(max);
      maxValue = max(maxValue, currentMax);

      final currentMin = trendLineSpots.map((spot) => spot.y).reduce(min);
      minValue = min(minValue, currentMin);
    }

    final interval = _calculateInterval(maxValue);
    final maxYValue = maxValue * maxYRatio;
    final double adjustedMinY = minValue < 0 ? 0 : minValue;

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                    borderData: FlBorderData(
                      show: true,
                      border: const Border(
                        left: BorderSide(color: Colors.grey),
                        right: BorderSide(color: Colors.transparent),
                        top: BorderSide(color: Colors.transparent),
                        bottom: BorderSide(color: Colors.transparent),
                      ),
                    ),
                    lineBarsData: allTrendLines,
                    minY: adjustedMinY,
                    maxY: maxYValue,
                  ),
                ),
              ),
            ),
            _buildLegend(chartLoopCodes, colors),
          ],
        ),
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
      targetName,
    );

    if (chartData.isEmpty) return const SizedBox.shrink();

    // 최소값과 최대값 계산
    final maxValue = chartData.values.reduce(max);
    final interval = _calculateInterval(maxValue);

    // CAGR과 추세선 데이터 계산
    final (cagr, trendLineData) = _calculateCagrAndTrendLine(
      context,
      dataProvider,
      chartData,
    );

    final years = chartData.keys.toList()..sort();

    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (chartTitle != null) _buildTitle(chartTitle!, chartColor, true),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Stack(
                  children: [
                    _buildBarChart(
                        context, years, chartData, maxValue, interval),
                    _buildTrendLineOverlay(
                        years, trendLineData, maxValue), // 미리 계산된 추세선 데이터 전달
                    _buildCagrOverlay(cagr),
                  ],
                ),
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
    final fullData = dataProvider.getChartData(
      techCode: techCode ?? selectedCodes![0],
      country: country,
      targetName: targetName,
    );
    final allYears = fullData.keys.toList()..sort();

    switch (cagrMode) {
      case CagrCalculationMode.selectedPeriod:
        // 선택된 기간의 데이터만 사용
        final years = chartData.keys.toList()..sort();

        final startYear = years.first;
        final endYear =
            years.last == allYears.last ? years.last - 1 : years.last;

        final cagr = calculateCAGR(
          chartData[startYear] ?? 0,
          chartData[endYear] ?? 0,
          endYear - startYear,
        );

        // 선택된 기간의 추세선 데이터 계산
        final trendLineData = Map.fromEntries(
          years.map((year) {
            final yearDiff = year - years.first;
            double firstData = chartData[years.first] ?? 1;
            firstData = firstData == 0 ? 1 : firstData;
            final expectedValue = firstData * pow(1 + cagr, yearDiff);
            return MapEntry(year, expectedValue);
          }),
        );

        return (cagr, trendLineData);

      case CagrCalculationMode.fullPeriod:
        // 전체 기간의 데이터 사용

        final fullDataCagr = calculateCAGR(
          fullData[allYears.first] ?? 0,
          fullData[allYears.last - 1] ?? 0,
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
          borderData: FlBorderData(
            show: true,
            border: Border(
              left: BorderSide(color: Colors.grey.shade400),
              right: const BorderSide(color: Colors.transparent),
              top: const BorderSide(color: Colors.transparent),
              bottom: BorderSide(color: Colors.grey.shade400),
            ),
          ),
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
    // maxValue가 0이면 기본값 1 반환
    if (maxValue <= 0) return 0.1;

    // 자릿수 계산을 위해 로그 사용
    final digitCount = (log(maxValue) / ln10).floor();
    final base = pow(10, digitCount - 1).toDouble();

    // 최고 자릿수 추출
    final firstDigit = (maxValue / pow(10, digitCount)).floor();

    if (firstDigit <= 2) return base * 4; // 2배 증가
    if (firstDigit <= 5) return base * 10; // 2배 증가
    return base * 20; // 2배 증가
  }

  /// 지수함수 형태로 추세선 포인트를 계산
  List<FlSpot> calculateTrendLine(Map<int, double> data, List<int> years) {
    if (years.length < 2) return [];

    int n = years.length;
    double sumX = 0;
    double sumLnY = 0;
    double sumXLnY = 0;
    double sumX2 = 0;
    int validPoints = 0;

    // x축을 0부터 시작하는 인덱스로 변환하고 로그 변환된 y값 사용
    for (int i = 0; i < n; i++) {
      double x = i.toDouble();
      double? y = data[years[i]];
      if (y != null && y > 0) {
        double lnY = log(y);
        sumX += x;
        sumLnY += lnY;
        sumXLnY += x * lnY;
        sumX2 += x * x;
        validPoints++;
      }
    }

    if (validPoints < 2) {
      return List.generate(n,
          (i) => FlSpot(i.toDouble(), 0)); // 유효한 데이터 포인트가 2개 미만이면 0으로 채운 리스트 반환
    }

    // 지수 회귀 계수 계산
    double b = (validPoints * sumXLnY - sumX * sumLnY) /
        (validPoints * sumX2 - sumX * sumX);
    double a = exp((sumLnY - b * sumX) / validPoints);

    // 추세선 포인트 생성
    return List.generate(n, (i) {
      double y = a * exp(b * i);
      return FlSpot(i.toDouble(), y > 0 ? y : 0); // 음수 값 방지
    });
  }

  /// 두 값 사이의 연평균 성장률(CAGR)을 계산
  double calculateCAGR(double startValue, double endValue, int years) {
    // startValue가 0인 경우 endValue를 years로 나눈 평균 증가율 반환
    if (startValue == 0) {
      startValue = 1;
    }
    // CAGR = (최종값/초기값)^(1/기간) - 1
    return pow((endValue / startValue), 1 / years) - 1;
  }

  /// 차트 제목을 스타일링하여 생성
  Widget _buildTitle(String title, Color? textColor, bool isBarChart) {
    // title -> 좌우 의 [] 제거하면 코드
    String countryCode = title.replaceAll(RegExp(r'[\[\]]'), '');

    return Container(
      padding: const EdgeInsets.only(left: 80),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isBarChart ? Colors.white : Colors.blue,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category == AnalysisCategory.countryTech) ...[
              CountryFlag.fromCountryCode(
                countryCode,
                height: 16,
                width: 24,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isBarChart ? textColor ?? Colors.blue : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 다중 선 차트를 위한 범례를 생성
  Widget _buildLegend(List<String> codes, List<Color> colors) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1500), // 최대 너비 설정
      child: Wrap(
        // Wrap 사용
        alignment: WrapAlignment.center, // 왼쪽 정렬
        spacing: 8, // 자식 위젯 간의 간격
        runSpacing: 4, // 줄 간의 간격
        children: codes.asMap().entries.map((entry) {
          return Row(
            mainAxisSize: MainAxisSize.min, // Row의 크기를 최소로 설정
            children: [
              Container(
                width: 12,
                height: 2,
                color: colors[entry.key % colors.length],
              ),
              const SizedBox(width: 4),
              Text(
                entry.value,
                style: const TextStyle(fontSize: 15),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// 양쪽 축의 타이틀 데이터를 구성
  FlTitlesData _buildTitlesData(List<int> years, double interval) {
    return FlTitlesData(
      show: true,
      // 하단 타틀 (연도)
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
            // value를 Decimal로 변환하고 소수점 두 자리로 반올림
            final Decimal roundedValue =
                Decimal.parse(value.toStringAsFixed(2)); // 소수점 두 자리로 반올림
            final Decimal decimalInterval =
                Decimal.parse(interval.toString()); // interval을 Decimal로 변환

            if (roundedValue % decimalInterval != Decimal.zero) {
              return const SizedBox.shrink(); // 최댓값일 경우 빈 위젯 반환
            }
            // roundedValue가 10 이상이면 정수로 표시
            if (roundedValue >= Decimal.fromInt(10) ||
                decimalInterval >= Decimal.fromInt(10)) {
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

  /// 선택된 매개변수에 따라 차트 데이터를 검색하고 필터링
  Map<int, double> _getFilteredChartData(BuildContext context, String techCode,
      String? country, String? targetName) {
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
    final chartData = dataProvider.getChartData(
      techCode: techCode,
      country: country,
      targetName: targetName,
    );
    return filterChartData(chartData);
  }
}

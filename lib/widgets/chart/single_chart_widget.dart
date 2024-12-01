import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/utils/dash_circle_dot_painter.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../models/enum_defines.dart';
import '../../providers/analysis_data_provider.dart';
import 'package:decimal/decimal.dart'; // Decimal 패키지 임포트

class SingleChartWidget extends StatefulWidget {
  final AnalysisCategory category;
  final AnalysisSubCategory? selectedSubCategory;
  final String? chartTitle;
  final AnalysisTechListType? techListType;
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
  final ChartType chartType;
  final CagrCalculationMode cagrMode;

  const SingleChartWidget({
    super.key,
    required this.category,
    required this.selectedSubCategory,
    this.chartTitle,
    required this.techListType,
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
    this.chartType = ChartType.none,
    this.cagrMode = CagrCalculationMode.selectedPeriod,
  });

  @override
  State<SingleChartWidget> createState() => _SingleChartWidgetState();
}

class _SingleChartWidgetState extends State<SingleChartWidget> with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    // 선 그리기 애니메이션용 컨트롤러
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();

    // 회전 애니메이션용 컨트롤러
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // 계속 반복
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(widget.selectedSubCategory);

    List<String> chartLoopCodes = [];
    if (widget.selectedCodes != null) {
      chartLoopCodes.addAll(widget.selectedCodes!);
    } else if (widget.countries != null) {
      chartLoopCodes.addAll(widget.countries!);
    } else if (widget.targetNames != null) {
      chartLoopCodes.addAll(widget.targetNames!);
    }

    if (widget.chartType == ChartType.multiline) {
      return _buildMultiLineChart(context, dataProvider, chartLoopCodes);
    } else if (widget.chartType == ChartType.barWithTrendLine) {
      return _buildBarChartWithTrendLine(context, dataProvider);
    }

    if ((isIndexType && chartLoopCodes.isNotEmpty) || dataProvider.selectedCategory == AnalysisCategory.techGap || dataProvider.selectedCategory == AnalysisCategory.techAssessment) {
      return _buildMultiLineChart(context, dataProvider, chartLoopCodes);
    }
    return _buildBarChartWithTrendLine(context, dataProvider);
  }

  /// 여러 데이터셋을 비교하기 위한 다중 선 차트를 생성
  Widget _buildMultiLineChart(BuildContext context, AnalysisDataProvider dataProvider, List<String> chartLoopCodes) {
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
      String? countryCode;
      if (widget.category == AnalysisCategory.countryTech) {
        countryCode = code;
      } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
        countryCode = code;
      }

      String? targetName;
      if (widget.category == AnalysisCategory.companyTech || widget.category == AnalysisCategory.academicTech) {
        targetName = code;
      } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail || dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
        targetName = code;
      }

      final chartData = _getFilteredChartData(
        context: context,
        techListType: widget.techListType!,
        techCode: widget.techCode ?? widget.selectedCodes![0],
        country: countryCode,
        targetName: targetName,
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
        context: context,
        techListType: widget.techListType!,
        techCode: widget.category == AnalysisCategory.countryTech ||
                widget.category == AnalysisCategory.companyTech ||
                widget.category == AnalysisCategory.academicTech ||
                widget.category == AnalysisCategory.techGap ||
                widget.category == AnalysisCategory.techAssessment
            ? widget.techCode ?? widget.selectedCodes![0]
            : code,
        country: widget.category == AnalysisCategory.countryTech ||
                (widget.category == AnalysisCategory.techGap && dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail) ||
                (widget.category == AnalysisCategory.techAssessment && dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail)
            ? code
            : null,
        targetName: widget.category == AnalysisCategory.companyTech ||
                widget.category == AnalysisCategory.academicTech ||
                (widget.category == AnalysisCategory.techGap &&
                    (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail || dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail))
            ? code
            : null,
      );

      if (chartData.isEmpty) continue;

      final trendLineSpots = _calculateTrendLine(chartData, years);
      allTrendLines.add(
        LineChartBarData(
          spots: trendLineSpots,
          isCurved: true,
          color: colors[i % colors.length],
          barWidth: 2,
          dotData: FlDotData(
            show: true,
            checkToShowDot: (spot, barData) {
              return spot.x == trendLineSpots.last.x;
            },
            getDotPainter: (spot, percent, barData, index) {
              return DashedCircleDotPainter(
                radius: 6,
                strokeColor: colors[i % colors.length],
                fillColor: Colors.white,
                strokeWidth: 1.5,
              );
            },
          ),
          isStrokeCapRound: true,
          belowBarData: BarAreaData(show: false),
          showingIndicators: List.generate(
            trendLineSpots.length,
            (index) => index,
          ).where((index) {
            return index <= (trendLineSpots.length - 1) * _controller.value;
          }).toList(),
        ),
      );

      final currentMax = trendLineSpots.map((spot) => spot.y).reduce(max);
      maxValue = max(maxValue, currentMax);

      final currentMin = trendLineSpots.map((spot) => spot.y).reduce(min);
      minValue = min(minValue, currentMin);
    }

    final interval = CommonUtils.instance.calculateInterval(maxValue);
    final maxYValue = maxValue * widget.maxYRatio;
    final double adjustedMinY = minValue < 0 ? 0 : minValue;

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: SizedBox(
                height: widget.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (() {
                      if (widget.category != AnalysisCategory.techAssessment) {
                        return Center(
                          child: _buildLegend(chartLoopCodes, colors),
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    })(),
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
                            lineBarsData: allTrendLines.map((lineData) {
                              final spots = lineData.spots;
                              final currentSpots = spots
                                  .asMap()
                                  .entries
                                  .where((entry) {
                                    return entry.key <= (spots.length - 1) * _controller.value;
                                  })
                                  .map((e) => e.value)
                                  .toList();

                              return lineData.copyWith(
                                spots: currentSpots,
                                dotData: FlDotData(
                                  show: true,
                                  checkToShowDot: (spot, barData) {
                                    return spot.x == currentSpots.last.x;
                                  },
                                  getDotPainter: (spot, percent, barData, index) {
                                    return DashedCircleDotPainter(
                                      radius: 6,
                                      strokeColor: lineData.color ?? Colors.blue,
                                      fillColor: Colors.white,
                                      strokeWidth: 1.5,
                                      rotationDegree: _rotationController.value * 360,
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                            minY: adjustedMinY,
                            maxY: maxYValue,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 막대 차트와 추세선을 함께 표시하는 차트를 생성
  Widget _buildBarChartWithTrendLine(BuildContext context, AnalysisDataProvider dataProvider) {
    final chartData = _getFilteredChartData(
      context: context,
      techListType: widget.techListType!,
      techCode: widget.techCode ?? widget.selectedCodes![0],
      country: widget.country,
      targetName: widget.targetName,
    );

    if (chartData.isEmpty) return const SizedBox.shrink();

    // 최소값과 최대값 계산
    final maxValue = chartData.values.reduce(max);
    final interval = CommonUtils.instance.calculateInterval(maxValue);

    // CAGR과 추세선 데이터 계산
    final (cagr, trendLineData) = _calculateCagrAndTrendLine(
      context,
      dataProvider,
      chartData,
    );

    final years = chartData.keys.toList()..sort();

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SizedBox(
              height: widget.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.chartTitle != null) _buildTitle(widget.chartTitle!, widget.chartColor, true),
                  Expanded(
                    child: Stack(
                      children: [
                        _buildBarChart(context, years, chartData, maxValue, interval),
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
                              lineTouchData: const LineTouchData(
                                enabled: false,
                                handleBuiltInTouches: true,
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: years.asMap().entries.where((entry) {
                                    // 애니메이션이 완료되면 모든 포인트 표시, 아니면 한 칸 뒤에서 시작
                                    return _controller.value == 1
                                        ? true // 애니메이션 완료 시 모든 포인트 표시
                                        : entry.key < (years.length - 1) * _controller.value; // 진행 중에는 한 칸 뒤에서 따라가기
                                  }).map((entry) {
                                    return FlSpot(
                                      entry.key.toDouble(),
                                      trendLineData[entry.value] ?? 0,
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: Colors.red,
                                  dotData: FlDotData(
                                    show: true,
                                    checkToShowDot: (spot, barData) {
                                      final currentLastIndex = ((years.length - 1) * _controller.value - 1).floor();
                                      return _controller.value == 1
                                          ? spot.x == years.length - 1 // 애니메이션 완료 시 마지막 점
                                          : spot.x == currentLastIndex; // 진행 중에는 현재 위치
                                    },
                                    getDotPainter: (spot, percent, barData, index) {
                                      return DashedCircleDotPainter(
                                        radius: 6,
                                        strokeColor: Colors.red,
                                        fillColor: Colors.white,
                                        strokeWidth: 1.5,
                                        rotationDegree: _rotationController.value * 360,
                                      );
                                    },
                                  ),
                                  dashArray: [5, 5],
                                  barWidth: 2,
                                ),
                              ],
                              minX: -0.5,
                              maxX: years.length.toDouble() - 0.5,
                              minY: 0,
                              maxY: maxValue * widget.maxYRatio,
                            ),
                          ),
                        ),
                        _buildCagrOverlay(cagr),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// CAGR과 추세선 데이터를 계산
  (double, Map<int, double>) _calculateCagrAndTrendLine(
    BuildContext context,
    AnalysisDataProvider dataProvider,
    Map<int, double> chartData,
  ) {
    final fullData = dataProvider.getChartData(
      techListType: widget.techListType!,
      techCode: widget.techCode ?? widget.selectedCodes![0],
      country: widget.country,
      targetName: widget.targetName,
    );
    final allYears = fullData.keys.toList()..sort();

    switch (widget.cagrMode) {
      case CagrCalculationMode.selectedPeriod:
        // 선택된 기간의 데이터만 사용
        final years = chartData.keys.toList()..sort();

        final startYear = years.first;
        final endYear = years.last == allYears.last ? years.last - 1 : years.last;

        final cagr = _calculateCAGR(
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

        final fullDataCagr = _calculateCAGR(
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
  Widget _buildBarChart(BuildContext context, List<int> years, Map<int, double> chartData, double maxValue, double interval) {
    final barWidth = (MediaQuery.of(context).size.width / (years.length * 12)).clamp(8.0, 24.0);

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
          maxY: maxValue * widget.maxYRatio,
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

            final shouldShow = index <= (years.length - 1) * _controller.value;

            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: shouldShow ? value : 0,
                  color: widget.chartColor ?? Colors.blue,
                  width: barWidth,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
              barsSpace: 4,
            );
          }).toList(),
        ),
      ),
    );
  }

  /// CAGR 값을 보여주는 오버레이 위젯을 생성
  Widget _buildCagrOverlay(double cagr) {
    return Positioned(
      top: widget.height * 0.1, // 차트 높이의 15% 위치에 배치
      left: widget.width * 0.1, // 차트 너비의 10% 위치에 배치
      right: widget.width * 0.1, // 차트 너비의 10% 위치에 배치
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

  /// 지수함수 형태로 추세선 포인트를 계산
  List<FlSpot> _calculateTrendLine(Map<int, double> data, List<int> years) {
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
      return List.generate(n, (i) => FlSpot(i.toDouble(), 0)); // 유효한 데이터 포인트가 2개 미만이면 0으로 채운 리스트 반환
    }

    // 지수 회귀 계수 계산
    double b = (validPoints * sumXLnY - sumX * sumLnY) / (validPoints * sumX2 - sumX * sumX);
    double a = exp((sumLnY - b * sumX) / validPoints);

    // 추세선 포인트 생성
    return List.generate(n, (i) {
      double y = a * exp(b * i);
      return FlSpot(i.toDouble(), y > 0 ? y : 0); // 음수 값 방지
    });
  }

  /// 두 값 사이의 연평균 성장률(CAGR)을 계산
  double _calculateCAGR(double startValue, double endValue, int years) {
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
            if (widget.category == AnalysisCategory.countryTech) ...[
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

  /// 선택된 매개변수에 따라 차트 데이터를 검색하고 필터링
  Map<int, double> _getFilteredChartData({required BuildContext context, required AnalysisTechListType techListType, required String techCode, String? country, String? targetName}) {
    // 차트 데이터를 연도 범위로 필터링
    Map<int, double> filterChartData(Map<int, double> data) {
      final provider = context.read<AnalysisDataProvider>();
      return Map.fromEntries(
        data.entries.where((entry) => entry.key >= provider.startYear && entry.key <= provider.endYear).toList()..sort((a, b) => a.key.compareTo(b.key)),
      );
    }

    final dataProvider = context.read<AnalysisDataProvider>();
    final chartData = dataProvider.getChartData(
      techListType: techListType,
      techCode: techCode,
      country: country,
      targetName: targetName,
    );
    return filterChartData(chartData);
  }
}

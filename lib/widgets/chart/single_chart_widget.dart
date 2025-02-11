import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/utils/dash_circle_dot_painter.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../../models/enum_defines.dart';
import '../../providers/analysis_data_provider.dart';
import 'package:decimal/decimal.dart';
import 'package:flutter/gestures.dart'; // Decimal 패키지 임포트

class SingleChartWidget extends StatefulWidget {
  final String? chartTitle;
  final AnalysisTechListType? techListType;
  final String? techCode;
  final List<String>? selectedCodes;
  final String? country;
  final List<String>? countries;
  final String? targetName;
  final List<String>? targetNames;
  final double maxYRatio;
  final Color? chartColor;
  final ChartType chartType;
  final CagrCalculationMode cagrMode;
  final GlobalKey? chartKey;
  final GlobalKey? tableKey;

  const SingleChartWidget({
    super.key,
    this.chartTitle,
    required this.techListType,
    this.techCode,
    this.selectedCodes,
    this.country,
    this.countries,
    this.targetName,
    this.targetNames,
    this.maxYRatio = 1.6,
    this.chartColor,
    this.chartType = ChartType.none,
    this.cagrMode = CagrCalculationMode.selectedPeriod,
    this.chartKey,
    this.tableKey,
  });

  @override
  State<SingleChartWidget> createState() => _SingleChartWidgetState();
}

class _SingleChartWidgetState extends State<SingleChartWidget> with TickerProviderStateMixin {
  AnalysisCategory? _category;
  AnalysisSubCategory? _selectedSubCategory;

  late AnimationController _controller;
  late AnimationController _rotationController;

  // 확대/축소 상태를 저장할 변수 추가
  double _scaleX = 1.0;
  double _scaleY = 1.0;

  // 드래그 위치 추적을 위한 변수 추가
  double _dragStartX = 0.0;
  double _dragStartY = 0.0;
  double _offsetX = 0.0;
  double _offsetY = 0.0;

  // 터치 정보를 저장할 변수들 추가
  Offset? _touchPosition;
  int _nearSpotIndex = 0;

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

    // 확대/축소 및 드래그 상태 초기화
    _scaleX = 1.0;
    _scaleY = 1.0;
    _offsetX = 0.0;
    _offsetY = 0.0;
    _dragStartX = 0.0;
    _dragStartY = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    _rotationController.dispose();
    // 상태 변수들 초기화
    _scaleX = 1.0;
    _scaleY = 1.0;
    _offsetX = 0.0;
    _offsetY = 0.0;
    _dragStartX = 0.0;
    _dragStartY = 0.0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();

    _category = dataProvider.selectedCategory;
    _selectedSubCategory = dataProvider.selectedSubCategory;

    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(_selectedSubCategory);

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

    // 첫 번째 유효한 데이터에서 years 가져오기
    for (final code in chartLoopCodes) {
      String? countryCode;
      if (_category == AnalysisCategory.countryTech) {
        countryCode = code;
      } else if (_selectedSubCategory == AnalysisSubCategory.countryDetail) {
        countryCode = code;
      }

      String? targetName;
      if (_category == AnalysisCategory.companyTech || _category == AnalysisCategory.academicTech) {
        targetName = code;
      } else if (_selectedSubCategory == AnalysisSubCategory.companyDetail || _selectedSubCategory == AnalysisSubCategory.academicDetail) {
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

    final cagrDatas = [];
    // 각 코드별 추세선 생성
    for (var i = 0; i < chartLoopCodes.length; i++) {
      final code = chartLoopCodes[i];
      final chartData = _getFilteredChartData(
        context: context,
        techListType: widget.techListType!,
        techCode: _category == AnalysisCategory.countryTech ||
                _category == AnalysisCategory.companyTech ||
                _category == AnalysisCategory.academicTech ||
                _category == AnalysisCategory.techGap ||
                _category == AnalysisCategory.techAssessment
            ? widget.techCode ?? widget.selectedCodes![0]
            : code,
        country: _category == AnalysisCategory.countryTech ||
                (_category == AnalysisCategory.techGap && _selectedSubCategory == AnalysisSubCategory.countryDetail) ||
                (_category == AnalysisCategory.techAssessment && _selectedSubCategory == AnalysisSubCategory.countryDetail)
            ? code
            : null,
        targetName: _category == AnalysisCategory.companyTech ||
                _category == AnalysisCategory.academicTech ||
                (_category == AnalysisCategory.techAssessment && _selectedSubCategory != AnalysisSubCategory.countryDetail) ||
                (_category == AnalysisCategory.techGap && (_selectedSubCategory == AnalysisSubCategory.companyDetail || _selectedSubCategory == AnalysisSubCategory.academicDetail))
            ? code
            : null,
      );

      final cagr = _calculateCAGR(chartData, years);
      cagrDatas.add(cagr);

      if (chartData.isEmpty) continue;

      List<FlSpot> trendLineSpots = [];
      if (dataProvider.selectedCategory == AnalysisCategory.techAssessment) {
        trendLineSpots = chartData.entries.map((entry) {
          return FlSpot(
            years.indexOf(entry.key).toDouble(),
            entry.value,
          );
        }).toList();
      } else {
        trendLineSpots = _calculateTrendLine(chartData, years);
      }

      // 현재 연도를 기준으로 데이터 분리
      final currentYear = DateTime.now().year;
      final splitIndex = years.indexWhere((year) => year > currentYear);

      if (splitIndex != -1) {
        // 실선 부분 (현재까지)
        final solidLineSpots = trendLineSpots.sublist(0, splitIndex);
        allTrendLines.add(
          LineChartBarData(
            spots: solidLineSpots,
            isCurved: true,
            color: dataProvider.getColorForCode(code),
            barWidth: 1,
            dotData: const FlDotData(show: false),
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        );

        // 점선 부분 (미래)
        final dashedLineSpots = trendLineSpots.sublist(splitIndex - 1);
        allTrendLines.add(
          LineChartBarData(
            spots: dashedLineSpots,
            isCurved: true,
            color: dataProvider.getColorForCode(code),
            barWidth: 1,
            dashArray: [5, 5], // 점선 처리
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) {
                return spot.x == trendLineSpots.last.x;
              },
              getDotPainter: (spot, percent, barData, index) {
                return DashedCircleDotPainter(
                  radius: 6,
                  strokeColor: dataProvider.getColorForCode(code),
                  fillColor: Colors.white,
                  strokeWidth: 1.5,
                );
              },
            ),
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        );
      } else {
        // 모든 데이터가 현재 이전인 경우 실선으로 처리
        allTrendLines.add(
          LineChartBarData(
            spots: trendLineSpots,
            isCurved: true,
            color: dataProvider.getColorForCode(code),
            barWidth: 1,
            dotData: FlDotData(
              show: true,
              checkToShowDot: (spot, barData) {
                return spot.x == trendLineSpots.last.x;
              },
              getDotPainter: (spot, percent, barData, index) {
                return DashedCircleDotPainter(
                  radius: 6,
                  strokeColor: dataProvider.getColorForCode(code),
                  fillColor: Colors.white,
                  strokeWidth: 1.5,
                );
              },
            ),
            isStrokeCapRound: true,
            belowBarData: BarAreaData(show: false),
          ),
        );
      }

      final currentMax = trendLineSpots.map((spot) => spot.y).reduce(max);
      maxValue = max(maxValue, currentMax);

      final currentMin = trendLineSpots.map((spot) => spot.y).reduce(min);
      minValue = min(minValue, currentMin);
    }

    final interval = CommonUtils.instance.calculateInterval(maxValue);
    final maxYValue = maxValue * widget.maxYRatio;
    final dialogKey = GlobalKey();
    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return Listener(
          onPointerSignal: (PointerSignalEvent event) {
            if (_controller.isAnimating) return;

            if (event is PointerScrollEvent) {
              setState(() {
                if (event.kind == PointerDeviceKind.mouse) {
                  _scaleY = (_scaleY * (event.scrollDelta.dy > 0 ? 0.95 : 1.05)).clamp(1, 5.0);
                  _scaleX = (_scaleX * (event.scrollDelta.dy > 0 ? 0.95 : 1.05)).clamp(1, 5.0);
                }
              });
            }
          },
          child: GestureDetector(
            onPanStart: (details) {
              if (_controller.isAnimating) return;

              setState(() {
                _dragStartX = details.localPosition.dx;
                _dragStartY = details.localPosition.dy;
              });
            },
            onPanUpdate: (details) {
              if (_controller.isAnimating) return;

              setState(() {
                final deltaX = (details.localPosition.dx - _dragStartX) / 100;
                final deltaY = (details.localPosition.dy - _dragStartY) / 100;

                _offsetX += deltaX;
                _offsetY += deltaY;

                _dragStartX = details.localPosition.dx;
                _dragStartY = details.localPosition.dy;

                _offsetX = _offsetX.clamp(-5.0, 5.0);
                _offsetY = _offsetY.clamp(-5.0, 5.0);
              });
            },
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  (() {
                    if (dataProvider.selectedCategory != AnalysisCategory.techAssessment) {
                      return Container(
                        width: constraints.maxWidth,
                        padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.02),
                        child: Row(
                          children: [
                            (() {
                              if (dataProvider.selectedCategory == AnalysisCategory.techGap) {
                                return const Spacer();
                              }
                              return Expanded(child: Center(child: _buildLegend(chartLoopCodes)));
                            })(),
                            CommonUtils.instance.saveMenuPopup(
                              constraints: constraints,
                              chartKey: widget.chartKey ?? dialogKey,
                              tableKey: widget.tableKey,
                              dataProvider: dataProvider,
                              techCodes: dataProvider.selectedTechCodes.isNotEmpty ? dataProvider.selectedTechCodes : [dataProvider.selectedTechCode ?? ''],
                              chartCodes: chartLoopCodes,
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const SizedBox.shrink();
                    }
                  })(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => Stack(
                        children: [
                          LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawHorizontalLine: false,
                                drawVerticalLine: true,
                                verticalInterval: 1,
                                getDrawingVerticalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey.withOpacity(0.2),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: _buildTitlesData(
                                years: years,
                                interval: interval,
                                constraints: constraints,
                              ),
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchCallback: dataProvider.selectedCategory == AnalysisCategory.techAssessment
                                    ? null
                                    : (FlTouchEvent event, LineTouchResponse? response) {
                                        if (response == null || response.lineBarSpots == null) {
                                          return;
                                        }

                                        if (event is FlPointerHoverEvent) {
                                          // 가장 가까운 포인트 찾기
                                          var minDistance = double.infinity;
                                          var offsetY = 0.0;
                                          final chartContainerPixelHeight = constraints.maxHeight * 0.92 - 2;
                                          var maxY = maxYValue / _scaleY;
                                          for (var spot in response.lineBarSpots!) {
                                            // spot의 실제 픽셀 위치 얻기
                                            final pixelPointY = chartContainerPixelHeight * (maxY - spot.y) / maxY;
                                            // 절대값
                                            final distance = event.localPosition.dy - pixelPointY;
                                            if (distance.abs() < minDistance) {
                                              minDistance = distance.abs();
                                              _nearSpotIndex = spot.barIndex;
                                              offsetY = pixelPointY;
                                            }
                                          }

                                          if (minDistance > 10) {
                                            _nearSpotIndex = -1;
                                          }

                                          setState(() {
                                            _touchPosition = Offset(event.localPosition.dx, offsetY);
                                          });
                                        }
                                      },
                                touchTooltipData: LineTouchTooltipData(
                                  tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
                                  tooltipRoundedRadius: 8,
                                  tooltipPadding: const EdgeInsets.all(8),
                                  tooltipMargin: 20,
                                  getTooltipItems: (List<LineBarSpot> touchedSpots) {
                                    return touchedSpots.map((LineBarSpot spot) {
                                      if (cagrDatas.isEmpty) {
                                        return null;
                                      }

                                      if (touchedSpots.length > chartLoopCodes.length && spot.barIndex % 2 == 1) {
                                        return null;
                                      }

                                      if (dataProvider.selectedCategory == AnalysisCategory.techAssessment) {
                                        return LineTooltipItem(
                                          '${years[spot.x.toInt()]}\n${spot.y.toStringAsFixed(4)}',
                                          const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: '\n${CommonUtils.instance.replaceCountryCode(chartLoopCodes[spot.barIndex])}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.normal,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        );
                                      }
                                      return null;
                                    }).toList();
                                  },
                                ),
                                touchSpotThreshold: 100,
                                getTouchLineStart: (data, index) => 0,
                                getTouchLineEnd: (data, index) => 0,
                                getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
                                  return spotIndexes.map((spotIndex) {
                                    return const TouchedSpotIndicatorData(
                                      FlLine(color: Colors.transparent),
                                      FlDotData(show: false),
                                    );
                                  }).toList();
                                },
                                handleBuiltInTouches: true,
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border: const Border(
                                  left: BorderSide(color: Colors.grey),
                                  right: BorderSide(color: Colors.transparent),
                                  top: BorderSide(color: Colors.transparent),
                                  bottom: BorderSide(color: Colors.grey),
                                ),
                              ),
                              lineBarsData: allTrendLines.map((lineData) {
                                final spots = lineData.spots;
                                final isSecondLine = lineData.dashArray != null; // 점선 여부 확인

                                // 애니메이션 진행률 계산
                                // 실선은 0~0.5 구간에서, 점선은 0.5~1.0 구간에서 애니메이션
                                final progress = isSecondLine
                                    ? (_controller.value <= 0.5 ? 0.0 : (_controller.value - 0.5) * 2) // 점선
                                    : (_controller.value >= 0.5 ? 1.0 : _controller.value * 2); // 실선

                                final currentSpots = spots
                                    .asMap()
                                    .entries
                                    .where((entry) {
                                      return entry.key <= (spots.length - 1) * progress;
                                    })
                                    .map((e) => e.value)
                                    .toList();

                                return lineData.copyWith(
                                  spots: currentSpots,
                                  isCurved: dataProvider.selectedCategory != AnalysisCategory.techAssessment,
                                  dotData: FlDotData(
                                    show: dataProvider.selectedCategory == AnalysisCategory.techGap ? isSecondLine : true, // 점선인 경우만 점 표시
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
                              minY: 0,
                              maxY: maxYValue / _scaleY,
                              minX: (-0.5 - _offsetX) / _scaleX,
                              maxX: ((years.length - 0.5) - _offsetX) / _scaleX,
                              clipData: const FlClipData.all(),
                            ),
                          ),

                          // 팝업 위젯 추가
                          (() {
                            if (dataProvider.selectedCategory == AnalysisCategory.techAssessment) {
                              return const SizedBox.shrink();
                            }

                            if (_touchPosition != null && _nearSpotIndex != -1) {
                              int spotIndex = _nearSpotIndex;
                              if (dataProvider.selectedCategory == AnalysisCategory.techGap) {
                                spotIndex = _nearSpotIndex ~/ 2;
                              }

                              var chartCode = chartLoopCodes[spotIndex];
                              final popupWidth = constraints.maxWidth * 0.15;
                              final popupHeight = constraints.maxWidth * 0.05;
                              return Positioned(
                                left: _touchPosition!.dx + popupWidth / 2,
                                top: _touchPosition!.dy - popupHeight,
                                child: Container(
                                  width: popupWidth,
                                  height: popupHeight,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blueGrey.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'CAGR: ${(cagrDatas[spotIndex] * 100).toStringAsFixed(1)}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ...(() {
                                            String countryCode = '';
                                            switch (dataProvider.selectedCategory) {
                                              case AnalysisCategory.countryTech:
                                                chartCode = CommonUtils.instance.replaceCountryCode(chartCode);
                                                countryCode = chartCode;
                                                break;
                                              case AnalysisCategory.techGap:
                                                if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
                                                  chartCode = CommonUtils.instance.replaceCountryCode(chartCode);
                                                  countryCode = chartCode;
                                                } else {
                                                  countryCode = CommonUtils.instance.replaceCountryCode(dataProvider.searchCountryCode(chartCode));
                                                }
                                                break;
                                              default:
                                                return [];
                                            }

                                            return [
                                              CountryFlag.fromCountryCode(countryCode, width: 20, height: 20),
                                              const SizedBox(width: 4),
                                            ];
                                          })(),
                                          Expanded(
                                            child: Text(
                                              chartCode,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          })(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
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

    final fullData = dataProvider.getChartData(
      techListType: widget.techListType!,
      techCode: widget.techCode ?? widget.selectedCodes![0],
      country: widget.country,
      targetName: widget.targetName,
    );
    final years = fullData.keys.toList()..sort();
    // CAGR과 추세선 데이터 계산
    final cagr = _calculateCAGR(chartData, years);
    final trendLineData = _calculateTrendLine(chartData, years);
    var rotateData = _calculateRotateData(chartData, years, maxValue);

    return AnimatedBuilder(
      animation: _rotationController,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) => Stack(
                      children: [
                        _buildCagrLineChart(
                          years: years,
                          trendLineData: trendLineData,
                          rotateData: rotateData,
                          maxValue: maxValue,
                          interval: interval,
                          constraints: constraints,
                        ),
                        _buildBarChart(
                          years: years,
                          chartData: chartData,
                          maxValue: maxValue,
                          interval: interval,
                          constraints: constraints,
                        ),
                        _buildCagrOverlay(
                          cagr: cagr,
                          constraints: constraints,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// 시각화의 막대 차트 컴포넌트를 생성
  Widget _buildBarChart({
    required List<int> years,
    required Map<int, double> chartData,
    required double maxValue,
    required double interval,
    required BoxConstraints constraints,
  }) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxValue * widget.maxYRatio,
        titlesData: _buildTitlesData(
          years: years,
          interval: interval,
          constraints: constraints,
        ),
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.blueGrey.withOpacity(0.8),
            tooltipPadding: const EdgeInsets.all(8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final year = years[group.x.toInt()];
              final value = chartData[year] ?? 0.0;
              return BarTooltipItem(
                '$year\n${value.toStringAsFixed(2)}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
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
                width: constraints.maxWidth * 0.01,
                borderRadius: BorderRadius.circular(2),
              ),
            ],
            barsSpace: 4,
          );
        }).toList(),
      ),
    );
  }

  /// 추세선 차트를 생성
  Widget _buildCagrLineChart({
    required List<int> years,
    required List<FlSpot> trendLineData,
    required List<FlSpot> rotateData,
    required double maxValue,
    required double interval,
    required BoxConstraints constraints,
  }) {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: _buildTitlesData(
          years: years,
          interval: interval,
          constraints: constraints,
          isShowTitle: false,
        ),
        clipData: const FlClipData.all(),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(
          enabled: false,
          handleBuiltInTouches: true,
        ),
        lineBarsData: [
          LineChartBarData(
            spots: trendLineData.asMap().entries.where((entry) {
              // 애니메이션이 완료되면 모든 포인트 표시, 아니면 한 칸 뒤에서 시작
              return _controller.value == 1
                  ? true // 애니메이션 완료 시 모든 포인트 표시
                  : entry.key < (years.length - 1) * _controller.value; // 진행 중에는 한 칸 뒤에서 따라가기
            }).map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.y,
              );
            }).toList(),
            isCurved: true,
            color: const Color.fromARGB(255, 109, 207, 245),
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
                  strokeColor: const Color.fromARGB(255, 109, 207, 245),
                  fillColor: Colors.white,
                  strokeWidth: 1.5,
                  rotationDegree: _rotationController.value * 360,
                );
              },
            ),
            dashArray: [5, 5],
            barWidth: 1,
          ),
        ],
        minX: -0.5,
        maxX: years.length.toDouble() - 0.5,
        minY: 0,
        maxY: maxValue * widget.maxYRatio,
      ),
    );
  }

  /// CAGR 값을 보여주는 오버레이 위젯을 생성
  Widget _buildCagrOverlay({required double cagr, required BoxConstraints constraints}) {
    return Positioned(
      top: constraints.maxHeight * 0.1, // 차트 높이의 15% 위치에 배치
      left: constraints.maxWidth * 0.1,
      right: constraints.maxWidth * 0.1,
      child: Center(
        child: Text(
          'CAGR ${(cagr * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  /// 지수함수 형태로 추세선 포인트를 계산
  List<FlSpot> _calculateTrendLine(Map<int, double> data, List<int> years) {
    if (years.length < 2) return [];

    bool isMultiple = false;
    double ratio = 1e+5;
    if (data.values.reduce(max) <= 1) {
      data = data.map((key, value) => MapEntry(key, value * ratio));
      isMultiple = true;
    }

    int n = years.length;
    double sumX = 0;
    double sumLnY = 0;
    double sumXLnY = 0;
    double sumX2 = 0;
    int validPoints = 0;

    // x축을 0부터 시작하는 인덱스로 변환하고 로그 변환된 y값 사용
    for (int i = 0; i < n; i++) {
      double x = i.toDouble();
      double? y = max(data[years[i]] ?? 1, 1);

      if (y > 0) {
        double lnY = max(log(y), 0);
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

    return List.generate(n, (i) {
      double y = a * exp(b * i);
      if (isMultiple) {
        y = y / ratio;
      }
      return FlSpot(i.toDouble(), y > 0 ? y : 0); // 음수 값 방지
    });
  }

  List<FlSpot> _calculateRotateData(Map<int, double> data, List<int> years, double maxValue) {
    if (years.length < 2) return [];

    bool isMultiple = false;
    double ratio = 1e+5;
    if (data.values.reduce(max) <= 1) {
      data = data.map((key, value) => MapEntry(key, value * ratio));
      isMultiple = true;
    }

    int n = years.length;
    double sumX = 0;
    double sumLnY = 0;
    double sumXLnY = 0;
    double sumX2 = 0;
    int validPoints = 0;

    // x축을 0부터 시작하는 인덱스로 변환하고 로그 변환된 y값 사용
    for (int i = 0; i < n; i++) {
      double x = i.toDouble();
      double? y = max(data[years[i]] ?? 1, 1);

      if (y > 0) {
        double lnY = max(log(y), 0);
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

    //추세선 배수
    int multiple = 1;

    var list = List.generate(n * multiple, (i) {
      double y = a * exp(b * i / multiple);
      if (isMultiple) {
        y = y / ratio;
      }
      return FlSpot(i.toDouble() / multiple, y > 0 ? y : 0); // 음수 값 방지
    });
    final maxYValue = maxValue * (widget.maxYRatio - 0.025);
    list.removeWhere((spot) => spot.y > maxYValue);
    // maxYValue에 대한 x값 계산
    double targetY = maxYValue;
    if (isMultiple) {
      targetY = targetY * ratio;
    }
    double xAtMaxY = log(targetY / a) / b;
    list.add(FlSpot(xAtMaxY, maxYValue));
    return list;
  }

  double _calculateCAGR(Map<int, double> chartData, List<int> years) {
    var startYear = years.first;
    final dataProvider = context.read<AnalysisDataProvider>();

    int endYear = years.last - 1;
    switch (dataProvider.selectedCategory) {
      case AnalysisCategory.countryTech:
      case AnalysisCategory.companyTech:
      case AnalysisCategory.academicTech:
        if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ||
            dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail ||
            dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
          break;
        } else {
          endYear = years.last;
        }
        break;
      default:
        break;
    }

    final yearsGap = years.last - years.first;
    late double startValue;
    if (chartData[startYear] == 0) {
      // chartData 의 최댓값이 1보다 작거나 같으면 1e-5 로 설정하고 아니면 1로 설정
      if (chartData.values.reduce(max) <= 1) {
        startValue = 1e-5;
      } else {
        startValue = 1;
      }
    } else {
      startValue = chartData[startYear] ?? 0;
    }

    final endValue = chartData[endYear] ?? 0;

    // CAGR = (최종값/초기값)^(1/기간) - 1
    return pow((endValue / startValue), 1 / yearsGap) - 1;
  }

  /// 다중 선 차트를 위한 범례를 생성
  Widget _buildLegend(List<String> codes) {
    final dataProvider = context.read<AnalysisDataProvider>();

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
                  final color = dataProvider.getColorForCode(entry.value);

                  // 각 코드별 CAGR 계산
                  final chartData = _getFilteredChartData(
                    context: context,
                    techListType: widget.techListType!,
                    techCode: _category == AnalysisCategory.countryTech ||
                            _category == AnalysisCategory.companyTech ||
                            _category == AnalysisCategory.academicTech ||
                            _category == AnalysisCategory.techGap ||
                            _category == AnalysisCategory.techAssessment
                        ? widget.techCode ?? widget.selectedCodes![0]
                        : entry.value,
                    country: _category == AnalysisCategory.countryTech || (_category == AnalysisCategory.techGap && dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail)
                        ? entry.value
                        : null,
                    targetName: _category == AnalysisCategory.companyTech ||
                            _category == AnalysisCategory.academicTech ||
                            (_category == AnalysisCategory.techGap && (_selectedSubCategory == AnalysisSubCategory.companyDetail || _selectedSubCategory == AnalysisSubCategory.academicDetail))
                        ? entry.value
                        : null,
                  );

                  final years = chartData.keys.toList()..sort();
                  double cagr = 0;

                  if (years.length >= 2) {
                    cagr = _calculateCAGR(chartData, years);
                  }

                  late String countryCode;
                  switch (_category) {
                    case AnalysisCategory.companyTech:
                    case AnalysisCategory.academicTech:
                      countryCode = CommonUtils.instance.replaceCountryCode(dataProvider.searchCountryCode(entry.value));
                      break;
                    case AnalysisCategory.techGap:
                      if (_selectedSubCategory == AnalysisSubCategory.countryDetail) {
                        countryCode = CommonUtils.instance.replaceCountryCode(entry.value);
                      } else {
                        countryCode = CommonUtils.instance.replaceCountryCode(dataProvider.searchCountryCode(entry.value));
                      }
                      break;
                    case AnalysisCategory.countryTech:
                    default:
                      countryCode = CommonUtils.instance.replaceCountryCode(entry.value);
                  }

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
                            if (_category != AnalysisCategory.industryTech) ...[
                              const SizedBox(width: 4),
                              CountryFlag.fromCountryCode(countryCode, height: 12, width: 12),
                            ],
                            const SizedBox(width: 4),
                            Text(
                              CommonUtils.instance.replaceCountryCode(entry.value),
                              style: const TextStyle(
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'CAGR ${(cagr * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 8,
                            color: color,
                          ),
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

  /// 양쪽 축의 타이틀 데이터를 구성
  FlTitlesData _buildTitlesData({
    required List<int> years,
    required double interval,
    required BoxConstraints constraints,
    bool isShowTitle = true,
  }) {
    return FlTitlesData(
      show: true,
      // 하단 타이틀 (연도)
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          interval: 1, // 간격을 1로 설정하여 모든 값을 표시
          getTitlesWidget: (value, meta) {
            if (isShowTitle == false) {
              return const SizedBox.shrink();
            }

            if (value < 0 || value > years.length - 1) {
              return const SizedBox.shrink();
            }

            final index = value.toInt();
            if (index >= 0 && index < years.length) {
              return Transform.translate(
                offset: Offset(constraints.maxWidth * 0.005, constraints.maxHeight * 0.015),
                child: Transform.rotate(
                  angle: -45 * pi / 180,
                  child: Text(
                    years[index].toString(),
                    style: TextStyle(
                      fontSize: constraints.maxWidth * 0.01,
                      color: Colors.black,
                    ),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          reservedSize: constraints.maxWidth * 0.04,
        ),
      ),
      // 좌측 타이틀 (값)
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (isShowTitle == false) {
              return const SizedBox.shrink();
            }
            // value를 Decimal로 변환하고 소수점 두 자리로 반올림
            final Decimal roundedValue = Decimal.parse(value.toStringAsFixed(2)); // 소수점 두 자리로 반올림
            final Decimal decimalInterval = Decimal.parse(interval.toString()); // interval을 Decimal로 변환

            if (roundedValue % decimalInterval != Decimal.zero) {
              return const SizedBox.shrink(); // 최댓값일 경우 빈 위젯 반환
            }
            return Padding(
              padding: const EdgeInsets.only(right: 5),
              child: Text(
                (roundedValue >= Decimal.fromInt(10) || decimalInterval >= Decimal.fromInt(10)) ? roundedValue.toString() : roundedValue.toStringAsFixed(2), // 소수점 2자리까지 표시
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.01,
                  color: Colors.black,
                ),
              ),
            );
          },
          interval: interval,
          reservedSize: constraints.maxWidth * 0.065,
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
  Map<int, double> _getFilteredChartData({
    required BuildContext context,
    required AnalysisTechListType techListType,
    required String techCode,
    String? country,
    String? targetName,
  }) {
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

import 'dart:math';

import 'package:country_flags/country_flags.dart';
import 'package:decimal/decimal.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/models/table_chart_data_model.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_table_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_chart_data.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';

class ChartWidgetTechCompetition extends StatefulWidget {
  const ChartWidgetTechCompetition({super.key});

  @override
  State<ChartWidgetTechCompetition> createState() => _ChartWidgetTechCompetitionState();
}

class _ChartWidgetTechCompetitionState extends State<ChartWidgetTechCompetition> with SingleTickerProviderStateMixin {
  AnalysisCategory get _category => AnalysisCategory.techCompetition;
  double get _maxYRatio => 1.6;

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
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          top: constraints.maxHeight * 0.05,
        ),
        child: SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: LayoutGrid(
            columnSizes: [1.fr],
            rowSizes: [1.fr, 1.fr],
            children: [
              const SizedBox(
                height: double.infinity,
                // child: ChartTableWidget(
                //   width: constraints.maxWidth,
                //   height: constraints.maxHeight,
                //   title: 'Tech Competition',
                //   headerTitles: const [
                //     (TableDataType.country, '국가 순위'),
                //   ],
                //   tableChartDataModels: CommonUtils.instance.createTestData(),
                // ),
              ),
              _buildChartBarType(),
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

  Widget _buildChartBarType() {
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
                  return BarTooltipItem(',', const TextStyle(color: Colors.black));
                }
              },
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
    final provider = context.watch<AnalysisDataProvider>();
    return FlTitlesData(
      show: true,
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index >= 0 && index < codes.length) {
              return Column(
                children: [
                  // 짝수 인덱스일 경우 상단에 빈 공간 추가
                  if (index % 2 == 1) const SizedBox(height: 16),
                  Row(
                    children: [
                      if (provider.selectedSubCategory == AnalysisSubCategory.countryDetail)
                        CountryFlag.fromCountryCode(
                          CommonUtils.instance.replaceCountryCode(codes[index]),
                          height: 16,
                          width: 16,
                        ),
                      Text(
                        CommonUtils.instance.replaceCountryCode(codes[index]),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
            return const Text('');
          },
          reservedSize: 52, // 높이를 늘려서 짝수 타이틀이 겹치지 않도록 함
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

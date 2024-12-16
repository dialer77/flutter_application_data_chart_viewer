import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math';

class ChartCircleWidget extends StatefulWidget {
  final AnalysisTechListType techListType;
  final List<String> techCodes;

  const ChartCircleWidget({
    super.key,
    required this.techListType,
    required this.techCodes,
  });

  @override
  State<ChartCircleWidget> createState() => _ChartCircleWidgetState();
}

class _ChartCircleWidgetState extends State<ChartCircleWidget> {
  String? selectedItem;
  AnalysisSubCategory? _previousSubCategory;

  List<String> getItemsBySubCategory(AnalysisDataProvider dataProvider) {
    switch (dataProvider.selectedSubCategory) {
      case AnalysisSubCategory.countryDetail:
        return dataProvider.selectedCountries.isEmpty ? dataProvider.getAvailableCountriesFromTechAssessment().take(10).toList() : dataProvider.selectedCountries.toList();
      case AnalysisSubCategory.companyDetail:
        return dataProvider.selectedCompanies.isEmpty ? dataProvider.getAvailableCompaniesFromTechAssessment().take(10).toList() : dataProvider.selectedCompanies.toList();
      case AnalysisSubCategory.academicDetail:
        return dataProvider.selectedAcademics.isEmpty ? dataProvider.getAvailableAcademicsFromTechAssessment().take(10).toList() : dataProvider.selectedAcademics.toList();
      default:
        return [];
    }
  }

  Widget _buildPieChart({
    required Map<String, double> data,
  }) {
    final dataEntries = data.entries.toList();
    // 기준 값
    final baseValue = 360 / data.length * 0.8;
    return Stack(
      children: [
        ...dataEntries.asMap().entries.map((entry) {
          final index = entry.key;
          final mapEntry = entry.value;

          return PieChart(
            PieChartData(
              centerSpaceRadius: 0,
              startDegreeOffset: (360 / data.length * index) + 270 - baseValue / 2,
              sections: [
                PieChartSectionData(
                  value: baseValue,
                  color: const Color.fromARGB(255, 103, 183, 220),
                  title: '',
                  radius: mapEntry.value * 90,
                ),
                PieChartSectionData(
                  value: 360 - baseValue,
                  color: Colors.transparent,
                  title: '',
                  radius: 50,
                ),
              ],
            ),
          );
        }),
        RadarChart(
          RadarChartData(
            radarShape: RadarShape.circle,
            ticksTextStyle: const TextStyle(color: Colors.transparent),
            tickBorderData: const BorderSide(color: Colors.grey, width: 0.5),
            gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
            titleTextStyle: const TextStyle(fontSize: 12),
            dataSets: [
              RadarDataSet(
                fillColor: Colors.transparent,
                borderColor: Colors.transparent,
                entryRadius: 0,
                dataEntries: data.entries.toList().map((e) => RadarEntry(value: e.value)).toList(),
              ),
            ],
            getTitle: (index, angle) {
              return RadarChartTitle(
                text: data.entries.toList()[index].key,
                angle: 0,
              );
            },
            tickCount: 5,
            radarBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
        ),
      ],
    );
  }

  // 레이더 차트 데이터 생성 함수
  Widget _createRadarChartData({
    required Color color,
    required Map<String, double> data,
    required bool isFilled,
  }) {
    final entries = data.entries.toList();

    return LayoutBuilder(builder: (context, constraints) {
      // 반지름을 컨테이너의 최소 크기의 40%로 설정
      final radius = min(constraints.maxWidth, constraints.maxHeight) * 0.475;

      return Stack(
        children: [
          RadarChart(
            RadarChartData(
              radarShape: RadarShape.circle,
              ticksTextStyle: const TextStyle(color: Colors.transparent),
              tickBorderData: const BorderSide(color: Colors.grey, width: 0.5),
              gridBorderData: const BorderSide(color: Colors.grey, width: 0.5),
              titleTextStyle: const TextStyle(fontSize: 12),
              dataSets: [
                RadarDataSet(
                  fillColor: isFilled ? color.withOpacity(0.3) : Colors.transparent,
                  borderColor: Colors.transparent,
                  entryRadius: 0,
                  dataEntries: entries.map((e) => RadarEntry(value: e.value)).toList(),
                ),
              ],
              getTitle: (index, angle) {
                return const RadarChartTitle(
                  text: '', // 기존 타이틀은 비움
                  angle: 0,
                );
              },
              tickCount: 10,
              radarBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
            ),
          ),
          ...List.generate(entries.length, (index) {
            final angle = (2 * pi * index / entries.length) - pi / 2;

            // Text 크기 계산
            final textSpan = TextSpan(
              text: entries[index].key,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.black,
              ),
            );
            final textPainter = TextPainter(
              text: textSpan,
              textDirection: TextDirection.ltr,
              textAlign: TextAlign.center,
              maxLines: 1, // 한 줄로 제한
            );
            textPainter.layout(maxWidth: double.infinity); // 무제한 너비로 레이아웃
            final textWidth = textPainter.width;

            // 텍스트 정렬 방향 결정
            final textAlign = (() {
              if (index == 0) {
                return TextAlign.center;
              } else if (entries.length / 2 > index) {
                return TextAlign.end;
              } else {
                return TextAlign.start;
              }
            })();

            // 위치 보정값 계산
            final horizontalOffset = (() {
              if (index == 0) {
                return -textWidth / 2; // 중앙 정렬일 때는 텍스트 너비의 절반
              } else if (entries.length / 2 > index) {
                return 0.0; // 우측 정렬일 때는 보정 없음
              } else {
                return -textWidth; // 좌측 정렬일 때는 텍스트 전체 너비만큼
              }
            })();

            return Positioned(
              left: constraints.maxWidth / 2 + cos(angle) * radius + horizontalOffset,
              top: constraints.maxHeight / 2 + sin(angle) * radius - 5,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: double.infinity,
                  minWidth: textWidth,
                ),
                child: Text(
                  entries[index].key,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                  textAlign: textAlign,
                  overflow: TextOverflow.visible, // 텍스트가 잘리지 않도록 설정
                  softWrap: false, // 줄바꿈 방지
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  // 차트 컨테이너 생성 함수
  Widget _buildChartContainer(AnalysisDataProvider dataProvider) {
    var raderChartData = dataProvider.getRaderChartData(widget.techListType, dataProvider.selectedYear);

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: (() {
          if (raderChartData.length < 3) {
            return Center(
              child: Text("${widget.techListType} 데이터가 부족합니다.\n3개 이상 선택해주세요.", style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            );
          }

          if (widget.techListType == AnalysisTechListType.sc) {
            return _createRadarChartData(
              color: Colors.red,
              data: raderChartData,
              isFilled: true,
            );
          } else {
            return _buildPieChart(data: raderChartData);
          }
        })(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dataProvider = context.read<AnalysisDataProvider>();

    // SubCategory가 변경되었을 때만 selectedItem 초기화
    if (_previousSubCategory != dataProvider.selectedSubCategory) {
      _previousSubCategory = dataProvider.selectedSubCategory;
      final items = getItemsBySubCategory(dataProvider);
      if (items.isNotEmpty) {
        setState(() {
          selectedItem = items.first;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();

    return _buildChartContainer(dataProvider);
  }
}

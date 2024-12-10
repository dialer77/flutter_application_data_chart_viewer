import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/single_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartCircleWidget extends StatefulWidget {
  const ChartCircleWidget({super.key});

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

  // 레이더 차트 데이터 생성 함수
  RadarChartData _createRadarChartData({
    required Color color,
    required Map<String, double> data,
    required bool isFilled,
  }) {
    final entries = data.entries.toList();

    return RadarChartData(
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
        return RadarChartTitle(
          text: entries[index].key,
          angle: angle,
        );
      },
      tickCount: 10,
      radarBorderData: BorderSide(color: Colors.grey.shade300, width: 1),
    );
  }

  // 개별 레이더 차트 위젯 생성 함수
  Widget _buildRadarChart({
    required Color color,
    required Map<String, double> data,
    required bool isFilled,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: RadarChart(
          _createRadarChartData(
            color: color,
            data: data,
            isFilled: isFilled,
          ),
        ),
      ),
    );
  }

  // 차트 컨테이너 생성 함수
  Widget _buildChartContainer(AnalysisDataProvider dataProvider) {
    // 임시 데이터 예시
    var raderChartMCData = dataProvider.getRaderChartData(AnalysisTechListType.mc, dataProvider.selectedYear);
    var raderChartSCData = dataProvider.getRaderChartData(AnalysisTechListType.sc, dataProvider.selectedYear);

    return Container(
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              selectedItem ?? '',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Flexible(
            child: SingleChartWidget(
              techListType: AnalysisTechListType.lc,
              techCode: dataProvider.selectedLcTechCode,
              countries: dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? [dataProvider.selectedCountry ?? ''] : null,
              targetNames: dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail
                  ? [dataProvider.selectedCompany ?? '']
                  : dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail
                      ? [dataProvider.selectedAcademic ?? '']
                      : null,
            ),
          ),
          Flexible(
            child: Row(
              children: [
                _buildRadarChart(
                  color: Colors.blue,
                  data: raderChartMCData,
                  isFilled: true,
                ),
                _buildRadarChart(
                  color: Colors.red,
                  data: raderChartSCData,
                  isFilled: true,
                ),
              ],
            ),
          ),
        ],
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
    final items = getItemsBySubCategory(dataProvider);

    return Column(
      children: [
        ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: items.map((item) {
                final isSelected = item ==
                    (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail
                        ? dataProvider.selectedCountry
                        : dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail
                            ? dataProvider.selectedCompany
                            : dataProvider.selectedAcademic);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedItem = item;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.blue,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(child: _buildChartContainer(dataProvider)),
      ],
    );
  }
}

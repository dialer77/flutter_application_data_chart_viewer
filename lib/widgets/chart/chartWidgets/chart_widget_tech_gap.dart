import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/single_chart_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_tech_gap_data_widget.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';

class ChartWidgetTechGap extends StatefulWidget {
  const ChartWidgetTechGap({super.key});

  @override
  State<ChartWidgetTechGap> createState() => _ChartWidgetTechGapState();
}

class _ChartWidgetTechGapState extends State<ChartWidgetTechGap> {
  bool _isTableVisible = false;
  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final techCode = dataProvider.selectedTechCode;

    var countries = dataProvider.selectedCountries.isEmpty ? dataProvider.getAvailableCountriesFormTechGap(techCode).take(10).toList() : dataProvider.selectedCountries.toList();

    List<String> targetNames = [];
    if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
      targetNames = dataProvider.selectedCompanies.isEmpty ? dataProvider.getAvailableCompaniesFormTechGap(techCode).take(10).toList() : dataProvider.selectedCompanies.toList();
    } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
      targetNames = dataProvider.selectedAcademics.isEmpty ? dataProvider.getAvailableAcademicsFormTechGap(techCode).take(10).toList() : dataProvider.selectedAcademics.toList();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          top: constraints.maxHeight * 0.05,
        ),
        child: Column(
          children: [
            Expanded(child: _buildChartMultiLineType(targetNames, dataProvider)),
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
                  child: TableTechGapDataWidget(),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildChartMultiLineType(List<String> targetNames, AnalysisDataProvider dataProvider) {
    final techCode = dataProvider.selectedTechCode;

    var countries = dataProvider.selectedCountries.isEmpty ? dataProvider.getAvailableCountriesFormTechGap(techCode).take(10).toList() : dataProvider.selectedCountries.toList();
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: SingleChartWidget(
              category: AnalysisCategory.techGap,
              selectedSubCategory: dataProvider.selectedSubCategory,
              techListType: dataProvider.selectedTechListType,
              techCode: techCode,
              countries: dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? countries.toList() : null,
              targetNames: dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail || dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail ? targetNames : null,
            ),
          ),
        ],
      );
    });
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_circle_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_widget_analysis_target.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_widget_industry_tech.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_chart_data.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_tech_gap_data_widget.dart';
import 'package:provider/provider.dart';
import '../../models/enum_defines.dart';
import 'dart:math';
import '../../providers/analysis_data_provider.dart';
import 'single_chart_widget.dart'; // 새로 분리한 위젯 import

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

    switch (dataProvider.selectedCategory) {
      case AnalysisCategory.industryTech:
        return const ChartWidgetIndustryTech();
      case AnalysisCategory.countryTech:
      case AnalysisCategory.companyTech:
      case AnalysisCategory.academicTech:
        return const ChartWidgetAnalysisTarget();
      default:
        break;
    }

    // 지수 타입인지 확인
    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(selectedSubCategory);

    final techCode = dataProvider.selectedTechCode;
    final techCodes = dataProvider.selectedTechCodes;

    if (category == AnalysisCategory.techCompetition) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        width: double.infinity,
        child: const Column(
          children: [
            Flexible(child: TableChartData()),
          ],
        ),
      );
    } else if (category == AnalysisCategory.techAssessment) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: const ChartCircleWidget(),
      );
    } else if (category == AnalysisCategory.techGap) {
      var countries = dataProvider.selectedCountries.isEmpty ? dataProvider.getAvailableCountriesFormTechGap(techCode).take(10).toList() : dataProvider.selectedCountries.toList();

      List<String> targetNames = [];
      if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
        targetNames = dataProvider.selectedCompanies.isEmpty ? dataProvider.getAvailableCompaniesFormTechGap(techCode).take(10).toList() : dataProvider.selectedCompanies.toList();
      } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
        targetNames = dataProvider.selectedAcademics.isEmpty ? dataProvider.getAvailableAcademicsFormTechGap(techCode).take(10).toList() : dataProvider.selectedAcademics.toList();
      }

      return Column(
        children: [
          SingleChartWidget(
            category: category,
            selectedSubCategory: selectedSubCategory,
            techListType: dataProvider.selectedTechListType,
            techCode: techCode,
            height: 300,
            countries: dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? countries.toList() : null,
            targetNames: dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail || dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail ? targetNames : null,
          ),
          const Expanded(
            child: SizedBox(
              width: double.infinity,
              child: TableTechGapDataWidget(),
            ),
          ),
        ],
      );
    }

    if (techCode == '') {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Center(
          child: Text(
            '${dataProvider.selectedTechListType} 데이터를 선택해주세요.',
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    // 지수 타입일 때는 하나의 차트에 모든 라인 표시
    if (isIndexType) {
      if (category == AnalysisCategory.countryTech || category == AnalysisCategory.companyTech || category == AnalysisCategory.academicTech) {
        var countries = dataProvider.selectedCountries.toList();
        if (countries.isEmpty) {
          countries = dataProvider.getAvailableCountries(techCode).take(10).toList();
        }
        List<String> targetNames = [];
        if (category == AnalysisCategory.companyTech) {
          targetNames = dataProvider.selectedCompanies.toList();
          if (targetNames.isEmpty) {
            targetNames = dataProvider.getAvailableCompanies().take(10).toList();
          }
        } else if (category == AnalysisCategory.academicTech) {
          targetNames = dataProvider.selectedAcademics.toList();
          if (targetNames.isEmpty) {
            targetNames = dataProvider.getAvailableAcademics().take(10).toList();
          }
        }

        return Column(
          children: [
            SingleChartWidget(
              category: category,
              selectedSubCategory: selectedSubCategory,
              techListType: dataProvider.selectedTechListType,
              chartTitle: '지수 추세',
              techCode: techCode,
              height: 300,
              countries: category == AnalysisCategory.countryTech ? countries : null,
              targetNames: (category == AnalysisCategory.companyTech || category == AnalysisCategory.academicTech) ? targetNames : null,
            ),
            const Expanded(child: TableChartData()),
          ],
        );
      } else {
        return SingleChartWidget(
          category: category,
          selectedSubCategory: selectedSubCategory,
          techListType: dataProvider.selectedTechListType,
          chartTitle: '지수 추세',
          techCode: techCode,
          height: 400,
          selectedCodes: techCodes.whereType<String>().toList(),
        );
      }
    }

    // 지수가 아닐 때는 기존 로직 유지
    if (techCodes.length == 1 && (category != AnalysisCategory.countryTech && category != AnalysisCategory.companyTech && category != AnalysisCategory.academicTech) ||
        (dataProvider.selectedCountries.length == 1)) {
      return SingleChartWidget(
        category: category,
        selectedSubCategory: selectedSubCategory,
        techListType: dataProvider.selectedTechListType,
        chartTitle: category == AnalysisCategory.countryTech ? dataProvider.selectedCountries.first : techCode ?? '',
        techCode: techCodes.first,
        country: category == AnalysisCategory.countryTech ? dataProvider.selectedCountries.first : null,
        chartColor: category == AnalysisCategory.countryTech ? dataProvider.getColorForCode(dataProvider.selectedCountries.first) : null,
        height: 250,
      );
    }

    const itemsPerRow = 2;
    List<String> codes;

    if (category == AnalysisCategory.countryTech) {
      codes = dataProvider.selectedCountries.toList();
      if (codes.isEmpty) {
        codes = dataProvider.getAvailableCountries(techCode).take(10).toList();
      }
    } else if (category == AnalysisCategory.companyTech) {
      codes = dataProvider.selectedCompanies.toList();
      if (codes.isEmpty) {
        codes = dataProvider.getAvailableCompanies().take(10).toList();
      }
    } else if (category == AnalysisCategory.academicTech) {
      codes = dataProvider.selectedAcademics.toList();
      if (codes.isEmpty) {
        codes = dataProvider.getAvailableAcademics().take(10).toList();
      }
    } else {
      codes = techCodes.whereType<String>().toList();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            for (var i = 0; i < codes.length; i += itemsPerRow)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var j = i; j < min(i + itemsPerRow, codes.length); j++)
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: j % itemsPerRow == 0 ? 0 : 4,
                            right: j % itemsPerRow == itemsPerRow - 1 ? 0 : 4,
                          ),
                          child: category == AnalysisCategory.countryTech
                              ? SingleChartWidget(
                                  category: category,
                                  selectedSubCategory: selectedSubCategory,
                                  techListType: dataProvider.selectedTechListType,
                                  techCode: techCode,
                                  chartTitle: codes[j],
                                  country: codes[j],
                                  height: 300,
                                  maxYRatio: 1.6,
                                  chartColor: dataProvider.getColorForCode(codes[j]),
                                )
                              : category == AnalysisCategory.companyTech || category == AnalysisCategory.academicTech
                                  ? SingleChartWidget(
                                      category: category,
                                      selectedSubCategory: selectedSubCategory,
                                      techListType: dataProvider.selectedTechListType,
                                      techCode: techCode,
                                      chartTitle: codes[j],
                                      targetName: codes[j],
                                      height: 300,
                                      chartColor: dataProvider.getColorForCode(codes[j]),
                                    )
                                  : SingleChartWidget(
                                      category: category,
                                      selectedSubCategory: selectedSubCategory,
                                      techListType: dataProvider.selectedTechListType,
                                      chartTitle: codes[j],
                                      techCode: codes[j],
                                      height: 300,
                                      chartColor: dataProvider.getColorForCode(codes[j]),
                                    ),
                        ),
                      ),
                    if (i + itemsPerRow > codes.length) Expanded(child: Container()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

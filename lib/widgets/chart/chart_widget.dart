import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chartWidgets/chart_widget_tech_assessment.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chartWidgets/chart_widget_tech_gap.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_circle_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chartWidgets/chart_widget_analysis_target.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chartWidgets/chart_widget_industry_tech.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chartWidgets/chart_widget_tech_competition.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_chart_data.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_tech_gap_data_widget.dart';
import 'package:provider/provider.dart';
import '../../models/enum_defines.dart';
import 'dart:math';
import '../../providers/analysis_data_provider.dart';
import 'single_chart_widget.dart'; // 새로 분리한 위젯 import

class ChartWidget extends StatefulWidget {
  final AnalysisCategory category;
  final AnalysisSubCategory? selectedSubCategory;

  const ChartWidget({
    super.key,
    required this.category,
    this.selectedSubCategory,
  });

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  final bool _isTableVisible = false;

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
    if (widget.selectedSubCategory == null) {
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
      case AnalysisCategory.techCompetition:
        return const ChartWidgetTechCompetition();
      case AnalysisCategory.techAssessment:
        return const ChartWidgetTechAssessment();
      case AnalysisCategory.techGap:
        return const ChartWidgetTechGap();
      default:
        break;
    }

    // 지수 타입인지 확인
    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(widget.selectedSubCategory);

    final techCode = dataProvider.selectedTechCode;
    final techCodes = dataProvider.selectedTechCodes;

    if (widget.category == AnalysisCategory.techCompetition) {
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
    } else if (widget.category == AnalysisCategory.techAssessment) {
      return Container(
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: const ChartCircleWidget(),
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
      if (widget.category == AnalysisCategory.countryTech || widget.category == AnalysisCategory.companyTech || widget.category == AnalysisCategory.academicTech) {
        var countries = dataProvider.selectedCountries.toList();
        if (countries.isEmpty) {
          countries = dataProvider.getAvailableCountries(techCode).take(10).toList();
        }
        List<String> targetNames = [];
        if (widget.category == AnalysisCategory.companyTech) {
          targetNames = dataProvider.selectedCompanies.toList();
          if (targetNames.isEmpty) {
            targetNames = dataProvider.getAvailableCompanies().take(10).toList();
          }
        } else if (widget.category == AnalysisCategory.academicTech) {
          targetNames = dataProvider.selectedAcademics.toList();
          if (targetNames.isEmpty) {
            targetNames = dataProvider.getAvailableAcademics().take(10).toList();
          }
        }

        return Column(
          children: [
            SingleChartWidget(
              category: widget.category,
              selectedSubCategory: widget.selectedSubCategory,
              techListType: dataProvider.selectedTechListType,
              chartTitle: '지수 추세',
              techCode: techCode,
              countries: widget.category == AnalysisCategory.countryTech ? countries : null,
              targetNames: (widget.category == AnalysisCategory.companyTech || widget.category == AnalysisCategory.academicTech) ? targetNames : null,
            ),
            const Expanded(child: TableChartData()),
          ],
        );
      } else {
        return SingleChartWidget(
          category: widget.category,
          selectedSubCategory: widget.selectedSubCategory,
          techListType: dataProvider.selectedTechListType,
          chartTitle: '지수 추세',
          techCode: techCode,
          selectedCodes: techCodes.whereType<String>().toList(),
        );
      }
    }

    // 지수가 아닐 때는 기존 로직 유지
    if (techCodes.length == 1 && (widget.category != AnalysisCategory.countryTech && widget.category != AnalysisCategory.companyTech && widget.category != AnalysisCategory.academicTech) ||
        (dataProvider.selectedCountries.length == 1)) {
      return SingleChartWidget(
        category: widget.category,
        selectedSubCategory: widget.selectedSubCategory,
        techListType: dataProvider.selectedTechListType,
        chartTitle: widget.category == AnalysisCategory.countryTech ? dataProvider.selectedCountries.first : techCode ?? '',
        techCode: techCodes.first,
        country: widget.category == AnalysisCategory.countryTech ? dataProvider.selectedCountries.first : null,
        chartColor: widget.category == AnalysisCategory.countryTech ? dataProvider.getColorForCode(dataProvider.selectedCountries.first) : null,
      );
    }

    const itemsPerRow = 2;
    List<String> codes;

    if (widget.category == AnalysisCategory.countryTech) {
      codes = dataProvider.selectedCountries.toList();
      if (codes.isEmpty) {
        codes = dataProvider.getAvailableCountries(techCode).take(10).toList();
      }
    } else if (widget.category == AnalysisCategory.companyTech) {
      codes = dataProvider.selectedCompanies.toList();
      if (codes.isEmpty) {
        codes = dataProvider.getAvailableCompanies().take(10).toList();
      }
    } else if (widget.category == AnalysisCategory.academicTech) {
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
                          child: widget.category == AnalysisCategory.countryTech
                              ? SingleChartWidget(
                                  category: widget.category,
                                  selectedSubCategory: widget.selectedSubCategory,
                                  techListType: dataProvider.selectedTechListType,
                                  techCode: techCode,
                                  chartTitle: codes[j],
                                  country: codes[j],
                                  maxYRatio: 1.6,
                                  chartColor: dataProvider.getColorForCode(codes[j]),
                                )
                              : widget.category == AnalysisCategory.companyTech || widget.category == AnalysisCategory.academicTech
                                  ? SingleChartWidget(
                                      category: widget.category,
                                      selectedSubCategory: widget.selectedSubCategory,
                                      techListType: dataProvider.selectedTechListType,
                                      techCode: techCode,
                                      chartTitle: codes[j],
                                      targetName: codes[j],
                                      chartColor: dataProvider.getColorForCode(codes[j]),
                                    )
                                  : SingleChartWidget(
                                      category: widget.category,
                                      selectedSubCategory: widget.selectedSubCategory,
                                      techListType: dataProvider.selectedTechListType,
                                      chartTitle: codes[j],
                                      techCode: codes[j],
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

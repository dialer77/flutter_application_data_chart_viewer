import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enum_defines.dart';
import 'dart:math';
import '../providers/analysis_data_provider.dart';
import '../providers/analysis_state_provider.dart';
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
    final stateProvider = context.watch<AnalysisStateProvider>();

    // 연도 범위 가져오기
    final startYear = stateProvider.startYear;
    final endYear = stateProvider.endYear;

    // 디버그 출력 추가
    print('ChartWidget - Current LC Code: ${stateProvider.selectedLcDataCode}');

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

    // 지수 타입인지 확인
    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(selectedSubCategory);

    // MC 또는 SC 타입일 때
    final selectedCodes = switch (stateProvider.selectedTechListType) {
      TechListType.mc => stateProvider.selectedMcDataCodes,
      TechListType.sc => stateProvider.selectedScDataCodes,
      _ => {stateProvider.selectedLcDataCode!},
    };

    if (selectedCodes.isEmpty && category != AnalysisCategory.countryTech) {
      return const Center(child: Text('코드를 선택해주세요'));
    }

    final codePrefix =
        stateProvider.selectedTechListType == TechListType.mc ? 'MC' : 'SC';

    // 지수 타입일 때는 하나의 차트에 모든 라인 표시
    if (isIndexType) {
      final techCode = switch (stateProvider.selectedTechListType) {
        TechListType.mc => stateProvider.selectedMcDataCode,
        TechListType.sc => stateProvider.selectedScDataCode,
        _ => stateProvider.selectedLcDataCode,
      };
      if (category == AnalysisCategory.countryTech) {
        return SingleChartWidget(
          category: category,
          selectedSubCategory: selectedSubCategory,
          codeTitle: '$codePrefix 지수 추세',
          selectedTechListType: stateProvider.selectedTechListType,
          techCode: techCode,
          height: 400,
          countries: dataProvider.selectedCountries.toList(),
          startYear: startYear,
          endYear: endYear,
        );
      } else {
        final techCode = switch (stateProvider.selectedTechListType) {
          TechListType.mc => stateProvider.selectedMcDataCodes.first,
          TechListType.sc => stateProvider.selectedScDataCodes.first,
          _ => stateProvider.selectedLcDataCode,
        };
        return SingleChartWidget(
          category: category,
          selectedSubCategory: selectedSubCategory,
          codeTitle: '$codePrefix 지수 추세',
          selectedTechListType: stateProvider.selectedTechListType,
          techCode: techCode,
          height: 400,
          selectedCodes: selectedCodes as List<String>?,
          startYear: startYear,
          endYear: endYear,
        );
      }
    }

    // 지수가 아닐 때는 기존 로직 유지
    if (selectedCodes.length == 1 &&
        (category != AnalysisCategory.countryTech ||
            dataProvider.selectedCountries.length == 1)) {
      return SingleChartWidget(
        category: category,
        selectedSubCategory: selectedSubCategory,
        codeTitle: '$codePrefix: ${selectedCodes.first}',
        selectedTechListType: stateProvider.selectedTechListType,
        techCode: selectedCodes.first,
        height: 250,
        startYear: startYear,
        endYear: endYear,
      );
    }

    const itemsPerRow = 2;
    List<String> codes;
    if (category == AnalysisCategory.countryTech) {
      codes = dataProvider.selectedCountries.toList();
    } else {
      codes = selectedCodes.whereType<String>().toList();
    }

    return SingleChildScrollView(
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
                                selectedTechListType:
                                    stateProvider.selectedTechListType,
                                techCode: switch (
                                    stateProvider.selectedTechListType) {
                                  TechListType.mc =>
                                    stateProvider.selectedMcDataCodes.first,
                                  TechListType.sc =>
                                    stateProvider.selectedScDataCodes.first,
                                  _ => stateProvider.selectedLcDataCode,
                                },
                                codeTitle: codes[j],
                                country: codes[j],
                                height: 300,
                                maxYRatio: 1.6,
                                startYear: startYear,
                                endYear: endYear,
                              )
                            : SingleChartWidget(
                                category: category,
                                selectedSubCategory: selectedSubCategory,
                                selectedTechListType:
                                    stateProvider.selectedTechListType,
                                codeTitle: codes[j],
                                techCode: codes[j],
                                height: 300,
                                startYear: startYear,
                                endYear: endYear,
                              ),
                      ),
                    ),
                  if (i + itemsPerRow > codes.length)
                    Expanded(child: Container()),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

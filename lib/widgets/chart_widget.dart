import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/enum_defines.dart';
import 'dart:math';
import '../providers/analysis_data_provider.dart';
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

    final selectedCodes = dataProvider.selectedTechCodes;

    // 지수 타입인지 확인
    final isIndexType = [
      AnalysisSubCategory.techInnovationIndex,
      AnalysisSubCategory.marketExpansionIndex,
      AnalysisSubCategory.rdInvestmentIndex,
    ].contains(selectedSubCategory);

    // 지수 타입일 때는 하나의 차트에 모든 라인 표시
    if (isIndexType) {
      final techCode = switch (dataProvider.selectedTechListType) {
        TechListType.mc => dataProvider.selectedMcTechCodes.first,
        TechListType.sc => dataProvider.selectedScTechCodes.first,
        _ => dataProvider.selectedLcTechCode,
      };
      if (category == AnalysisCategory.countryTech) {
        return Column(
          children: [
            SingleChartWidget(
              category: category,
              selectedSubCategory: selectedSubCategory,
              codeTitle: '지수 추세',
              selectedTechListType: dataProvider.selectedTechListType,
              techCode: techCode,
              height: 400,
              countries: dataProvider.selectedCountries.toList(),
            ),
          ],
        );
      } else {
        final techCode = switch (dataProvider.selectedTechListType) {
          TechListType.mc => dataProvider.selectedMcTechCodes.first,
          TechListType.sc => dataProvider.selectedScTechCodes.first,
          _ => dataProvider.selectedLcTechCode,
        };
        return SingleChartWidget(
          category: category,
          selectedSubCategory: selectedSubCategory,
          codeTitle: '지수 추세',
          selectedTechListType: dataProvider.selectedTechListType,
          techCode: techCode,
          height: 400,
          selectedCodes: selectedCodes.whereType<String>().toList(),
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
        codeTitle: dataProvider.selectedTechCode!,
        selectedTechListType: dataProvider.selectedTechListType,
        techCode: selectedCodes.first,
        height: 250,
      );
    }

    const itemsPerRow = 2;
    List<String> codes;
    List<Color> chartColors = [
      // 다홍색
      Colors.red,
      // 초록색
      Colors.green,
      // 파란색
      Colors.blue,
      // 주황색
      Colors.orange,
      // 보라색
      Colors.purple,
      // 청록색
      Colors.teal,
      // 분홍색
      Colors.pink,
      // 갈색
      Colors.brown,
      // 남색
      Colors.indigo,
      // 회색
      Colors.grey,
    ];

    if (category == AnalysisCategory.countryTech) {
      codes = dataProvider.selectedCountries.toList();
    } else {
      codes = selectedCodes.whereType<String>().toList();
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
                                  selectedTechListType:
                                      dataProvider.selectedTechListType,
                                  techCode: switch (
                                      dataProvider.selectedTechListType) {
                                    TechListType.lc =>
                                      dataProvider.selectedLcTechCode,
                                    TechListType.mc =>
                                      dataProvider.selectedMcTechCodes.first,
                                    TechListType.sc =>
                                      dataProvider.selectedScTechCodes.first,
                                  },
                                  codeTitle: codes[j],
                                  country: codes[j],
                                  height: 300,
                                  maxYRatio: 1.6,
                                  chartColor:
                                      dataProvider.getColorForCode(codes[j]),
                                )
                              : SingleChartWidget(
                                  category: category,
                                  selectedSubCategory: selectedSubCategory,
                                  selectedTechListType:
                                      dataProvider.selectedTechListType,
                                  codeTitle: codes[j],
                                  techCode: codes[j],
                                  height: 300,
                                  chartColor:
                                      dataProvider.getColorForCode(codes[j]),
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
      ),
    );
  }
}

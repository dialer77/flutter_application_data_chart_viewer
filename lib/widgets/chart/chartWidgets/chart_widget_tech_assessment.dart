import 'dart:ui';
import 'package:country_flags/country_flags.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_circle_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/single_chart_widget.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class ChartWidgetTechAssessment extends StatefulWidget {
  const ChartWidgetTechAssessment({super.key});

  @override
  State<ChartWidgetTechAssessment> createState() => _ChartWidgetTechAssessmentState();
}

class _ChartWidgetTechAssessmentState extends State<ChartWidgetTechAssessment> {
  String? selectedItem;
  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final items = getItemsBySubCategory(dataProvider);
    return LayoutBuilder(builder: (context, constraints) {
      return LayoutGrid(
        columnSizes: [1.fr, 1.fr],
        rowSizes: [1.fr, 4.5.fr, 4.5.fr],
        children: [
          Row(
            children: [
              Expanded(
                child: Center(
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(
                      dragDevices: {
                        PointerDeviceKind.touch,
                        PointerDeviceKind.mouse,
                      },
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: items.map((item) {
                            final isSelected = item == selectedItem;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    selectedItem = item;
                                    if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
                                      dataProvider.setSelectedCountry(item);
                                    } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
                                      dataProvider.setSelectedCompany(item);
                                    } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
                                      dataProvider.setSelectedAcademic(item);
                                    }
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.blue : Colors.white,
                                    border: Border.all(color: Colors.blue),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: Row(
                                    children: [
                                      (() {
                                        if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
                                          final countryCode = CommonUtils.instance.replaceCountryCode(item);
                                          return CountryFlag.fromCountryCode(countryCode, height: 20, width: 20);
                                        }
                                        return const SizedBox.shrink();
                                      })(),
                                      Text(
                                        item,
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : Colors.blue,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                width: constraints.maxHeight * 0.12,
                height: constraints.maxHeight * 0.08,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color.fromARGB(255, 109, 207, 245),
                  ),
                ),
                child: CommonUtils.instance.saveMenuPopup(constraints: constraints),
              ),
            ],
          ).withGridPlacement(
            columnStart: 0,
            columnSpan: 2,
            rowStart: 0,
            rowSpan: 1,
          ),
          RepaintBoundary(
            key: CommonUtils.chartKey,
            child: SingleChartWidget(
              techListType: dataProvider.selectedTechListType,
              techCode: dataProvider.selectedTechCode,
              countries: dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? [dataProvider.selectedCountry ?? ''] : null,
              targetNames: (() {
                List<String> targetNames = [];
                if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
                  targetNames.add(dataProvider.selectedCompany ?? '');
                } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
                  targetNames.add(dataProvider.selectedAcademic ?? '');
                }
                return targetNames;
              })(),
            ).withGridPlacement(
              columnStart: 0,
              columnSpan: 1,
              rowStart: 1,
              rowSpan: 1,
            ),
          ),
          ChartCircleWidget(
            techListType: AnalysisTechListType.mc,
            techCodes: dataProvider.selectedMcTechCodes.toList(),
          ).withGridPlacement(
            columnStart: 1,
            columnSpan: 1,
            rowStart: 1,
            rowSpan: 1,
          ),
          ChartCircleWidget(
            techListType: AnalysisTechListType.sc,
            techCodes: dataProvider.selectedScTechCodes.toList(),
          ).withGridPlacement(
            columnStart: 0,
            columnSpan: 2,
            rowStart: 2,
            rowSpan: 1,
          ),
        ],
      );
    });
  }

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
}

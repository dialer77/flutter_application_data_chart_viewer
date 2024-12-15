import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:provider/provider.dart';

class TableTechGapDataWidget extends StatefulWidget {
  const TableTechGapDataWidget({super.key});

  @override
  State<TableTechGapDataWidget> createState() => _TableTechGapDataWidgetState();
}

class _TableTechGapDataWidgetState extends State<TableTechGapDataWidget> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: dataProvider.selectedCategory != AnalysisCategory.techGap ? const Text('기술격차 페이지에서만 사용해주세요') : _buildTechGapTable(),
    );
  }

  Widget _buildTechGapTable() {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final techCode = dataProvider.selectedTechCode;

    var countries = dataProvider.selectedCountries.isEmpty ? dataProvider.getAvailableCountriesFormTechGap(techCode).take(10).toList() : dataProvider.selectedCountries.toList();

    List<String> targetNames = [];
    if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
      targetNames = dataProvider.selectedCompanies.isEmpty ? dataProvider.getAvailableCompaniesFormTechGap(techCode).take(10).toList() : dataProvider.selectedCompanies.toList();
    } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
      targetNames = dataProvider.selectedAcademics.isEmpty ? dataProvider.getAvailableAcademicsFormTechGap(techCode).take(10).toList() : dataProvider.selectedAcademics.toList();
    }

    final items = dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? countries : targetNames;

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: 0,
              horizontalMargin: 0,
              headingRowHeight: 56,
              headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
              columns: [
                DataColumn(
                  label: SizedBox(
                    width: constraints.maxWidth * 0.1,
                    child: const Center(
                        child: Text(
                      '기준',
                      style: TextStyle(fontSize: 10),
                    )),
                  ),
                ),
                ...items.map((item) {
                  var countryCode = dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? item : dataProvider.searchCountryCode(item);
                  countryCode = CommonUtils.instance.replaceCountryCode(countryCode);
                  return DataColumn(
                      label: SizedBox(
                    width: constraints.maxWidth * 0.9 / items.length,
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          (() {
                            if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CountryFlag.fromCountryCode(countryCode, height: 12, width: 18),
                                  const SizedBox(width: 4),
                                  Text(
                                    countryCode,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              );
                            } else {
                              return Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CountryFlag.fromCountryCode(countryCode, height: 12, width: 18),
                                    Text(
                                      item,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ],
                                ),
                              );
                            }
                          })(),
                        ],
                      ),
                    ),
                  ));
                }),
              ],
              rows: const [],
            ),
          ),
          Expanded(
            child: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 0,
                  horizontalMargin: 0,
                  headingRowHeight: 0,
                  columns: [
                    const DataColumn(label: SizedBox()),
                    ...items.map((item) => const DataColumn(label: SizedBox())),
                  ],
                  rows: items.map((rowItem) {
                    var countryCode = dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? rowItem : dataProvider.searchCountryCode(rowItem);
                    countryCode = CommonUtils.instance.replaceCountryCode(countryCode);
                    return DataRow(
                      cells: [
                        DataCell(
                          Container(
                            width: constraints.maxWidth * 0.1,
                            color: Colors.grey[200],
                            child: Center(
                              child: Row(
                                children: [
                                  CountryFlag.fromCountryCode(countryCode, height: 12, width: 18),
                                  Expanded(
                                    child: Text(
                                      CommonUtils.instance.replaceCountryCode(rowItem),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ...items.map((colItem) {
                          if (rowItem == colItem) {
                            return DataCell(SizedBox(
                              width: constraints.maxWidth * 0.9 / items.length,
                              child: const Center(child: Text('-')),
                            ));
                          }

                          double rowValue = dataProvider
                              .getChartData(
                                  techListType: dataProvider.selectedTechListType,
                                  techCode: techCode,
                                  country: dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? rowItem : null,
                                  targetName:
                                      dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail || dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail ? rowItem : null)
                              .values
                              .last;
                          double colValue = dataProvider
                              .getChartData(
                                  techListType: dataProvider.selectedTechListType,
                                  techCode: techCode,
                                  country: dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? colItem : null,
                                  targetName:
                                      dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail || dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail ? colItem : null)
                              .values
                              .last;
                          double gap = calculateGap(rowValue, colValue);

                          return DataCell(
                            SizedBox(
                              width: constraints.maxWidth * 0.9 / items.length,
                              child: Center(
                                child: Text(
                                  '${gap >= 0 ? '+' : ''}${(gap * 10).toStringAsFixed(1)}',
                                  style: TextStyle(
                                    color: gap < 0 ? Colors.blue : Colors.red,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  double calculateGap(double currentValue, double baseValue) {
    return currentValue - baseValue;
  }
}

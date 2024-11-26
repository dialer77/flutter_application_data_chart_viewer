import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
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
      child: dataProvider.selectedCategory != AnalysisCategory.techGap
          ? const Text('기술격차 페이지에서만 사용해주세요')
          : _buildTechGapTable(),
    );
  }

  Widget _buildTechGapTable() {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final techCode = dataProvider.selectedTechCode;

    var countries = dataProvider.selectedCountries.isEmpty
        ? dataProvider
            .getAvailableCountriesFormTechGap(techCode)
            .take(10)
            .toList()
        : dataProvider.selectedCountries.toList();

    List<String> targetNames = [];
    if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
      targetNames = dataProvider.selectedCompanies.isEmpty
          ? dataProvider
              .getAvailableCompaniesFormTechGap(techCode)
              .take(10)
              .toList()
          : dataProvider.selectedCompanies.toList();
    } else if (dataProvider.selectedSubCategory ==
        AnalysisSubCategory.academicDetail) {
      targetNames = dataProvider.selectedAcademics.isEmpty
          ? dataProvider
              .getAvailableAcademicsFormTechGap(techCode)
              .take(10)
              .toList()
          : dataProvider.selectedAcademics.toList();
    }

    final items =
        dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail
            ? countries
            : targetNames;

    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: DataTable(
        headingRowHeight: 56,
        headingRowColor: WidgetStateProperty.all(Colors.grey[200]),
        columns: [
          const DataColumn(
            label: SizedBox(
              child: Center(child: Text('기준')),
            ),
          ),
          ...items.map((item) {
            var conturyCode = dataProvider.selectedSubCategory ==
                    AnalysisSubCategory.countryDetail
                ? item.replaceAll(RegExp(r'[\[\]]'), '')
                : dataProvider
                    .searchCountryCode(item)
                    .replaceAll(RegExp(r'[\[\]]'), '');
            return DataColumn(
                label: SizedBox(
              width: 80,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryFlag.fromCountryCode(conturyCode,
                      height: 16, width: 24),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                    ),
                  ),
                ],
              ),
            ));
          }),
        ],
        rows: items.map((rowItem) {
          var countryCode = dataProvider.selectedSubCategory ==
                  AnalysisSubCategory.countryDetail
              ? rowItem.replaceAll(RegExp(r'[\[\]]'), '')
              : dataProvider
                  .searchCountryCode(rowItem)
                  .replaceAll(RegExp(r'[\[\]]'), '');
          return DataRow(
            cells: [
              DataCell(
                Container(
                  color: Colors.grey[200],
                  child: Row(
                    children: [
                      CountryFlag.fromCountryCode(countryCode,
                          height: 16, width: 24),
                      Expanded(
                        child: Text(
                          rowItem,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              ...items.map((colItem) {
                if (rowItem == colItem) {
                  return const DataCell(Text('-'));
                }

                double rowValue = dataProvider
                    .getChartData(
                        techListType: dataProvider.selectedTechListType,
                        techCode: techCode,
                        country: dataProvider.selectedSubCategory ==
                                AnalysisSubCategory.countryDetail
                            ? rowItem
                            : null,
                        targetName: dataProvider.selectedSubCategory ==
                                    AnalysisSubCategory.companyDetail ||
                                dataProvider.selectedSubCategory ==
                                    AnalysisSubCategory.academicDetail
                            ? rowItem
                            : null)
                    .values
                    .last;
                double colValue = dataProvider
                    .getChartData(
                        techListType: dataProvider.selectedTechListType,
                        techCode: techCode,
                        country: dataProvider.selectedSubCategory ==
                                AnalysisSubCategory.countryDetail
                            ? colItem
                            : null,
                        targetName: dataProvider.selectedSubCategory ==
                                    AnalysisSubCategory.companyDetail ||
                                dataProvider.selectedSubCategory ==
                                    AnalysisSubCategory.academicDetail
                            ? colItem
                            : null)
                    .values
                    .last;
                double gap = calculateGap(rowValue, colValue);

                return DataCell(
                  Text(
                    gap.toStringAsFixed(1),
                    style: TextStyle(
                      color: gap < 0 ? Colors.red : Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ],
          );
        }).toList(),
      ),
    );
  }

  double calculateGap(double currentValue, double baseValue) {
    return currentValue - baseValue;
  }
}

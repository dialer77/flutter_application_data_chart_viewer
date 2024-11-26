import 'package:country_flags/country_flags.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class TableChartData extends StatelessWidget {
  final double? height;
  const TableChartData({
    super.key,
    this.height = 440,
  });

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final years = dataProvider.getYearRange();

    final techCode = dataProvider.selectedTechCode;
    var countries = dataProvider.selectedCountries.toList();
    if (countries.isEmpty) {
      countries =
          dataProvider.getAvailableCountries(techCode).take(10).toList();
    }

    var companies = dataProvider.selectedCompanies.toList();
    if (companies.isEmpty) {
      companies = dataProvider.getAvailableCompanies().take(10).toList();
    }

    var academics = dataProvider.selectedAcademics.toList();
    if (academics.isEmpty) {
      academics = dataProvider.getAvailableAcademics().take(10).toList();
    }

    final ScrollController horizontalController = ScrollController();
    final ScrollController verticalController = ScrollController();

    DataTable dataTable;
    if (dataProvider.selectedCategory == AnalysisCategory.countryTech ||
        dataProvider.selectedCategory == AnalysisCategory.companyTech ||
        dataProvider.selectedCategory == AnalysisCategory.academicTech) {
      dataTable = _buildDataTableNormal(
          dataProvider, years, techCode, countries, companies, academics);
    } else {
      var data = dataProvider.getTechCompetitionData();
      var dataCodes = dataProvider.getTechCompetitionDataCodes();
      dataTable = _buildDataTableTechCompetition(dataProvider, data, dataCodes);
    }
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      width: double.infinity,
      height: height ?? 200,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: verticalController,
              child: GestureDetector(
                onPanUpdate: (details) {
                  horizontalController.position.moveTo(
                    horizontalController.position.pixels - details.delta.dx,
                  );
                  verticalController.position.moveTo(
                    verticalController.position.pixels - details.delta.dy,
                  );
                },
                child: Listener(
                  onPointerSignal: (pointerSignal) {
                    if (pointerSignal is PointerScrollEvent) {
                      horizontalController.position.moveTo(
                        horizontalController.position.pixels +
                            pointerSignal.scrollDelta.dx,
                      );
                      verticalController.position.moveTo(
                        verticalController.position.pixels +
                            pointerSignal.scrollDelta.dy,
                      );
                    }
                  },
                  child: SingleChildScrollView(
                    controller: horizontalController,
                    scrollDirection: Axis.horizontal,
                    child: dataTable,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  DataTable _buildDataTableNormal(
      AnalysisDataProvider dataProvider,
      RangeValues years,
      String? techCode,
      List<String> countries,
      List<String> companies,
      List<String> academics) {
    return DataTable(
      headingRowColor:
          WidgetStateProperty.all(const Color.fromARGB(255, 16, 72, 98)),
      columns: [
        const DataColumn(
          label:
              Text('Rank', style: TextStyle(fontSize: 12, color: Colors.white)),
        ),
        const DataColumn(
          label:
              Text('국가', style: TextStyle(fontSize: 12, color: Colors.white)),
        ),
        if (dataProvider.selectedCategory == AnalysisCategory.companyTech)
          const DataColumn(
            label:
                Text('기업', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        if (dataProvider.selectedCategory == AnalysisCategory.academicTech)
          const DataColumn(
            label:
                Text('대학', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ...List.generate(
            (years.end - years.start).toInt() + 1,
            (index) => DataColumn(
                label: Text((years.start.toInt() + index).toString(),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.white)))),
      ],
      rows: List<DataRow>.generate(
        dataProvider.selectedCategory == AnalysisCategory.countryTech
            ? countries.length
            : dataProvider.selectedCategory == AnalysisCategory.companyTech
                ? companies.length
                : academics.length,
        (index) {
          final tableData = dataProvider.getChartData(
              techCode: techCode,
              country:
                  dataProvider.selectedCategory == AnalysisCategory.countryTech
                      ? countries[index]
                      : null,
              targetName:
                  dataProvider.selectedCategory == AnalysisCategory.companyTech
                      ? companies[index]
                      : dataProvider.selectedCategory ==
                              AnalysisCategory.academicTech
                          ? academics[index]
                          : null);
          var countryCode = dataProvider.selectedCategory ==
                  AnalysisCategory.countryTech
              ? countries[index].replaceAll(RegExp(r'[\[\]]'), '')
              : dataProvider.selectedCategory == AnalysisCategory.companyTech
                  ? dataProvider
                      .searchCountryCode(companies[index])
                      .replaceAll(RegExp(r'[\[\]]'), '')
                  : dataProvider
                      .searchCountryCode(academics[index])
                      .replaceAll(RegExp(r'[\[\]]'), '');
          return DataRow(
            cells: [
              DataCell(Text((index + 1).toString())), // Rank
              DataCell(
                Row(
                  children: [
                    CountryFlag.fromCountryCode(
                      countryCode,
                      height: 16,
                      width: 24,
                    ),
                    Text(countryCode),
                  ],
                ),
              ),
              if (dataProvider.selectedCategory == AnalysisCategory.companyTech)
                DataCell(
                  Text(companies[index]),
                ),
              if (dataProvider.selectedCategory ==
                  AnalysisCategory.academicTech)
                DataCell(
                  Text(academics[index]),
                ),
              ...List.generate(
                (years.end - years.start).toInt() + 1,
                (yearIndex) => DataCell(
                  Text(tableData[(years.start.toInt() + yearIndex)]
                          ?.toStringAsFixed(3) ??
                      '0.000'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  DataTable _buildDataTableTechCompetition(AnalysisDataProvider dataProvider,
      Map<String, Map<String, double>> data, List<String> dataCodes) {
    return DataTable(
      headingRowColor:
          WidgetStateProperty.all(const Color.fromARGB(255, 16, 72, 98)),
      columns: [
        const DataColumn(
          label:
              Text('RANK', style: TextStyle(fontSize: 12, color: Colors.white)),
        ),
        DataColumn(
          label: Text(
              dataProvider.selectedSubCategory ==
                      AnalysisSubCategory.countryDetail
                  ? 'COUNTRY'
                  : dataProvider.selectedSubCategory ==
                          AnalysisSubCategory.companyDetail
                      ? 'COMPANY'
                      : 'INSTITUTE',
              style: const TextStyle(fontSize: 12, color: Colors.white)),
        ),
        ...dataCodes.map(
          (code) => DataColumn(
            label: Container(
              width: 80,
              child: Text(code,
                  style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
        ),
      ],
      rows: List<DataRow>.generate(
        data.keys.length,
        (index) {
          return DataRow(
            cells: [
              DataCell(Text((index + 1).toString())), // Rank
              DataCell(
                Row(
                  children: [
                    CountryFlag.fromCountryCode(
                      dataProvider.selectedSubCategory ==
                              AnalysisSubCategory.countryDetail
                          ? data.keys
                              .elementAt(index)
                              .replaceAll(RegExp(r'[\[\]]'), '')
                          : dataProvider
                              .searchCountryCode(data.keys.elementAt(index))
                              .replaceAll(RegExp(r'[\[\]]'), ''),
                      height: 16,
                      width: 24,
                    ),
                    Text(data.keys.elementAt(index)),
                  ],
                ),
              ),
              ...dataCodes.map(
                (code) => DataCell(
                  Text(data[data.keys.elementAt(index)]?[code]
                          ?.toStringAsFixed(3) ??
                      '0.000'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

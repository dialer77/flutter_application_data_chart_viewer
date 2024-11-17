import 'package:country_flags/country_flags.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class ChartDataTable extends StatelessWidget {
  const ChartDataTable({super.key});

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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      width: double.infinity,
      height: 440,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 16, 72, 98),
            ),
            child: const Center(
              child: Text('Citation Index',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
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
                    child: SizedBox(
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            const Color.fromARGB(255, 16, 72, 98)),
                        columns: [
                          const DataColumn(
                            label: Text('Rank',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ),
                          const DataColumn(
                            label: Text('국가',
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ),
                          if (dataProvider.selectedCategory ==
                              AnalysisCategory.companyTech)
                            const DataColumn(
                              label: Text('기업',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white)),
                            ),
                          if (dataProvider.selectedCategory ==
                              AnalysisCategory.academicTech)
                            const DataColumn(
                              label: Text('대학',
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.white)),
                            ),
                          ...List.generate(
                              (years.end - years.start).toInt() + 1,
                              (index) => DataColumn(
                                  label: Text(
                                      (years.start.toInt() + index).toString(),
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.white)))),
                        ],
                        rows: List<DataRow>.generate(countries.length, (index) {
                          final tableData = dataProvider.getChartData(
                              techCode: techCode,
                              country: dataProvider.selectedCategory ==
                                      AnalysisCategory.countryTech
                                  ? countries[index]
                                  : null,
                              targetName: dataProvider.selectedCategory ==
                                      AnalysisCategory.companyTech
                                  ? companies[index]
                                  : dataProvider.selectedCategory ==
                                          AnalysisCategory.academicTech
                                      ? academics[index]
                                      : null);
                          return DataRow(cells: [
                            DataCell(Text((index + 1).toString())), // Rank
                            DataCell(
                              Row(
                                children: [
                                  CountryFlag.fromCountryCode(
                                    countries[index]
                                        .replaceAll(RegExp(r'[\[\]]'), ''),
                                    height: 16,
                                    width: 24,
                                  ),
                                  Text(countries[index]),
                                ],
                              ),
                            ),
                            if (dataProvider.selectedCategory ==
                                AnalysisCategory.companyTech)
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
                                Text(
                                    tableData[(years.start.toInt() + yearIndex)]
                                            ?.toStringAsFixed(3) ??
                                        '0.000'),
                              ),
                            ),
                          ]);
                        }),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

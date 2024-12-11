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

    final techCode = dataProvider.selectedTechCode;
    var countries = dataProvider.selectedCountries.toList();
    if (countries.isEmpty) {
      countries = dataProvider.getAvailableCountries(techCode).take(10).toList();
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
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        width: constraints.maxWidth,
        height: constraints.maxHeight,
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
                          horizontalController.position.pixels + pointerSignal.scrollDelta.dx,
                        );
                        verticalController.position.moveTo(
                          verticalController.position.pixels + pointerSignal.scrollDelta.dy,
                        );
                      }
                    },
                    child: SingleChildScrollView(
                      controller: horizontalController,
                      scrollDirection: Axis.horizontal,
                      child: (() {
                        var data = dataProvider.getTechCompetitionData();
                        var dataCodes = dataProvider.getTechCompetitionDataCodes();
                        return _buildDataTableTechCompetition(dataProvider, data, dataCodes, constraints);
                      }()),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataTable _buildDataTableTechCompetition(AnalysisDataProvider dataProvider, Map<String, Map<String, double>> data, List<String> dataCodes, BoxConstraints constraints) {
    return DataTable(
      headingRowColor: WidgetStateProperty.all(const Color.fromARGB(255, 16, 72, 98)),
      horizontalMargin: 0,
      columnSpacing: 0,
      columns: [
        DataColumn(
          headingRowAlignment: MainAxisAlignment.center,
          label: SizedBox(
            width: constraints.maxWidth * 0.075,
            child: const Center(
              child: Text(
                'RANK',
                style: TextStyle(fontSize: 12, color: Colors.white),
              ),
            ),
          ),
        ),
        DataColumn(
          headingRowAlignment: MainAxisAlignment.center,
          label: SizedBox(
            width: constraints.maxWidth * (1 - 0.1 * dataCodes.length - 0.075),
            child: Center(
              child: Text(
                  dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail
                      ? 'COUNTRY'
                      : dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail
                          ? 'COMPANY'
                          : 'INSTITUTE',
                  style: const TextStyle(fontSize: 12, color: Colors.white)),
            ),
          ),
        ),
        ...dataCodes.map(
          (code) => DataColumn(
            headingRowAlignment: MainAxisAlignment.center,
            label: SizedBox(
              width: constraints.maxWidth * 0.1,
              child: Center(
                child: Text(
                  code,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ],
      rows: List<DataRow>.generate(
        data.keys.length,
        (index) {
          return DataRow(
            cells: [
              DataCell(
                SizedBox(
                  child: Center(
                    child: Text(
                      (index + 1).toString(),
                    ),
                  ),
                ),
              ), // Rank
              DataCell(
                Row(
                  children: [
                    CountryFlag.fromCountryCode(
                      dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail
                          ? data.keys.elementAt(index).replaceAll(RegExp(r'[\[\]]'), '')
                          : dataProvider.searchCountryCode(data.keys.elementAt(index)).replaceAll(RegExp(r'[\[\]]'), ''),
                      height: 16,
                      width: 24,
                    ),
                    Text(data.keys.elementAt(index)),
                  ],
                ),
              ),
              ...dataCodes.map(
                (code) => DataCell(
                  Center(child: Text(data[data.keys.elementAt(index)]?[code]?.toStringAsFixed(3) ?? '0.000')),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/single_chart_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/table_tech_gap_data_widget.dart';
import 'package:provider/provider.dart';

class ChartWidgetTechGap extends StatefulWidget {
  const ChartWidgetTechGap({super.key});

  @override
  State<ChartWidgetTechGap> createState() => _ChartWidgetTechGapState();
}

class _ChartWidgetTechGapState extends State<ChartWidgetTechGap> {
  bool _isTableVisible = false;
  bool _isMaxHeightTable = false;

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    final techCode = dataProvider.selectedTechCode;

    List<String> targetNames = [];
    if (dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail) {
      targetNames = dataProvider.selectedCompanies.isEmpty ? dataProvider.getAvailableCompaniesFromTechGap(techCode).take(10).toList() : dataProvider.selectedCompanies.toList();
    } else if (dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail) {
      targetNames = dataProvider.selectedAcademics.isEmpty ? dataProvider.getAvailableAcademicsFromTechGap(techCode).take(10).toList() : dataProvider.selectedAcademics.toList();
    }
    final tableKey = GlobalKey();
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Visibility(
            visible: !_isMaxHeightTable,
            child: Expanded(
                child: _buildChartMultiLineType(
              targetNames,
              dataProvider,
              tableKey,
            )),
          ),
          Row(
            children: [
              Flexible(
                flex: 18,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      if (_isMaxHeightTable) {
                        return;
                      }
                      _isTableVisible = !_isTableVisible;
                    });
                  },
                  child: Container(
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 왼쪽 정렬 유지
                      children: [
                        Icon(
                          _isTableVisible ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          size: 28,
                          color: Colors.blue[700],
                        ),
                        Text(
                          _isTableVisible ? '테이블 닫기' : '테이블 보기',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _isTableVisible,
                child: Flexible(
                  flex: 1,
                  child: Container(
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _isMaxHeightTable = !_isMaxHeightTable;
                        });
                      },
                      child: Center(
                        child: Icon(
                          _isMaxHeightTable ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                          size: 28,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Visibility(
                visible: _isTableVisible,
                child: Flexible(
                  flex: 2,
                  child: PopupMenuButton<String>(
                    offset: Offset(constraints.maxHeight * 0, constraints.maxHeight * 0.02),
                    position: PopupMenuPosition.under,
                    onSelected: (String value) async {
                      switch (value) {
                        case 'PNG':
                        case 'JPG':
                          CommonUtils.instance.saveImage(format: value, chartKey: tableKey);
                          break;
                        case 'CSV':
                          CommonUtils.instance.saveCsv(globalKey: tableKey, dataProvider: dataProvider);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem<String>(
                        value: 'PNG',
                        height: constraints.maxHeight * 0.05,
                        padding: EdgeInsets.zero,
                        child: const Center(child: Text('PNG')),
                      ),
                      PopupMenuItem<String>(
                        value: 'JPG',
                        height: constraints.maxHeight * 0.05,
                        padding: EdgeInsets.zero,
                        child: const Center(child: Text('JPG')),
                      ),
                      PopupMenuItem<String>(
                        value: 'CSV',
                        height: constraints.maxHeight * 0.05,
                        padding: EdgeInsets.zero,
                        child: const Center(child: Text('CSV')),
                      ),
                    ],
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.download,
                            size: 28,
                            color: Colors.blue[700],
                          ),
                          Text(
                            ' 저장',
                            style: TextStyle(
                              color: Colors.blue[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: (() {
              if (_isMaxHeightTable) {
                return constraints.maxHeight.toDouble() * 0.9;
              }

              if (_isTableVisible) {
                return 300.toDouble();
              } else {
                return 0.toDouble();
              }
            }()),
            child: SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                height: (() {
                  if (_isMaxHeightTable) {
                    return constraints.maxHeight.toDouble() * 0.9;
                  }

                  if (_isTableVisible) {
                    return 300.toDouble();
                  } else {
                    return 0.toDouble();
                  }
                }()),
                child: RepaintBoundary(
                  key: tableKey,
                  child: const TableTechGapDataWidget(),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChartMultiLineType(List<String> targetNames, AnalysisDataProvider dataProvider, GlobalKey? tableKey) {
    final techCode = dataProvider.selectedTechCode;
    var countries = dataProvider.selectedCountries.isEmpty ? dataProvider.getAvailableCountriesFromTechGap(techCode).take(10).toList() : dataProvider.selectedCountries.toList();

    final codes = dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? countries.toList() : targetNames;
    final chartKey = GlobalKey();
    return RepaintBoundary(
      key: chartKey,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                margin: EdgeInsets.only(
                  top: constraints.maxHeight * 0.05,
                  left: constraints.maxWidth * 0.2,
                  bottom: constraints.maxHeight * 0.3,
                ),
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: codes.asMap().entries.map((entry) {
                      final color = dataProvider.getColorForCode(codes[entry.key]);

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 12,
                              height: 2,
                              color: color,
                            ),
                            const SizedBox(width: 4),
                            (() {
                              String countryCode = '';
                              if (dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
                                countryCode = CommonUtils.instance.replaceCountryCode(codes[entry.key]);
                              } else {
                                countryCode = CommonUtils.instance.replaceCountryCode(dataProvider.searchCountryCode(codes[entry.key]));
                              }

                              return CountryFlag.fromCountryCode(
                                countryCode,
                                height: 16,
                                width: 16,
                              );
                            }()),
                            const SizedBox(width: 4),
                            Text(
                              CommonUtils.instance.replaceCountryCode(codes[entry.key]),
                              style: TextStyle(
                                fontSize: 12,
                                color: color,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Container(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: SingleChartWidget(
                  techListType: dataProvider.selectedTechListType,
                  techCode: techCode,
                  countries: dataProvider.selectedSubCategory == AnalysisSubCategory.countryDetail ? countries.toList() : null,
                  targetNames: dataProvider.selectedSubCategory == AnalysisSubCategory.companyDetail || dataProvider.selectedSubCategory == AnalysisSubCategory.academicDetail ? targetNames : null,
                  chartKey: chartKey,
                  tableKey: _isTableVisible ? tableKey : null,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

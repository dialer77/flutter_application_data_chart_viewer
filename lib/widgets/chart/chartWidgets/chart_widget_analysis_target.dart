import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_table_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/single_chart_widget.dart';
import 'package:provider/provider.dart';

class ChartWidgetAnalysisTarget extends StatefulWidget {
  const ChartWidgetAnalysisTarget({super.key});

  @override
  State<ChartWidgetAnalysisTarget> createState() => _ChartWidgetAnalysisTargetState();
}

class _ChartWidgetAnalysisTargetState extends State<ChartWidgetAnalysisTarget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isTableVisible = false; // 추가

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();

    List<String> codes = [];
    final category = provider.selectedCategory;
    final techCode = provider.selectedTechCode;
    final techCodes = provider.selectedTechCodes;

    if (category == AnalysisCategory.countryTech) {
      codes = provider.selectedCountries.toList();
      if (codes.isEmpty) {
        codes = provider.getAvailableCountries(techCode).take(10).toList();
      }
    } else if (category == AnalysisCategory.companyTech) {
      codes = provider.selectedCompanies.toList();
      if (codes.isEmpty) {
        codes = provider.getAvailableCompanies().take(10).toList();
      }
    } else if (category == AnalysisCategory.academicTech) {
      codes = provider.selectedAcademics.toList();
      if (codes.isEmpty) {
        codes = provider.getAvailableAcademics().take(10).toList();
      }
    } else {
      codes = techCodes.whereType<String>().toList();
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          top: constraints.maxHeight * 0.05,
        ),
        child: (() {
          switch (provider.selectedSubCategory) {
            case AnalysisSubCategory.countryTrend:
            case AnalysisSubCategory.companyTrend:
            case AnalysisSubCategory.academicTrend:
              if (codes.length == 1) {
                return _buildChartBarType(codes[0]);
              } else {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.15, // 높이를 낮추기 위해 비율을 증가시킴
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: codes.length,
                  itemBuilder: (context, index) {
                    return _buildChartBarType(codes[index]);
                  },
                );
              }
            default:
              return Column(
                children: [
                  Expanded(
                    child: _buildChartMultiLineType(codes),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
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
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _isTableVisible ? 300 : 0, // 테이블의 최대 높이를 300으로 설정
                    child: SingleChildScrollView(
                      child: SizedBox(
                        height: 300,
                        child: ChartTableWidget(
                          title: (() {
                            switch (provider.selectedCategory) {
                              case AnalysisCategory.countryTech:
                                if (provider.selectedSubCategory == AnalysisSubCategory.countryTrend) {
                                  return 'Citation Index';
                                } else {
                                  return 'Activity Index';
                                }
                              case AnalysisCategory.companyTech:
                                return 'Market Index';
                              case AnalysisCategory.academicTech:
                                return 'Citation Index';
                              default:
                                return '';
                            }
                          }()),
                          headerTitles: (() {
                            switch (provider.selectedCategory) {
                              case AnalysisCategory.countryTech:
                                return const [
                                  (TableDataType.country, '국가 순위'),
                                ];
                              case AnalysisCategory.companyTech:
                                return const [
                                  (TableDataType.country, '기업 순위'),
                                  (TableDataType.name, '기업'),
                                ];
                              case AnalysisCategory.academicTech:
                                return const [
                                  (TableDataType.country, '대학 순위'),
                                  (TableDataType.name, '대학'),
                                ];
                              default:
                                return [(TableDataType.country, '')];
                            }
                          }()),
                          tableChartDataModels: provider.getTableChartDataModels(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
          }
        })(),
      );
    });
  }

  Widget _buildChartMultiLineType(List<String> targetNameList) {
    final provider = context.watch<AnalysisDataProvider>();
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
            ),
            child: SingleChartWidget(
              category: provider.selectedCategory,
              selectedSubCategory: provider.selectedSubCategory,
              techListType: provider.selectedTechListType,
              techCode: provider.selectedTechCode,
              targetNames: targetNameList,
              chartType: ChartType.multiline,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChartBarType(String targetCode) {
    final provider = context.watch<AnalysisDataProvider>();
    final category = provider.selectedCategory;

    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: constraints.maxWidth * 0.035,
            ),
            // Title
            child: Container(
              alignment: Alignment.centerLeft,
              width: category == AnalysisCategory.countryTech ? constraints.maxWidth * 0.175 : constraints.maxWidth * 0.5,
              height: constraints.maxHeight * 0.1,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 109, 207, 245),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: category == AnalysisCategory.countryTech ? constraints.maxWidth * 0.035 : 8,
                  vertical: 4.0,
                ),
                child: Center(
                  child: Row(
                    mainAxisAlignment: category == AnalysisCategory.countryTech ? MainAxisAlignment.spaceAround : MainAxisAlignment.center,
                    children: [
                      (() {
                        if (category == AnalysisCategory.countryTech) {
                          return CountryFlag.fromCountryCode(
                            CommonUtils.instance.replaceCountryCode(targetCode),
                            height: 16,
                            width: 24,
                          );
                        } else {
                          return const SizedBox.shrink();
                        }
                      }()),
                      Text(
                        CommonUtils.instance.replaceCountryCode(targetCode),
                        style: TextStyle(
                          fontSize: constraints.maxHeight * 0.035,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: constraints.maxHeight * 0.025,
            ),
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight * 0.875,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: SingleChartWidget(
                category: category,
                selectedSubCategory: provider.selectedSubCategory,
                techListType: provider.selectedTechListType,
                techCode: provider.selectedTechCode,
                country: category == AnalysisCategory.countryTech ? targetCode : null,
                targetName: (targetCode) {
                  if (category == AnalysisCategory.companyTech || category == AnalysisCategory.academicTech) {
                    return targetCode;
                  } else {
                    return null;
                  }
                }(targetCode),
                chartColor: provider.getColorForCode(targetCode),
              ),
            ),
          ),
        ],
      );
    });
  }
}

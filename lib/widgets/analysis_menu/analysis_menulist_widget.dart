import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_menu/analysis_target_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_menu/analysis_techlist_widget.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';

class AnalysisMenuListWidget extends StatefulWidget {
  const AnalysisMenuListWidget({super.key});

  @override
  State<AnalysisMenuListWidget> createState() => _AnalysisMenuListWidgetState();
}

class _AnalysisMenuListWidgetState extends State<AnalysisMenuListWidget> {
  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    return LayoutBuilder(builder: (context, constraints) {
      final titleSize = constraints.maxHeight * 0.05;
      final buttonHeight = constraints.maxHeight * 0.065;
      final fontSize = constraints.maxHeight * 0.020;

      return Padding(
        padding: EdgeInsets.only(
          top: constraints.maxHeight * 0.05,
        ),
        child: Container(
          height: constraints.maxHeight * 0.95,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(45),
          ),
          padding: EdgeInsets.only(
            left: constraints.maxWidth * 0.125,
            right: constraints.maxWidth * 0.125,
            top: constraints.maxHeight * 0.05,
            bottom: constraints.maxHeight * 0.05,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonUtils.instance.menuTitle(
                title: '분석 데이터',
                height: titleSize,
                fontSize: fontSize,
                color: const Color.fromARGB(255, 70, 177, 225),
              ),
              _buildAnalysisDataButton(
                buttonHeight: buttonHeight,
                fontSize: fontSize,
              ),
              CommonUtils.instance.menuTitle(
                title: '기술 목록',
                height: titleSize,
                fontSize: fontSize,
                color: const Color.fromARGB(255, 70, 177, 225),
              ),
              (() {
                if (dataProvider.selectedCategory ==
                    AnalysisCategory.industryTech) {
                  return Expanded(
                    child: AnalysisTechListWidget(
                      buttonHeight: buttonHeight,
                      fontSize: fontSize,
                    ),
                  );
                } else {
                  return Expanded(
                    child: Column(
                      children: [
                        SizedBox(
                            height: (() {
                              if (dataProvider.selectedCategory ==
                                  AnalysisCategory.techAssessment) {
                                return buttonHeight * 4;
                              } else {
                                return buttonHeight * 2;
                              }
                            })(),
                            child: AnalysisTechListWidget(
                              buttonHeight: buttonHeight,
                              fontSize: fontSize,
                            )),
                        CommonUtils.instance.menuTitle(
                          title: '분석 대상',
                          height: titleSize,
                          fontSize: fontSize,
                          color: const Color.fromARGB(255, 70, 177, 225),
                        ),
                        Expanded(
                          child: AnalysisTargetWidget(
                            category: dataProvider.selectedCategory,
                            buttonHeight: buttonHeight,
                            fontSize: fontSize,
                          ),
                        ),
                      ],
                    ),
                  );
                }
              })(),
              SizedBox(height: constraints.maxHeight * 0.025),
              CommonUtils.instance.menuTitle(
                title: '분석 기간',
                height: titleSize,
                fontSize: fontSize,
                color: const Color.fromARGB(255, 70, 177, 225),
              ),
              _buildAnalysisPeriodWidget(
                buttonHeight: buttonHeight,
                fontSize: fontSize,
                provider: dataProvider,
                analysisType: () {
                  if (dataProvider.selectedCategory ==
                      AnalysisCategory.techAssessment) {
                    return AnalysisType.single;
                  } else {
                    return AnalysisType.range;
                  }
                }(),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAnalysisPeriodWidget({
    required double buttonHeight,
    required double fontSize,
    required AnalysisDataProvider provider,
    required AnalysisType analysisType,
  }) {
    return SizedBox(
      height: buttonHeight,
      child: switch (analysisType) {
        AnalysisType.single => _buildYearDropdown(provider, fontSize),
        AnalysisType.range => _buildRangeSelector(provider, fontSize),
      },
    );
  }

  Widget _buildYearDropdown(AnalysisDataProvider provider, double fontSize) {
    RangeValues currentRangeValues = provider.getYearRange();
    final List<int> years = List<int>.generate(
      (currentRangeValues.end.toInt() - currentRangeValues.start.toInt() + 1),
      (i) => currentRangeValues.start.toInt() + i,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '연도 선택: ',
          style: TextStyle(fontSize: fontSize),
        ),
        DropdownButton<int>(
          value: provider.selectedYear,
          items: years.map<DropdownMenuItem<int>>((int year) {
            return DropdownMenuItem<int>(
              value: year,
              child: Text('$year년'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              provider.setSelectedYear(newValue);
            }
          },
        ),
      ],
    );
  }

  Widget _buildRangeSelector(AnalysisDataProvider provider, double fontSize) {
    RangeValues currentRangeValue = provider.getYearRange();
    return Row(
      children: [
        Text(
          '${provider.startYear}년',
          style: TextStyle(fontSize: fontSize),
        ),
        Expanded(
          child: RangeSlider(
            values: RangeValues(
              provider.startYear.toDouble(),
              provider.endYear.toDouble(),
            ),
            min: currentRangeValue.start.toDouble(),
            max: currentRangeValue.end.toDouble(),
            divisions:
                currentRangeValue.end.toInt() - currentRangeValue.start.toInt(),
            labels: RangeLabels(
              provider.startYear.toString(),
              provider.endYear.toString(),
            ),
            onChanged: (RangeValues values) {
              provider.setYearRange(
                values.start.round(),
                values.end.round(),
              );
            },
          ),
        ),
        Text(
          '${provider.endYear}년',
          style: TextStyle(fontSize: fontSize),
        ),
      ],
    );
  }

  Widget _buildAnalysisDataButton({
    required double buttonHeight,
    required double fontSize,
  }) {
    final provider = context.watch<AnalysisDataProvider>();
    final availableOptions =
        provider.getAvailableDataTypes(provider.selectedCategory);

    return SizedBox(
      height: buttonHeight,
      child: LayoutGrid(
        columnSizes: [1.fr, 1.fr, 1.2.fr],
        rowSizes: [1.fr],
        children: [
          ...AnalysisDataType.values.map(
            (option) => Opacity(
              opacity: availableOptions.contains(option) ? 1.0 : 0.0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Transform.scale(
                      scale: buttonHeight * 0.02,
                      child: Radio<AnalysisDataType>(
                        value: option,
                        groupValue: provider.selectedDataType,
                        onChanged: (AnalysisDataType? value) {
                          if (value != null) {
                            context
                                .read<AnalysisDataProvider>()
                                .setSelectedDataType(value);
                          }
                        },
                      ),
                    ),
                    Text(
                      option.toString(),
                      style: TextStyle(
                        fontSize: fontSize,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

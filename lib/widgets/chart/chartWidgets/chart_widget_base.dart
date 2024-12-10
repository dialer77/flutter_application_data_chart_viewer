import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/single_chart_widget.dart';
import 'package:provider/provider.dart';

abstract class ChartWidgetBase extends StatefulWidget {
  const ChartWidgetBase({super.key});
  @override
  State<ChartWidgetBase> createState();
}

abstract class ChartWidgetBaseState<T extends ChartWidgetBase> extends State<T> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

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

  Widget buildChartContent(BuildContext context, BoxConstraints constraints);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          top: constraints.maxHeight * 0.05,
        ),
        child: buildChartContent(context, constraints),
      );
    });
  }

  @protected
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

  @protected
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

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/single_chart_widget.dart';
import 'package:provider/provider.dart';

class ChartWidgetIndustryTech extends StatefulWidget {
  const ChartWidgetIndustryTech({super.key});

  @override
  State<ChartWidgetIndustryTech> createState() => _ChartWidgetIndustryTechState();
}

class _ChartWidgetIndustryTechState extends State<ChartWidgetIndustryTech> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  AnalysisCategory get _category => AnalysisCategory.industryTech;

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
    List<String> techCodeList = provider.selectedTechCodes;

    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
          top: constraints.maxHeight * 0.05,
        ),
        child: (() {
          if (techCodeList.isEmpty) {
            return Center(
              child: Text(
                "${provider.selectedTechListType} 항목을 선택해주세요",
                style: TextStyle(
                  fontSize: constraints.maxHeight * 0.1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          switch (provider.selectedSubCategory) {
            case AnalysisSubCategory.techTrend:
              if (techCodeList.length == 1) {
                return _buildChartBarType(techCodeList[0]);
              } else {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.15, // 높이를 낮추기 위해 비율을 증가시킴
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                  ),
                  itemCount: techCodeList.length,
                  itemBuilder: (context, index) {
                    return _buildChartBarType(techCodeList[index]);
                  },
                );
              }
            default:
              return _buildChartMultiLineType(techCodeList);
          }
        })(),
      );
    });
  }

  Widget _buildChartMultiLineType(List<String> techCodeList) {
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
              category: _category,
              selectedSubCategory: provider.selectedSubCategory,
              techListType: provider.selectedTechListType,
              techCode: techCodeList[0],
              selectedCodes: techCodeList,
              chartType: ChartType.multiline,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildChartBarType(String techCode) {
    final provider = context.watch<AnalysisDataProvider>();
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: constraints.maxWidth * 0.035,
            ),
            child: Container(
              alignment: Alignment.centerLeft,
              width: constraints.maxWidth * 0.175,
              height: constraints.maxHeight * 0.1,
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 109, 207, 245),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    techCode,
                    style: TextStyle(
                      fontSize: constraints.maxHeight * 0.035,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                category: _category,
                selectedSubCategory: provider.selectedSubCategory,
                techListType: provider.selectedTechListType,
                techCode: techCode,
                chartColor: provider.getColorForCode(techCode),
                chartType: ChartType.barWithTrendLine,
              ),
            ),
          ),
        ],
      );
    });
  }
}

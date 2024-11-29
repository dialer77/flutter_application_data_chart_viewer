import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_widget.dart';

class ChartWidgetIndustryTech extends StatefulWidget {
  const ChartWidgetIndustryTech({super.key});

  @override
  State<ChartWidgetIndustryTech> createState() =>
      _ChartWidgetIndustryTechState();
}

class _ChartWidgetIndustryTechState extends State<ChartWidgetIndustryTech>
    with SingleTickerProviderStateMixin {
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
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: 50,
          top: constraints.maxHeight * 0.05,
        ),
        child: Column(
          children: [
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight * 0.1,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(_category.name),
            ),
            Container(
              width: constraints.maxWidth,
              height: constraints.maxHeight * 0.85,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: Column(
                children: [],
              ),
            ),
          ],
        ),
      );
    });
  }
}

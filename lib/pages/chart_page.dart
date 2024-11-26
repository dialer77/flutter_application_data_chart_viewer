import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_data_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_target_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/techlist_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_period_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';

class ChartPage extends StatefulWidget {
  final AnalysisCategory category;

  const ChartPage({super.key, required this.category});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  List<AnalysisSubCategory> _subCategories = [];
  AnalysisSubCategory? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );

    _controller.forward();
    _subCategories = context
        .read<AnalysisDataProvider>()
        .getAvailableSubCategories(widget.category);

    // 첫 번째 서브카테고리를 기본값으로 설정
    if (_subCategories.isNotEmpty) {
      _selectedSubCategory = _subCategories.first;
    }
  }

  Widget _buildSubCategoryButtons() {
    _selectedSubCategory =
        context.watch<AnalysisDataProvider>().selectedSubCategory;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey),
      ),
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: _subCategories.map((subCategory) {
          final isSelected = _selectedSubCategory == subCategory;
          return Flexible(
            child: LayoutBuilder(builder: (context, constraints) {
              return Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: constraints.maxWidth * 0.15),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.blue // 선택된 항목의 배경색
                          : const Color.fromARGB(255, 16, 72, 98), // 기본 배경색
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _selectedSubCategory = subCategory;
                        context
                            .read<AnalysisDataProvider>()
                            .setSelectedSubCategory(subCategory);
                      });
                    },
                    child: Text(
                      subCategory.toString(),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: constraints.maxWidth * 0.05,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal, // 선택된 항목의 텍스트를 굵게
                      ),
                    ),
                  ),
                ),
              );
            }),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Flexible(
          flex: 1,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 0, 0),
                child: InkWell(
                  onTap: () {
                    context.read<ContentController>().goBack();
                  },
                  child: LayoutBuilder(builder: (context, constraints) {
                    return Container(
                      color: const Color.fromARGB(255, 21, 96, 130),
                      padding: EdgeInsets.symmetric(
                          horizontal: constraints.maxWidth * 0.2, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.category.toString(),
                            style: TextStyle(
                              fontSize: constraints.maxWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 0, 30),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return ClipRect(
                        child: Align(
                          alignment: Alignment.topCenter,
                          heightFactor: _animation.value,
                          child: child,
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AnalysisDataWidget(category: widget.category),
                          const SizedBox(height: 10),
                          TechListWidget(category: widget.category),
                          if (widget.category == AnalysisCategory.countryTech ||
                              widget.category == AnalysisCategory.companyTech ||
                              widget.category ==
                                  AnalysisCategory.academicTech ||
                              widget.category ==
                                  AnalysisCategory.techCompetition ||
                              widget.category ==
                                  AnalysisCategory.techAssessment ||
                              widget.category == AnalysisCategory.techGap)
                            Column(
                              children: [
                                const SizedBox(height: 10),
                                AnalysisTargetWidget(category: widget.category),
                              ],
                            ),
                          const Spacer(),
                          AnalysisPeriodWidget(
                            analysisType: dataProvider.selectedCategory ==
                                    AnalysisCategory.techAssessment
                                ? AnalysisType.single
                                : AnalysisType.range,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Flexible(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                child: _buildSubCategoryButtons(),
              ),
              if (dataProvider.isChartVisible)
                Expanded(
                  child: Container(
                    color: Colors.grey[200],
                    margin: const EdgeInsets.all(20),
                    child: ChartWidget(
                      category: widget.category,
                      selectedSubCategory: _selectedSubCategory,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

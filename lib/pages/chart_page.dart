import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_data_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_target_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/menulist_widget.dart';
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
    _subCategories = MenuListWidget.getAnalysisSubCategories(widget.category);

    // 첫 번째 서브카테고리를 기본값으로 설정
    if (_subCategories.isNotEmpty) {
      _selectedSubCategory = _subCategories.first;
    }
  }

  Widget _buildSubCategoryButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: _subCategories.map((subCategory) {
          final isSelected = _selectedSubCategory == subCategory;
          return Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected
                    ? Colors.blue // 선택된 항목의 배경색
                    : const Color.fromARGB(255, 16, 72, 98), // 기본 배경색
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
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
                  fontSize: 16,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.normal, // 선택된 항목의 텍스트를 굵게
                ),
              ),
            ),
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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 300,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 50, 0, 0),
                  child: InkWell(
                    onTap: () {
                      context.read<ContentController>().goBack();
                    },
                    child: Container(
                      color: Colors.blue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 70, vertical: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            widget.category.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                            if (widget.category ==
                                    AnalysisCategory.countryTech ||
                                widget.category ==
                                    AnalysisCategory.companyTech ||
                                widget.category ==
                                    AnalysisCategory.academicTech)
                              Column(
                                children: [
                                  const SizedBox(height: 10),
                                  AnalysisTargetWidget(
                                      category: widget.category),
                                ],
                              ),
                            const SizedBox(height: 10),
                            const Spacer(),
                            const AnalysisPeriodWidget(),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      const Color.fromARGB(255, 16, 72, 98),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 15),
                                ),
                                onPressed: () {
                                  final dataProvider =
                                      context.read<AnalysisDataProvider>();

                                  // 현재 선택된 값들 확인
                                  if (_selectedSubCategory == null) {
                                    // 서브카테고리가 선택되지 않았을 때 처리
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('서브카테고리를 선택해주세요')),
                                    );
                                    return;
                                  }

                                  if (dataProvider.selectedLcTechCode == null) {
                                    // LC 코드가 선택되지 않았을 때 처리
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('LC 코드를 선택해주세요')),
                                    );
                                    return;
                                  }
                                  // 차트 데이터 갱신 및 표시
                                  dataProvider.showChart();
                                },
                                child: const Text(
                                  '실행',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: _buildSubCategoryButtons(),
                        ),
                      ),
                    ],
                  ),
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
      ),
    );
  }
}

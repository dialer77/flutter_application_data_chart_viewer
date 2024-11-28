import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_menu/analysis_data_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_menu/analysis_target_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_menu/analysis_techlist_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_menu/analysis_period_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';

class TriangleArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width * 0.7, size.height * 0.2);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.lineTo(size.width * 0.7, size.height * 0.8);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TriangleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(size.width, 0); // 오른쪽 상단
    path.lineTo(0, size.height / 2); // 왼쪽 중앙
    path.lineTo(size.width, size.height); // 오른쪽 하단
    path.close(); // 삼각형 완성
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class ChartPage extends StatefulWidget {
  final AnalysisCategory category;

  const ChartPage({super.key, required this.category});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
  }

  Widget _buildCategoryButton({double fontSizeRatio = 0.25}) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: constraints.maxWidth * 0.05,
          vertical: constraints.maxHeight * 0.18,
        ),
        child: InkWell(
          onTap: () {
            context.read<ContentController>().goBack();
          },
          child: SizedBox(
            height: constraints.maxHeight,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipPath(
                  clipper: TriangleClipper(),
                  child: Container(
                    width: constraints.maxWidth * 0.065,
                    height: constraints.maxHeight,
                    color: const Color.fromARGB(255, 97, 203, 244),
                  ),
                ),
                Container(
                  width: constraints.maxWidth * 0.30,
                  height: constraints.maxHeight,
                  color: const Color.fromARGB(255, 97, 203, 244),
                  child: Center(
                    child: Text(
                      '이전 화면',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: constraints.maxHeight * fontSizeRatio,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    color: const Color.fromARGB(255, 21, 96, 130),
                    padding: const EdgeInsets.all(10.0),
                    child: Center(
                      child: Text(
                        widget.category.toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: constraints.maxHeight * 0.25,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildSubCategoryButtons({double fontSizeRatio = 0.25}) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    _selectedSubCategory = dataProvider.selectedSubCategory;
    final subCategories = dataProvider.getAvailableSubCategories(widget.category);

    // 첫 번째 서브카테고리를 기본값으로 설정
    if (_selectedSubCategory == null || subCategories.contains(_selectedSubCategory) == false) {
      dataProvider.setSelectedSubCategory(subCategories.first);
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(50, 0, 0, 0),
        child: Container(
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: subCategories.map((subCategory) {
              final isSelected = _selectedSubCategory == subCategory;
              return Flexible(
                child: LayoutBuilder(builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.15),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected
                              ? const Color.fromARGB(255, 97, 203, 244) // 선택된 항목의 배경색
                              : const Color.fromARGB(255, 16, 72, 98), // 기본 배경색
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedSubCategory = subCategory;
                            context.read<AnalysisDataProvider>().setSelectedSubCategory(subCategory);
                          });
                        },
                        child: SizedBox(
                          height: constraints.maxHeight * 0.8,
                          child: Center(
                            child: Text(
                              subCategory.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: constraints.maxHeight * fontSizeRatio,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // 선택된 항목의 텍스트를 굵게
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              );
            }).toList(),
          ),
        ),
      );
    });
  }

  Widget _buildMenuLists() {
    final dataProvider = context.watch<AnalysisDataProvider>();
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.fromLTRB(
          0,
          constraints.maxHeight * 0.05,
          0,
          0,
        ),
        child: Container(
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(45),
          ),
          padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: constraints.maxHeight * 0.05),
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.15,
                child: AnalysisDataWidget(category: widget.category),
              ),
              if (widget.category == AnalysisCategory.industryTech)
                Expanded(
                  child: AnalysisTechListWidget(category: widget.category),
                ),
              if (widget.category == AnalysisCategory.countryTech ||
                  widget.category == AnalysisCategory.companyTech ||
                  widget.category == AnalysisCategory.academicTech ||
                  widget.category == AnalysisCategory.techCompetition ||
                  widget.category == AnalysisCategory.techAssessment ||
                  widget.category == AnalysisCategory.techGap)
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: constraints.maxHeight * 0.2,
                        child: AnalysisTechListWidget(category: widget.category),
                      ),
                      Expanded(
                        child: AnalysisTargetWidget(category: widget.category),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight * 0.15,
                child: AnalysisPeriodWidget(
                  analysisType: dataProvider.selectedCategory == AnalysisCategory.techAssessment ? AnalysisType.single : AnalysisType.range,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(50, 75, 50, 50),
      child: LayoutGrid(
        columnSizes: [2.fr, 7.fr],
        rowSizes: [1.fr, 8.fr],
        children: [
          _buildCategoryButton(fontSizeRatio: 0.25),
          _buildSubCategoryButtons(fontSizeRatio: 0.3),
          _buildMenuLists(),
        ],
      ),
    );

    // return Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     Flexible(
    //       flex: 1,
    //       child: Column(
    //         children: [
    //           Padding(
    //             padding: const EdgeInsets.fromLTRB(10, 50, 0, 0),
    //
    //           ),
    //           Expanded(
    //             child: Padding(
    //               padding: const EdgeInsets.fromLTRB(10, 30, 0, 30),
    //               child: AnimatedBuilder(
    //                 animation: _animation,
    //                 builder: (context, child) {
    //                   return ClipRect(
    //                     child: Align(
    //                       alignment: Alignment.topCenter,
    //                       heightFactor: _animation.value,
    //                       child: child,
    //                     ),
    //                   );
    //                 },
    //
    //               ),
    //             ),
    //           ),
    //         ],
    //       ),
    //     ),
    //     Flexible(
    //       flex: 3,
    //       child: Expanded(
    //   child: Container(
    //     color: Colors.grey[200],
    //     margin: const EdgeInsets.all(20),
    //     child: ChartWidget(
    //       category: widget.category,
    //       selectedSubCategory: _selectedSubCategory,
    //     ),
    //   ),
    // ),
    //     ),
    //   ],
    // );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/analysis_menu/analysis_menulist_widget.dart';
import 'package:flutter_application_data_chart_viewer/widgets/chart/chart_widget.dart';
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

  AnalysisSubCategory? _selectedSubCategory;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
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

  Widget _buildSubCategoryButtons({double fontSizeRatio = 0.2}) {
    final dataProvider = context.watch<AnalysisDataProvider>();
    _selectedSubCategory = dataProvider.selectedSubCategory;
    final subCategories = dataProvider.getAvailableSubCategories(widget.category);

    // 첫 번째 서브카테고리를 기본값으로 설정
    if (_selectedSubCategory == null || subCategories.contains(_selectedSubCategory) == false) {
      dataProvider.setSelectedSubCategory(subCategories.first);
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: EdgeInsets.only(
          left: constraints.maxWidth * 0.025,
        ),
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

  Widget _buildChartWidget() {
    return ChartWidget(category: widget.category, selectedSubCategory: _selectedSubCategory);
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
          left: constraints.maxWidth * 0.05,
          top: constraints.maxHeight * 0.1,
          right: constraints.maxWidth * 0.05,
          bottom: constraints.maxHeight * 0.05,
        ),
        child: LayoutGrid(
          columnSizes: [2.fr, 7.fr],
          rowSizes: [1.fr, 8.fr],
          children: [
            _buildCategoryButton(fontSizeRatio: 0.25),
            _buildSubCategoryButtons(fontSizeRatio: 0.25),
            const AnalysisMenuListWidget(),
            _buildChartWidget(),
          ],
        ),
      );
    });
  }
}

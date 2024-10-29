import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class MenuListWidget extends StatefulWidget {
  final AnalysisCategory analysisCategory;
  final List<AnalysisDataType> analysisDataTypes;
  final List<AnalysisSubCategory> analysisSubCategories;
  final Function(AnalysisCategory)? onSubCategorySelected;

  MenuListWidget({
    super.key,
    required this.analysisCategory,
    this.onSubCategorySelected,
  })  : analysisDataTypes = _getAnalysisDataTypes(analysisCategory),
        analysisSubCategories = _getAnalysisSubCategories(analysisCategory);

  static List<AnalysisDataType> _getAnalysisDataTypes(
      AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
      case AnalysisCategory.countryTech:
        return [
          AnalysisDataType.patent,
          AnalysisDataType.paper,
        ];
      case AnalysisCategory.companyTech:
        return [AnalysisDataType.patent];
      case AnalysisCategory.academicTech:
        return [AnalysisDataType.paper];
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        return [
          AnalysisDataType.patent,
          AnalysisDataType.paper,
          AnalysisDataType.patentAndPaper,
        ];
    }
  }

  static List<AnalysisSubCategory> _getAnalysisSubCategories(
      AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
        return [
          AnalysisSubCategory.techTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.marketExpansionIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.countryTech:
        return [
          AnalysisSubCategory.countryTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.marketExpansionIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.companyTech:
        return [
          AnalysisSubCategory.companyTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.marketExpansionIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.academicTech:
        return [
          AnalysisSubCategory.academicTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        return [
          AnalysisSubCategory.countryDetail,
          AnalysisSubCategory.companyDetail,
          AnalysisSubCategory.academicDetail,
        ]; // Fixed missing closing bracket and semicolon
    }
  }

  @override
  State<MenuListWidget> createState() => _MenuListWidgetState();
}

class _MenuListWidgetState extends State<MenuListWidget>
    with SingleTickerProviderStateMixin {
  bool _isAnimating = false; // 애니메이션 상태를 제어하는 플래그
  final GlobalKey _categoryKey = GlobalKey(); // 카테고리 위치를 찾기 위한 키
  double? _targetY; // 카테고리의 Y축 위치를 저장
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    final RenderBox? renderBox =
        _categoryKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _targetY = position.dy;
    }

    setState(() {
      _isAnimating = true;
    });
    _controller.forward(); // 애니메이션 시작

    Future.delayed(const Duration(milliseconds: 1000), () {
      widget.onSubCategorySelected?.call(widget.analysisCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    const int maxSubCategories = 4; // 최대 서브카테고리 개수
    final int emptySpaceCount =
        maxSubCategories - widget.analysisSubCategories.length;

    return Stack(
      children: [
        Column(
          children: [
            // 최상단 데이터타입 컨테이너
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _isAnimating ? 0.0 : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..translate(
                    0.0,
                    _isAnimating ? (_targetY ?? 0) - 100 : 0.0,
                  ),
                child: Container(
                  width: 200,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3.0),
                  ),
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      widget.analysisDataTypes.join(', '),
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            // 카테고리 컨테이너 (고정)
            Container(
              key: _categoryKey,
              width: 240,
              height: 80,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 21, 96, 130),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text(
                  widget.analysisCategory.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26.0,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...widget.analysisSubCategories.asMap().entries.map((entry) {
              final int index = entry.key;
              final subCategory = entry.value;
              return AnimatedOpacity(
                duration: Duration(milliseconds: 400 + (index * 100)),
                opacity: _isAnimating ? 0.0 : 1.0,
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400 + (index * 100)),
                  transform: Matrix4.identity()
                    ..translate(
                      0.0,
                      _isAnimating
                          ? (_targetY ?? 0) - (250 + (index * 50))
                          : 0.0,
                    ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Container(
                      width: 200,
                      height: 60,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 16, 72, 98),
                        border: Border.all(color: Colors.black, width: 3.0),
                      ),
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          subCategory.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
            // 빈 공간
            ...List.generate(
                emptySpaceCount,
                (_) => const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: SizedBox(width: 200, height: 60),
                    )),
            const SizedBox(height: 20),
            // 하단 버튼
            AnimatedOpacity(
              duration: const Duration(milliseconds: 800),
              opacity: _isAnimating ? 0.0 : 1.0,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                child: InkWell(
                  onTap: _handleTap,
                  hoverColor: Colors.grey[200],
                  splashColor: Colors.grey[300],
                  highlightColor: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    width: 200,
                    height: 60,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black,
                        width: 3.0,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    padding: const EdgeInsets.all(8.0),
                    child: const Center(
                      child: Text(
                        "실행",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

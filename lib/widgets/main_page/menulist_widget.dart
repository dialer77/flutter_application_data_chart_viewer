import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
import 'package:provider/provider.dart';

class MenuListWidget extends StatefulWidget {
  final AnalysisCategory analysisCategory;
  final Function(AnalysisCategory)? onSubCategorySelected;
  final BoxConstraints constraints;
  const MenuListWidget({
    super.key,
    required this.analysisCategory,
    required this.constraints,
    this.onSubCategorySelected,
  });

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
    final dataProvider =
        Provider.of<AnalysisDataProvider>(context, listen: false);

    final RenderBox? renderBox =
        _categoryKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      _targetY = position.dy;
    }

    setState(() {
      _isAnimating = true;
    });
    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1000), () {
      dataProvider.showChart();
      widget.onSubCategorySelected?.call(widget.analysisCategory);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataProvider = context.watch<AnalysisDataProvider>();

    const int maxSubCategories = 4; // 최대 서브카테고리 개수
    final int emptySpaceCount = maxSubCategories -
        context
            .watch<AnalysisDataProvider>()
            .getAvailableSubCategories(widget.analysisCategory)
            .length;

    return Stack(
      children: [
        Column(
          children: [
            _buildSubCategoryList(dataProvider, emptySpaceCount),
            CommonUtils.instance.blankContainer(flex: 1),
            _buildExecuteButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildSubCategoryList(
      AnalysisDataProvider dataProvider, int emptySpaceCount) {
    return Flexible(
      flex: 5,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ...dataProvider
              .getAvailableSubCategories(widget.analysisCategory)
              .asMap()
              .entries
              .map((entry) {
            final int index = entry.key;
            final subCategory = entry.value;
            return Flexible(
              child: Padding(
                padding: EdgeInsets.symmetric(
                    vertical: widget.constraints.maxWidth * 0.15),
                child: AnimatedOpacity(
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
                    child: Container(
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 97, 203, 244),
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      child: Center(
                        child: Text(
                          subCategory.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: widget.constraints.maxWidth * 0.1,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
          ...List.generate(emptySpaceCount,
              (_) => const Flexible(child: SizedBox(height: double.infinity))),
        ],
      ),
    );
  }

  Widget _buildExecuteButton() {
    return Flexible(
      flex: 1,
      child: Padding(
        padding:
            EdgeInsets.symmetric(vertical: widget.constraints.maxWidth * 0.1),
        child: AnimatedOpacity(
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
                height: double.infinity,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 8, 79, 106),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    "Execute  ",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: widget.constraints.maxWidth * 0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

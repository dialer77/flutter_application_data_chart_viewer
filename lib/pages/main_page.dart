import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_data_chart_viewer/controllers/content_controller.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/widgets/menulist_widget.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void _handleCategorySelected(
      BuildContext context, AnalysisCategory category) {
    final analysisProvider = context.read<AnalysisDataProvider>();

    // 현재 선택된 DB의 카테고리별 데이터 가져오기
    final categoryData = analysisProvider.getDataByCategory(category);

    context.read<ContentController>().changeContent(category);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: AnalysisCategory.values
            .map((analysisCategory) => Expanded(
                  child: MenuListWidget(
                    analysisCategory: analysisCategory,
                    onSubCategorySelected: (category) =>
                        _handleCategorySelected(context, category),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

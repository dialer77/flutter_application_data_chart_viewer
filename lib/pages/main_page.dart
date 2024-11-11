import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_data_chart_viewer/controllers/content_controller.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/widgets/menulist_widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void _handleCategorySelected(
      BuildContext context, AnalysisCategory category) {
    final dataProvider = context.read<AnalysisDataProvider>();
    dataProvider.setSelectedCategory(category);
    dataProvider.initializeWithCategory(category);
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

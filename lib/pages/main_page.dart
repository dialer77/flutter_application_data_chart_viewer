import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/widgets/menulist_widget.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void _handleCategorySelected(
    AnalysisCategory category,
    AnalysisSubCategory subCategory,
    AnalysisDataType dataType,
  ) {
    print('Selected: Category=${category.toString()}, '
        'SubCategory=${subCategory.toString()}, '
        'DataType=${dataType.toString()}');
    // 여기에 선택했을 때의 로직을 추가하면 됩니다
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
                    onSubCategorySelected: _handleCategorySelected,
                  ),
                ))
            .toList(),
      ),
    );
  }
}

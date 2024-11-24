import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/utils/common_utils.dart';
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
      padding: const EdgeInsets.fromLTRB(50, 80, 50, 80),
      child: Column(
        children: [
          _buildCategoryTitles(flex: 1),
          Flexible(
            flex: 8,
            child: Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 100),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: AnalysisCategory.values
                      .map(
                        (category) => Flexible(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 30.0),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Container(
                                  alignment: Alignment.center,
                                  height: double.infinity,
                                  child: MenuListWidget(
                                    analysisCategory: category,
                                    constraints: constraints,
                                    onSubCategorySelected: (category) =>
                                        _handleCategorySelected(
                                            context, category),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTitles({int flex = 1}) {
    return Flexible(
      flex: flex,
      child: Container(
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 8, 79, 106),
          borderRadius: BorderRadius.all(Radius.circular(15)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: AnalysisCategory.values
                .map((category) => Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 5.0),
                        child: LayoutBuilder(builder: (context, constraints) {
                          return Container(
                            alignment: Alignment.center,
                            height: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            child: Text(
                              category.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: constraints.maxWidth * 0.12,
                              ),
                            ),
                          );
                        }),
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

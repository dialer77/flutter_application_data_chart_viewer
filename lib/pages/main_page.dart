import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/widgets/main_page/menulist_widget.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_data_chart_viewer/controllers/content_controller.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  void _handleCategorySelected(BuildContext context, AnalysisCategory category) {
    final dataProvider = context.read<AnalysisDataProvider>();
    dataProvider.setSelectedCategory(category);
    dataProvider.initializeWithCategory(category);
    context.read<ContentController>().changeContent(category);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Container(
        padding: EdgeInsets.symmetric(horizontal: constraints.maxWidth * 0.05, vertical: constraints.maxWidth * 0.05),
        height: constraints.maxHeight,
        child: LayoutGrid(
          columnSizes: [1.fr],
          rowSizes: [3.fr, 1.fr, 8.fr],
          children: [
            _buildTitle(constraints: constraints),
            _buildCategoryTitles(),
            Container(
              decoration: const BoxDecoration(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: AnalysisCategory.values
                    .map(
                      (category) => Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Container(
                                alignment: Alignment.center,
                                height: double.infinity,
                                child: MenuListWidget(
                                  analysisCategory: category,
                                  constraints: constraints,
                                  onSubCategorySelected: (category) => _handleCategorySelected(context, category),
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
          ],
        ),
      ),
    );
  }

  Widget _buildTitle({required BoxConstraints constraints}) {
    const TextStyle englishStyle = TextStyle(
      fontFamily: 'Times New Roman',
      fontWeight: FontWeight.bold,
      letterSpacing: 1.0,
      color: Color.fromARGB(255, 0, 32, 96),
    );

    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontFamily: 'Paperlogy-5',
          fontSize: constraints.maxWidth * 0.01,
          height: 3,
          letterSpacing: constraints.maxWidth * 0.0025,
          color: Colors.black,
        ),
        children: const [
          TextSpan(text: '특허·논문 빅데이터 분석 솔루션'),
          TextSpan(
            text: '(InnoPatent Analytics v4.5)',
            style: englishStyle,
          ),
          TextSpan(text: '은 과학기술의 연구개발 산물인 특허·논문 빅데이터를 전처리'),
          TextSpan(
            text: '(Pre-Processing)',
            style: englishStyle,
          ),
          TextSpan(text: '하고, 인덱싱'),
          TextSpan(
            text: '(Indexing)',
            style: englishStyle,
          ),
          TextSpan(text: '하여, 기계학습'),
          TextSpan(
            text: '(Machine Learning)',
            style: englishStyle,
          ),
          TextSpan(text: '을 통해 최신 산업기술정보, '),
          TextSpan(
            text: 'R&D',
            style: englishStyle,
          ),
          TextSpan(text: ' 정보를 도출하여  공공 기관, 기업, 연구기관의 '),
          TextSpan(
            text: 'R&D',
            style: englishStyle,
          ),
          TextSpan(text: ' 정책 결정을 지원하는 혁신적인 데이터 분석 도구입니다.'),
        ],
      ),
    );
  }

  Widget _buildCategoryTitles() {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 8, 79, 106),
        borderRadius: BorderRadius.all(Radius.circular(15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: AnalysisCategory.values
            .map((category) => Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                    child: LayoutBuilder(builder: (context, constraints) {
                      return Container(
                        alignment: Alignment.center,
                        height: double.infinity,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: Text(
                          category.toString(),
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: constraints.maxWidth * 0.12,
                            fontFamily: 'Paperlogy-6',
                          ),
                        ),
                      );
                    }),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

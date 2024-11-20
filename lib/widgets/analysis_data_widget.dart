import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class AnalysisDataWidget extends StatefulWidget {
  final AnalysisCategory category;

  const AnalysisDataWidget({
    super.key,
    required this.category,
  });

  @override
  State<AnalysisDataWidget> createState() => _AnalysisDataWidgetState();
}

class _AnalysisDataWidgetState extends State<AnalysisDataWidget> {
  @override
  void initState() {
    super.initState();
    // build 과정이 끝난 후 초기화하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<AnalysisDataProvider>()
          .initializeWithCategory(widget.category);
    });
  }

  List<AnalysisDataType> _getAvailableOptions() {
    // 카테고리별 표시할 옵션 설정
    final provider = context.watch<AnalysisDataProvider>();
    switch (widget.category) {
      case AnalysisCategory.industryTech:
        if (provider.selectedSubCategory ==
            AnalysisSubCategory.marketExpansionIndex) {
          return [AnalysisDataType.patent];
        } else {
          return [AnalysisDataType.patent, AnalysisDataType.paper];
        }
      case AnalysisCategory.countryTech:
        if (provider.selectedSubCategory ==
            AnalysisSubCategory.marketExpansionIndex) {
          return [AnalysisDataType.patent];
        } else {
          return [AnalysisDataType.patent, AnalysisDataType.paper];
        }
      case AnalysisCategory.companyTech:
        return [AnalysisDataType.patent];
      case AnalysisCategory.academicTech:
        return [AnalysisDataType.paper];
      case AnalysisCategory.techCompetition:
        if (provider.selectedSubCategory == AnalysisSubCategory.countryDetail) {
          return [
            AnalysisDataType.patent,
            AnalysisDataType.paper,
            AnalysisDataType.patentAndPaper
          ];
        } else if (provider.selectedSubCategory ==
            AnalysisSubCategory.companyDetail) {
          return [AnalysisDataType.patent];
        } else if (provider.selectedSubCategory ==
            AnalysisSubCategory.academicDetail) {
          return [AnalysisDataType.paper];
        }
        return [];
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        return [
          AnalysisDataType.patent,
          AnalysisDataType.paper,
          AnalysisDataType.patentAndPaper
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
    final availableOptions = _getAvailableOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '분석 데이터',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        Row(
          children: [
            ...AnalysisDataType.values.map(
              (option) => Opacity(
                opacity: availableOptions.contains(option) ? 1.0 : 0.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Radio<AnalysisDataType>(
                      value: option,
                      groupValue: provider.selectedDataType,
                      onChanged: (AnalysisDataType? value) {
                        if (value != null) {
                          context
                              .read<AnalysisDataProvider>()
                              .setSelectedDataType(value);
                        }
                      },
                    ),
                    Text(option.toString()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_state_provider.dart';
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
          .read<AnalysisStateProvider>()
          .initializeWithCategory(widget.category);
    });
  }

  List<AnalysisDataType> _getAvailableOptions() {
    // 카테고리별 표시할 옵션 설정
    switch (widget.category) {
      case AnalysisCategory.industryTech:
      case AnalysisCategory.countryTech:
        return [AnalysisDataType.patent, AnalysisDataType.paper];
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
          children: availableOptions
              .expand((option) => [
                    Radio<AnalysisDataType>(
                      value: option,
                      groupValue: provider.selectedDataType,
                      onChanged: (AnalysisDataType? value) {
                        if (value != null) {
                          context
                              .read<AnalysisDataProvider>()
                              .selectDataType(value);
                        }
                      },
                    ),
                    Text(option.toString()),
                  ])
              .toList(),
        ),
      ],
    );
  }
}

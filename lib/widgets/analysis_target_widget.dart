import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_state_provider.dart';
import 'package:provider/provider.dart';

class AnalysisTargetWidget extends StatefulWidget {
  final AnalysisCategory category;

  const AnalysisTargetWidget({
    super.key,
    required this.category,
  });

  @override
  State<AnalysisTargetWidget> createState() => _AnalysisTargetWidgetState();
}

class _AnalysisTargetWidgetState extends State<AnalysisTargetWidget> {
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

  List<AnalysisCategory> _getAvailableOptions() {
    return [
      AnalysisCategory.countryTech,
      AnalysisCategory.companyTech,
      AnalysisCategory.academicTech
    ];
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
    final availableOptions = _getAvailableOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '분석 대상',
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
          children: availableOptions.map((option) {
            return Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Radio<AnalysisCategory>(
                    value: option,
                    groupValue: provider.selectedCategory,
                    onChanged: (AnalysisCategory? value) {
                      if (value != null) {
                        provider.selectCategory(value);
                      }
                    },
                  ),
                  Text(option == AnalysisCategory.countryTech
                      ? '국가'
                      : option == AnalysisCategory.companyTech
                          ? '기업'
                          : '학계'),
                ],
              ),
            );
          }).toList(),
        ),
        if (provider.selectedCategory == AnalysisCategory.countryTech)
          Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 150,
            child: ListView(
              children: provider
                  .getAvailableCountries(
                      context
                          .watch<AnalysisStateProvider>()
                          .selectedTechListType,
                      context.watch<AnalysisStateProvider>().selectedTechCode)
                  .map((country) {
                return CheckboxListTile(
                  title: Text(country),
                  value: provider.selectedCountries.contains(country),
                  onChanged: (bool? value) {
                    if (value != null) {
                      provider.toggleCountrySelection(
                        country,
                        context
                            .read<AnalysisStateProvider>()
                            .selectedTechListType,
                        context.read<AnalysisStateProvider>().selectedTechCode,
                      );
                    }
                  },
                  dense: true,
                  controlAffinity: ListTileControlAffinity.leading,
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

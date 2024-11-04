import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/repositories/analysis_data_repository.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_state_provider.dart';
import 'package:provider/provider.dart';

class TechListWidget extends StatefulWidget {
  final AnalysisCategory category;

  const TechListWidget({
    super.key,
    required this.category,
  });

  @override
  State<TechListWidget> createState() => _TechListWidgetState();
}

class _TechListWidgetState extends State<TechListWidget> {
  final AnalysisDataRepository _repository = AnalysisDataRepository();

  @override
  void initState() {
    super.initState();
    _loadDataCodes();
  }

  Future<void> _loadDataCodes() async {
    try {
      final provider = context.read<AnalysisStateProvider>();
      final data =
          await _repository.loadAnalysisData(provider.selectedDataType);
      final codes = _repository.extractDataCodes(data);
      provider.setDataCodes(codes);
    } catch (e) {
      print('Error loading data codes: $e');
    }
  }

  List<TechListType> _getAvailableOptions() {
    switch (widget.category) {
      case AnalysisCategory.countryTech:
        return [TechListType.lc, TechListType.mc];
      case AnalysisCategory.companyTech:
        return [TechListType.lc];
      case AnalysisCategory.academicTech:
        return [TechListType.mc];
      case AnalysisCategory.industryTech:
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        return [TechListType.lc, TechListType.mc, TechListType.sc];
    }
  }

  Widget _buildAdditionalControls() {
    final provider = context.watch<AnalysisStateProvider>();

    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        children: [
          const Text('LC', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 30),
          Expanded(
            child: DropdownButton<String>(
              value: provider.selectedDataCode,
              items: provider.dataCodes
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                provider.setSelectedDataCode(newValue);
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisStateProvider>();
    final availableOptions = _getAvailableOptions();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '기술 목록',
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
                    Radio<TechListType>(
                      value: option,
                      groupValue: provider.selectedTechListType,
                      onChanged: (TechListType? value) {
                        provider.setSelectedTechListType(value!);
                      },
                    ),
                    Text(option.toString()),
                  ])
              .toList(),
        ),
        _buildAdditionalControls(),
      ],
    );
  }
}

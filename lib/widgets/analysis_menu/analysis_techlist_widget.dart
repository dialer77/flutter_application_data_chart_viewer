import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class AnalysisTechListWidget extends StatefulWidget {
  final AnalysisCategory category;

  const AnalysisTechListWidget({
    super.key,
    required this.category,
  });

  @override
  State<AnalysisTechListWidget> createState() => _AnalysisTechListWidgetState();
}

class _AnalysisTechListWidgetState extends State<AnalysisTechListWidget> {
  @override
  void initState() {
    super.initState();
  }

  Widget _buildAdditionalControls() {
    final provider = context.watch<AnalysisDataProvider>();
    if (provider.selectedTechListType == AnalysisTechListType.lc) {
      // LC 컨트롤 (단일 선택)
      return _buildDropdownControl(
        'LC',
        provider.selectedLcTechCode,
        provider.getDataCodeNames(AnalysisTechListType.lc),
        (newValue) => provider.setSelectedLcDataCode(newValue),
      );
    } else if (provider.selectedTechListType == AnalysisTechListType.mc) {
      if (widget.category == AnalysisCategory.countryTech ||
          widget.category == AnalysisCategory.companyTech ||
          widget.category == AnalysisCategory.academicTech ||
          widget.category == AnalysisCategory.techCompetition ||
          widget.category == AnalysisCategory.techAssessment ||
          widget.category == AnalysisCategory.techGap) {
        return _buildDropdownControl(
          'MC',
          provider.selectedMcTechCodes.firstOrNull,
          provider.getDataCodeNames(AnalysisTechListType.mc),
          (newValue) => provider.setSelectedMcTechCodes({newValue!}),
        );
      } else {
        return _buildCheckboxList(
          'MC',
          provider.getDataCodeNames(AnalysisTechListType.mc),
          provider.selectedMcTechCodes,
          provider.toggleMcTechCode,
        );
      }
    } else if (provider.selectedTechListType == AnalysisTechListType.sc) {
      if (widget.category == AnalysisCategory.countryTech ||
          widget.category == AnalysisCategory.companyTech ||
          widget.category == AnalysisCategory.academicTech ||
          widget.category == AnalysisCategory.techCompetition ||
          widget.category == AnalysisCategory.techAssessment ||
          widget.category == AnalysisCategory.techGap) {
        return _buildDropdownControl(
          'SC',
          provider.selectedScTechCodes.firstOrNull,
          provider.getDataCodeNames(AnalysisTechListType.sc),
          (newValue) => provider.setSelectedScTechCodes({newValue!}),
        );
      } else {
        return _buildCheckboxList(
          'SC',
          provider.getDataCodeNames(AnalysisTechListType.sc),
          provider.selectedScTechCodes,
          provider.toggleScTechCode,
        );
      }
    }
    return const SizedBox();
  }

  // 드롭다운 컨트롤을 위한 헬퍼 메서드
  Widget _buildDropdownControl(String label, String? selectedValue, Set<String> items, Function(String?) onChanged) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: constraints.maxWidth * 0.3,
            padding: EdgeInsets.fromLTRB(constraints.maxWidth * 0.05, constraints.maxWidth * 0.05, 0, 0),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: constraints.maxWidth * 0.06),
            ),
          ),
          Expanded(
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedValue,
              items: items.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  // 체크박스 리스트를 위한 헬퍼 메서드
  Widget _buildCheckboxList(String label, Set<String> items, Set<String> selectedItems, Function(String) onChanged) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: constraints.maxWidth * 0.3,
            padding: EdgeInsets.fromLTRB(constraints.maxWidth * 0.05, constraints.maxWidth * 0.05, 0, 0),
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: constraints.maxWidth * 0.06),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: constraints.maxWidth * 0.05),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: ListView(
                children: items.map((code) {
                  return CheckboxListTile(
                    title: Text(code, style: TextStyle(fontSize: constraints.maxWidth * 0.05)),
                    value: selectedItems.contains(code),
                    onChanged: (bool? value) {
                      onChanged(code);
                    },
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
    final availableOptions = provider.getAvailableTechListTypes(widget.category);

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Container(
            height: constraints.maxWidth * 0.15,
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromARGB(255, 70, 177, 225)),
            ),
            child: Center(
              child: Text(
                '기술 목록',
                style: TextStyle(
                  fontSize: constraints.maxWidth * 0.06,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 70, 177, 225),
                ),
              ),
            ),
          ),
          SizedBox(
            height: constraints.maxWidth * 0.15,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...AnalysisTechListType.values.map(
                  (option) => Opacity(
                    opacity: availableOptions.contains(option) ? 1.0 : 1.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: constraints.maxWidth * 0.004,
                          child: Radio<AnalysisTechListType>(
                            value: option,
                            groupValue: provider.selectedTechListType,
                            onChanged: (AnalysisTechListType? value) {
                              if (value != null) {
                                context.read<AnalysisDataProvider>().setSelectedTechListType(value);
                              }
                            },
                          ),
                        ),
                        Text(
                          option.toString(),
                          style: TextStyle(fontSize: constraints.maxWidth * 0.06),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              alignment: Alignment.topCenter,
              height: constraints.maxHeight * 0.5,
              child: _buildAdditionalControls(),
            ),
          ),
        ],
      ),
    );
  }
}

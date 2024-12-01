import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:flutter_layout_grid/flutter_layout_grid.dart';
import 'package:provider/provider.dart';

class AnalysisTechListWidget extends StatefulWidget {
  final double buttonHeight;
  final double fontSize;
  const AnalysisTechListWidget({
    super.key,
    required this.buttonHeight,
    required this.fontSize,
  });

  @override
  State<AnalysisTechListWidget> createState() => _AnalysisTechListWidgetState();
}

class _AnalysisTechListWidgetState extends State<AnalysisTechListWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
    final availableOptions = provider.getAvailableTechListTypes(provider.selectedCategory);

    return Column(
      children: [
        SizedBox(
          height: widget.buttonHeight,
          child: LayoutGrid(
            columnSizes: [1.fr, 1.fr, 1.fr],
            rowSizes: [1.fr],
            children: [
              ...AnalysisTechListType.values.map(
                (option) => Opacity(
                  opacity: availableOptions.contains(option) ? 1.0 : 0.0,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: widget.buttonHeight * 0.02,
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
                          style: TextStyle(fontSize: widget.fontSize),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _buildAdditionalControls(),
        ),
      ],
    );
  }

  Widget _buildAdditionalControls() {
    final provider = context.watch<AnalysisDataProvider>();

    if (provider.selectedCategory == AnalysisCategory.industryTech) {
      if (provider.selectedTechListType == AnalysisTechListType.lc) {
        return _buildDropdownControl(
          provider.selectedTechListType.toString(),
          provider.selectedLcTechCode,
          provider.getDataCodeNames(provider.selectedTechListType),
          (newValue) => provider.setSelectedLcDataCode(newValue),
        );
      } else {
        return _buildCheckboxList(
          provider.selectedTechListType.toString(),
          provider.getDataCodeNames(provider.selectedTechListType),
          provider.selectedTechCodes.toSet(),
          (newValue) {
            if (provider.selectedTechListType == AnalysisTechListType.mc) {
              provider.toggleMcTechCode(newValue);
            } else {
              provider.toggleScTechCode(newValue);
            }
          },
        );
      }
    } else {
      return _buildDropdownControl(
        provider.selectedTechListType.toString(),
        provider.selectedTechCode,
        provider.getDataCodeNames(provider.selectedTechListType),
        (newValue) {
          if (provider.selectedTechListType == AnalysisTechListType.lc) {
            provider.setSelectedLcDataCode(newValue);
          } else if (provider.selectedTechListType == AnalysisTechListType.mc) {
            provider.setSelectedMcTechCodes({newValue!});
          } else {
            provider.setSelectedScTechCodes({newValue!});
          }
        },
      );
    }
  }

  // 드롭다운 컨트롤을 위한 헬퍼 메서드
  Widget _buildDropdownControl(String label, String? selectedValue, Set<String> items, Function(String?) onChanged) {
    return LayoutBuilder(
      builder: (context, constraints) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: widget.buttonHeight,
            width: constraints.maxWidth * 0.3,
            padding: EdgeInsets.only(
              left: constraints.maxWidth * 0.05,
            ),
            margin: EdgeInsets.only(
              top: constraints.maxHeight * 0.05,
            ),
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth * 0.06,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: widget.buttonHeight,
              margin: EdgeInsets.only(
                top: constraints.maxHeight * 0.05,
              ),
              alignment: Alignment.center,
              child: DropdownButton<String>(
                isExpanded: true,
                value: selectedValue,
                iconSize: constraints.maxWidth * 0.08,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: constraints.maxWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
                items: items.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        value,
                      ),
                    ),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
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
            padding: EdgeInsets.only(
              left: constraints.maxWidth * 0.05,
              top: constraints.maxHeight * 0.08,
            ),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: constraints.maxWidth * 0.06,
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(top: constraints.maxHeight * 0.05),
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
}

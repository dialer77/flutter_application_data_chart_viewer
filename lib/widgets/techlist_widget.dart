import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // 첫 프레임 렌더링 이후에 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataCodes();
    });
  }

  Future<void> _loadDataCodes() async {
    if (!mounted) return; // 위젯이 dispose된 경우 처리 중단

    final dataProvider = context.read<AnalysisDataProvider>();

    // 데이터가 아직 로드되지 않았다면 로드
    if (!dataProvider.isInitialized) {
      await dataProvider.loadAllData();
    }

    if (!mounted) return; // 비동기 작업 후 위젯이 여전히 유효한지 확인

    // LC 데이터 코드 로드
    final codes = dataProvider.getDataCodeNames(
      widget.category,
      TechListType.lc,
    );
    dataProvider.setLcDataCodes(codes.toSet());

    // MC 데이터 코드 로드
    final mcCodes = dataProvider.getDataCodeNames(
      widget.category,
      TechListType.mc,
    );
    dataProvider.setMcDataCodes(mcCodes.toSet());

    // SC 데이터 코드 로드
    final scCodes = dataProvider.getDataCodeNames(
      widget.category,
      TechListType.sc,
    );
    dataProvider.setScDataCodes(scCodes.toSet());
  }

  List<TechListType> _getAvailableOptions() {
    final provider = context.watch<AnalysisDataProvider>();
    switch (widget.category) {
      case AnalysisCategory.industryTech:
        if (provider.selectedSubCategory ==
            AnalysisSubCategory.marketExpansionIndex) {
          return [TechListType.mc, TechListType.sc];
        } else {
          return [TechListType.lc, TechListType.mc, TechListType.sc];
        }
      case AnalysisCategory.countryTech:
        return [TechListType.lc, TechListType.mc, TechListType.sc];
      case AnalysisCategory.companyTech:
        return [TechListType.lc];
      case AnalysisCategory.academicTech:
        return [TechListType.mc];
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        return [TechListType.lc, TechListType.mc, TechListType.sc];
    }
  }

  Widget _buildAdditionalControls() {
    final provider = context.watch<AnalysisDataProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LC 컨트롤 (단일 선택)
        _buildDropdownControl(
            'LC',
            provider.selectedLcDataCode,
            provider.lcDataCodes,
            (newValue) => provider.setSelectedLcDataCode(newValue)),

        // MC 컨트롤
        if (provider.selectedTechListType == TechListType.mc ||
            provider.selectedTechListType == TechListType.sc)
          widget.category == AnalysisCategory.countryTech
              ? _buildDropdownControl(
                  'MC',
                  provider.selectedMcDataCode,
                  provider.mcDataCodes,
                  (newValue) => provider.setSelectedMcDataCode(newValue))
              : _buildCheckboxList('MC', provider.mcDataCodes,
                  provider.selectedMcDataCodes, provider.toggleMcDataCode),

        // SC 컨트롤
        if (provider.selectedTechListType == TechListType.sc)
          widget.category == AnalysisCategory.countryTech
              ? _buildDropdownControl(
                  'SC',
                  provider.selectedScDataCode,
                  provider.scDataCodes,
                  (newValue) => provider.setSelectedScDataCode(newValue))
              : _buildCheckboxList('SC', provider.scDataCodes,
                  provider.selectedScDataCodes, provider.toggleScDataCode),
      ],
    );
  }

  // 드롭다운 컨트롤을 위한 헬퍼 메서드
  Widget _buildDropdownControl(String label, String? selectedValue,
      Set<String> items, Function(String?) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 80,
          padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
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
        const SizedBox(width: 10),
      ],
    );
  }

  // 체크박스 리스트를 위한 헬퍼 메서드
  Widget _buildCheckboxList(String label, Set<String> items,
      Set<String> selectedItems, Function(String) onChanged) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80, // LC/MC/SC 텍스트를 위한 고정 너비
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            height: 120,
            child: ListView(
              children: items.map((code) {
                return CheckboxListTile(
                  title: Text(code),
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
        const SizedBox(width: 10), // 오른쪽 여백
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
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
          children: [
            ...TechListType.values.map(
              (option) => Opacity(
                opacity: availableOptions.contains(option) ? 1.0 : 0.0,
                child: Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<TechListType>(
                        value: option,
                        groupValue: provider.selectedTechListType,
                        onChanged: availableOptions.contains(option)
                            ? (TechListType? value) {
                                provider.setSelectedTechListType(value!);
                              }
                            : null,
                      ),
                      Text(option.toString()),
                      const SizedBox(width: 20),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        _buildAdditionalControls(),
      ],
    );
  }
}

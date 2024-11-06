import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
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
  @override
  void initState() {
    super.initState();
    // 첫 프레임 렌더링 이후에 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataCodes();
    });
  }

  Future<void> _loadDataCodes() async {
    try {
      if (!mounted) return; // 위젯이 dispose된 경우 처리 중단

      final stateProvider = context.read<AnalysisStateProvider>();
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
      stateProvider.setDataCodes(codes.toSet());

      // MC 데이터 코드 로드
      final mcCodes = dataProvider.getDataCodeNames(
        widget.category,
        TechListType.mc,
      );
      stateProvider.setMcDataCodes(mcCodes.toSet());

      // SC 데이터 코드 로드
      final scCodes = dataProvider.getDataCodeNames(
        widget.category,
        TechListType.sc,
      );
      stateProvider.setScDataCodes(scCodes.toSet());
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // LC 컨트롤 (단일 선택)
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
              child: const Text(
                'LC',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: DropdownButton<String>(
                isExpanded: true,
                value: provider.selectedDataCode,
                items: provider.dataCodes
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  print('Selected LC Code: $newValue');
                  provider.setSelectedDataCode(newValue);
                },
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
        // MC 다중 선택 컨트롤
        if (provider.selectedTechListType == TechListType.mc ||
            provider.selectedTechListType == TechListType.sc)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80, // LC/MC/SC 텍스트를 위한 고정 너비
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: const Text(
                  'MC',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: 150,
                  child: ListView(
                    children: provider.mcDataCodes.map((code) {
                      return CheckboxListTile(
                        title: Text(code),
                        value: provider.selectedMcDataCodes.contains(code),
                        onChanged: (bool? value) {
                          provider.toggleMcDataCode(code);
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
          ),
        // SC 다중 선택 컨트롤
        if (provider.selectedTechListType == TechListType.sc)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 80, // LC/MC/SC 텍스트를 위한 고정 너비
                padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                child: const Text(
                  'SC',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: 150,
                  child: ListView(
                    children: provider.scDataCodes.map((code) {
                      return CheckboxListTile(
                        title: Text(code),
                        value: provider.selectedScDataCodes.contains(code),
                        onChanged: (bool? value) {
                          provider.toggleScDataCode(code);
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
          ),
      ],
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
                    const SizedBox(width: 30), // Radio 버튼들 사이의 간격 추가
                  ])
              .toList()
            ..removeLast(), // 마지막 SizedBox 제거
        ),
        _buildAdditionalControls(),
      ],
    );
  }
}

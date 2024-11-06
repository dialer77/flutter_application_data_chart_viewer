import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class AnalysisStateProvider extends ChangeNotifier {
  AnalysisDataType _selectedDataType = AnalysisDataType.patent;
  TechListType _selectedTechListType = TechListType.lc;
  String? _selectedDataCode;
  Set<String> _dataCodes = {};
  Set<String> _mcDataCodes = {};
  Set<String> _selectedMcDataCodes = {};
  Set<String> _scDataCodes = {};
  Set<String> _selectedScDataCodes = {};

  bool _isChartVisible = false;
  bool get isChartVisible => _isChartVisible;

  // Getters
  AnalysisDataType get selectedDataType => _selectedDataType;
  TechListType get selectedTechListType => _selectedTechListType;
  String? get selectedDataCode => _selectedDataCode;
  Set<String> get dataCodes => _dataCodes;
  Set<String> get mcDataCodes => _mcDataCodes;
  Set<String> get selectedMcDataCodes => _selectedMcDataCodes;
  Set<String> get scDataCodes => _scDataCodes;
  Set<String> get selectedScDataCodes => _selectedScDataCodes;

  // Setters with notification
  void setSelectedDataType(AnalysisDataType type) {
    _selectedDataType = type;
    notifyListeners();
  }

  void setSelectedTechListType(TechListType type) {
    _selectedTechListType = type;
    notifyListeners();
  }

  void setSelectedDataCode(String? code) {
    print('Setting selected LC code to: $code');
    _selectedDataCode = code;
    notifyListeners();
  }

  void setDataCodes(Set<String> codes) {
    _dataCodes = codes;
    if (codes.isNotEmpty &&
        (_selectedDataCode == null || !codes.contains(_selectedDataCode))) {
      _selectedDataCode = codes.first;
    }
    notifyListeners();
  }

  void setMcDataCodes(Set<String> codes) {
    _mcDataCodes = codes;
    _selectedMcDataCodes = {};
    notifyListeners();
  }

  void toggleMcDataCode(String code) {
    if (_selectedMcDataCodes.contains(code)) {
      _selectedMcDataCodes.remove(code);
    } else {
      _selectedMcDataCodes.add(code);
    }
    notifyListeners();
  }

  void setScDataCodes(Set<String> codes) {
    _scDataCodes = codes;
    _selectedScDataCodes = {};
    notifyListeners();
  }

  void toggleScDataCode(String code) {
    if (_selectedScDataCodes.contains(code)) {
      _selectedScDataCodes.remove(code);
    } else {
      _selectedScDataCodes.add(code);
    }
    notifyListeners();
  }

  // Initialize with category
  void initializeWithCategory(AnalysisCategory category) {
    // Set default data type
    switch (category) {
      case AnalysisCategory.techGap:
        _selectedDataType = AnalysisDataType.patent;
        _selectedTechListType = TechListType.lc;
      case AnalysisCategory.academicTech:
        _selectedDataType = AnalysisDataType.paper;
        _selectedTechListType = TechListType.mc;
      default:
        _selectedDataType = AnalysisDataType.patent;
        _selectedTechListType = TechListType.lc;
    }
    notifyListeners();
  }

  void showChart() {
    _isChartVisible = true;
    notifyListeners();
  }

  void hideChart() {
    _isChartVisible = false;
    notifyListeners();
  }

  // 차트 데이터 갱신 요청을 위한 플래그
  bool _shouldRefreshChart = false;
  bool get shouldRefreshChart => _shouldRefreshChart;

  void refreshChart() {
    _shouldRefreshChart = true;
    notifyListeners();
    // 플래그 리셋
    _shouldRefreshChart = false;
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class AnalysisStateProvider extends ChangeNotifier {
  // State declarations
  TechListType _selectedTechListType = TechListType.lc;
  String? _selectedLcDataCode;
  String? _selectedMcDataCode;
  String? _selectedScDataCode;
  Set<String> _lcDataCodes = {};
  Set<String> _mcDataCodes = {};
  Set<String> _scDataCodes = {};
  Set<String> _selectedMcDataCodes = {};
  Set<String> _selectedScDataCodes = {};
  bool _isChartVisible = false;
  bool _shouldRefreshChart = false;

  // Year related state
  final int _currentYear = DateTime.now().year;
  int _startYear;
  int _endYear;

  // Constructor
  AnalysisStateProvider()
      : _startYear = DateTime.now().year - 10,
        _endYear = DateTime.now().year;

  // Getters
  TechListType get selectedTechListType => _selectedTechListType;
  String? get selectedLcDataCode => _selectedLcDataCode;
  String? get selectedMcDataCode => _selectedMcDataCode;
  String? get selectedScDataCode => _selectedScDataCode;
  Set<String> get lcDataCodes => _lcDataCodes;
  Set<String> get mcDataCodes => _mcDataCodes;
  Set<String> get scDataCodes => _scDataCodes;
  Set<String> get selectedMcDataCodes => _selectedMcDataCodes;
  Set<String> get selectedScDataCodes => _selectedScDataCodes;
  bool get isChartVisible => _isChartVisible;
  bool get shouldRefreshChart => _shouldRefreshChart;
  int get startYear => _startYear;
  int get endYear => _endYear;
  int get currentYear => _currentYear;

  String? get selectedTechCode {
    if (_selectedTechListType == TechListType.lc) {
      return _selectedLcDataCode;
    } else if (_selectedTechListType == TechListType.mc) {
      return _selectedMcDataCode;
    } else {
      return _selectedScDataCode;
    }
  }

  // Setters and state update methods
  void setSelectedTechListType(TechListType type) {
    _selectedTechListType = type;
    notifyListeners();
  }

  void setSelectedDataCode(String? code) {
    _selectedLcDataCode = code;
    notifyListeners();
  }

  void setSelectedMcDataCode(String? code) {
    _selectedMcDataCode = code;
    notifyListeners();
  }

  void setSelectedScDataCode(String? code) {
    _selectedScDataCode = code;
    notifyListeners();
  }

  void setLcDataCodes(Set<String> codes) {
    _lcDataCodes = codes;
    if (codes.isNotEmpty &&
        (_selectedLcDataCode == null || !codes.contains(_selectedLcDataCode))) {
      _selectedLcDataCode = codes.first;
    }
    notifyListeners();
  }

  void setMcDataCodes(Set<String> codes) {
    _mcDataCodes = codes;
    _selectedMcDataCodes = {};
    notifyListeners();
  }

  void setScDataCodes(Set<String> codes) {
    _scDataCodes = codes;
    _selectedScDataCodes = {};
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

  void toggleScDataCode(String code) {
    if (_selectedScDataCodes.contains(code)) {
      _selectedScDataCodes.remove(code);
    } else {
      _selectedScDataCodes.add(code);
    }
    notifyListeners();
  }

  void setYearRange(int start, int end) {
    if (start > end) return;
    if (start < _currentYear - 20) return;
    if (end > _currentYear) return;
    if (start == _startYear && end == _endYear) return;

    _startYear = start;
    _endYear = end;
    refreshChart();
    notifyListeners();
  }

  // Chart visibility methods
  void showChart() {
    _isChartVisible = true;
    notifyListeners();
  }

  void hideChart() {
    _isChartVisible = false;
    notifyListeners();
  }

  void refreshChart() {
    _shouldRefreshChart = true;
    notifyListeners();
    _shouldRefreshChart = false;
  }

  // Category initialization
  void initializeWithCategory(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.techGap:
        _selectedTechListType = TechListType.lc;
      case AnalysisCategory.academicTech:
        _selectedTechListType = TechListType.mc;
      default:
        _selectedTechListType = TechListType.lc;
    }

    _startYear = _currentYear - 10;
    _endYear = _currentYear;

    notifyListeners();
  }
}

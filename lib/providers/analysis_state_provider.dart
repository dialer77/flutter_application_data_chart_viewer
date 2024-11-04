import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class AnalysisStateProvider with ChangeNotifier {
  AnalysisDataType _selectedDataType = AnalysisDataType.patent;
  TechListType _selectedTechListType = TechListType.lc;
  String? _selectedDataCode;
  Set<String> _dataCodes = {};

  // Getters
  AnalysisDataType get selectedDataType => _selectedDataType;
  TechListType get selectedTechListType => _selectedTechListType;
  String? get selectedDataCode => _selectedDataCode;
  Set<String> get dataCodes => _dataCodes;

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
    _selectedDataCode = code;
    notifyListeners();
  }

  void setDataCodes(Set<String> codes) {
    _dataCodes = codes;
    if (codes.isNotEmpty && _selectedDataCode == null) {
      _selectedDataCode = codes.first;
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
}

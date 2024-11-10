import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class AnalysisStateProvider extends ChangeNotifier {
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
  TechListType get selectedTechListType => _selectedTechListType;
  String? get selectedDataCode => _selectedDataCode;
  Set<String> get dataCodes => _dataCodes;
  Set<String> get mcDataCodes => _mcDataCodes;
  Set<String> get selectedMcDataCodes => _selectedMcDataCodes;
  Set<String> get scDataCodes => _scDataCodes;
  Set<String> get selectedScDataCodes => _selectedScDataCodes;

  // 연도 범위 상태 추가
  final int _currentYear = DateTime.now().year;
  int _startYear;
  int _endYear;

  // 생성자에서 초기값 설정
  AnalysisStateProvider()
      : _startYear = DateTime.now().year - 10,
        _endYear = DateTime.now().year;

  // Getters for year range
  int get startYear => _startYear;
  int get endYear => _endYear;
  int get currentYear => _currentYear;

  // Setter for year range
  void setYearRange(int start, int end) {
    // 유효성 검사
    if (start > end) return;
    if (start < _currentYear - 20) return; // 최대 20년 전까지만 허용
    if (end > _currentYear) return; // 현재 년도까지만 허용

    if (start == _startYear && end == _endYear) return; // 변경사항 없으면 리턴

    _startYear = start;
    _endYear = end;
    refreshChart(); // 차트 갱신 요청
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

  // Initialize with category 메서드 수정
  void initializeWithCategory(AnalysisCategory category) {
    // 기존 초기화 코드
    switch (category) {
      case AnalysisCategory.techGap:
        _selectedTechListType = TechListType.lc;
      case AnalysisCategory.academicTech:
        _selectedTechListType = TechListType.mc;
      default:
        _selectedTechListType = TechListType.lc;
    }

    // 연도 범위 초기화 추가
    _startYear = _currentYear - 10; // 기본값: 10년 전
    _endYear = _currentYear; // 기본값: 현재 년도

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

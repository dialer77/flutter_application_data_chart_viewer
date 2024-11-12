import 'dart:math';
import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/analysis_data_model.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/repositories/analysis_data_repository.dart';

class AnalysisDataProvider extends ChangeNotifier {
// State declarations
  AnalysisCategory _selectedCategory = AnalysisCategory.industryTech;
  AnalysisSubCategory _selectedSubCategory = AnalysisSubCategory.techTrend;

  TechListType _selectedTechListType = TechListType.lc;
  String? _selectedLcTechCode;
  final Set<String> _selectedMcTechCodes = {};
  final Set<String> _selectedScTechCodes = {};

  bool _isChartVisible = false;
  bool _shouldRefreshChart = false;

  // Year related state
  late int _startYear;
  late int _endYear;

  // Getters
  AnalysisCategory get selectedCategory => _selectedCategory;
  AnalysisSubCategory get selectedSubCategory => _selectedSubCategory;

  TechListType get selectedTechListType => _selectedTechListType;
  String? get selectedLcTechCode => _selectedLcTechCode;
  Set<String> get selectedMcTechCodes => _selectedMcTechCodes;
  Set<String> get selectedScTechCodes => _selectedScTechCodes;
  bool get isChartVisible => _isChartVisible;
  bool get shouldRefreshChart => _shouldRefreshChart;
  int get startYear => _startYear;
  int get endYear => _endYear;

  String? get selectedTechCode {
    if (_selectedTechListType == TechListType.lc) {
      return _selectedLcTechCode;
    } else if (_selectedTechListType == TechListType.mc) {
      return _selectedMcTechCodes.first;
    } else {
      return _selectedScTechCodes.first;
    }
  }

  List<String> get selectedTechCodes {
    switch (_selectedTechListType) {
      case TechListType.lc:
        return [selectedLcTechCode ?? ''];
      case TechListType.mc:
        return [...selectedMcTechCodes]..sort();
      case TechListType.sc:
        return [...selectedScTechCodes]..sort();
    }
  }

  // Setters and state update methods
  void setSelectedCategory(AnalysisCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedSubCategory(AnalysisSubCategory subCategory) {
    if (subCategory == AnalysisSubCategory.marketExpansionIndex &&
        _selectedCategory == AnalysisCategory.industryTech) {
      _selectedDataType = AnalysisDataType.patent;
      if (_selectedTechListType == TechListType.lc) {
        _selectedTechListType = TechListType.mc;
      }
    }

    _selectedSubCategory = subCategory;
    notifyListeners();
  }

  void setSelectedTechListType(TechListType type) {
    _selectedTechListType = type;
    notifyListeners();
  }

  void setSelectedLcDataCode(String? code) {
    _selectedLcTechCode = code;
    notifyListeners();
  }

  void setSelectedMcTechCodes(Set<String> codes) {
    _selectedMcTechCodes.clear();
    _selectedMcTechCodes.addAll(codes);
    notifyListeners();
  }

  void toggleMcTechCode(String code) {
    if (_selectedMcTechCodes.contains(code)) {
      _selectedMcTechCodes.remove(code);
    } else {
      _selectedMcTechCodes.add(code);
    }
    notifyListeners();
  }

  void setSelectedScTechCodes(Set<String> codes) {
    _selectedScTechCodes.clear();
    _selectedScTechCodes.addAll(codes);
    notifyListeners();
  }

  void toggleScTechCode(String code) {
    if (_selectedScTechCodes.contains(code)) {
      _selectedScTechCodes.remove(code);
    } else {
      _selectedScTechCodes.add(code);
    }
    notifyListeners();
  }

  void setYearRange(int start, int end) {
    if (start > end) return;
    if (start == _startYear && end == _endYear) return;

    _startYear = start;
    _endYear = end;
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
      case AnalysisCategory.industryTech:
        _selectedSubCategory = AnalysisSubCategory.techTrend;
        _selectedTechListType = TechListType.lc;
        _selectedLcTechCode = getDataCodeNames(_selectedTechListType).first;
        break;
      case AnalysisCategory.countryTech:
        _selectedSubCategory = AnalysisSubCategory.countryTrend;
        _selectedTechListType = TechListType.lc;
        _selectedLcTechCode = getDataCodeNames(_selectedTechListType).first;
        break;
      case AnalysisCategory.companyTech:
        _selectedDataType = AnalysisDataType.patent;
        _selectedSubCategory = AnalysisSubCategory.companyTrend;
        _selectedTechListType = TechListType.lc;
        _selectedLcTechCode = getDataCodeNames(_selectedTechListType).first;
        break;
      case AnalysisCategory.academicTech:
        _selectedSubCategory = AnalysisSubCategory.academicTrend;
        _selectedTechListType = TechListType.lc;
        _selectedLcTechCode = getDataCodeNames(_selectedTechListType).first;
        break;
      case AnalysisCategory.techGap:
        _selectedTechListType = TechListType.lc;
      default:
        _selectedTechListType = TechListType.lc;
    }

    RangeValues yearRange = getYearRange();
    _startYear = yearRange.start.toInt();
    _endYear = yearRange.end.toInt();

    notifyListeners();
  }

  // === Repository ===
  final AnalysisDataRepository _repository;
  AnalysisDataProvider(this._repository) {
    _startYear = 0;
    _endYear = 0;
  }

  // === State Variables ===
  // Data Type
  AnalysisDataType _selectedDataType = AnalysisDataType.patent;
  final Map<AnalysisDataType, List<AnalysisDataModel>> _dataMap = {
    AnalysisDataType.paper: [],
    AnalysisDataType.patent: [],
    AnalysisDataType.patentAndPaper: [],
  };

  // Countries
  final Set<String> _selectedCountries = {};
  bool _isInitialCountrySelection = true; // 초기 선택 상태 체크용

  // Loading State
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // === Getters ===
  // Data Type
  AnalysisDataType get selectedDataType => _selectedDataType;
  List<AnalysisDataModel> get currentData => _dataMap[_selectedDataType] ?? [];

  // Countries
  Set<String> availableCountries(AnalysisCategory category) {
    if (category != AnalysisCategory.countryTech) return {};

    final Map<String, double> countryScores = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName ==
          getCategorySheetName(AnalysisCategory.countryTech)) {
        data.analysisDatas.forEach((country, yearData) {
          // 가장 최근 연도의 데이터 값을 기준으로 정렬
          final latestYear = yearData.keys.reduce((a, b) => a > b ? a : b);
          countryScores[country] = yearData[latestYear] ?? 0.0;
        });
      }
    }

    // 점수 기준으로 정렬된 국가 목록 반환
    return countryScores.keys.toSet();
  }

  Set<String> get selectedCountries => _selectedCountries;

  // Loading State
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // === State Update Methods ===
  // Data Type
  void selectDataType(AnalysisDataType dataType) {
    _selectedDataType = dataType;
    notifyListeners();
  }

  // Countries
  void toggleCountrySelection(
      String country, TechListType techListType, String? techCode) {
    // 아무것도 선택되지 않은 상태라면 초기 선택 실행
    if (_selectedCountries.isEmpty) {
      _initializeTopCountries(techListType, techCode);
    } else {
      // 이미 선택된 국가들이 있다면 토글
      if (_selectedCountries.contains(country)) {
        _selectedCountries.remove(country);
      } else {
        _selectedCountries.add(country);
      }
      notifyListeners();
    }
  }

  void _initializeTopCountries(TechListType techListType, String? techCode) {
    final countries = getAvailableCountries(techListType, techCode);
    _selectedCountries.clear();

    // 앞에서 10개 국가 선택
    final countriesToSelect = countries.take(10).toList();
    _selectedCountries.addAll(countriesToSelect);

    notifyListeners();
  }

  // 차트 데이터 가져오기
  Map<int, double> getChartData({
    String? techCode,
    String? country,
  }) {
    // currentData 에서 국가 데이터만 반환
    var filterData = currentData
        .where((data) =>
            data.codeInfo.sheetName == getCategorySheetName(_selectedCategory))
        .toList();

    // filterData 에서 techListType 과 techCode 에 해당하는 데이터만 반환
    filterData = filterData
        .where((data) =>
            data.codeInfo.techType == selectedTechListType &&
            data.codeInfo.codeName == techCode)
        .toList();

    if (country != null) {
      filterData =
          filterData.where((data) => data.codeInfo.country == country).toList();
    }

    var dataCode = getDataCode();
    if (dataCode == null) return {};

    // filterData 의 내용중 analysisDatas 의 key값이 dataCode 인 데이터만 반환
    filterData = filterData
        .where((data) => data.analysisDatas.containsKey(dataCode))
        .toList();

    return filterData.first.analysisDatas[dataCode] ?? {};
  }

  // === Data Loading Methods ===
  Future<void> loadAllData() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      for (var dataType in AnalysisDataType.values) {
        final rawData = await _repository.loadAnalysisData(dataType);
        _dataMap[dataType] = rawData.entries
            .expand((entry) => entry.value
                .map((item) => AnalysisDataModel.fromMap(entry.key, item)))
            .toList();
      }

      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Utility Methods ===
  // Category Sheet Name
  String getCategorySheetName(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
        return '기술트렌드';
      case AnalysisCategory.countryTech:
        return '국가트렌드';
      case AnalysisCategory.companyTech:
        return '기업트렌드';
      case AnalysisCategory.academicTech:
        return '기관트렌드';
      case AnalysisCategory.techGap:
        return 'TechGap';
      case AnalysisCategory.techCompetition:
        return 'TechCompetition';
      case AnalysisCategory.techAssessment:
        return 'TechAssessment';
    }
  }

  // Data Code Names
  Set<String> getDataCodeNames(TechListType techListType) {
    final sheetName = getCategorySheetName(_selectedCategory);

    var filteredData = currentData
        .where((data) => data.codeInfo.sheetName == sheetName)
        .toList();

    filteredData = filteredData
        .where((data) => data.codeInfo.techType == techListType)
        .toList();

    return SplayTreeSet<String>.from(
        filteredData.map((data) => data.codeInfo.codeName));
  }

  // Year Range
  RangeValues getYearRange() {
    int minYear = 9999;
    int maxYear = 0;
    //currentData 에서 selectedCategory 에 해당하는 데이터만 찾고
    var filteredData = currentData
        .where((data) =>
            data.codeInfo.sheetName == getCategorySheetName(selectedCategory))
        .toList();

    //filteredData 에서 techListType 과 techCode 에 해당하는 데이터만 찾고
    filteredData = filteredData
        .where((data) =>
            data.codeInfo.techType == selectedTechListType &&
            data.codeInfo.codeName == selectedTechCode)
        .toList();

    var dataCode = getDataCode();
    // dataCode와 key가 일치하는 데이터에서 연도 정보를 찾아 최소/최대 연도를 구한다
    filteredData = filteredData
        .where((data) => data.analysisDatas.keys.contains(dataCode))
        .toList();

    for (var data in filteredData) {
      for (var yearData in data.analysisDatas.values) {
        for (var year in yearData.keys) {
          minYear = year < minYear ? year : minYear;
          maxYear = year > maxYear ? year : maxYear;
        }
      }
    }

    return RangeValues(minYear.toDouble(), maxYear.toDouble());
  }

  // Data Code
  String? getDataCode() {
    if (selectedCategory == AnalysisCategory.industryTech) {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.techTrend:
          if (selectedDataType == AnalysisDataType.patent) {
            return 'PAN';
          } else if (selectedDataType == AnalysisDataType.paper) {
            return 'TPN';
          }
        case AnalysisSubCategory.techInnovationIndex:
          if (selectedDataType == AnalysisDataType.patent) {
            if (selectedTechListType == TechListType.lc) {
              return 'PCN';
            } else {
              return 'PCI';
            }
          } else if (selectedDataType == AnalysisDataType.paper) {
            if (selectedTechListType == TechListType.lc) {
              return 'TCN';
            } else {
              return 'TCI';
            }
          }
        case AnalysisSubCategory.marketExpansionIndex:
          return 'PFI';
        case AnalysisSubCategory.rdInvestmentIndex:
          if (selectedDataType == AnalysisDataType.patent) {
            return 'PAI';
          } else if (selectedDataType == AnalysisDataType.paper) {
            return 'TPI';
          }
        default:
          return null;
      }
    } else if (selectedCategory == AnalysisCategory.countryTech) {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.countryTrend:
          if (selectedDataType == AnalysisDataType.patent) {
            return 'PAN';
          } else if (selectedDataType == AnalysisDataType.paper) {
            return 'TPN';
          }
        case AnalysisSubCategory.techInnovationIndex:
          if (selectedDataType == AnalysisDataType.patent) {
            return 'PCI';
          } else if (selectedDataType == AnalysisDataType.paper) {
            return 'TCI';
          }
        case AnalysisSubCategory.marketExpansionIndex:
          return 'PFI';
        case AnalysisSubCategory.rdInvestmentIndex:
          if (selectedDataType == AnalysisDataType.patent) {
            return 'PAI';
          } else if (selectedDataType == AnalysisDataType.paper) {
            return 'TPI';
          }
        default:
          return null;
      }
    } else if (selectedCategory == AnalysisCategory.companyTech) {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.companyTrend:
          return 'PAN';
        case AnalysisSubCategory.techInnovationIndex:
          return 'PCI';
        case AnalysisSubCategory.marketExpansionIndex:
          return 'PFI';
        case AnalysisSubCategory.rdInvestmentIndex:
          return 'PAI';
        default:
          return null;
      }
    } else if (selectedCategory == AnalysisCategory.academicTech) {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.academicTrend:
          return 'TPN';
        case AnalysisSubCategory.techInnovationIndex:
          return 'TCI';
        case AnalysisSubCategory.rdInvestmentIndex:
          return 'TPI';
        default:
          return null;
      }
    } else if (selectedCategory == AnalysisCategory.techCompetition) {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.techTrend:
          return 'CPN';
        default:
          return null;
      }
    } else if (selectedCategory == AnalysisCategory.techAssessment) {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.techTrend:
          return 'CPN';
        default:
          return null;
      }
    } else if (selectedCategory == AnalysisCategory.techGap) {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.techTrend:
          return 'CPN';
        default:
          return null;
      }
    }

    return null;
  }

  // === Private Methods ===
  void initializeCountrySelection() {
    if (!_isInitialCountrySelection) return;

    final Map<String, double> countryScores = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName ==
          getCategorySheetName(AnalysisCategory.countryTech)) {
        var filteredData = data.analysisDatas;
        filteredData.forEach((country, yearData) {
          final latestYear = yearData.keys.reduce((a, b) => a > b ? a : b);
          countryScores[country] = yearData[latestYear] ?? 0.0;
        });
      }
    }

    final sortedCountries = countryScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    _selectedCountries.clear();
    for (var i = 0; i < min(10, sortedCountries.length); i++) {
      _selectedCountries.add(sortedCountries[i].key);
    }

    _isInitialCountrySelection = false;
    notifyListeners();
  }

  // === Methods ===
  Set<String> getAvailableCountries(
      TechListType techListType, String? techCode) {
    if (techCode == null || techCode.isEmpty) return {};

    // currentData 에서 카테고리가  countryTech이고, techListType과 techCode가 일치하는 데이터를 찾는다
    final Set<String> countries = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName ==
              getCategorySheetName(AnalysisCategory.countryTech) &&
          data.codeInfo.techType == techListType &&
          data.codeInfo.codeName == techCode) {
        countries.add(data.codeInfo.country); // CodeInfo에서 국가 정보 가져오기
      }
    }
    return countries;
  }

  // 코드별 색상 매핑을 저장할 맵
  final Map<String, Color> _codeColorMap = {};

  // 사용할 색상 리스트
  final List<Color> _defaultColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.brown,
    Colors.indigo,
    Colors.grey,
  ];

  // 코드에 대한 색상을 가져오거나 할당
  Color getColorForCode(String code) {
    if (!_codeColorMap.containsKey(code)) {
      // 새로운 코드라면 다음 사용 가능한 색상 할당
      final colorIndex = _codeColorMap.length % _defaultColors.length;
      _codeColorMap[code] = _defaultColors[colorIndex];
    }
    return _codeColorMap[code]!;
  }
}

import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/analysis_data_model.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/repositories/analysis_data_repository.dart';

class AnalysisDataProvider extends ChangeNotifier {
  // === Data Loading Methods ===
  Future<void> loadAllData() async {
    if (_isInitialized) return;

    try {
      _isLoading = true;
      notifyListeners();

      for (var dataType in AnalysisDataType.values) {
        final rawData = await _repository.loadAnalysisData(dataType);
        _dataMap[dataType] = rawData.entries.expand((entry) => entry.value.map((item) => AnalysisDataModel.fromMap(entry.key, item))).toList();
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

  final Map<AnalysisDataType, List<AnalysisDataModel>> _dataMap = {
    AnalysisDataType.paper: [],
    AnalysisDataType.patent: [],
    AnalysisDataType.patentAndPaper: [],
  };
  List<AnalysisDataModel> get currentData => _dataMap[_selectedDataType] ?? [];

  final AnalysisDataRepository _repository;
  AnalysisDataProvider(this._repository) {
    _startYear = 0;
    _endYear = 0;
  }

  //정의
  AnalysisDataType _selectedDataType = AnalysisDataType.patent;
  AnalysisCategory _selectedCategory = AnalysisCategory.industryTech;
  AnalysisSubCategory _selectedSubCategory = AnalysisSubCategory.techTrend;
  AnalysisTechListType _selectedAnalysisTechListType = AnalysisTechListType.lc;

  //getter
  AnalysisDataType get selectedDataType => _selectedDataType;
  AnalysisCategory get selectedCategory => _selectedCategory;
  AnalysisSubCategory get selectedSubCategory => _selectedSubCategory;
  AnalysisTechListType get selectedTechListType => _selectedAnalysisTechListType;
  String? get selectedLcTechCode => _selectedLcTechCode;
  Set<String> get selectedMcTechCodes => _selectedMcTechCodes;
  Set<String> get selectedScTechCodes => _selectedScTechCodes;
  int get startYear => _startYear;
  int get endYear => _endYear;
  int get selectedYear => _selectedYear;

  String? get selectedTechCode {
    if (_selectedAnalysisTechListType == AnalysisTechListType.lc) {
      return _selectedLcTechCode ?? '';
    } else if (_selectedAnalysisTechListType == AnalysisTechListType.mc) {
      return _selectedMcTechCodes.isNotEmpty ? _selectedMcTechCodes.first : getDataCodeNames(_selectedAnalysisTechListType).first;
    } else {
      return _selectedScTechCodes.isNotEmpty ? _selectedScTechCodes.first : getDataCodeNames(_selectedAnalysisTechListType).first;
    }
  }

  List<String> get selectedTechCodes {
    switch (_selectedAnalysisTechListType) {
      case AnalysisTechListType.lc:
        return [selectedLcTechCode ?? ''];
      case AnalysisTechListType.mc:
        return [...selectedMcTechCodes]..sort();
      case AnalysisTechListType.sc:
        return [...selectedScTechCodes]..sort();
    }
  }

  Set<String> get selectedToggleTechCodes {
    if (_selectedAnalysisTechListType == AnalysisTechListType.mc) {
      return selectedMcTechCodes;
    } else {
      return selectedScTechCodes;
    }
  }

  String? get selectedCountry => _selectedCountry;

  String? get selectedCompany => _selectedCompany;

  String? get selectedAcademic => _selectedAcademic;

  Set<String> get selectedCountries {
    // _selectedCountries를 List로 변환 후 정렬
    final sortedCountries = _selectedCountries.toList()
      ..sort((a, b) {
        // getAvailableCountries와 동일한 기준으로 정렬
        final aValue = getCountryValue(a);
        final bValue = getCountryValue(b);
        return bValue.compareTo(aValue); // 내림차순 정렬
      });
    return sortedCountries.toSet();
  }

  Set<String> get selectedCompanies {
    final sortedCompanies = _selectedCompanies.toList()
      ..sort((a, b) {
        final aValue = getTargetNameValue(a);
        final bValue = getTargetNameValue(b);
        return bValue.compareTo(aValue); // 내림차순 정렬
      });
    return sortedCompanies.toSet();
  }

  Set<String> get selectedAcademics {
    final sortedAcademics = _selectedAcademics.toList()
      ..sort((a, b) {
        final aValue = getTargetNameValue(a);
        final bValue = getTargetNameValue(b);
        return bValue.compareTo(aValue); // 내림차순 정렬
      });
    return sortedAcademics.toSet();
  }

  //setter
  void setSelectedDataType(AnalysisDataType dataType) {
    _selectedDataType = dataType;
    notifyListeners();
  }

  void setSelectedCategory(AnalysisCategory category) {
    if (category == AnalysisCategory.countryTech) {
      if (_selectedSubCategory == AnalysisSubCategory.companyTrend || _selectedSubCategory == AnalysisSubCategory.academicTrend) {
        _selectedSubCategory = AnalysisSubCategory.countryTrend;
      }
    } else if (category == AnalysisCategory.companyTech) {
      _selectedDataType = AnalysisDataType.patent;
      if (_selectedSubCategory == AnalysisSubCategory.countryTrend || _selectedSubCategory == AnalysisSubCategory.academicTrend) {
        _selectedSubCategory = AnalysisSubCategory.companyTrend;
      }
    } else if (category == AnalysisCategory.academicTech) {
      _selectedDataType = AnalysisDataType.paper;
      if (_selectedSubCategory == AnalysisSubCategory.companyTrend || _selectedSubCategory == AnalysisSubCategory.countryTrend) {
        _selectedSubCategory = AnalysisSubCategory.academicTrend;
      }
    } else if (category == AnalysisCategory.techCompetition || category == AnalysisCategory.techAssessment || category == AnalysisCategory.techGap) {
      if (_selectedSubCategory != AnalysisSubCategory.countryDetail && _selectedSubCategory != AnalysisSubCategory.companyDetail && _selectedSubCategory != AnalysisSubCategory.academicDetail) {
        _selectedSubCategory = AnalysisSubCategory.countryDetail;
      }

      // Clear selected items
      _selectedCountries.clear();
      _selectedCompanies.clear();
      _selectedAcademics.clear();
    }

    _selectedCategory = category;

    initializeWithCategory(category);

    RangeValues yearRange = getYearRange();
    _startYear = yearRange.start.toInt();
    _endYear = yearRange.end.toInt();
    notifyListeners();
  }

  // aviliable function
  List<AnalysisDataType> getAvailableDataTypes(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
        if (_selectedSubCategory == AnalysisSubCategory.marketExpansionIndex) {
          return [AnalysisDataType.patent];
        } else {
          return [AnalysisDataType.patent, AnalysisDataType.paper];
        }
      case AnalysisCategory.countryTech:
        if (_selectedSubCategory == AnalysisSubCategory.marketExpansionIndex) {
          return [AnalysisDataType.patent];
        } else {
          return [AnalysisDataType.patent, AnalysisDataType.paper];
        }
      case AnalysisCategory.companyTech:
        return [AnalysisDataType.patent];
      case AnalysisCategory.academicTech:
        return [AnalysisDataType.paper];
      case AnalysisCategory.techCompetition:
        if (_selectedSubCategory == AnalysisSubCategory.countryDetail) {
          return [AnalysisDataType.patent, AnalysisDataType.paper, AnalysisDataType.patentAndPaper];
        } else if (_selectedSubCategory == AnalysisSubCategory.companyDetail) {
          return [AnalysisDataType.patent];
        } else if (_selectedSubCategory == AnalysisSubCategory.academicDetail) {
          return [AnalysisDataType.paper];
        }
        return [];
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        if (_selectedSubCategory == AnalysisSubCategory.countryDetail) {
          return [AnalysisDataType.patent, AnalysisDataType.paper, AnalysisDataType.patentAndPaper];
        } else if (_selectedSubCategory == AnalysisSubCategory.companyDetail) {
          return [AnalysisDataType.patent];
        } else if (_selectedSubCategory == AnalysisSubCategory.academicDetail) {
          return [AnalysisDataType.paper];
        }
        return [];
    }
  }

  List<AnalysisTechListType> getAvailableTechListTypes(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
        if (_selectedSubCategory == AnalysisSubCategory.marketExpansionIndex || _selectedSubCategory == AnalysisSubCategory.rdInvestmentIndex) {
          return [AnalysisTechListType.mc, AnalysisTechListType.sc];
        } else {
          return [AnalysisTechListType.lc, AnalysisTechListType.mc, AnalysisTechListType.sc];
        }
      case AnalysisCategory.countryTech:
      case AnalysisCategory.companyTech:
      case AnalysisCategory.academicTech:
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        return [AnalysisTechListType.lc, AnalysisTechListType.mc, AnalysisTechListType.sc];
    }
  }

  String? _selectedLcTechCode;
  final Set<String> _selectedMcTechCodes = {};
  final Set<String> _selectedScTechCodes = {};

  // Year related state
  late int _startYear;
  late int _endYear;

  int _selectedYear = DateTime.now().year;

  // === Setters ===

  void setSelectedSubCategory(AnalysisSubCategory subCategory) {
    switch (selectedCategory) {
      case AnalysisCategory.industryTech:
        if (subCategory == AnalysisSubCategory.rdInvestmentIndex && _selectedAnalysisTechListType == AnalysisTechListType.lc) {
          _selectedAnalysisTechListType = AnalysisTechListType.mc;
        } else if (subCategory == AnalysisSubCategory.marketExpansionIndex) {
          _selectedDataType = AnalysisDataType.patent;
          if (_selectedAnalysisTechListType == AnalysisTechListType.lc) {
            _selectedAnalysisTechListType = AnalysisTechListType.mc;
          }
        }
        break;
      case AnalysisCategory.techCompetition:
        if (subCategory == AnalysisSubCategory.companyDetail) {
          _selectedDataType = AnalysisDataType.patent;
        } else if (subCategory == AnalysisSubCategory.academicDetail) {
          _selectedDataType = AnalysisDataType.paper;
        }
        break;

      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        if (subCategory == AnalysisSubCategory.companyDetail) {
          _selectedDataType = AnalysisDataType.patent;
        } else if (subCategory == AnalysisSubCategory.academicDetail) {
          _selectedDataType = AnalysisDataType.paper;
        }
        break;
      default:
        break;
    }

    _selectedSubCategory = subCategory;
    Future.microtask(() => notifyListeners());
  }

  void setSelectedTechListType(AnalysisTechListType type) {
    _selectedAnalysisTechListType = type;
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

  void setSelectedScTechCodes(Set<String> codes) {
    _selectedScTechCodes.clear();
    _selectedScTechCodes.addAll(codes);
    notifyListeners();
  }

  void setYearRange(int start, int end) {
    if (start > end) return;
    if (start == _startYear && end == _endYear) return;

    _startYear = start;
    _endYear = end;
    notifyListeners();
  }

  void setSelectedYear(int year) {
    _selectedYear = year;
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

  void toggleScTechCode(String code) {
    if (_selectedScTechCodes.contains(code)) {
      _selectedScTechCodes.remove(code);
    } else {
      _selectedScTechCodes.add(code);
    }
    notifyListeners();
  }

  void setSelectedCountry(String? country) {
    _selectedCountry = country;
    notifyListeners();
  }

  void setSelectedCompany(String? company) {
    _selectedCompany = company;
    notifyListeners();
  }

  void setSelectedAcademic(String? academic) {
    _selectedAcademic = academic;
    notifyListeners();
  }

  // Category initialization
  void initializeWithCategory(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
        _selectedSubCategory = AnalysisSubCategory.techTrend;
        break;
      case AnalysisCategory.countryTech:
        _selectedSubCategory = AnalysisSubCategory.countryTrend;
        break;
      case AnalysisCategory.companyTech:
        _selectedDataType = AnalysisDataType.patent;
        _selectedSubCategory = AnalysisSubCategory.companyTrend;
        break;
      case AnalysisCategory.academicTech:
        _selectedSubCategory = AnalysisSubCategory.academicTrend;
        break;
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techGap:
      case AnalysisCategory.techAssessment:
        _selectedSubCategory = AnalysisSubCategory.countryDetail;
        break;
      default:
        break;
    }
    _selectedAnalysisTechListType = AnalysisTechListType.lc;
    _selectedLcTechCode = getDataCodeNames(_selectedAnalysisTechListType).first;
    RangeValues yearRange = getYearRange();
    _startYear = yearRange.start.toInt();
    _endYear = yearRange.end.toInt();
    _selectedYear = _endYear;

    if (selectedCategory == AnalysisCategory.techAssessment) {
      _selectedCountry = getAvailableCountriesFromTechAssessment().first;
    }
  }

  // === Repository ===

  String? _selectedCountry;
  String? _selectedCompany;
  String? _selectedAcademic;

  final Set<String> _selectedCountries = {};

  final Set<String> _selectedCompanies = {};

  final Set<String> _selectedAcademics = {};

  // Loading State
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  // 국가의 값을 가져오는 헬퍼 메서드
  double getCountryValue(String country) {
    double value = 0.0;
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(selectedCategory) &&
          data.codeInfo.techType == selectedTechListType &&
          data.codeInfo.codeName == selectedTechCode &&
          data.codeInfo.country == country) {
        var dataCode = getDataCode();
        if (dataCode != null) {
          var yearData = data.analysisDatas[dataCode];
          if (yearData != null && yearData.isNotEmpty) {
            value = yearData[yearData.keys.last] ?? 0.0;
          }
        }
      }
    }
    return value;
  }

  // 회사의 값을 가져오는 헬퍼 메서드
  double getTargetNameValue(String targetName) {
    double value = 0.0;
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(selectedCategory) &&
          data.codeInfo.techType == selectedTechListType &&
          data.codeInfo.codeName == selectedTechCode &&
          data.codeInfo.name == targetName) {
        var dataCode = getDataCode();
        if (dataCode != null) {
          var yearData = data.analysisDatas[dataCode];
          if (yearData != null && yearData.isNotEmpty) {
            value = yearData[yearData.keys.last] ?? 0.0;
          }
        }
      }
    }
    return value;
  }

  // Loading State
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;

  String? get error => _error;

  void toggleCountrySelection(String country) {
    if (_selectedCountries.contains(country)) {
      _selectedCountries.remove(country);
    } else {
      _selectedCountries.add(country);
    }
    notifyListeners();
  }

  void toggleCompanySelection(String company) {
    if (_selectedCompanies.contains(company)) {
      _selectedCompanies.remove(company);
    } else {
      _selectedCompanies.add(company);
    }
    notifyListeners();
  }

  void toggleAcademicSelection(String academic) {
    if (_selectedAcademics.contains(academic)) {
      _selectedAcademics.remove(academic);
    } else {
      _selectedAcademics.add(academic);
    }
    notifyListeners();
  }

  Map<String, Map<String, double>> getTechCompetitionData() {
    if (selectedSubCategory == AnalysisSubCategory.countryDetail) {
      var countries = selectedCountries.isEmpty ? getAvailableCountriesFromTechCompetition(selectedTechCode).take(10).toList() : selectedCountries;

      var dataCodes = getTechCompetitionDataCodes();
      Map<String, Map<String, double>> data = {};
      for (var country in countries) {
        data[country] = {};
        for (var dataCode in dataCodes) {
          data[country]?[dataCode] = getChartData(techListType: selectedTechListType, techCode: selectedTechCode, country: country, dataCode: dataCode).values.last;
        }
      }
      return data;
    } else if (selectedSubCategory == AnalysisSubCategory.companyDetail) {
      var companies = selectedCompanies.isEmpty ? getAvailableCompaniesFromTechCompetition(selectedTechCode).take(10).toList() : selectedCompanies;
      var dataCodes = getTechCompetitionDataCodes();
      Map<String, Map<String, double>> data = {};
      for (var company in companies) {
        data[company] = {};
        for (var dataCode in dataCodes) {
          data[company]?[dataCode] = getChartData(techListType: selectedTechListType, techCode: selectedTechCode, targetName: company, dataCode: dataCode).values.last;
        }
      }
      return data;
    } else if (selectedSubCategory == AnalysisSubCategory.academicDetail) {
      var academics = selectedAcademics.isEmpty ? getAvailableAcademicsFromTechCompetition(selectedTechCode).take(10).toList() : selectedAcademics;
      var dataCodes = getTechCompetitionDataCodes();
      Map<String, Map<String, double>> data = {};
      for (var academic in academics) {
        data[academic] = {};
        for (var dataCode in dataCodes) {
          data[academic]?[dataCode] = getChartData(techListType: selectedTechListType, techCode: selectedTechCode, targetName: academic, dataCode: dataCode).values.last;
        }
      }
      return data;
    }
    return {};
  }

  List<String> getTechCompetitionDataCodes() {
    if (selectedSubCategory == AnalysisSubCategory.countryDetail) {
      if (selectedDataType == AnalysisDataType.patent) {
        return ['PAN', 'PFN', 'PCN', 'PAI', 'PFI', 'PCI', 'TC'];
      } else if (selectedDataType == AnalysisDataType.paper) {
        return ['TPN', 'TCN', 'TPI', 'TCI', 'TC'];
      } else {
        return ['PAN', 'PFN', 'PCN', 'PAI', 'PFI', 'PCI', 'TPN', 'TCN', 'TPI', 'TCI', 'TC'];
      }
    } else if (selectedSubCategory == AnalysisSubCategory.companyDetail) {
      if (selectedDataType == AnalysisDataType.patent) {
        return ['PAI', 'PFI', 'PCI', 'TC'];
      }
    } else if (selectedSubCategory == AnalysisSubCategory.academicDetail) {
      if (selectedDataType == AnalysisDataType.paper) {
        return ['TPN', 'TCN', 'TPI', 'TCI', 'TC'];
      }
    }
    return [];
  }

  // 차트 데이터 가져오기
  Map<int, double> getChartData({
    required AnalysisTechListType techListType,
    String? techCode,
    String? country,
    String? targetName,
    String? dataCode,
  }) {
    if (selectedCategory == AnalysisCategory.techCompetition) {
      return _getTechCompetitionChartData(techCode: techCode, country: country, targetName: targetName, dataCode: dataCode);
    } else if (selectedCategory == AnalysisCategory.techAssessment) {
      return _getTechAssessmentChartData(techListType: techListType, techCode: techCode, country: country, targetName: targetName, dataCode: dataCode);
    } else if (selectedCategory == AnalysisCategory.techGap) {
      return _getTechGapChartData(country: country, targetName: targetName);
    }

    // currentData 에서 국가 데이터만 반환
    var filterData = currentData.where((data) => data.codeInfo.sheetName == getCategorySheetNames(selectedCategory)).toList();

    // filterData 에서 techListType 과 techCode 에 해당하는 데이터만 반환

    filterData = filterData.where((data) => data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == (techCode ?? selectedTechCode)).toList();

    switch (_selectedCategory) {
      case AnalysisCategory.countryTech:
      case AnalysisCategory.techCompetition:
        filterData = filterData.where((data) => data.codeInfo.country == country).toList();
        break;
      case AnalysisCategory.companyTech:
      case AnalysisCategory.academicTech:
        filterData = filterData.where((data) => data.codeInfo.name == targetName).toList();
        break;
      default:
        break;
    }
    String? finalDataCode = dataCode ?? getDataCode();
    if (finalDataCode == null) return {};

    // filterData 의 내용중 analysisDatas 의 key값이 dataCode 인 데이터만 반환
    filterData = filterData.where((data) => data.analysisDatas.containsKey(finalDataCode)).toList();

    return filterData.first.analysisDatas[finalDataCode] ?? {};
  }

  Map<int, double> _getTechCompetitionChartData({
    String? techCode,
    String? country,
    String? targetName,
    String? dataCode,
  }) {
    var sheetName = getCategorySheetNames(AnalysisCategory.techCompetition);
    if (dataCode != "TC") {
      switch (selectedSubCategory) {
        case AnalysisSubCategory.countryDetail:
          sheetName = "국가진단";
          break;
        case AnalysisSubCategory.companyDetail:
          sheetName = "기업진단";
          break;
        case AnalysisSubCategory.academicDetail:
          sheetName = "기관진단";
          break;
        default:
          break;
      }
    }
    var dataModels = currentData;
    if (selectedDataType == AnalysisDataType.patentAndPaper) {
      if (dataCode != "TC") {
        if (dataCode!.startsWith("P")) {
          dataModels = _dataMap[AnalysisDataType.patent] ?? [];
        } else if (dataCode.startsWith("T")) {
          dataModels = _dataMap[AnalysisDataType.paper] ?? [];
        }
      }
    }

    var filteredData =
        dataModels.where((data) => data.codeInfo.sheetName == sheetName && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == (techCode ?? selectedTechCode)).toList();

    if (country != null) {
      filteredData = filteredData.where((data) => data.codeInfo.country == country).toList();
    }

    if (targetName != null) {
      filteredData = filteredData.where((data) => data.codeInfo.name == targetName).toList();
    }

    if (dataCode != null) {
      filteredData = filteredData.where((data) => data.analysisDatas.containsKey(dataCode == "TC" ? "" : dataCode)).toList();
    }

    if (filteredData.isEmpty) {
      return {};
    }

    return filteredData.first.analysisDatas[dataCode == "TC" ? "" : dataCode] ?? {};
  }

  Map<int, double> _getTechAssessmentChartData({
    required AnalysisTechListType techListType,
    String? techCode,
    String? country,
    String? targetName,
    String? dataCode,
  }) {
    var filteredData = currentData
        .where((data) =>
            data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techAssessment) && data.codeInfo.techType == techListType && data.codeInfo.codeName == (techCode ?? selectedTechCode))
        .toList();

    if (country != null) {
      filteredData = filteredData.where((data) => data.codeInfo.country == country).toList();
    }

    if (targetName != null) {
      filteredData = filteredData.where((data) => data.codeInfo.name == targetName).toList();
    }

    if (filteredData.isEmpty) {
      return {};
    }

    return filteredData.first.analysisDatas[dataCode ?? ""] ?? {};
  }

  Map<int, double> _getTechGapChartData({String? country, String? targetName}) {
    // 우선 진단 데이터 확보
    var filteredData = currentData
        .where((data) =>
            data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techCompetition) &&
            data.codeInfo.techType == selectedTechListType &&
            data.codeInfo.codeName == selectedTechCode &&
            data.analysisDatas.containsKey(""))
        .toList();
    if (country != null) {
      filteredData = filteredData.where((data) => data.codeInfo.country == country).toList();
    }

    if (targetName != null) {
      filteredData = filteredData.where((data) => data.codeInfo.name == targetName).toList();
    }

    if (filteredData.isEmpty) {
      return {};
    }

    final beforeData = filteredData.first.analysisDatas[""] ?? {};

    filteredData = currentData
        .where((data) =>
            data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techGap) &&
            data.codeInfo.techType == selectedTechListType &&
            data.codeInfo.codeName == selectedTechCode &&
            data.analysisDatas.containsKey(""))
        .toList();

    if (country != null) {
      filteredData = filteredData.where((data) => data.codeInfo.country == country).toList();
    }

    if (targetName != null) {
      filteredData = filteredData.where((data) => data.codeInfo.name == targetName).toList();
    }
    final afterData = filteredData.first.analysisDatas[""] ?? {};

    return {...beforeData, ...afterData};
  }

  Map<String, double> getRaderChartData(AnalysisTechListType techListType, int year) {
    Map<String, double> chartData = {};

    Set<String> techCodes = {};
    if (techListType == AnalysisTechListType.mc) {
      techCodes = _selectedMcTechCodes.isNotEmpty ? _selectedMcTechCodes : getDataCodeNames(techListType);
    } else if (techListType == AnalysisTechListType.sc) {
      techCodes = _selectedScTechCodes.isNotEmpty ? _selectedScTechCodes : getDataCodeNames(techListType);
    }

    for (var techCode in techCodes) {
      var filteredData = currentData
          .where((data) => data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techCompetition) && data.codeInfo.techType == techListType && data.codeInfo.codeName == techCode)
          .toList();

      if (selectedSubCategory == AnalysisSubCategory.countryDetail) {
        filteredData = filteredData.where((data) => data.codeInfo.country == selectedCountry).toList();
      }

      if (selectedSubCategory == AnalysisSubCategory.companyDetail) {
        filteredData = filteredData.where((data) => data.codeInfo.name == selectedCompany).toList();
      }

      if (selectedSubCategory == AnalysisSubCategory.academicDetail) {
        filteredData = filteredData.where((data) => data.codeInfo.name == selectedAcademic).toList();
      }

      filteredData = filteredData.where((data) => data.analysisDatas.containsKey("")).toList();

      chartData[techCode] = filteredData.first.analysisDatas[""]?[year] ?? 0.0;
    }

    return chartData;
  }

  // === Utility Methods ===
  // Category Sheet Name
  String getCategorySheetNames(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
        return '기술트렌드';
      case AnalysisCategory.countryTech:
        return '국가트렌드';
      case AnalysisCategory.companyTech:
        return '기업트렌드';
      case AnalysisCategory.academicTech:
        return '기관트렌드';
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techAssessment:
        switch (selectedSubCategory) {
          case AnalysisSubCategory.countryDetail:
            if (selectedDataType == AnalysisDataType.patentAndPaper) {
              return '특허+논문과학기술진단';
            } else {
              return '국가과학기술진단';
            }
          case AnalysisSubCategory.companyDetail:
            return '기업과학기술진단';
          case AnalysisSubCategory.academicDetail:
            return '기관과학기술진단';
          default:
            return '';
        }

      case AnalysisCategory.techGap:
        switch (selectedSubCategory) {
          case AnalysisSubCategory.countryDetail:
            if (selectedDataType == AnalysisDataType.patentAndPaper) {
              return '특허+논문과학기술예측';
            } else {
              return '국가과학기술예측';
            }
          case AnalysisSubCategory.companyDetail:
            return '기업과학기술예측';
          case AnalysisSubCategory.academicDetail:
            return '기관과학기술예측';
          default:
            return '';
        }
    }
  }

  // Data Code Names
  Set<String> getDataCodeNames(AnalysisTechListType techListType) {
    final sheetName = getCategorySheetNames(_selectedCategory);

    var filteredData = currentData.where((data) => data.codeInfo.sheetName == sheetName).toList();

    filteredData = filteredData.where((data) => data.codeInfo.techType == techListType).toList();

    return SplayTreeSet<String>.from(filteredData.map((data) => data.codeInfo.codeName));
  }

  // Year Range
  RangeValues getYearRange() {
    int minYear = 9999;
    int maxYear = 0;

    var filteredData = currentData.where((data) => data.codeInfo.sheetName == getCategorySheetNames(selectedCategory) && data.codeInfo.techType == selectedTechListType).toList();

    for (var data in filteredData) {
      for (var yearData in data.analysisDatas.values) {
        for (var year in yearData.keys) {
          minYear = year < minYear ? year : minYear;
          maxYear = year > maxYear ? year : maxYear;
        }
      }
    }

    if (selectedCategory == AnalysisCategory.techGap) {
      filteredData = currentData
          .where((data) =>
              data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techCompetition) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == selectedTechCode)
          .toList();

      var dataCode = getDataCode() ?? "";
      // dataCode와 key가 일치하는 데이터에서 연도 정보를 찾아 최소/최대 연도를 구한다
      filteredData = filteredData.where((data) => data.analysisDatas.keys.contains(dataCode)).toList();

      for (var data in filteredData) {
        for (var yearData in data.analysisDatas.values) {
          for (var year in yearData.keys) {
            minYear = year < minYear ? year : minYear;
            maxYear = year > maxYear ? year : maxYear;
          }
        }
      }
    }

    return RangeValues(minYear.toDouble(), maxYear.toDouble());
  }

  int getSelectedYear() {
    return selectedYear;
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
            if (selectedTechListType == AnalysisTechListType.lc) {
              return 'PCN';
            } else {
              return 'PCI';
            }
          } else if (selectedDataType == AnalysisDataType.paper) {
            if (selectedTechListType == AnalysisTechListType.lc) {
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
    }

    return null;
  }

  List<AnalysisSubCategory> getAvailableSubCategories(AnalysisCategory category) {
    switch (category) {
      case AnalysisCategory.industryTech:
        return [
          AnalysisSubCategory.techTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.marketExpansionIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.countryTech:
        return [
          AnalysisSubCategory.countryTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.marketExpansionIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.companyTech:
        return [
          AnalysisSubCategory.companyTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.marketExpansionIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.academicTech:
        return [
          AnalysisSubCategory.academicTrend,
          AnalysisSubCategory.techInnovationIndex,
          AnalysisSubCategory.rdInvestmentIndex,
        ];
      case AnalysisCategory.techCompetition:
      case AnalysisCategory.techAssessment:
      case AnalysisCategory.techGap:
        return [
          AnalysisSubCategory.countryDetail,
          AnalysisSubCategory.companyDetail,
          AnalysisSubCategory.academicDetail,
        ]; // Fixed missing closing bracket and semicolon
    }
  }

  Set<String> getAvailableCountriesFromTechCompetition(String? techCode) {
    // currentData 에서 카테고리가  countryTech이고, techListType과 techCode가 일치하는 데이터를 찾는다
    final Map<String, double> countries = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techCompetition) &&
          data.codeInfo.techType == selectedTechListType &&
          data.codeInfo.codeName == (techCode ?? selectedTechCode)) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        countries[data.codeInfo.country] = value;
      }
    }

    final sortedList = countries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableCompaniesFromTechCompetition(String? techCode) {
    final Map<String, double> companies = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techCompetition) &&
          data.codeInfo.techType == selectedTechListType &&
          data.codeInfo.codeName == (techCode ?? selectedTechCode)) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        companies[data.codeInfo.name] = value;
      }
    }

    final sortedList = companies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableAcademicsFromTechCompetition(String? techCode) {
    final Map<String, double> academics = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techCompetition) &&
          data.codeInfo.techType == selectedTechListType &&
          data.codeInfo.codeName == (techCode ?? selectedTechCode)) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        academics[data.codeInfo.name] = value;
      }
    }

    final sortedList = academics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableCountriesFromTechAssessment() {
    // currentData 에서 카테고리가  countryTech이고, techListType과 techCode가 일치하는 데이터를 찾는다
    final Map<String, double> countries = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techAssessment) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == selectedTechCode) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        countries[data.codeInfo.country] = value;
      }
    }

    final sortedList = countries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableCompaniesFromTechAssessment() {
    final Map<String, double> companies = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techAssessment) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == selectedTechCode) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        companies[data.codeInfo.name] = value;
      }
    }

    final sortedList = companies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableAcademicsFromTechAssessment() {
    final Map<String, double> academics = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techAssessment) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == selectedTechCode) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        academics[data.codeInfo.name] = value;
      }
    }

    final sortedList = academics.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableAcademicsFormTechGap(String? techCode) {
    final Map<String, double> companies = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techGap) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == (techCode ?? selectedTechCode)) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        companies[data.codeInfo.name] = value;
      }
    }

    final sortedList = companies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableCompaniesFormTechGap(String? techCode) {
    final Map<String, double> companies = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techGap) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == (techCode ?? selectedTechCode)) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        companies[data.codeInfo.name] = value;
      }
    }

    final sortedList = companies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableCountriesFormTechGap(String? techCode) {
    final Map<String, double> countries = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.techGap) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == (techCode ?? selectedTechCode)) {
        var yearData = data.analysisDatas[""];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last] ?? 0.0;
        }
        countries[data.codeInfo.country] = value;
      }
    }

    final sortedList = countries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableCountries(String? techCode) {
    // currentData 에서 카테고리가  countryTech이고, techListType과 techCode가 일치하는 데이터를 찾는다
    final Map<String, double> countries = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.countryTech) &&
          data.codeInfo.techType == selectedTechListType &&
          data.codeInfo.codeName == (techCode ?? selectedTechCode)) {
        var dataCode = getDataCode();
        if (dataCode == null) continue;

        var yearData = data.analysisDatas[dataCode];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last - 1] ?? 0.0;
        }
        countries[data.codeInfo.country] = value;
      }
    }

    final sortedList = countries.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableCompanies() {
    // currentData 에서 카테고리가  companyTech이고, techListType과 techCode가 일치하는 데이터를 찾는다
    final Map<String, double> companies = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.companyTech) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == selectedTechCode) {
        var dataCode = getDataCode();
        if (dataCode == null) continue;

        var yearData = data.analysisDatas[dataCode];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last - 1] ?? 0.0;
        }
        companies[data.codeInfo.name] = value;
      }
    }

    final sortedList = companies.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  Set<String> getAvailableAcademics() {
    // currentData 에서 카테고리가  academicTech이고, techListType과 techCode가 일치하는 데이터를 찾는다
    final Map<String, double> academicNames = {};
    for (var data in currentData) {
      if (data.codeInfo.sheetName == getCategorySheetNames(AnalysisCategory.academicTech) && data.codeInfo.techType == selectedTechListType && data.codeInfo.codeName == selectedTechCode) {
        var dataCode = getDataCode();
        if (dataCode == null) continue;

        var yearData = data.analysisDatas[dataCode];
        double value = 0.0;
        if (yearData != null && yearData.isNotEmpty) {
          value = yearData[yearData.keys.last - 1] ?? 0.0;
        }
        academicNames[data.codeInfo.name] = value;
      }
    }

    final sortedList = academicNames.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value))
      ..map((e) => e.key).toList();
    List<String> keyValue = [];
    for (var entry in sortedList) {
      keyValue.add(entry.key);
    }
    return keyValue.toSet();
  }

  String searchCountryCode(String searchCode) {
    var filteredData = currentData
        .where((data) =>
            data.codeInfo.name == searchCode &&
            data.codeInfo.sheetName == getCategorySheetNames(selectedCategory) &&
            data.codeInfo.techType == selectedTechListType &&
            data.codeInfo.codeName == selectedTechCode)
        .toList();
    return filteredData.first.codeInfo.country;
  }

  // MC/SC 코드 매핑
  final Map<String, Color> _mcCodeMap = {};
  final Map<String, Color> _scCodeMap = {};

  final Map<String, Color> _countryCodeMap = {};
  final Map<String, Color> _companyCodeMap = {};
  final Map<String, Color> _academicCodeMap = {};

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
    Colors.cyan,
    Colors.amber,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
  ];

  // 코드에 대한 색상을 가져오거나 할당
  Color getColorForCode(String code) {
    if (_selectedCategory == AnalysisCategory.countryTech) {
      if (!_countryCodeMap.containsKey(code)) {
        final colorIndex = _countryCodeMap.length % _defaultColors.length;
        _countryCodeMap[code] = _defaultColors[colorIndex];
      }
      return _countryCodeMap[code]!;
    } else if (_selectedCategory == AnalysisCategory.companyTech) {
      if (!_companyCodeMap.containsKey(code)) {
        final colorIndex = _companyCodeMap.length % _defaultColors.length;
        _companyCodeMap[code] = _defaultColors[colorIndex];
      }
      return _companyCodeMap[code]!;
    } else if (_selectedCategory == AnalysisCategory.academicTech) {
      if (!_academicCodeMap.containsKey(code)) {
        final colorIndex = _academicCodeMap.length % _defaultColors.length;
        _academicCodeMap[code] = _defaultColors[colorIndex];
      }
      return _academicCodeMap[code]!;
    }

    if (_selectedAnalysisTechListType == AnalysisTechListType.mc) {
      if (!_mcCodeMap.containsKey(code)) {
        final colorIndex = _mcCodeMap.length % _defaultColors.length;
        _mcCodeMap[code] = _defaultColors[colorIndex];
      }
      return _mcCodeMap[code]!;
    } else if (_selectedAnalysisTechListType == AnalysisTechListType.sc) {
      if (!_scCodeMap.containsKey(code)) {
        final colorIndex = _scCodeMap.length % _defaultColors.length;
        _scCodeMap[code] = _defaultColors[colorIndex];
      }
      return _scCodeMap[code]!;
    }
    return Colors.blue;
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter_application_data_chart_viewer/models/analysis_data_model.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/repositories/analysis_data_repository.dart';

class AnalysisDataProvider extends ChangeNotifier {
  final AnalysisDataRepository _repository;
  final Map<AnalysisDataType, List<AnalysisDataModel>> _dataMap = {
    AnalysisDataType.paper: [],
    AnalysisDataType.patent: [],
    AnalysisDataType.patentAndPaper: [],
  };

  AnalysisDataType _selectedDataType = AnalysisDataType.paper;
  AnalysisDataType get selectedDataType => _selectedDataType;
  void selectDataType(AnalysisDataType dataType) {
    _selectedDataType = dataType;
    notifyListeners();
  }

  AnalysisCategory _selectedCategory = AnalysisCategory.countryTech;
  AnalysisCategory get selectedCategory => _selectedCategory;
  void selectCategory(AnalysisCategory category) {
    _selectedCategory = category;
    notifyListeners();
  }

  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  AnalysisDataProvider(this._repository);

  bool get isInitialized => _isInitialized;
  List<AnalysisDataModel> get currentData => _dataMap[_selectedDataType] ?? [];

  bool get isLoading => _isLoading;
  String? get error => _error;

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
      print('Data loading error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 카테고리별 시트 이름 매핑
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

  // 데이터 코드 가져오기 메서드 수정
  List<String> getDataCodeNames(
      AnalysisCategory category, TechListType techListType) {
    final sheetName = getCategorySheetName(category);

    return currentData
        .where((data) =>
            data.codeInfo.sheetName == sheetName &&
            data.codeInfo.techType == techListType)
        .map((data) => data.codeInfo.codeName)
        .toList();
  }

  // 데이터 코드 결정 메서드
  String? getDataCode({
    required AnalysisCategory category,
    required TechListType techListType,
    required AnalysisSubCategory subCategory,
  }) {
    if (category == AnalysisCategory.industryTech) {
      switch (subCategory) {
        case AnalysisSubCategory.techTrend:
          if (selectedDataType == AnalysisDataType.patent) {
            return 'PAN';
          } else if (selectedDataType == AnalysisDataType.paper) {
            return 'TPN';
          }
        case AnalysisSubCategory.techInnovationIndex:
          if (selectedDataType == AnalysisDataType.patent) {
            if (techListType == TechListType.lc) {
              return 'PCN';
            } else {
              return 'PCI';
            }
          } else if (selectedDataType == AnalysisDataType.paper) {
            if (techListType == TechListType.lc) {
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
    } else if (category == AnalysisCategory.countryTech) {
      switch (subCategory) {
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
    } else if (category == AnalysisCategory.companyTech) {
      switch (subCategory) {
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
    } else if (category == AnalysisCategory.academicTech) {
      switch (subCategory) {
        case AnalysisSubCategory.academicTrend:
          return 'TPN';
        case AnalysisSubCategory.techInnovationIndex:
          return 'TCI';
        case AnalysisSubCategory.rdInvestmentIndex:
          return 'TPI';
        default:
          return null;
      }
    } else if (category == AnalysisCategory.techCompetition) {
      switch (subCategory) {
        case AnalysisSubCategory.techTrend:
          return 'CPN';
        default:
          return null;
      }
    } else if (category == AnalysisCategory.techAssessment) {
      switch (subCategory) {
        case AnalysisSubCategory.techTrend:
          return 'CPN';
        default:
          return null;
      }
    } else if (category == AnalysisCategory.techGap) {
      switch (subCategory) {
        case AnalysisSubCategory.techTrend:
          return 'CPN';
        default:
          return null;
      }
    }

    return null;
  }

  // 차트 데이터 가져오기 메서드 수정
  Map<int, double> getChartData({
    required AnalysisCategory category,
    required AnalysisSubCategory subCategory,
    required String? selectedLcCode,
  }) {
    if (selectedLcCode == null) return {};

    // 선택된 LC 코드에 해당하는 데이터 찾기
    final data = currentData.firstWhere(
      (data) => data.codeInfo.codeName == selectedLcCode,
      orElse: () => throw Exception('Selected LC code not found'),
    );

    // currentDataType을 직접 사용
    final dataCode = getDataCode(
      category: category,
      techListType: data.codeInfo.techType,
      subCategory: subCategory,
    );

    if (dataCode == null) return {};

    return data.analysisDatas[dataCode] ?? {};
  }

  // 연도 범위 가져오기
  (int, int) getYearRange() {
    int minYear = 9999;
    int maxYear = 0;

    for (var data in currentData) {
      for (var yearData in data.analysisDatas.values) {
        for (var year in yearData.keys) {
          minYear = year < minYear ? year : minYear;
          maxYear = year > maxYear ? year : maxYear;
        }
      }
    }

    return (minYear, maxYear);
  }
}

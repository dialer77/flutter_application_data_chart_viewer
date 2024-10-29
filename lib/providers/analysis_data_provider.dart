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
  AnalysisDataType _currentDataType = AnalysisDataType.paper;
  bool _isInitialized = false;
  bool _isLoading = false;
  String? _error;

  AnalysisDataProvider(this._repository);

  bool get isInitialized => _isInitialized;
  List<AnalysisDataModel> get currentData => _dataMap[_currentDataType] ?? [];
  AnalysisDataType get currentDataType => _currentDataType;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadAllData() async {
    if (_isInitialized) return; // 이미 초기화되었다면 스킵

    try {
      _isLoading = true;
      notifyListeners();

      // 모든 데이터 타입에 대해 데이터 로드
      const dataType = AnalysisDataType.paper;
      final rawData = await _repository.loadAnalysisData(dataType);
      _dataMap[dataType] =
          rawData.map((map) => AnalysisDataModel.fromMap(map)).toList();

      _isInitialized = true;
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Data loading error: $e'); // 디버깅용 로그
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeDataType(AnalysisDataType dataType) {
    _currentDataType = dataType;
    notifyListeners();
  }

  List<AnalysisDataModel> getDataByCategory(AnalysisCategory category) {
    return currentData.where((data) => data.category == category).toList();
  }

  List<AnalysisDataModel> getDataBySubCategory(
      AnalysisSubCategory subCategory) {
    return currentData
        .where((data) => data.subCategory == subCategory)
        .toList();
  }

  // 특정 DB의 데이터만 가져오기
  List<AnalysisDataModel> getDataByDataType(AnalysisDataType dataType) {
    return _dataMap[dataType] ?? [];
  }
}

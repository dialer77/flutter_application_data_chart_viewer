import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/pages/chart_page.dart';
import '../pages/main_page.dart';

class ContentController extends ChangeNotifier {
  final List<Widget> _history = [const MainPage()];

  Widget get currentContent => _history.last;

  void changeContent(AnalysisCategory category) {
    if (_history.last is ChartPage) {
      _history.removeLast();
    }
    _history.add(ChartPage(category: category));
    notifyListeners();
  }

  void goBack() {
    if (_history.length > 1) {
      _history.removeLast();
      notifyListeners();
    }
  }

  bool get canGoBack => _history.length > 1;
}

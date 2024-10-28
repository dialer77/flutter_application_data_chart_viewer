import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import '../pages/main_page.dart';

class ContentController extends ChangeNotifier {
  final List<Widget> _history = [MainPage()];

  Widget get currentContent => _history.last;

  void changeContent(AnalysisCategory category) {
    // Widget newContent;
    // if (pageNumber == 0) {
    //   newContent = MainPage();
    // } else {
    //   newContent = ChartPage(pageNumber: pageNumber, title: title);
    // }
    // _history.add(newContent);
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

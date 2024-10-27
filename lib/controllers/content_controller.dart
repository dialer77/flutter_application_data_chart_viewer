import 'package:flutter/material.dart';
import '../pages/main_page.dart';
import '../pages/chart_page.dart';

class ContentController extends ChangeNotifier {
  final List<Widget> _history = [MainPage()];

  Widget get currentContent => _history.last;

  void changeContent(int pageNumber, String title) {
    Widget newContent;
    if (pageNumber == 0) {
      newContent = MainPage();
    } else {
      newContent = ChartPage(pageNumber: pageNumber, title: title);
    }
    _history.add(newContent);
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

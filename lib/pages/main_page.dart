import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_item.dart';
import '../controllers/content_controller.dart';

class MainPage extends StatelessWidget {
  MainPage({super.key});

  final List<MenuItem> menuItems = [
    MenuItem(text: "특허 논문 구분", row: 0, column: 0),
    MenuItem(text: "산업기술 분석", row: 1, column: 0),
    MenuItem(text: "기술트렌드", row: 2, column: 0),
    MenuItem(text: "기술혁신지수", row: 3, column: 0),
    MenuItem(text: "시장확장지수", row: 4, column: 0),
    MenuItem(text: "R&D 투자지수", row: 5, column: 0),
    MenuItem(text: "특허 논문 구분", row: 0, column: 1),
    MenuItem(text: "국가별 분석", row: 1, column: 1),
    MenuItem(text: "국가트렌드", row: 2, column: 1),
    MenuItem(text: "기술혁신지수", row: 3, column: 1),
    MenuItem(text: "시장확장지수", row: 4, column: 1),
    MenuItem(text: "R&D 투자지수", row: 5, column: 1),
    MenuItem(text: "Menu 4", row: 0, column: 4),
    MenuItem(text: "Menu 5", row: 0, column: 5),
    MenuItem(text: "Menu 6", row: 0, column: 6),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(7, (index) => _buildMenuColumn(context, index)),
    );
  }

  Widget _buildMenuColumn(BuildContext context, int columnIndex) {
    List<MenuItem> columnItems =
        menuItems.where((item) => item.column == columnIndex).toList();
    columnItems.sort((a, b) => a.row.compareTo(b.row));

    // Row 0과 Row 1이 없는 경우 빈 MenuItem 추가
    if (!columnItems.any((item) => item.row == 0)) {
      columnItems.insert(0, MenuItem(text: "", row: 0, column: columnIndex));
    }
    if (!columnItems.any((item) => item.row == 1)) {
      columnItems.insert(1, MenuItem(text: "", row: 1, column: columnIndex));
    }

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children:
                  columnItems.map((item) => _buildMenuItem(item)).toList(),
            ),
            ElevatedButton(
              onPressed: () {
                context.read<ContentController>().changeContent(
                    columnIndex + 1, columnItems[columnIndex].text);
              },
              child: Text('Go to Sub ${columnIndex + 1}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(MenuItem item) {
    Widget content;
    if (item.row == 0) {
      content = Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.blue[100],
        child: Center(
          child: Text(
            item.text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else if (item.row == 1) {
      content = Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.green[100],
        child: Center(
          child: Text(
            item.text,
            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
        ),
      );
    } else {
      content = Center(
        child: Text(
          item.text,
          style: const TextStyle(fontSize: 14),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: content,
    );
  }
}

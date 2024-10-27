class MenuItem {
  final String text;
  final int row;
  final int column;
  final bool isBlank;

  MenuItem({
    required this.text,
    required this.row,
    required this.column,
    this.isBlank = false,
  });
}

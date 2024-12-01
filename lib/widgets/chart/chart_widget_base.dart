import 'package:flutter/material.dart';

class ChartWidgetBase extends StatefulWidget {
  const ChartWidgetBase({super.key});

  @override
  State<ChartWidgetBase> createState() => _ChartWidgetBaseState();
}

class _ChartWidgetBaseState extends State<ChartWidgetBase> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

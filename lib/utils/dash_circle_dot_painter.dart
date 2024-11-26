import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';

class DashedCircleDotPainter extends FlDotPainter {
  final double radius;
  final Color strokeColor;
  final Color fillColor;
  final double strokeWidth;

  DashedCircleDotPainter({
    required this.radius,
    required this.strokeColor,
    required this.fillColor,
    this.strokeWidth = 2,
  });

  @override
  void draw(Canvas canvas, FlSpot spot, Offset offset) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // 배경 원 그리기
    canvas.drawCircle(
      offset,
      radius,
      Paint()
        ..color = fillColor
        ..style = PaintingStyle.fill,
    );

    // 점선 원 그리기
    final path = Path()
      ..addOval(Rect.fromCircle(center: offset, radius: radius));
    final dashPath = Path();
    const dashWidth = 3.0;
    const dashSpace = 3.0;
    final metrics = path.computeMetrics().first;
    var distance = 0.0;

    while (distance < metrics.length) {
      if (distance + dashWidth > metrics.length) {
        dashPath.addPath(
          metrics.extractPath(distance, metrics.length),
          Offset.zero,
        );
      } else {
        dashPath.addPath(
          metrics.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
      }
      distance += dashWidth + dashSpace;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  Size getSize(FlSpot spot) {
    return Size(radius * 2, radius * 2);
  }

  @override
  List<Object?> get props => [radius, strokeColor, fillColor, strokeWidth];
}

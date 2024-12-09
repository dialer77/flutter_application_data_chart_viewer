import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CustomTooltipOverlay extends StatelessWidget {
  final List<LineBarSpot> touchedSpots;
  final List<int> years;
  final List<String> codes;
  final List<Color> colors;
  final int? tooltipLocation;
  final Offset? mousePosition;

  const CustomTooltipOverlay({
    super.key,
    required this.touchedSpots,
    required this.years,
    required this.codes,
    required this.colors,
    required this.tooltipLocation,
    required this.mousePosition,
  });

  @override
  Widget build(BuildContext context) {
    if (tooltipLocation == null || mousePosition == null) return const SizedBox.shrink();

    final year = years[touchedSpots.first.x.toInt()];

    final screenSize = MediaQuery.of(context).size;
    const tooltipWidth = 200.0;
    const tooltipHeight = 100.0;

    double left = mousePosition!.dx + 10;
    if (left + tooltipWidth > screenSize.width) {
      left = mousePosition!.dx - tooltipWidth - 10;
    }

    double top = mousePosition!.dy - tooltipHeight - 10;
    if (top < 0) {
      top = mousePosition!.dy + 10;
    }

    return Positioned(
      left: left,
      top: top,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blueGrey.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              year.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            ...touchedSpots.map((spot) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[spot.barIndex % colors.length],
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${codes[spot.barIndex]}: ${spot.y.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

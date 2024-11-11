import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class AnalysisPeriodWidget extends StatefulWidget {
  const AnalysisPeriodWidget({super.key});

  @override
  State<AnalysisPeriodWidget> createState() => _AnalysisPeriodWidgetState();
}

class _AnalysisPeriodWidgetState extends State<AnalysisPeriodWidget> {
  final int currentYear = DateTime.now().year;
  RangeValues _currentRangeValues = const RangeValues(0, 0);

  @override
  void initState() {
    super.initState();
    final provider = context.read<AnalysisDataProvider>();
    _currentRangeValues = provider.getYearRange();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalysisDataProvider>();
      setState(() {
        provider.setYearRange(
          _currentRangeValues.start.toInt(),
          _currentRangeValues.end.toInt(),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '분석 기간',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        Row(
          children: [
            Text('${provider.startYear}년'),
            Expanded(
              child: RangeSlider(
                values: RangeValues(
                  provider.startYear.toDouble(),
                  provider.endYear.toDouble(),
                ),
                min: _currentRangeValues.start,
                max: _currentRangeValues.end,
                divisions: _currentRangeValues.end.toInt() -
                    _currentRangeValues.start.toInt(),
                labels: RangeLabels(
                  provider.startYear.toString(),
                  provider.endYear.toString(),
                ),
                onChanged: (RangeValues values) {
                  provider.setYearRange(
                    values.start.round(),
                    values.end.round(),
                  );
                },
              ),
            ),
            Text('${provider.endYear}년'),
          ],
        ),
      ],
    );
  }
}

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
  RangeValues _currentRangeValues = RangeValues(
    DateTime.now().year - 10.0,
    DateTime.now().year.toDouble(),
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<AnalysisDataProvider>();
      setState(() {
        _currentRangeValues = RangeValues(
          provider.startYear.toDouble(),
          provider.endYear.toDouble(),
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
            Text('${_currentRangeValues.start.round()}년'),
            Expanded(
              child: RangeSlider(
                values: _currentRangeValues,
                min: (currentYear - 10).toDouble(),
                max: currentYear.toDouble(),
                divisions: 20,
                labels: RangeLabels(
                  _currentRangeValues.start.round().toString(),
                  _currentRangeValues.end.round().toString(),
                ),
                onChanged: (RangeValues values) {
                  setState(() {
                    _currentRangeValues = values;
                  });
                  provider.setYearRange(
                    values.start.round(),
                    values.end.round(),
                  );
                },
              ),
            ),
            Text('${_currentRangeValues.end.round()}년'),
          ],
        ),
      ],
    );
  }
}

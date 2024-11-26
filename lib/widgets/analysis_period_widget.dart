import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class AnalysisPeriodWidget extends StatefulWidget {
  final AnalysisType analysisType;

  const AnalysisPeriodWidget({
    super.key,
    required this.analysisType,
  });

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

  Widget _buildRangeSelector(AnalysisDataProvider provider) {
    return Row(
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
    );
  }

  Widget _buildYearDropdown(AnalysisDataProvider provider) {
    final List<int> years = List<int>.generate(
      (_currentRangeValues.end.toInt() - _currentRangeValues.start.toInt() + 1),
      (i) => _currentRangeValues.start.toInt() + i,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('연도 선택: '),
        DropdownButton<int>(
          value: provider.selectedYear,
          items: years.map<DropdownMenuItem<int>>((int year) {
            return DropdownMenuItem<int>(
              value: year,
              child: Text('$year년'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              provider.setSelectedYear(newValue);
            }
          },
        ),
      ],
    );
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
        widget.analysisType == AnalysisType.range
            ? _buildRangeSelector(provider)
            : _buildYearDropdown(provider),
      ],
    );
  }
}

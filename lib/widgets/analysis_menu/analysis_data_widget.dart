import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class AnalysisDataWidget extends StatefulWidget {
  final AnalysisCategory category;

  const AnalysisDataWidget({
    super.key,
    required this.category,
  });

  @override
  State<AnalysisDataWidget> createState() => _AnalysisDataWidgetState();
}

class _AnalysisDataWidgetState extends State<AnalysisDataWidget> {
  @override
  void initState() {
    super.initState();
    // build 과정이 끝난 후 초기화하도록 수정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AnalysisDataProvider>().initializeWithCategory(widget.category);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalysisDataProvider>();
    final availableOptions = provider.getAvailableDataTypes(widget.category);

    return LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          Center(
            child: Container(
              height: constraints.maxHeight * 0.5,
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromARGB(255, 70, 177, 225)),
              ),
              child: Center(
                child: Text(
                  '분석 데이터',
                  style: TextStyle(
                    fontSize: constraints.maxHeight * 0.225,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 70, 177, 225),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ...AnalysisDataType.values.map(
                  (option) => Opacity(
                    opacity: availableOptions.contains(option) ? 1.0 : 0.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.scale(
                          scale: constraints.maxWidth * 0.004,
                          child: Radio<AnalysisDataType>(
                            value: option,
                            groupValue: provider.selectedDataType,
                            onChanged: (AnalysisDataType? value) {
                              if (value != null) {
                                context.read<AnalysisDataProvider>().setSelectedDataType(value);
                              }
                            },
                          ),
                        ),
                        Text(
                          option.toString(),
                          style: TextStyle(fontSize: constraints.maxWidth * 0.06),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

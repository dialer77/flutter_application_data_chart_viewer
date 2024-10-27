import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';

class SectionWidget extends StatefulWidget {
  final SectionType sectionType;

  const SectionWidget({
    super.key,
    required this.sectionType,
  });

  @override
  State<SectionWidget> createState() => _SectionWidgetState();
}

class _SectionWidgetState extends State<SectionWidget> {
  late String _title;
  String _selectedOption = '특허';

  @override
  void initState() {
    super.initState();
    _setTitle();
  }

  void _setTitle() {
    switch (widget.sectionType) {
      case SectionType.analysisData:
        _title = '분석 데이터';
        break;
      case SectionType.analysisPeriod:
        _title = '분석 기간';
        break;
      case SectionType.technologyList:
        _title = '기술 목록';
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(
          color: Colors.grey,
          thickness: 1,
        ),
        switch (widget.sectionType) {
          SectionType.analysisData => Row(
              children: [
                Radio<String>(
                  value: '특허',
                  groupValue: _selectedOption,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('특허'),
                Radio<String>(
                  value: '논문',
                  groupValue: _selectedOption,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('논문'),
                Radio<String>(
                  value: '특허+논문',
                  groupValue: _selectedOption,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedOption = value!;
                    });
                  },
                ),
                const Text('특허+논문'),
              ],
            ),
          SectionType.analysisPeriod => const SizedBox(height: 10),
          SectionType.technologyList => const SizedBox(height: 10),
        },
        const SizedBox(height: 20),
      ],
    );
  }
}

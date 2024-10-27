import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/widgets/section_widget.dart';
import 'package:provider/provider.dart';
import '../controllers/content_controller.dart';

class ChartPage extends StatefulWidget {
  final int pageNumber;
  final String title;

  const ChartPage({super.key, required this.pageNumber, required this.title});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            SizedBox(
              width: 40,
              child: ElevatedButton(
                onPressed: () {
                  context.read<ContentController>().goBack();
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
        SizedBox(
          width: 300,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 0, 0),
                child: Container(
                  color: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 70, vertical: 4),
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 30, 0, 30),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionWidget(
                          sectionType: SectionType.analysisData,
                        ),
                        SectionWidget(
                          sectionType: SectionType.analysisPeriod,
                        ),
                        SectionWidget(
                          sectionType: SectionType.technologyList,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

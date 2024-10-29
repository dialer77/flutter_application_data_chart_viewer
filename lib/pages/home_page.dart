import 'package:flutter/material.dart';
import 'package:flutter_application_data_chart_viewer/pages/main_page.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AnalysisDataProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.error != null) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('데이터 로드 중 오류가 발생했습니다'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadAllData(),
                    child: const Text('다시 시도'),
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold(
          body: MainPage(), // 실제 앱 컨텐츠
        );
      },
    );
  }
}

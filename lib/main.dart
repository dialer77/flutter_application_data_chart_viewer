import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'layout/main_layout.dart';
import 'controllers/content_controller.dart';
import 'package:provider/provider.dart';
import 'repositories/analysis_data_repository.dart';
import 'providers/analysis_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    setWindowTitle('InnoPatent Analytics v4.5');
    setWindowMinSize(const Size(800, 600));
    getCurrentScreen().then((screen) {
      if (screen != null) {
        final screenFrame = screen.frame;
        const initialSize = Size(1920, 1080);

        final left = (screenFrame.width - initialSize.width) / 2;
        final top = (screenFrame.height - initialSize.height) / 2;

        setWindowFrame(Rect.fromLTWH(
          left + screenFrame.left,
          top + screenFrame.top,
          initialSize.width,
          initialSize.height,
        ));
      }
    });
  }

  final repository = AnalysisDataRepository();
  final dataProvider = AnalysisDataProvider(repository);

  await dataProvider.loadAllData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: dataProvider,
        ),
        ChangeNotifierProvider(
          create: (context) => ContentController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainLayout(),
    );
  }
}

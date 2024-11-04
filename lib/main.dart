import 'package:flutter/material.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'layout/main_layout.dart';
import 'controllers/content_controller.dart';
import 'package:provider/provider.dart';
import 'repositories/analysis_data_repository.dart';
import 'providers/analysis_data_provider.dart';
import 'providers/analysis_state_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Platform.isWindows) {
    setWindowTitle('Flutter Demo');
    setWindowMinSize(const Size(1920, 1080));
    setWindowMaxSize(const Size(1920, 1080));
    getCurrentScreen().then((screen) {
      setWindowFrame(Rect.fromCenter(
        center: screen!.frame.center,
        width: 1920,
        height: 1080,
      ));
    });
  }

  final repository = AnalysisDataRepository();
  final dataProvider = AnalysisDataProvider(repository);

  await dataProvider.loadAllData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AnalysisStateProvider()),
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

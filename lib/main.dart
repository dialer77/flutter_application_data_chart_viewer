import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'layout/main_layout.dart';
import 'controllers/content_controller.dart';
import 'package:provider/provider.dart';
import 'repositories/analysis_data_repository.dart';
import 'providers/analysis_data_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      size: Size(1920, 1080),
      minimumSize: Size(1280, 720),
      center: true,
      title: 'InnoPatent Analytics v4.5',
      backgroundColor: Colors.transparent,
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  final repository = AnalysisDataRepository();
  final dataProvider = AnalysisDataProvider(repository);

  await dataProvider.loadAllData();

  runApp(
    AspectRatio(
      aspectRatio: 16 / 9,
      child: MultiProvider(
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
        fontFamily: 'Paperlogy-5',
      ),
      home: const MainLayout(),
    );
  }
}

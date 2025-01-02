import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/providers/analysis_data_provider.dart';
import 'package:image/image.dart' as img;
import 'package:file_picker/file_picker.dart';

class CommonUtils {
  static CommonUtils? _instance;
  static CommonUtils get instance => _instance ??= CommonUtils._();

  CommonUtils._();

  Widget blankContainer({int flex = 1, Color color = Colors.white}) {
    return Flexible(
      flex: flex,
      child: Container(
        decoration: BoxDecoration(color: color),
      ),
    );
  }

  Widget menuTitle({
    required String title,
    required double height,
    required double fontSize,
    required Color color,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        border: Border.all(color: color),
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  String replaceCountryCode(String countryCode) {
    return countryCode.replaceAll('[', '').replaceAll(']', '');
  }

  double calculateInterval(double maxValue) {
    // maxValue가 0이면 기본값 1 반환
    if (maxValue <= 0) return 0.1;

    // 자릿수 계산을 위해 로그 사용
    final digitCount = (log(maxValue) / ln10).floor();
    final base = pow(10, digitCount - 1).toDouble();

    // 최고 자릿수 추출
    final firstDigit = (maxValue / pow(10, digitCount)).floor();

    if (firstDigit <= 2) return base * 4; // 2배 증가
    if (firstDigit <= 5) return base * 10; // 2배 증가
    return base * 20; // 2배 증가
  }

  List<Shadow> getTextBorderShadow() {
    return const [
      Shadow(
        offset: Offset(-1, -1),
        color: Colors.black,
        blurRadius: 0,
      ),
      Shadow(
        offset: Offset(1, -1),
        color: Colors.black,
        blurRadius: 0,
      ),
      Shadow(
        offset: Offset(-1, 1),
        color: Colors.black,
        blurRadius: 0,
      ),
      Shadow(
        offset: Offset(1, 1),
        color: Colors.black,
        blurRadius: 0,
      ),
    ];
  }

  Widget saveMenuPopup({
    required BoxConstraints constraints,
    required GlobalKey globalKey,
    required AnalysisDataProvider dataProvider,
    required List<String> techCodes,
    List<String>? chartCodes,
  }) {
    return PopupMenuButton<String>(
      offset: Offset(constraints.maxHeight * 0, constraints.maxHeight * 0.02),
      position: PopupMenuPosition.under,
      onSelected: (String value) {
        switch (value) {
          case 'PNG':
          case 'JPG':
            _handleImageExport(format: value, globalKey: globalKey);
            break;
          case 'CSV':
            _handleCsvExport(globalKey, dataProvider, techCodes, chartCodes);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          value: 'PNG',
          height: constraints.maxHeight * 0.05,
          padding: EdgeInsets.zero,
          child: const Center(child: Text('PNG')),
        ),
        PopupMenuItem<String>(
          value: 'JPG',
          height: constraints.maxHeight * 0.05,
          padding: EdgeInsets.zero,
          child: const Center(child: Text('JPG')),
        ),
        // PopupMenuItem<String>(
        //   value: 'SVG',
        //   height: constraints.maxHeight * 0.05,
        //   padding: EdgeInsets.zero,
        //   child: const Center(child: Text('SVG')),
        // ),
        PopupMenuItem<String>(
          value: 'CSV',
          height: constraints.maxHeight * 0.05,
          padding: EdgeInsets.zero,
          child: const Center(child: Text('CSV')),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Icon(
          Icons.download,
          size: constraints.maxHeight * 0.05,
          color: const Color.fromARGB(255, 109, 207, 245),
        ),
      ),
    );
  }

  Future<void> _handleImageExport(
      {required String format, required GlobalKey globalKey}) async {
    try {
      RenderRepaintBoundary? boundary = globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        showDialog(
          context: globalKey.currentContext!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        // 이미지 생성 로직
        late final List<int> bytes;
        late final String defaultFileName;

        switch (format) {
          case 'PNG':
            final image = await boundary.toImage(pixelRatio: 3.0);
            final recorder = PictureRecorder();
            final canvas = Canvas(
                recorder,
                Rect.fromLTWH(
                    0, 0, image.width.toDouble(), image.height.toDouble()));

            canvas.drawColor(Colors.white, BlendMode.src);
            canvas.drawImage(image, Offset.zero, Paint());

            final picture = recorder.endRecording();
            final imageWithBg =
                await picture.toImage(image.width, image.height);
            final byteData =
                await imageWithBg.toByteData(format: ImageByteFormat.png);
            bytes = byteData!.buffer.asUint8List();
            defaultFileName = 'chart.png';
            break;

          case 'JPG':
            final image = await boundary.toImage(pixelRatio: 3.0);
            final byteData =
                await image.toByteData(format: ImageByteFormat.rawRgba);
            final rawBytes = byteData!.buffer.asUint8List();

            final imgData = img.Image.fromBytes(
              width: image.width,
              height: image.height,
              bytes: rawBytes.buffer,
              numChannels: 4,
            );

            bytes = img.encodeJpg(imgData, quality: 90);
            defaultFileName = 'chart.jpg';
            break;

          default:
            throw UnsupportedError('Unsupported format: $format');
        }

        // 저장 다이얼로그 닫기
        if (globalKey.currentContext != null) {
          Navigator.of(globalKey.currentContext!).pop();
        }

        // 파일 저장 위치 선택
        String? outputFile = await FilePicker.platform.saveFile(
          dialogTitle: '저장할 위치를 선택하세요',
          fileName: defaultFileName,
          type: FileType.custom,
          allowedExtensions: [format.toLowerCase()],
        );

        if (outputFile != null) {
          // 파일 확장자 확인 및 추가
          if (!outputFile.toLowerCase().endsWith('.${format.toLowerCase()}')) {
            outputFile = '$outputFile.${format.toLowerCase()}';
          }

          final file = File(outputFile);
          await file.writeAsBytes(bytes);

          if (globalKey.currentContext != null) {
            showDialog(
              context: globalKey.currentContext!,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('저장 완료'),
                  content: Text('차트가 저장되었습니다.\n저장 위치: ${file.path}'),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('확인'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                );
              },
            );
          }
        }
      }
    } catch (e) {
      if (globalKey.currentContext != null) {
        Navigator.of(globalKey.currentContext!).pop();
      }

      if (globalKey.currentContext != null) {
        showDialog(
          context: globalKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('오류'),
              content: Text('차트 저장 중 오류가 발생했습니다.\n$e'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      }
    }
  }

  Future<void> _handleCsvExport(
    GlobalKey globalKey,
    AnalysisDataProvider dataProvider,
    List<String> techCodes,
    List<String>? chartCodes,
  ) async {
    try {
      // CSV 헤더와 데이터 생성
      final StringBuffer csvContent = StringBuffer();

      // 헤더 추가 (순위, 국가명, 연도별 데이터)
      StringBuffer csvHeader = StringBuffer();
      csvHeader.write(
          '${dataProvider.selectedCategory},${dataProvider.selectedSubCategory},${dataProvider.selectedDataType},${dataProvider.selectedTechListType}');

      bool isFirst = true;
      AnalysisCategory category = dataProvider.selectedCategory;
      AnalysisSubCategory subCategory = dataProvider.selectedSubCategory;
      Map<int, double> chartData = {};

      for (var techCode in techCodes) {
        if (chartCodes != null &&
            chartCodes.isNotEmpty &&
            dataProvider.selectedCategory != AnalysisCategory.industryTech) {
          for (var chartCode in chartCodes) {
            if (category == AnalysisCategory.techCompetition) {
              final dataCodes = dataProvider.getTechCompetitionDataCodes();
              for (var dataCode in dataCodes) {
                chartData = dataProvider.getChartData(
                  techListType: dataProvider.selectedTechListType,
                  techCode: techCode,
                  country: subCategory == AnalysisSubCategory.countryDetail
                      ? chartCode
                      : null,
                  targetName: subCategory != AnalysisSubCategory.countryDetail
                      ? chartCode
                      : null,
                  dataCode: dataCode,
                );

                if (isFirst) {
                  csvHeader.writeln(',$techCode');
                  String yearData = chartData.keys.join(',');
                  csvContent.writeln(",,$yearData");
                  isFirst = false;
                }

                csvContent.writeln(
                    "$chartCode,$dataCode, ${chartData.values.join(',')}");
              }
            } else if (category == AnalysisCategory.techAssessment) {
              csvHeader = StringBuffer();
              csvHeader.write(
                  '${dataProvider.selectedCategory},${dataProvider.selectedSubCategory},${dataProvider.selectedDataType},$chartCode');
              chartData = dataProvider.getChartData(
                techListType: AnalysisTechListType.lc,
                techCode: dataProvider.selectedLcTechCode,
                country: subCategory == AnalysisSubCategory.countryDetail
                    ? chartCode
                    : null,
                targetName: subCategory != AnalysisSubCategory.countryDetail
                    ? chartCode
                    : null,
              );
              if (isFirst) {
                csvHeader.writeln('');
                String yearData = chartData.keys.join(',');
                csvContent.writeln(",,$yearData");
                isFirst = false;
              }
              csvContent.writeln('LC,$techCode,${chartData.values.join(',')}');
              Set<String> mcTechCodes = dataProvider.selectedMcTechCodes;
              if (mcTechCodes.isEmpty) {
                mcTechCodes =
                    dataProvider.getDataCodeNames(AnalysisTechListType.mc);
              }
              for (var mcTechCode in mcTechCodes) {
                chartData = dataProvider.getChartData(
                  techListType: AnalysisTechListType.mc,
                  techCode: mcTechCode,
                  country: subCategory == AnalysisSubCategory.countryDetail
                      ? chartCode
                      : null,
                  targetName: subCategory != AnalysisSubCategory.countryDetail
                      ? chartCode
                      : null,
                );

                csvContent
                    .writeln('MC,$mcTechCode,${chartData.values.join(',')}');
              }
              Set<String> scTechCodes = dataProvider.selectedScTechCodes;
              if (scTechCodes.isEmpty) {
                scTechCodes =
                    dataProvider.getDataCodeNames(AnalysisTechListType.sc);
              }

              for (var scTechCode in scTechCodes) {
                chartData = dataProvider.getChartData(
                  techListType: AnalysisTechListType.sc,
                  techCode: scTechCode,
                  country: subCategory == AnalysisSubCategory.countryDetail
                      ? chartCode
                      : null,
                  targetName: subCategory != AnalysisSubCategory.countryDetail
                      ? chartCode
                      : null,
                );

                csvContent
                    .writeln('SC,$scTechCode,${chartData.values.join(',')}');
              }
            } else {
              chartData = dataProvider.getChartData(
                techListType: dataProvider.selectedTechListType,
                techCode: techCode,
                country: category == AnalysisCategory.countryTech ||
                        (category == AnalysisCategory.techGap &&
                            subCategory == AnalysisSubCategory.countryDetail) ||
                        (category == AnalysisCategory.techAssessment &&
                            subCategory == AnalysisSubCategory.countryDetail) ||
                        (category == AnalysisCategory.techCompetition &&
                            subCategory == AnalysisSubCategory.countryDetail)
                    ? chartCode
                    : null,
                targetName: category == AnalysisCategory.companyTech ||
                        category == AnalysisCategory.academicTech ||
                        (category == AnalysisCategory.techAssessment &&
                            subCategory != AnalysisSubCategory.countryDetail) ||
                        (category == AnalysisCategory.techGap &&
                            (subCategory == AnalysisSubCategory.companyDetail ||
                                subCategory ==
                                    AnalysisSubCategory.academicDetail)) ||
                        (category == AnalysisCategory.techCompetition &&
                            subCategory != AnalysisSubCategory.countryDetail)
                    ? chartCode
                    : null,
                dataCode:
                    category == AnalysisCategory.techCompetition ? "TC" : null,
              );

              if (isFirst) {
                csvHeader.writeln(',$techCode');

                String dataCode = dataProvider.getDataCode() ?? '';
                if (dataCode != '') {
                  String yearData =
                      chartData.keys.map((key) => '${dataCode}_$key').join(',');
                  csvContent.writeln(",$yearData");
                } else {
                  String yearData = chartData.keys.join(',');
                  csvContent.writeln(",$yearData");
                }
                isFirst = false;
              }

              csvContent.writeln("$chartCode,${chartData.values.join(',')}");
            }
          }
        } else {
          chartData = dataProvider.getChartData(
            techListType: dataProvider.selectedTechListType,
            techCode: techCode,
            country: null,
            targetName: null,
          );

          if (isFirst) {
            csvHeader.writeln('');
            String dataCode = dataProvider.getDataCode() ?? '';
            if (dataCode != '') {
              String yearData =
                  chartData.keys.map((key) => '${dataCode}_$key').join(',');
              csvContent.writeln(",$yearData");
            } else {
              String yearData = chartData.keys.join(',');
              csvContent.writeln(",$yearData");
            }
            isFirst = false;
          }

          csvContent.writeln("$techCode,${chartData.values.join(',')}");
        }
      }

      // 파일 저장 위치 선택
      String? outputFile = await FilePicker.platform.saveFile(
        dialogTitle: '저장할 위치를 선택하세요',
        fileName: 'chart_data.csv',
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (outputFile != null) {
        // 파일 확장자 확인 및 추가
        if (!outputFile.toLowerCase().endsWith('.csv')) {
          outputFile = '$outputFile.csv';
        }

        // 파일 저장 - UTF-8 인코딩 적용
        final file = File(outputFile);
        // UTF-8 with BOM을 위한 바이트 배열
        final List<int> bom = [0xEF, 0xBB, 0xBF];
        final List<int> content = [
          ...bom,
          ...utf8.encode(csvHeader.toString()),
          ...utf8.encode(csvContent.toString())
        ];
        await file.writeAsBytes(content);

        // 저장 완료 다이얼로그 표시
        showDialog(
          context: globalKey.currentContext!,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('저장 완료'),
              content: Text('CSV 파일이 저장되었습니다.\n저장 위치: ${file.path}'),
              actions: <Widget>[
                TextButton(
                  child: const Text('확인'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // 에러 발생 시 다이얼로그 표시
      showDialog(
        context: globalKey.currentContext!,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('오류'),
            content: Text('CSV 파일 저장 중 오류가 발생했습니다.\n$e'),
            actions: <Widget>[
              TextButton(
                child: const Text('확인'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }
}

import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_application_data_chart_viewer/models/enum_defines.dart';
import 'package:flutter_application_data_chart_viewer/models/table_chart_data_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

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

  List<TableChartDataModel> createTestData() {
    return [
      TableChartDataModel(
        rank: 1,
        name: 'Korea',
        dataInfo: {
          TableDataType.country: 'KR',
        },
        yearDatas: {
          2018: 85.5,
          2019: 87.2,
          2020: 89.1,
          2021: 90.5,
          2022: 92.3,
        },
      ),
      TableChartDataModel(
        rank: 2,
        name: 'Japan',
        dataInfo: {
          TableDataType.country: 'JP',
        },
        yearDatas: {
          2018: 82.1,
          2019: 83.5,
          2020: 85.2,
          2021: 86.8,
          2022: 88.4,
        },
      ),
      TableChartDataModel(
        rank: 3,
        name: 'China',
        dataInfo: {
          TableDataType.country: 'CN',
        },
        yearDatas: {
          2018: 78.3,
          2019: 80.5,
          2020: 82.9,
          2021: 84.7,
          2022: 86.2,
        },
      ),
    ];
  }

  Widget saveMenuPopup({required BoxConstraints constraints}) {
    return PopupMenuButton<String>(
      offset: Offset(constraints.maxHeight * 0, constraints.maxHeight * 0.02),
      position: PopupMenuPosition.under,
      onSelected: (String value) {
        switch (value) {
          case 'PNG':
          case 'JPG':
            _handleImageExport(format: value);
            break;
          case 'SVG':
            // SVG 내보내기는 아직 구현되지 않음
            print('SVG export is not implemented yet');
            break;
          case 'CSV':
            _handleCsvExport();
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

  // GlobalKey 선언
  static final GlobalKey chartKey = GlobalKey();

  Future<void> _handleImageExport({required String format}) async {
    try {
      RenderRepaintBoundary? boundary = CommonUtils.chartKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;

      if (boundary != null) {
        showDialog(
          context: CommonUtils.chartKey.currentContext!,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        );

        final directory = await getApplicationDocumentsDirectory();
        late final File file;
        late final List<int> bytes;

        switch (format) {
          case 'PNG':
            final image = await boundary.toImage(pixelRatio: 3.0);
            final recorder = PictureRecorder();
            final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()));

            canvas.drawColor(Colors.white, BlendMode.src);
            canvas.drawImage(image, Offset.zero, Paint());

            final picture = recorder.endRecording();
            final imageWithBg = await picture.toImage(image.width, image.height);
            final byteData = await imageWithBg.toByteData(format: ImageByteFormat.png);
            bytes = byteData!.buffer.asUint8List();
            file = File('${directory.path}/chart.png');
            break;

          case 'JPG':
            final image = await boundary.toImage(pixelRatio: 3.0);
            final byteData = await image.toByteData(format: ImageByteFormat.rawRgba);
            final bytes = byteData!.buffer.asUint8List();

            // RGBA 데이터를 이미지로 변환
            final imgData = img.Image.fromBytes(
              width: image.width,
              height: image.height,
              bytes: bytes.buffer,
              numChannels: 4,
            );

            // JPG로 인코딩
            final jpgBytes = img.encodeJpg(imgData, quality: 90);

            file = File('${directory.path}/chart.jpg');
            await file.writeAsBytes(jpgBytes);
            break;

          case 'SVG':
            // SVG 변환은 별도의 라이브러리가 필요합니다
            throw UnimplementedError('SVG export is not implemented yet');
            break;

          default:
            throw UnsupportedError('Unsupported format: $format');
        }

        await file.writeAsBytes(bytes);

        if (CommonUtils.chartKey.currentContext != null) {
          Navigator.of(CommonUtils.chartKey.currentContext!).pop();
        }

        if (CommonUtils.chartKey.currentContext != null) {
          showDialog(
            context: CommonUtils.chartKey.currentContext!,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('저장 완료'),
                content: Text('차트가 $format 형식으로 저장되었습니다.\n저장 위치: ${file.path}'),
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
    } catch (e) {
      if (CommonUtils.chartKey.currentContext != null) {
        Navigator.of(CommonUtils.chartKey.currentContext!).pop();
      }

      if (CommonUtils.chartKey.currentContext != null) {
        showDialog(
          context: CommonUtils.chartKey.currentContext!,
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
      print('Error saving chart: $e');
    }
  }

  void _handleCsvExport() {
    // CSV 내보내기 로직 구현
    print('Exporting as CSV...');
  }
}

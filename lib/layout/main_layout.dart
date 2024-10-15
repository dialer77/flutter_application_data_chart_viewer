import 'package:flutter/material.dart';

class MainLayout extends StatelessWidget {
  final Widget child;

  const MainLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: Container(
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Container(
                  color: const Color.fromARGB(255, 37, 52, 103),
                  child: Center(
                    child: Image.asset(
                      'assets/images/logo_amur_white_full.png', // 이미지 경로를 실제 경로로 변경하세요
                      height: 40, // 이미지 높이 조정
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  color: const Color.fromARGB(255, 0, 32, 96),
                  child: const Center(
                    child: Text(
                      '데이터 시각화 프로그램',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2, // 기본 공간
                child: Container(
                  color: const Color.fromARGB(255, 37, 52, 103),
                ),
              ),
            ],
          ),
        ),
      ),
      body: child,
      bottomNavigationBar: Container(
        height: 80, // 원하는 높이로 조정
        color: const Color.fromARGB(255, 37, 52, 103),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Text(
                'FRONTIER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24, // 글자 크기 조정
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 16.0,
              bottom: 16.0, // 아래쪽 여백 추가
              child: Text(
                'Big Data Solution',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // 글자 크기 조정
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

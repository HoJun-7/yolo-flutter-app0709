import 'package:flutter/material.dart';
// ✅ ClinicsMapScreen 임포트 추가
// 이 경로는 실제 프로젝트 구조에 따라 달라질 수 있습니다.
// 'package:ultralytics_yolo_example/presentation/screens/clinics_map_screen.dart'
// 또는 상대 경로:
import 'clinics_map_screen.dart'; 

class ClinicsScreen extends StatelessWidget {
  const ClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('주변 치과')),
      body: const ClinicsMapScreen(), // ✅ ClinicsMapScreen 위젯으로 교체
    );
  }
}

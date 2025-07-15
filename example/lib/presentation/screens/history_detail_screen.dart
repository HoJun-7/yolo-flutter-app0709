import 'package:flutter/material.dart';
import '../model/diagnosis_record.dart'; // DiagnosisRecord 모델 import

class HistoryDetailScreen extends StatelessWidget {
  final DiagnosisRecord record;

  const HistoryDetailScreen({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    // 콘솔에 이미지 URL 출력
    print('🟢 원본 이미지 URL: ${record.originalImagePath}');
    print('🟢 진단 결과 이미지 URL: ${record.processedImagePath}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 상세'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context), // ⬅ 뒤로가기
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('사용자 ID: ${record.userId}'),
              Text('파일명: ${record.fileName}'),
              Text('진단 시각: ${record.timestamp.toLocal().toString().substring(0, 16)}'),
              const SizedBox(height: 20),
              const Text('원본 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.network(
                record.originalImagePath,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('❌ 원본 이미지를 불러올 수 없습니다.'),
              ),
              const SizedBox(height: 20),
              const Text('진단 결과 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Image.network(
                record.processedImagePath,
                errorBuilder: (context, error, stackTrace) =>
                    const Text('❌ 결과 이미지를 불러올 수 없습니다.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

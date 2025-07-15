import 'package:flutter/material.dart';

class ResultDetailScreen extends StatefulWidget {
  final String originalImageUrl;
  final Map<int, String> processedImageUrls;
  final Map<int, Map<String, dynamic>> modelInfos;

  const ResultDetailScreen({
    super.key,
    required this.originalImageUrl,
    required this.processedImageUrls,
    required this.modelInfos,
  });

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  int? _selectedModelIndex = 1; // 기본 1번 모델 선택

  void _toggleModel(int index) {
    setState(() {
      _selectedModelIndex = (_selectedModelIndex == index) ? null : index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double imageHeight = MediaQuery.of(context).size.height * 0.3;

    final String imageUrl = (_selectedModelIndex != null)
        ? widget.processedImageUrls[_selectedModelIndex!] ?? widget.originalImageUrl
        : widget.originalImageUrl;

    final modelInfo = (_selectedModelIndex != null)
        ? widget.modelInfos[_selectedModelIndex!]
        : null;

    final double? confidence = modelInfo?['confidence'];
    final String? modelName = modelInfo?['model_used'];
    final String className = "Dental Plaque"; // ✅ 추후 모델별 클래스로 변경 가능

    return Scaffold(
      appBar: AppBar(title: const Text('결과 이미지 상세 보기')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('🖼️ 표시 중인 이미지', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Image.network(imageUrl, height: imageHeight, fit: BoxFit.contain),

            const SizedBox(height: 24),
            const Text('🧪 사용할 AI 모델 선택', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [1, 2, 3].map((index) {
                return ChoiceChip(
                  label: Text("모델 $index"),
                  selected: _selectedModelIndex == index,
                  onSelected: (_) => _toggleModel(index),
                );
              }).toList(),
            ),

            const SizedBox(height: 24),
            if (modelInfo != null) ...[
              const Text('📊 모델 분석 정보', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              if (modelName != null) Text('모델: $modelName'),
              if (confidence != null) Text('확신도: ${(confidence * 100).toStringAsFixed(1)}%'),
              Text('클래스: $className'),
            ],

            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ 신청이 완료되었습니다.')),
                );
              },
              icon: const Icon(Icons.send),
              label: const Text('신청하기'),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
            ),
          ],
        ),
      ),
    );
  }
}

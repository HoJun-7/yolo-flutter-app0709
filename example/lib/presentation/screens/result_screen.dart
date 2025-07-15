import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String imageUrl;
  final Map<String, dynamic> inferenceData;

  const ResultScreen({
    super.key,
    required this.imageUrl,
    required this.inferenceData,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool showOverlay1 = true;
  bool showOverlay2 = false;
  bool showOverlay3 = false;

  @override
  Widget build(BuildContext context) {
    final String baseImageUrl = widget.imageUrl;
    final String overlayImageUrl = widget.imageUrl; // 오버레이도 같은 이미지 경로 사용

    final prediction = widget.inferenceData['prediction'] ?? '결과 없음';
    final details = widget.inferenceData['details'] ?? [];

    // 하나라도 오버레이가 켜져 있으면 오버레이 이미지 사용
    final bool useOverlay = showOverlay1 || showOverlay2 || showOverlay3;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 진단 결과'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 이미지 영역 (오버레이 적용 여부에 따라 이미지 변경)
            Expanded(
              child: Center(
                child: Image.network(
                  useOverlay ? overlayImageUrl : baseImageUrl,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 오버레이 옵션 스위치 3개
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSwitch("충치/치주염/치은염", showOverlay1, (val) {
                  setState(() => showOverlay1 = val);
                }),
                _buildSwitch("치석/보철물", showOverlay2, (val) {
                  setState(() => showOverlay2 = val);
                }),
                _buildSwitch("치아번호", showOverlay3, (val) {
                  setState(() => showOverlay3 = val);
                }),
              ],
            ),

            const SizedBox(height: 8),

            // AI 예측 결과 텍스트
            Text(
              '🔍 AI 예측 결과: $prediction',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            if (details.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                    details.length,
                    (i) => Text('・${details[i]}'),
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // 저장 및 AI 비대면 진료 버튼
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save_alt),
                    label: const Text("이미지 저장"),
                    onPressed: () {
                      // TODO: 이미지 저장 기능 구현 예정
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('이미지를 저장했습니다.')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.local_hospital),
                    label: const Text("AI 비대면 진료"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      // TODO: AI 비대면 진료 신청 기능 구현 예정
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('AI 비대면 진료 신청이 완료되었습니다.')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 라벨과 스위치가 세로로 배치된 위젯
  Widget _buildSwitch(String label, bool value, ValueChanged<bool> onChanged) {
    return Column(
      children: [
        Switch(value: value, onChanged: onChanged),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

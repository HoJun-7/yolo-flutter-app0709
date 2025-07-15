import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '/presentation/viewmodel/doctor/d_consultation_record_viewmodel.dart'; // ConsultationRecordViewModel 임포트 유지
import '/presentation/model/doctor/d_consultation_record.dart'; // ✅ ConsultationRecord 모델 임포트 다시 추가
import '/presentation/screens/doctor/d_result_detail_screen.dart'; // 상세 화면 임포트

class InferenceResultScreen extends StatefulWidget {
  final String baseUrl;

  const InferenceResultScreen({super.key, required this.baseUrl});

  @override
  State<InferenceResultScreen> createState() => _InferenceResultScreenState();
}

class _InferenceResultScreenState extends State<InferenceResultScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<ConsultationRecordViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchRecords();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ConsultationRecordViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('진단 결과 목록'),
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text('오류: ${viewModel.error}'))
              : _buildListView(viewModel.records),
    );
  }

  Widget _buildListView(List<ConsultationRecord> records) { // ConsultationRecord 타입 사용
    if (records.isEmpty) {
      return const Center(child: Text('진단 결과가 없습니다.'));
    }

    // 시간 역순으로 정렬 (가장 최신 기록이 위로 오도록)
    final sortedRecords = List<ConsultationRecord>.from(records) // ConsultationRecord 타입 사용
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // ConsultationRecord의 timestamp 사용

    // 날짜별로 인덱스를 매기기 위한 맵
    final Map<String, int> dailyIndexMap = {};

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: sortedRecords.length,
      itemBuilder: (context, index) {
        final record = sortedRecords[index];
        final timestamp = record.timestamp;
        final formattedTime = DateFormat('yyyy-MM-dd-HH-mm').format(timestamp);
        final dateKey = DateFormat('yyyyMMdd').format(timestamp);

        dailyIndexMap[dateKey] = (dailyIndexMap[dateKey] ?? 0) + 1;
        final dailyIndex = dailyIndexMap[dateKey]!;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ListTile(
            title: Text('[$dailyIndex] $formattedTime'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('사용자 ID: ${record.userId}'),
                Text('파일명: ${record.originalImageFilename}'),
                // AI 결과 및 의사 소견 표시 (선택 사항)
                if (record.aiResult != null) Text('AI 결과: ${record.aiResult}'),
                if (record.doctorOpinion != null && record.doctorOpinion!.isNotEmpty)
                  Text('의사 소견: ${record.doctorOpinion}'),
              ],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ResultDetailScreen(
                    originalImageUrl: '${widget.baseUrl}${record.originalImagePath}',
                    processedImageUrl: '${widget.baseUrl}${record.processedImagePath}',
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

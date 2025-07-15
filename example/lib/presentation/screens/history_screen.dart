import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../viewmodel/history_viewmodel.dart';
import '../model/diagnosis_record.dart';
import 'history_detail_screen.dart'; // 상세 화면 import

class HistoryScreen extends StatefulWidget {
  final String userId; // 현재는 사용 안 하지만 구조 유지
  final String baseUrl;

  const HistoryScreen({
    super.key,
    required this.userId,
    required this.baseUrl,
  });

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    final viewModel = context.read<HistoryViewModel>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      viewModel.fetchRecords(widget.baseUrl);
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HistoryViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('이전 진단 기록'),
        centerTitle: true,
      ),
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : viewModel.error != null
              ? Center(child: Text(viewModel.error!))
              : _buildRecordList(viewModel.records),
    );
  }

  Widget _buildRecordList(List<DiagnosisRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('진단 기록이 없습니다.'));
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final record = records[index];
        final displayIndex = records.length - index;

        return Card(
          color: Colors.grey[100],
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: ListTile(
            title: Text(
              '[$displayIndex] ${DateFormat('yyyy-MM-dd HH:mm').format(record.timestamp)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('사용자 ID: ${record.userId}'),
                Text('파일명: ${record.fileName}'),
              ],
            ),
            onTap: () {
              GoRouter.of(context).push('/history/detail', extra: record);
            },
          ),
        );
      },
    );
  }
}

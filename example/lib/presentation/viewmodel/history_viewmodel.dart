// lib/presentation/viewmodel/history_viewmodel.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../model/diagnosis_record.dart';

class HistoryViewModel extends ChangeNotifier {
  List<DiagnosisRecord> _records = [];
  List<DiagnosisRecord> get records => _records;

  bool isLoading = false;
  String? error;

  Future<void> fetchRecords(String baseUrl) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final url = Uri.parse('$baseUrl/inference-results');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);

        _records = jsonList
            .map((jsonItem) => DiagnosisRecord.fromJson(jsonItem, baseUrl)) // ✅ baseUrl 전달
            .toList()
            .reversed
            .toList(); // 최신순 정렬
      } else {
        error = '서버 오류: ${response.statusCode}';
      }
    } catch (e) {
      error = '네트워크 오류: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

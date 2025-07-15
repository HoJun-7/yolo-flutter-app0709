// lib/presentation/viewmodel/patient_inference_viewmodel.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p; // 'path' 패키지 임포트 시 별칭 사용
import 'package:flutter/foundation.dart' show kDebugMode;

import '/presentation/model/doctor/d_consultation_record.dart'; // ConsultationRecord 모델 임포트

class PatientInferenceViewModel with ChangeNotifier {
  final String _baseUrl;
  ConsultationRecord? _currentConsultationRecord;
  bool _isLoading = false;
  String? _errorMessage;

  PatientInferenceViewModel({required String baseUrl}) : _baseUrl = baseUrl;

  String get baseUrl => _baseUrl;
  ConsultationRecord? get currentConsultationRecord => _currentConsultationRecord;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setCurrentConsultationRecord(ConsultationRecord record) {
    _currentConsultationRecord = record;
    notifyListeners();
  }

  Future<bool> uploadImageAndGetInference({
    required File imageFile,
    required String userId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _currentConsultationRecord = null;
    notifyListeners();

    final uri = Uri.parse('$_baseUrl/inference/image');
    final request = http.MultipartRequest('POST', uri)
      ..fields['user_id'] = userId
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path,
          filename: p.basename(imageFile.path)));

    try {
      final response = await request.send(); // StreamedResponse 반환

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString(); // StreamedResponse는 .stream 사용
        final Map<String, dynamic> data = json.decode(responseBody);
        final ConsultationRecord record = ConsultationRecord.fromJson(data);

        _currentConsultationRecord = record;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorBody = await response.stream.bytesToString(); // StreamedResponse는 .stream 사용
        _errorMessage = '업로드 실패: ${response.statusCode} - $errorBody';
        if (kDebugMode) {
          print('Image upload failed: Status ${response.statusCode}, Body: $errorBody');
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      if (kDebugMode) {
        print('Network error during image upload: $e');
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDoctorOpinion(String recordId, String opinion) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.post( // http.post는 Response 객체 반환
        Uri.parse('$_baseUrl/inference-results/$recordId/opinion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'doctor_opinion': opinion}),
      );

      if (response.statusCode == 200) {
        if (_currentConsultationRecord?.id == recordId) {
          _currentConsultationRecord = _currentConsultationRecord?.copyWith(doctorOpinion: opinion);
        }
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final errorBody = response.body; // http.post의 Response 객체는 .body 사용
        _errorMessage = '소견 업데이트 실패: ${response.statusCode} - $errorBody';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}

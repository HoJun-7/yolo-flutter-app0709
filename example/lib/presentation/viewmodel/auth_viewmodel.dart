import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kDebugMode;
import '/presentation/model/user.dart'; // ✅ user.dart 모델 임포트

class AuthViewModel with ChangeNotifier {
  final String _baseUrl;
  String? _errorMessage;
  String? duplicateCheckErrorMessage;
  bool isCheckingUserId = false;
  User? _currentUser; // 이제 user.dart의 User 모델 사용
  bool _isLoading = false; // ✅ isLoading 상태 추가

  AuthViewModel({required String baseUrl}) : _baseUrl = baseUrl;

  String? get errorMessage => _errorMessage;
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading; // ✅ isLoading getter 추가

  // ✅ isLoggedIn getter 추가
  bool get isLoggedIn => _currentUser != null;

  Future<bool?> checkUserIdDuplicate(String userId, String role) async {
    isCheckingUserId = true;
    duplicateCheckErrorMessage = null;
    notifyListeners();

    try {
      // 💡 수정: '/api' 접두사 추가
      final res = await http.get(Uri.parse('$_baseUrl/api/auth/check-username?username=$userId&role=$role'));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        return data['exists'] == true;
      } else {
        String message = '서버 응답 오류 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _errorMessage = '아이디 중복검사 서버 응답 오류: $message';
        if (kDebugMode) {
          print(_errorMessage);
        }
        notifyListeners();
        return null;
      }
    } catch (e) {
      _errorMessage = '아이디 중복검사 중 네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print(_errorMessage);
      }
      notifyListeners();
      return null;
    } finally {
      isCheckingUserId = false;
      notifyListeners();
    }
  }

  void clearDuplicateCheckErrorMessage() {
    duplicateCheckErrorMessage = null;
    notifyListeners();
  }

  Future<String?> registerUser(Map<String, dynamic> userData) async {
    _errorMessage = null;
    _isLoading = true; // 로딩 시작
    notifyListeners();

    try {
      // 💡 수정: '/api' 접두사 추가
      final res = await http.post(
        Uri.parse('$_baseUrl/api/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );

      if (res.statusCode == 201) {
        _errorMessage = null; // 성공 시 에러 메시지 초기화
        return null; // 성공 시 null 반환
      } else {
        String message = '회원가입 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _errorMessage = '회원가입 실패: $message';
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print('회원가입 중 네트워크 오류: $e');
      }
      return _errorMessage;
    } finally {
      _isLoading = false; // 로딩 종료
      notifyListeners();
    }
  }

  // ✅ loginUser 메서드 통합 및 수정 (이전 답변에서 이미 수정됨)
  Future<User?> loginUser(String registerId, String password, String role) async {
    _isLoading = true; // 로딩 시작
    _errorMessage = null;
    notifyListeners();

    try {
      // 💡 수정: '/api' 접두사 추가
      final res = await http.post(
        Uri.parse('$_baseUrl/api/auth/login'), // <-- 여기에 /api 추가
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'register_id': registerId, 'password': password, 'role': role}),
      );

      if (res.statusCode == 200) {
        final dynamic decodedBody = jsonDecode(res.body);
        if (decodedBody is Map && decodedBody.containsKey('user') && decodedBody['user'] is Map) {
          _currentUser = User.fromJson(decodedBody['user'] as Map<String, dynamic>);
          _errorMessage = null; // 성공 시 에러 메시지 초기화
          if (kDebugMode) {
            print('로그인 성공! 수신된 사용자 역할 (role): ${_currentUser?.role}');
            print('isDoctor 평가 결과: ${_currentUser?.isDoctor}');
          }
          return _currentUser;
        } else {
          _errorMessage = '로그인 실패: 서버 응답 형식이 올바르지 않습니다.';
          return null;
        }
      } else {
        String message = '로그인 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _errorMessage = '로그인 실패: $message';
        return null;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print('로그인 중 네트워크 오류: $e');
      }
      return null;
    } finally {
      _isLoading = false; // 로딩 종료
      notifyListeners();
    }
  }

  // ✅ deleteUser 메서드 추가 (MyPageScreen에서 사용)
  Future<String?> deleteUser(String registerId, String password, String? role) async {
    _isLoading = true; // 로딩 시작
    _errorMessage = null;
    notifyListeners();

    try {
      // 💡 수정: '/api' 접두사 추가
      final res = await http.delete(
        Uri.parse('$_baseUrl/api/auth/delete_account'), // <-- 여기에 /api 추가
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': registerId, 'password': password, 'role': role}),
      );

      if (res.statusCode == 200) {
        _errorMessage = null; // 성공 시 에러 메시지 초기화
        _currentUser = null; // 계정 삭제 성공 시 현재 사용자 정보 초기화
        debugPrint('회원 탈퇴 성공!');
        return null; // 성공 시 null 반환
      } else {
        String message = '회원 탈퇴 실패 (Status: ${res.statusCode})';
        try {
          final decodedBody = json.decode(res.body);
          if (decodedBody is Map && decodedBody.containsKey('message')) {
            message = decodedBody['message'] as String;
          }
        } catch (e) {
          // Body was not valid JSON
        }
        _errorMessage = message;
        debugPrint('회원 탈퇴 실패: $_errorMessage');
        return _errorMessage;
      }
    } catch (e) {
      _errorMessage = '네트워크 오류: ${e.toString()}';
      if (kDebugMode) {
        print('회원 탈퇴 중 네트워크 오류: $e');
      }
      return _errorMessage;
    } finally {
      _isLoading = false; // 로딩 종료
      notifyListeners();
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null; // 로그아웃 시 에러 메시지 초기화
    notifyListeners();
    debugPrint('로그아웃됨');
  }
}

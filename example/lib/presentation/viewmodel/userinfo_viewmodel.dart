import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider 사용을 위해 추가
import '/presentation/model/user.dart'; // User 모델 임포트
import '/presentation/viewmodel/auth_viewmodel.dart'; // AuthViewModel 임포트 (fetchUserInfo에서 활용)

class UserInfoViewModel extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // AuthViewModel 인스턴스를 주입받도록 생성자 수정
  final AuthViewModel _authViewModel; // 주입받은 AuthViewModel 인스턴스

  UserInfoViewModel({required AuthViewModel authViewModel}) : _authViewModel = authViewModel;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // ✅ loadUser 메서드 추가 (LoginScreen에서 사용)
  void loadUser(User user) {
    _user = user;
    notifyListeners();
    debugPrint('UserInfoViewModel: loadUser 호출됨, 사용자 ID: ${user.id}');
  }

  // ✅ fetchUserInfo 메서드 수정
  // 이 메서드는 주입받은 AuthViewModel의 currentUser를 기반으로 사용자 정보를 로드합니다.
  Future<void> fetchUserInfo() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // ✅ 주입받은 _authViewModel 인스턴스를 사용하여 currentUser에 접근
      if (_authViewModel.currentUser != null) {
        _user = _authViewModel.currentUser; // AuthViewModel에서 가져온 사용자 정보 할당
        _errorMessage = null;
        debugPrint('UserInfoViewModel: fetchUserInfo 성공: ${_user?.id}');
      } else {
        _errorMessage = '로그인된 사용자 정보가 없습니다.';
        debugPrint('UserInfoViewModel: fetchUserInfo 실패: 로그인된 사용자 정보 없음');
      }
    } catch (e) {
      _errorMessage = '사용자 정보 로드 실패: $e';
      debugPrint('UserInfoViewModel: 사용자 정보 로드 중 오류 발생: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 사용자 정보 업데이트 (필요 시)
  void updateUserInfo(User newUser) {
    _user = newUser;
    notifyListeners();
  }

  // 사용자 정보 초기화 (로그아웃 시 등)
  void clearUser() {
    _user = null;
    notifyListeners();
    debugPrint('UserInfoViewModel: clearUser 호출됨');
  }
}

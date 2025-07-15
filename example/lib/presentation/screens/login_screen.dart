import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '/presentation/viewmodel/auth_viewmodel.dart'; // AuthViewModel 임포트
import '/presentation/viewmodel/userinfo_viewmodel.dart'; // UserInfoViewModel 임포트
import '/presentation/model/user.dart'; // User 모델 임포트

class LoginScreen extends StatefulWidget {
  final String baseUrl;

  const LoginScreen({
    super.key,
    required this.baseUrl,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController(); // registerIdController 대신 _idController 사용
  final TextEditingController _passwordController = TextEditingController(); // passwordController 대신 _passwordController 사용
  String _selectedRole = 'P';

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Provider.of를 사용하여 AuthViewModel과 UserInfoViewModel을 가져옵니다.
    // listen: true로 설정하여 ViewModel의 변경 사항에 UI가 반응하도록 합니다.
    final authViewModel = Provider.of<AuthViewModel>(context);
    final userInfoViewModel = Provider.of<UserInfoViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('로그인')),
      body: Padding(
        padding: const EdgeInsets.all(24.0), // 패딩 통일
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                const Text('사용자 유형:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 10),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('환자'),
                    value: 'P',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('의사'),
                    value: 'D',
                    groupValue: _selectedRole,
                    onChanged: (value) => setState(() => _selectedRole = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idController, // registerIdController 대신 _idController 사용
              decoration: const InputDecoration(labelText: '아이디'),
            ),
            TextField(
              controller: _passwordController, // passwordController 대신 _passwordController 사용
              obscureText: true,
              decoration: const InputDecoration(labelText: '비밀번호'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              // ✅ onPressed에 직접 로직을 넣어 authViewModel.isLoading을 활용
              onPressed: authViewModel.isLoading
                  ? null // 로딩 중일 때는 버튼 비활성화
                  : () async {
                      final String id = _idController.text.trim();
                      final String password = _passwordController.text.trim();
                      final String role = _selectedRole;

                      if (id.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요')),
                        );
                        return;
                      }

                      debugPrint('로그인 시도: ID=$id, Role=$role');

                      User? loggedInUser = await authViewModel.loginUser(id, password, role);

                      if (loggedInUser != null) {
                        // ✅ 로그인 성공 시 UserInfoViewModel에 사용자 정보 로드
                        userInfoViewModel.loadUser(loggedInUser);
                        debugPrint('로그인 성공. 사용자 역할: ${loggedInUser.role}');
                        if (loggedInUser.isDoctor) {
                          context.go('/d_home', extra: widget.baseUrl);
                        } else {
                          context.go('/home', extra: {'userId': loggedInUser.id, 'baseUrl': widget.baseUrl});
                        }
                      } else {
                        // 로그인 실패 시 AuthViewModel의 errorMessage를 사용
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(authViewModel.errorMessage ?? '로그인 실패')),
                        );
                        debugPrint('로그인 실패: ${authViewModel.errorMessage ?? "알 수 없는 오류"}');
                      }
                    },
              child: authViewModel.isLoading
                  ? const CircularProgressIndicator(color: Colors.white) // 로딩 중일 때 인디케이터 표시
                  : const Text('로그인'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => context.go('/register'),
              child: const Text('회원가입 하기'),
            ),
            // ✅ 에러 메시지 표시 (AuthViewModel의 errorMessage 사용)
            if (authViewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  authViewModel.errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

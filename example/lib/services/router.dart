import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ✅ 필요한 화면들 임포트
import '/presentation/screens/doctor/d_home_screen.dart';
import '/presentation/screens/doctor/d_inference_result_screen.dart';
import '/presentation/screens/doctor/d_appointment_screen.dart'; // 정확한 클래스명 import
import '/presentation/screens/main_scaffold.dart';
import '/presentation/screens/login_screen.dart';
import '/presentation/screens/register_screen.dart';
import '/presentation/screens/home_screen.dart';
import '/presentation/screens/camera_inference_screen.dart';
import '/presentation/screens/web_placeholder_screen.dart';

// 하단 탭 바 화면들
import '/presentation/screens/chatbot_screen.dart';
import '/presentation/screens/mypage_screen.dart';
import '/presentation/screens/upload_screen.dart';
import '/presentation/screens/history_screen.dart';
import '/presentation/screens/history_detail_screen.dart';
import '/presentation/screens/clinics_screen.dart';
import '/presentation/screens/result_screen.dart'; // 결과 화면

import '/presentation/model/diagnosis_record.dart';

GoRouter createRouter(String baseUrl) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(baseUrl: baseUrl),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/web',
        builder: (context, state) => const WebPlaceholderScreen(),
      ),
      GoRoute(
        path: '/d_home',
        builder: (context, state) {
          final passedBaseUrl = state.extra as String? ?? baseUrl;
          return DoctorHomeScreen(baseUrl: passedBaseUrl);
        },
      ),

      // 수정된 부분: 정확한 화면 클래스명 사용
      GoRoute(
        path: '/d_appointments',
        builder: (context, state) => const DoctorAppointmentScreen(),
      ),

      GoRoute(
        path: '/result',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>? ?? {};
          final imageUrl = data['imageUrl'] as String? ?? '';
          final inferenceData = data['inferenceData'] as Map<String, dynamic>? ?? {};
          return ResultScreen(
            imageUrl: imageUrl,
            inferenceData: inferenceData,
          );
        },
      ),

      ShellRoute(
        builder: (context, state, child) {
          return MainScaffold(
            child: child,
            currentLocation: state.uri.toString(),
          );
        },
        routes: [
          GoRoute(
            path: '/chatbot',
            builder: (context, state) => const ChatbotScreen(),
          ),
          GoRoute(
            path: '/home',
            builder: (context, state) {
              final authViewModelExtra = state.extra as Map<String, dynamic>?;
              final userId = (authViewModelExtra?['userId'] as int?)?.toString() ?? 'guest';
              return HomeScreen(baseUrl: baseUrl, userId: userId);
            },
          ),
          GoRoute(
            path: '/mypage',
            builder: (context, state) => const MyPageScreen(),
          ),
          GoRoute(
            path: '/upload',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              final userId = data['userId'] ?? 'guest';
              final passedBaseUrl = data['baseUrl'] ?? baseUrl;
              return UploadScreen(
                userId: userId,
                baseUrl: passedBaseUrl,
              );
            },
          ),
          GoRoute(
            path: '/diagnosis/realtime',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return CameraInferenceScreen(
                baseUrl: data['baseUrl'] ?? '',
                userId: data['userId'] ?? 'guest',
              );
            },
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              final userId = data['userId'] ?? 'guest';
              final passedBaseUrl = data['baseUrl'] ?? 'http://192.168.0.19:5000/api'; // 기본값도 지정 가능

              return HistoryScreen(
                userId: userId,
                baseUrl: passedBaseUrl,
              );
            },
          ),
          GoRoute(
            path: '/history/detail',
            builder: (context, state) {
              final record = state.extra as DiagnosisRecord;
              return HistoryDetailScreen(record: record);
            },
          ),
          GoRoute(
            path: '/clinics',
            builder: (context, state) => const ClinicsScreen(),
          ),
          GoRoute(
            path: '/camera',
            builder: (context, state) {
              final data = state.extra as Map<String, dynamic>? ?? {};
              return CameraInferenceScreen(
                baseUrl: data['baseUrl'] ?? '',
                userId: data['userId'] ?? 'guest',
              );
            },
          ),
        ],
      ),
    ],
  );
}

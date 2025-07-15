import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// 기존 임포트
import 'presentation/viewmodel/userinfo_viewmodel.dart';
import 'services/router.dart';
import '/presentation/screens/doctor/d_home_screen.dart';
import '/presentation/viewmodel/doctor/d_consultation_record_viewmodel.dart';
import '/presentation/viewmodel/auth_viewmodel.dart';
import '/presentation/viewmodel/doctor/d_patient_viewmodel.dart';
import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart';
import '/presentation/viewmodel/chatbot_viewmodel.dart';
import '/presentation/viewmodel/patient_inference_viewmodel.dart';
import 'package:ultralytics_yolo_example/presentation/viewmodel/history_viewmodel.dart';
import 'package:ultralytics_yolo_example/presentation/viewmodel/clinics_viewmodel.dart';

// 새로 추가한 AppointmentViewModel 임포트
import 'presentation/viewmodel/appointment_viewmodel.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");

  const String globalBaseUrl = "http://192.168.0.19:5000/";

  final String? geminiApiKey = dotenv.env['GEMINI_API_KEY'];
  if (geminiApiKey == null || geminiApiKey.isEmpty) {
    throw Exception('❌ GEMINI_API_KEY not found in .env file or is empty');
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (context) => UserInfoViewModel(
            authViewModel: Provider.of<AuthViewModel>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorDashboardViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => DPatientViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => ConsultationRecordViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => ChatbotViewModel(apiKey: geminiApiKey, baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => PatientInferenceViewModel(baseUrl: globalBaseUrl),
        ),
        ChangeNotifierProvider(
          create: (_) => HistoryViewModel(),
        ),
        ChangeNotifierProvider(
          create: (_) => ClinicsViewModel(),
        ),
        // AppointmentViewModel 추가
        ChangeNotifierProvider(
          create: (_) => AppointmentViewModel(),
        ),
      ],
      child: YOLOExampleApp(baseUrl: globalBaseUrl),
    ),
  );
}

class YOLOExampleApp extends StatelessWidget {
  final String baseUrl;

  const YOLOExampleApp({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'YOLO Plugin Example',
      debugShowCheckedModeBanner: false,
      routerConfig: createRouter(baseUrl),
      theme: ThemeData(
        primaryColor: const Color(0xFF42A5F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF42A5F5),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF42A5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF42A5F5),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}

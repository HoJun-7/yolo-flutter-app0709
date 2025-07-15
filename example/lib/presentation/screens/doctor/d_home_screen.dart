import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '/presentation/viewmodel/auth_viewmodel.dart';
import '/presentation/screens/doctor/d_patient_list_screen.dart';
import '/presentation/screens/doctor/d_inference_result_screen.dart';
import '/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart';
import '/presentation/screens/doctor/d_appointment_screen.dart';

// DoctorMenu enum은 d_dashboard_viewmodel.dart에서 임포트됨

class DoctorHomeScreen extends StatelessWidget {
  final String baseUrl;

  const DoctorHomeScreen({super.key, required this.baseUrl});

  @override
  Widget build(BuildContext context) {
    final dashboardViewModel = context.watch<DoctorDashboardViewModel>();
    final authViewModel = context.read<AuthViewModel>();
    final currentUser = authViewModel.currentUser;

    if (kDebugMode) {
      print('--- DoctorHomeScreen rebuild cycle START ---');
      print('Current User (at build start): $currentUser');
      print('Is Current User Doctor (at build start): ${currentUser?.isDoctor}');
    }

    if (currentUser == null) {
      if (kDebugMode) {
        print('DoctorHomeScreen: currentUser is NULL. Showing access denied message.');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login'); // 로그인 화면으로 강제 이동
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!currentUser.isDoctor) {
      if (kDebugMode) {
        print('DoctorHomeScreen: currentUser is NOT a doctor. Showing access denied message.');
      }
      return const Scaffold(
        body: Center(child: Text('의사 계정으로 로그인해야 환자 목록을 볼 수 있습니다.')),
      );
    }

    if (kDebugMode) {
      print('DoctorHomeScreen: currentUser is valid and is a doctor. Proceeding to main content.');
      print('--- DoctorHomeScreen rebuild cycle END ---');
    }

    Widget mainContent;
    switch (dashboardViewModel.selectedMenu) {
      case DoctorMenu.inferenceResult:
        mainContent = InferenceResultScreen(baseUrl: baseUrl);
        break;
      case DoctorMenu.calendar:
        mainContent = const DoctorAppointmentScreen();
        break;
      case DoctorMenu.patientList:
        mainContent = const PatientListScreen();
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TOOTH AI',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              authViewModel.logout();
              context.go('/login');
            },
          ),
        ],
      ),
      body: mainContent,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: dashboardViewModel.selectedIndex,
        onTap: (index) {
          if (kDebugMode) {
            print('BottomNavigationBar tapped: index = $index');
            print('AuthViewModel currentUser before tab switch: ${authViewModel.currentUser?.isDoctor}');
          }
          dashboardViewModel.setSelectedIndex(index);
        },
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: '환자 현황',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: '예약 현황',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_alt),
            label: '환자 목록',
          ),
        ],
      ),
    );
  }
}

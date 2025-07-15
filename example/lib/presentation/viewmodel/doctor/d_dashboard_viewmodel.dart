// lib/presentation/viewmodel/doctor/d_dashboard_viewmodel.dart
import 'package:flutter/material.dart';

/// 의사 대시보드의 메뉴 항목을 정의하는 열거형 (Enum).
/// 각 항목은 대시보드의 특정 탭 또는 화면에 해당합니다.
enum DoctorMenu {
  inferenceResult, // 진단 결과 화면
  calendar,        // 진료 캘린더 화면
  patientList      // 환자 목록 화면
}

/// 의사 대시보드의 상태(선택된 메뉴/탭)를 관리하는 ViewModel.
/// ChangeNotifier를 상속받아 UI에 상태 변경을 알릴 수 있습니다.
class DoctorDashboardViewModel with ChangeNotifier {
  // 현재 선택된 메뉴의 인덱스를 저장하는 private 변수.
  // 기본값은 0 (inferenceResult)입니다.
  int _selectedIndex = 0;

  /// 현재 선택된 메뉴의 인덱스를 반환합니다.
  int get selectedIndex => _selectedIndex;

  /// 현재 선택된 DoctorMenu 열거형 값을 반환합니다.
  DoctorMenu get selectedMenu {
    // _selectedIndex 값에 따라 해당하는 DoctorMenu 값을 반환합니다.
    switch (_selectedIndex) {
      case 0:
        return DoctorMenu.inferenceResult;
      case 1:
        return DoctorMenu.calendar;
      case 2:
        return DoctorMenu.patientList;
      default:
        // 정의되지 않은 인덱스인 경우 기본값으로 진단 결과 반환
        return DoctorMenu.inferenceResult;
    }
  }

  /// 선택된 메뉴의 인덱스를 업데이트하고, UI에 변경을 알립니다.
  /// [index]는 새로 선택할 메뉴의 인덱스입니다.
  void setSelectedIndex(int index) {
    // 인덱스가 유효한 범위 내에 있는지 확인 (선택적)
    if (index >= 0 && index < DoctorMenu.values.length) {
      _selectedIndex = index;
      notifyListeners(); // 이 메서드를 호출하여 이 ViewModel을 구독하는 모든 위젯에 변경 사항을 알립니다.
    }
  }
}

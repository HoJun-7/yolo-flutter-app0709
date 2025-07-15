import 'package:flutter/material.dart';
import 'package:ultralytics_yolo_example/models/appointment.dart';

class AppointmentViewModel extends ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  List<Appointment> get appointments => _appointments;
  bool get isLoading => _isLoading;

  Future<void> fetchAppointments() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // 모의 딜레이

    _appointments = [
      Appointment(
        id: '1',
        patientName: '홍길동',
        date: DateTime.now(),
        description: '일반 진료',
      ),
      Appointment(
        id: '2',
        patientName: '김철수',
        date: DateTime.now().add(const Duration(days: 1)),
        description: '추가 상담',
      ),
    ];

    _isLoading = false;
    notifyListeners();
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void removeAppointment(String id) {
    _appointments.removeWhere((appt) => appt.id == id);
    notifyListeners();
  }
}

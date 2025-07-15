import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:ultralytics_yolo_example/presentation/viewmodel/appointment_viewmodel.dart';
import 'package:ultralytics_yolo_example/models/appointment.dart';

class DoctorAppointmentScreen extends StatefulWidget {
  const DoctorAppointmentScreen({super.key});

  @override
  State<DoctorAppointmentScreen> createState() => _DoctorAppointmentScreenState();
}

class _DoctorAppointmentScreenState extends State<DoctorAppointmentScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late TextEditingController nameController;
  late TextEditingController descController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    descController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentViewModel>().fetchAppointments();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    descController.dispose();
    super.dispose();
  }

  List<Appointment> _getAppointmentsForDay(DateTime day, List<Appointment> all) {
    return all.where((a) =>
      a.date.year == day.year &&
      a.date.month == day.month &&
      a.date.day == day.day
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appointmentVM = context.watch<AppointmentViewModel>();
    final appointmentsForSelectedDay = _selectedDay == null
        ? []
        : _getAppointmentsForDay(_selectedDay!, appointmentVM.appointments);

    return Scaffold(
      appBar: AppBar(
        title: const Text('예약 현황'),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2023, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            ),
          ),
          Expanded(
            child: appointmentVM.isLoading
                ? const Center(child: CircularProgressIndicator())
                : appointmentsForSelectedDay.isEmpty
                    ? const Center(child: Text('선택한 날짜에 예약이 없습니다.'))
                    : ListView.builder(
                        itemCount: appointmentsForSelectedDay.length,
                        itemBuilder: (context, index) {
                          final appt = appointmentsForSelectedDay[index];
                          return ListTile(
                            title: Text(appt.patientName),
                            subtitle: Text(appt.description),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => appointmentVM.removeAppointment(appt.id),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_selectedDay == null) return;
          _showAddDialog(context, _selectedDay!);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddDialog(BuildContext context, DateTime selectedDate) {
    nameController.clear();
    descController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('예약 추가'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: '환자 이름')),
            TextField(controller: descController, decoration: const InputDecoration(labelText: '내용')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          ElevatedButton(
            onPressed: () {
              if(nameController.text.trim().isEmpty || descController.text.trim().isEmpty){
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('모든 필드를 입력해주세요.')),
                );
                return;
              }
              final newAppt = Appointment(
                id: DateTime.now().millisecondsSinceEpoch.toString(),
                patientName: nameController.text.trim(),
                date: selectedDate,
                description: descController.text.trim(),
              );
              context.read<AppointmentViewModel>().addAppointment(newAppt);
              Navigator.pop(context);
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }
}

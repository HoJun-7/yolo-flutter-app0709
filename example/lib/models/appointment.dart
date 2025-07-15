class Appointment {
  final String id;
  final String patientName;
  final DateTime date;
  final String description;

  Appointment({
    required this.id,
    required this.patientName,
    required this.date,
    required this.description,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['_id'] ?? '',
      patientName: json['patientName'],
      date: DateTime.parse(json['date']),
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patientName': patientName,
      'date': date.toIso8601String(),
      'description': description,
    };
  }
}

class AppointmentModel {
  final String id;
  final String doctorId;
  final String patientId;
  final String doctorName;
  final String patientName;
  final DateTime dateTime;
  final String status; // 'upcoming', 'completed', 'cancelled', 'rescheduled'
  final String? reason;
  final String? notes;
  final DateTime createdAt;
  final Map<String, dynamic>? location; // For geolocation
  final bool isEmergency;

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.doctorName,
    required this.patientName,
    required this.dateTime,
    required this.status,
    this.reason,
    this.notes,
    required this.createdAt,
    this.location,
    this.isEmergency = false,
    String? specialty,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'doctorName': doctorName,
      'patientName': patientName,
      'dateTime': dateTime.toIso8601String(),
      'status': status,
      'reason': reason,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'location': location,
      'isEmergency': isEmergency,
    };
  }

  factory AppointmentModel.fromMap(Map<String, dynamic> map) {
    return AppointmentModel(
      id: map['id'] ?? '',
      doctorId: map['doctorId'] ?? '',
      patientId: map['patientId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      patientName: map['patientName'] ?? '',
      dateTime: DateTime.parse(map['dateTime']),
      status: map['status'] ?? '',
      reason: map['reason'],
      notes: map['notes'],
      createdAt: DateTime.parse(map['createdAt']),
      location: map['location'],
      isEmergency: map['isEmergency'] ?? false,
    );
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? patientId,
    String? doctorName,
    String? patientName,
    DateTime? dateTime,
    String? status,
    String? reason,
    String? notes,
    DateTime? createdAt,
    Map<String, dynamic>? location,
    bool? isEmergency,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      patientId: patientId ?? this.patientId,
      doctorName: doctorName ?? this.doctorName,
      patientName: patientName ?? this.patientName,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      location: location ?? this.location,
      isEmergency: isEmergency ?? this.isEmergency,
    );
  }
}

class EmergencyModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String reason;
  final DateTime timestamp;
  final String status; // 'active', 'resolved'
  final List<String> affectedAppointments;

  EmergencyModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.reason,
    required this.timestamp,
    required this.status,
    required this.affectedAppointments,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
      'affectedAppointments': affectedAppointments,
    };
  }

  factory EmergencyModel.fromMap(Map<String, dynamic> map) {
    return EmergencyModel(
      id: map['id'] ?? '',
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      reason: map['reason'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      status: map['status'] ?? '',
      affectedAppointments: List<String>.from(map['affectedAppointments'] ?? []),
    );
  }
} 
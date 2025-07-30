class MedicalRecordModel {
  final String id;
  final String patientId;
  final String patientName;
  final String? doctorId;
  final String? doctorName;
  final DateTime date;
  final String type; // 'diagnosis', 'prescription', 'test_result'
  final String title;
  final String description;
  final List<String>? attachments; // URLs to uploaded files
  final Map<String, dynamic>? metadata; // Additional data like test values, medication dosage, etc.
  final DateTime createdAt;

  MedicalRecordModel({
    required this.id,
    required this.patientId,
    required this.patientName,
    this.doctorId,
    this.doctorName,
    required this.date,
    required this.type,
    required this.title,
    required this.description,
    this.attachments,
    this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'patientName': patientName,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'date': date.toIso8601String(),
      'type': type,
      'title': title,
      'description': description,
      'attachments': attachments,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory MedicalRecordModel.fromMap(Map<String, dynamic> map) {
    return MedicalRecordModel(
      id: map['id'] ?? '',
      patientId: map['patientId'] ?? '',
      patientName: map['patientName'] ?? '',
      doctorId: map['doctorId'],
      doctorName: map['doctorName'],
      date: DateTime.parse(map['date']),
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      attachments: map['attachments'] != null 
          ? List<String>.from(map['attachments'])
          : null,
      metadata: map['metadata'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
} 
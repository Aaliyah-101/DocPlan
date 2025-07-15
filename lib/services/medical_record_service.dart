import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_record_model.dart';

class MedicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new medical record
  Future<void> createMedicalRecord(MedicalRecordModel record) async {
    await _firestore
        .collection('medical_records')
        .doc(record.id)
        .set(record.toMap());
  }

  // Get medical records for a patient
  Stream<List<MedicalRecordModel>> getPatientMedicalRecords(String patientId) {
    return _firestore
        .collection('medical_records')
        .where('patientId', isEqualTo: patientId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicalRecordModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Get medical records by doctor
  Stream<List<MedicalRecordModel>> getDoctorMedicalRecords(String doctorId) {
    return _firestore
        .collection('medical_records')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MedicalRecordModel.fromMap(doc.data()))
              .toList(),
        );
  }

  // Search medical records by patient name or email
  Future<List<MedicalRecordModel>> searchMedicalRecords(
    String searchTerm,
  ) async {
    // First, find patients matching the search term
    final userQuery = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'patient')
        .where('name', isGreaterThanOrEqualTo: searchTerm)
        .where('name', isLessThan: '$searchTerm\uf8ff')
        .get();

    final patientIds = userQuery.docs.map((doc) => doc.id).toList();

    if (patientIds.isEmpty) return [];

    // Then get medical records for those patients
    final recordsQuery = await _firestore
        .collection('medical_records')
        .where('patientId', whereIn: patientIds)
        .orderBy('date', descending: true)
        .get();

    return recordsQuery.docs
        .map((doc) => MedicalRecordModel.fromMap(doc.data()))
        .toList();
  }

  // Update a medical record
  Future<void> updateMedicalRecord(MedicalRecordModel record) async {
    await _firestore
        .collection('medical_records')
        .doc(record.id)
        .update(record.toMap());
  }

  // Delete a medical record
  Future<void> deleteMedicalRecord(String recordId) async {
    await _firestore.collection('medical_records').doc(recordId).delete();
  }
}

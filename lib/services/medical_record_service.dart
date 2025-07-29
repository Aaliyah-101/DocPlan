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
    if (searchTerm.trim().isEmpty) return [];

    print('DEBUG: Searching medical records for term: "$searchTerm"');

    // Use fallback method by default to avoid index issues
    return await _searchMedicalRecordsFallback(searchTerm);
    
    // Uncomment this section once indexes are created
    /*
    try {
      // First, find patients matching the search term
      final userQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .where('name', isGreaterThanOrEqualTo: searchTerm.trim())
          .where('name', isLessThan: '${searchTerm.trim()}\uf8ff')
          .get();

      final patientIds = userQuery.docs.map((doc) => doc.id).toList();
      print('DEBUG: Found ${patientIds.length} patients matching search term');

      if (patientIds.isEmpty) return [];

      // Then get medical records for those patients
      final recordsQuery = await _firestore
          .collection('medical_records')
          .where('patientId', whereIn: patientIds)
          .orderBy('date', descending: true)
          .get();

      final results = recordsQuery.docs
          .map((doc) => MedicalRecordModel.fromMap(doc.data()))
          .toList();
      
      print('DEBUG: Found ${results.length} medical records for patients');
      return results;
    } catch (e) {
      // If the query fails due to missing indexes, try a simpler approach
      print('DEBUG: Search failed with complex query: $e');
      print('DEBUG: Trying fallback search method...');
      
      return await _searchMedicalRecordsFallback(searchTerm);
    }
    */
  }

  // Fallback method for searching medical records
  Future<List<MedicalRecordModel>> _searchMedicalRecordsFallback(
    String searchTerm,
  ) async {
    try {
      print('DEBUG: Using fallback search method');
      
      // Get all patients and filter locally
      final allPatientsQuery = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'patient')
          .get();

      print('DEBUG: Found ${allPatientsQuery.docs.length} total patients');

      final matchingPatientIds = allPatientsQuery.docs
          .where((doc) {
            final data = doc.data();
            final name = (data['name'] ?? '').toString().toLowerCase();
            final email = (data['email'] ?? '').toString().toLowerCase();
            final searchLower = searchTerm.trim().toLowerCase();
            
            print('DEBUG: Checking patient: $name, email: $email');
            return name.contains(searchLower) || email.contains(searchLower);
          })
          .map((doc) => doc.id)
          .toList();

      print('DEBUG: Found ${matchingPatientIds.length} matching patients');

      if (matchingPatientIds.isEmpty) return [];

      // Get all medical records and filter locally
      final allRecordsQuery = await _firestore
          .collection('medical_records')
          .get();

      print('DEBUG: Found ${allRecordsQuery.docs.length} total medical records');

      final matchingRecords = allRecordsQuery.docs
          .where((doc) {
            final data = doc.data();
            final patientId = data['patientId'] ?? '';
            return matchingPatientIds.contains(patientId);
          })
          .map((doc) => MedicalRecordModel.fromMap(doc.data()))
          .toList();

      print('DEBUG: Found ${matchingRecords.length} matching medical records');
      
      // Sort by date descending
      matchingRecords.sort((a, b) => b.date.compareTo(a.date));
      
      return matchingRecords;
    } catch (e) {
      print('DEBUG: Fallback search also failed: $e');
      return [];
    }
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

  // Debug method to check medical records collection
  Future<void> debugMedicalRecordsCollection() async {
    try {
      print('DEBUG: Checking medical records collection...');
      final snapshot = await _firestore.collection('medical_records').limit(5).get();
      print('DEBUG: Medical records collection exists: ${snapshot.docs.isNotEmpty}');
      print('DEBUG: Number of documents in medical records collection: ${snapshot.docs.length}');
      
      if (snapshot.docs.isNotEmpty) {
        final firstDoc = snapshot.docs.first;
        final data = firstDoc.data();
        print('DEBUG: First medical record document structure:');
        data.forEach((key, value) {
          print('DEBUG:   $key: $value (${value.runtimeType})');
        });
      }
    } catch (e) {
      print('DEBUG: Error checking medical records collection: $e');
    }
  }

  // Debug method to check all medical records
  Future<void> debugAllMedicalRecords() async {
    try {
      final snapshot = await _firestore.collection('medical_records').get();
      print('DEBUG: Total medical records in database: ${snapshot.docs.length}');
      for (final doc in snapshot.docs) {
        final data = doc.data();
        print('DEBUG: Medical record ${doc.id}: patientId=${data['patientId']}, patientName=${data['patientName']}, type=${data['type']}');
      }
    } catch (e) {
      print('DEBUG: Error getting all medical records: $e');
    }
  }

  // Test method to create a test medical record
  Future<void> createTestMedicalRecord(String patientId, String patientName) async {
    try {
      print('DEBUG: Creating test medical record...');
      
      final testRecord = MedicalRecordModel(
        id: 'test_${DateTime.now().millisecondsSinceEpoch}',
        patientId: patientId,
        patientName: patientName,
        doctorId: 'test_doctor_id',
        doctorName: 'Test Doctor',
        date: DateTime.now(),
        type: 'diagnosis',
        title: 'Test Diagnosis',
        description: 'This is a test medical record for debugging purposes.',
        attachments: null,
        metadata: null,
        createdAt: DateTime.now(),
      );
      
      await createMedicalRecord(testRecord);
      print('DEBUG: Test medical record created successfully');
    } catch (e) {
      print('DEBUG: Error creating test medical record: $e');
    }
  }
}

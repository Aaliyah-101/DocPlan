import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/appointment_model.dart';
import '../models/emergency_model.dart';
import '../services/notification_service.dart';

class AppointmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create new appointment
  Future<void> createAppointment(AppointmentModel appointment) async {
    await _firestore
        .collection('appointments')
        .doc(appointment.id)
        .set({
      ...appointment.toMap(),
      'dateTime': Timestamp.fromDate(appointment.dateTime), // ✅ FIXED
    });
  }

  // Get appointments for a user (patient or doctor)
  Stream<List<AppointmentModel>> getUserAppointments(
      String userId,
      String role,
      ) {
    String field = role == 'doctor' ? 'doctorId' : 'patientId';

    return _firestore
        .collection('appointments')
        .where(field, isEqualTo: userId)
        .orderBy('dateTime', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Get available doctors
  Stream<List<Map<String, dynamic>>> getAvailableDoctors() {
    return _firestore
        .collection('doctors')
        .where('status', isEqualTo: 'available')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    });
  }

  // Get available doctors by specialty
  Stream<List<Map<String, dynamic>>> getAvailableDoctorsBySpecialty(String specialty) {
    return _firestore
        .collection('doctors')
        .where('status', isEqualTo: 'available')
        .where('specialty', isEqualTo: specialty)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    });
  }

  // Get doctor availability
  Stream<Map<String, List<String>>> getDoctorAvailability(String doctorId) {
    return _firestore
        .collection('doctors')
        .doc(doctorId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return {};
      final data = snapshot.data() as Map<String, dynamic>;
      final availability = data['availability'] as Map<String, dynamic>?;
      if (availability == null) return {};

      return availability.map((key, value) {
        if (value is List) {
          return MapEntry(key, value.cast<String>());
        }
        return MapEntry(key, <String>[]);
      });
    });
  }

  // Update appointment status
  Future<void> updateAppointmentStatus(
      String appointmentId,
      String status,
      ) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'status': status,
    });
  }

  // Cancel appointment
  Future<void> cancelAppointment(String appointmentId) async {
    final appointmentDoc = await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .get();

    if (!appointmentDoc.exists) return;

    final appointmentData = appointmentDoc.data() as Map<String, dynamic>;
    final patientId = appointmentData['patientId'] as String;
    final doctorName = appointmentData['doctorName'] as String;
    final appointmentTime = (appointmentData['dateTime'] as Timestamp).toDate();

    await updateAppointmentStatus(appointmentId, 'cancelled');

    await NotificationService.notifyAppointmentStatusChange(
      patientId: patientId,
      doctorName: doctorName,
      status: 'cancelled',
      appointmentTime: appointmentTime,
    );
  }

  // Reschedule appointment
  Future<void> rescheduleAppointment(
      String appointmentId,
      DateTime newDateTime,
      ) async {
    final appointmentDoc = await _firestore
        .collection('appointments')
        .doc(appointmentId)
        .get();

    if (!appointmentDoc.exists) return;

    final appointmentData = appointmentDoc.data() as Map<String, dynamic>;
    final patientId = appointmentData['patientId'] as String;
    final doctorName = appointmentData['doctorName'] as String;

    await _firestore.collection('appointments').doc(appointmentId).update({
      'dateTime': Timestamp.fromDate(newDateTime), // ✅ FIXED
      'status': 'upcoming',
    });

    await NotificationService.notifyAppointmentStatusChange(
      patientId: patientId,
      doctorName: doctorName,
      status: 'rescheduled',
      appointmentTime: newDateTime,
    );
  }

  // Check if patient is within doctor's radius
  Future<bool> isPatientWithinRadius(
      String doctorId,
      double patientLat,
      double patientLng,
      ) async {
    try {
      DocumentSnapshot doctorDoc = await _firestore
          .collection('doctors')
          .doc(doctorId)
          .get();

      if (!doctorDoc.exists) return false;

      Map<String, dynamic> doctorData =
      doctorDoc.data() as Map<String, dynamic>;
      Map<String, dynamic>? doctorLocation = doctorData['location'];
      int radius = doctorData['radius'] ?? 1000;

      if (doctorLocation == null) return true;

      double doctorLat = doctorLocation['latitude'];
      double doctorLng = doctorLocation['longitude'];

      double distance = Geolocator.distanceBetween(
        patientLat,
        patientLng,
        doctorLat,
        doctorLng,
      );

      return distance <= radius;
    } catch (e) {
      return false;
    }
  }

  // Update patient location for appointment
  Future<void> updatePatientLocation(
      String appointmentId,
      double latitude,
      double longitude,
      ) async {
    await _firestore.collection('appointments').doc(appointmentId).update({
      'location': {
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': Timestamp.now(),
      },
    });
  }

  // Declare emergency
  Future<void> declareEmergency(EmergencyModel emergency) async {
    await _firestore
        .collection('emergencies')
        .doc(emergency.id)
        .set(emergency.toMap());

    await _firestore.collection('doctors').doc(emergency.doctorId).update({
      'status': 'emergency',
      'emergency_reason': emergency.reason,
      'emergency_time': Timestamp.fromDate(emergency.timestamp),
    });

    final appointments = await _firestore
        .collection('appointments')
        .where('status', isEqualTo: 'upcoming')
        .get();

    for (DocumentSnapshot doc in appointments.docs) {
      await doc.reference.update({
        'status': 'frozen',
        'notes':
        'We apologize, your appointment is temporarily frozen due to a system-wide emergency.',
      });
    }

    await NotificationService.notifyDoctorPatients(
      doctorId: emergency.doctorId,
      doctorName: emergency.doctorName,
      emergencyReason: emergency.reason,
    );
  }

  // Resolve emergency
  Future<void> resolveEmergency(String doctorId) async {
    await _firestore.collection('doctors').doc(doctorId).update({
      'status': 'available',
      'emergency_reason': null,
      'emergency_time': null,
    });

    final emergencies = await _firestore
        .collection('emergencies')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'active')
        .get();

    for (DocumentSnapshot doc in emergencies.docs) {
      await doc.reference.update({'status': 'resolved'});
    }
  }

  // Get active emergencies
  Stream<List<EmergencyModel>> getActiveEmergencies() {
    return _firestore
        .collection('emergencies')
        .where('status', isEqualTo: 'active')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => EmergencyModel.fromMap(doc.data()))
          .toList();
    });
  }

  // Release all frozen appointments for a doctor
  Future<void> releaseAllFrozenAppointments(String doctorId) async {
    final frozenAppointments = await _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'frozen')
        .get();

    for (final doc in frozenAppointments.docs) {
      await doc.reference.update({
        'status': 'upcoming',
        'notes': null,
      });
    }
  }
}

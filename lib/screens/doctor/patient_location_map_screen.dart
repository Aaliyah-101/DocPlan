import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';
import '../../constants/app_colors.dart';
import 'dart:developer' as developer;

class PatientLocationMapScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const PatientLocationMapScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<PatientLocationMapScreen> createState() => _PatientLocationMapScreenState();
}

class _PatientLocationMapScreenState extends State<PatientLocationMapScreen> {
  LatLng? patientLatLng;
  LatLng? doctorLatLng;
  bool loading = true;
  String? error;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    developer.log('🚀 PatientLocationMapScreen: Initializing for appointment: ${widget.appointment.id}');
    _loadDoctorLocation();
  }

  Future<void> _loadDoctorLocation() async {
    try {
      developer.log('📍 Loading doctor location from Firestore...');
      // Fetch doctor location and radius from Firestore
      final doc = await FirebaseFirestore.instance.collection('doctors').doc(widget.appointment.doctorId).get();
      if (!doc.exists) {
        developer.log('❌ Doctor document does not exist');
        setState(() {
          error = 'Doctor location not found.';
          loading = false;
        });
        return;
      }
      final data = doc.data() as Map<String, dynamic>;
      final doctorLocation = data['location'];
      if (doctorLocation == null) {
        developer.log('❌ Doctor location is null');
        setState(() {
          error = 'Doctor location not set.';
          loading = false;
        });
        return;
      }
      doctorLatLng = LatLng(doctorLocation['latitude'], doctorLocation['longitude']);
      developer.log('✅ Doctor location loaded: $doctorLatLng');
      setState(() {
        loading = false;
      });
    } catch (e) {
      developer.log('❌ Error loading doctor location: $e');
      setState(() {
        error = 'Error loading map data: $e';
        loading = false;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    developer.log('🗺️ Patient location map created successfully');
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Location'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('appointments')
            .doc(widget.appointment.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No patient location available.'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final location = data['location'];
          if (location == null) {
            return const Center(child: Text('No patient location available.'));
          }
          patientLatLng = LatLng(location['latitude'], location['longitude']);
          developer.log('📍 Patient location: $patientLatLng');
          
          return GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: doctorLatLng!,
              zoom: 12,
            ),
            markers: {
              Marker(
                markerId: const MarkerId('patient'),
                position: patientLatLng!,
                infoWindow: const InfoWindow(title: 'Patient'),
              ),
              Marker(
                markerId: const MarkerId('doctor'),
                position: doctorLatLng!,
                infoWindow: const InfoWindow(title: 'Doctor'),
              ),
            },
            circles: {},
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            rotateGesturesEnabled: false,
            tiltGesturesEnabled: false,
            onCameraMove: null,
            onCameraIdle: null,
            onTap: null,
            onLongPress: null,
          );
        },
      ),
    );
  }


}
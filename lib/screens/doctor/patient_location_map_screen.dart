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
  bool _useStaticFallback = false;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _useStaticFallback = !_useStaticFallback;
              });
            },
            tooltip: _useStaticFallback ? 'Switch to Google Maps' : 'Switch to Static Map',
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text(error!))
          : _useStaticFallback
          ? _buildStaticMap()
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

  Widget _buildStaticMap() {
    return StreamBuilder<DocumentSnapshot>(
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
        final patientLat = location['latitude'];
        final patientLng = location['longitude'];
        
        return Container(
          color: Colors.grey[200],
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.person_pin,
                        size: 64,
                        color: Colors.red[600],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Patient Location',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Latitude: ${patientLat.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Longitude: ${patientLng.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 32),
                      Icon(
                        Icons.location_on,
                        size: 48,
                        color: Colors.blue[600],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Doctor Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Latitude: ${doctorLatLng!.latitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      Text(
                        'Longitude: ${doctorLatLng!.longitude.toStringAsFixed(6)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Static Location View',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Google Maps is experiencing buffer issues. This static view shows the location coordinates.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
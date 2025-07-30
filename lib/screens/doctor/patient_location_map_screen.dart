import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';
import '../../constants/app_colors.dart';

class PatientLocationMapScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const PatientLocationMapScreen({super.key, required this.appointment});

  @override
  State<PatientLocationMapScreen> createState() =>
      _PatientLocationMapScreenState();
}

class _PatientLocationMapScreenState extends State<PatientLocationMapScreen> {
  LatLng? patientLatLng;
  LatLng? doctorLatLng;
  double? radius;
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    try {
      final location = widget.appointment.location;
      if (location == null) {
        setState(() {
          error = 'No patient location available.';
          loading = false;
        });
        return;
      }
      patientLatLng = LatLng(location['latitude'], location['longitude']);
      // Fetch doctor location and radius from Firestore
      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.appointment.doctorId)
          .get();
      if (!doc.exists) {
        setState(() {
          error = 'Doctor location not found.';
          loading = false;
        });
        return;
      }
      final data = doc.data() as Map<String, dynamic>;
      final doctorLocation = data['location'];
      if (doctorLocation == null) {
        setState(() {
          error = 'Doctor location not set.';
          loading = false;
        });
        return;
      }
      doctorLatLng = LatLng(
        doctorLocation['latitude'],
        doctorLocation['longitude'],
      );
      radius = (data['radius'] ?? 1000).toDouble();
      setState(() {
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Error loading map data: $e';
        loading = false;
      });
    }
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
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: doctorLatLng!,
                zoom: 14,
              ),
              markers: {
                Marker(
                  markerId: const MarkerId('patient'),
                  position: patientLatLng!,
                  infoWindow: const InfoWindow(title: 'Patient'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('doctor'),
                  position: doctorLatLng!,
                  infoWindow: const InfoWindow(title: 'Doctor'),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
              },
              circles: {
                Circle(
                  circleId: const CircleId('radius'),
                  center: doctorLatLng!,
                  radius: radius!,
                  fillColor: Colors.green.withAlpha((255 * 0.2).toInt()),
                  strokeColor: Colors.green,
                  strokeWidth: 2,
                ),
              },
            ),
    );
  }
}

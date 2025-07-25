import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/appointment_model.dart';
import '../../constants/app_colors.dart';

class PatientLocationMapScreen extends StatefulWidget {
  final AppointmentModel appointment;
  const PatientLocationMapScreen({Key? key, required this.appointment}) : super(key: key);

  @override
  State<PatientLocationMapScreen> createState() => _PatientLocationMapScreenState();
}

class _PatientLocationMapScreenState extends State<PatientLocationMapScreen> {
  LatLng? patientLatLng;
  LatLng? doctorLatLng;
  double? radius;
  bool loading = true;
  String? error;
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _loadDoctorLocation();
  }

  Future<void> _loadDoctorLocation() async {
    try {
      // Fetch doctor location and radius from Firestore
      final doc = await FirebaseFirestore.instance.collection('doctors').doc(widget.appointment.doctorId).get();
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
      doctorLatLng = LatLng(doctorLocation['latitude'], doctorLocation['longitude']);
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

  void _onMapCreated(GoogleMapController controller) {
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
                    return GoogleMap(
                      onMapCreated: _onMapCreated,
                      initialCameraPosition: CameraPosition(
                        target: doctorLatLng!,
                        zoom: 14,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('patient'),
                          position: patientLatLng!,
                          infoWindow: const InfoWindow(title: 'Patient'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                        ),
                        Marker(
                          markerId: const MarkerId('doctor'),
                          position: doctorLatLng!,
                          infoWindow: const InfoWindow(title: 'Doctor'),
                          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
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
                    );
                  },
                ),
    );
  }
} 
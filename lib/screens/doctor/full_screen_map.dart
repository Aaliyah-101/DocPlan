import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class FullScreenMap extends StatelessWidget {
  final LatLng doctorLocation;
  final LatLng? patientLocation;

  const FullScreenMap({
    Key? key,
    required this.doctorLocation,
    this.patientLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('doctor'),
        position: doctorLocation,
        infoWindow: const InfoWindow(title: 'You'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    };
    if (patientLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('patient'),
          position: patientLocation!,
          infoWindow: const InfoWindow(title: 'Patient'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map'),
        leading: BackButton(),
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: doctorLocation,
          zoom: 15,
        ),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
} 
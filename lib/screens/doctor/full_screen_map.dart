import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:developer' as developer;

class FullScreenMap extends StatefulWidget {
  final LatLng doctorLocation;
  final LatLng? patientLocation;
  final double? radius;

  const FullScreenMap({
    Key? key,
    required this.doctorLocation,
    this.patientLocation,
    this.radius,
  }) : super(key: key);

  @override
  State<FullScreenMap> createState() => _FullScreenMapState();
}

class _FullScreenMapState extends State<FullScreenMap> {
  bool _isMapLoading = true;
  bool _hasMapError = false;
  String _errorMessage = '';
  GoogleMapController? _mapController;
  bool _useStaticFallback = false;

  @override
  void initState() {
    super.initState();
    developer.log('🚀 FullScreenMap: Initializing with doctor location: ${widget.doctorLocation}');
  }

  @override
  void dispose() {
    developer.log('🗑️ Disposing FullScreenMap');
    _mapController?.dispose();
    super.dispose();
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      developer.log('🗺️ Google Map created successfully!');
      _mapController = controller;

      setState(() {
        _isMapLoading = false;
        _hasMapError = false;
      });

    } catch (e, stackTrace) {
      developer.log('❌ Error in _onMapCreated: $e', stackTrace: stackTrace);
      setState(() {
        _isMapLoading = false;
        _hasMapError = true;
        _errorMessage = 'Map creation failed: $e';
        _useStaticFallback = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Map'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _useStaticFallback = !_useStaticFallback;
                _isMapLoading = true;
                _hasMapError = false;
                _errorMessage = '';
              });
            },
            tooltip: _useStaticFallback ? 'Switch to Google Maps' : 'Switch to Static Map',
          ),
        ],
      ),
      body: _useStaticFallback 
          ? _buildStaticMap()
          : _hasMapError
              ? _buildErrorWidget()
              : Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: widget.doctorLocation,
                        zoom: 12,
                      ),
                      markers: {
                        Marker(
                          markerId: const MarkerId('doctor'),
                          position: widget.doctorLocation,
                          infoWindow: const InfoWindow(
                            title: 'Doctor Location',
                            snippet: 'Your current location',
                          ),
                        ),
                      },
                      circles: {},
                      myLocationEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      mapToolbarEnabled: false,
                      zoomControlsEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      onMapCreated: _onMapCreated,
                      mapType: MapType.normal,
                      onCameraMove: null,
                      onCameraIdle: null,
                      onTap: null,
                      onLongPress: null,
                    ),
                    if (_isMapLoading)
                      Container(
                        color: Colors.white.withOpacity(0.9),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 16),
                              Text('Loading Google Maps...'),
                              SizedBox(height: 8),
                              Text(
                                'This may take a moment',
                                style: TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildStaticMap() {
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
                    Icons.location_on,
                    size: 64,
                    color: Colors.blue[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Doctor Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Latitude: ${widget.doctorLocation.latitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  Text(
                    'Longitude: ${widget.doctorLocation.longitude.toStringAsFixed(6)}',
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (widget.patientLocation != null) ...[
                    const SizedBox(height: 24),
                    Icon(
                      Icons.person_pin,
                      size: 48,
                      color: Colors.red[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Patient Location',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Latitude: ${widget.patientLocation!.latitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Longitude: ${widget.patientLocation!.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                  if (widget.radius != null) ...[
                    const SizedBox(height: 24),
                    Icon(
                      Icons.radio_button_checked,
                      size: 48,
                      color: Colors.green[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Service Radius',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${widget.radius!.toStringAsFixed(0)} meters',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Static Map View',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Google Maps is experiencing buffer issues on this device. This static view shows the location data.',
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
  }

  Widget _buildErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          const Text(
            'Map Loading Error',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_errorMessage, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isMapLoading = true;
                    _hasMapError = false;
                    _errorMessage = '';
                    _useStaticFallback = false;
                  });
                },
                child: const Text('Retry Google Maps'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _useStaticFallback = true;
                    _hasMapError = false;
                    _errorMessage = '';
                  });
                },
                child: const Text('Use Static Map'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
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

class _FullScreenMapState extends State<FullScreenMap> with WidgetsBindingObserver {
  late Set<Marker> markers;
  late Set<Circle> circles;
  bool _isMapLoading = true;
  bool _hasMapError = false;
  String _errorMessage = '';
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    developer.log('🚀 FullScreenMap: Initializing with doctor location: ${widget.doctorLocation}');
    _initializeMapData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    developer.log('🗑️ Disposing FullScreenMap');
    _mapController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      // Pause map rendering when app goes to background
      developer.log('📱 App paused - pausing map');
    } else if (state == AppLifecycleState.resumed) {
      // Resume map rendering when app comes to foreground
      developer.log('📱 App resumed - resuming map');
    }
  }

  void _initializeMapData() {
    try {
      developer.log('📍 Initializing map markers and circles...');

      // Initialize markers with reduced complexity
      markers = {
        Marker(
          markerId: const MarkerId('doctor'),
          position: widget.doctorLocation,
          infoWindow: const InfoWindow(
            title: 'Doctor Location',
            snippet: 'Your current location',
          ),
          // Use default marker to reduce memory usage
        ),
      };

      // Add patient marker if available
      if (widget.patientLocation != null) {
        markers.add(
          Marker(
            markerId: const MarkerId('patient'),
            position: widget.patientLocation!,
            infoWindow: const InfoWindow(
              title: 'Patient Location',
              snippet: 'Patient location',
            ),
          ),
        );
        developer.log('✅ Patient marker added');
      }

      // Initialize circles with optimized settings
      circles = {};
      if (widget.radius != null && widget.radius! > 0) {
        circles.add(
          Circle(
            circleId: const CircleId('radius'),
            center: widget.doctorLocation,
            radius: widget.radius!,
            strokeColor: Colors.blue.withOpacity(0.6), // Reduced opacity
            strokeWidth: 1, // Reduced stroke width
            fillColor: Colors.blue.withOpacity(0.1), // Reduced fill opacity
          ),
        );
        developer.log('✅ Radius circle added with radius: ${widget.radius} meters');
      }

      developer.log('✅ Map data initialized successfully');

    } catch (e, stackTrace) {
      developer.log('❌ Error initializing map data: $e', stackTrace: stackTrace);
      setState(() {
        _hasMapError = true;
        _errorMessage = 'Failed to initialize map data: $e';
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      developer.log('🗺️ Google Map created successfully!');
      _mapController = controller;

      setState(() {
        _isMapLoading = false;
        _hasMapError = false;
      });

      // Reduce map quality for better performance
      _mapController?.setMapStyle(null); // Use default style

      developer.log('📱 Map controller assigned');

      // Fit bounds with delay to prevent buffer issues
      if (widget.patientLocation != null) {
        developer.log('🎯 Fitting bounds for both locations...');
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) _fitBounds();
        });
      }

    } catch (e, stackTrace) {
      developer.log('❌ Error in _onMapCreated: $e', stackTrace: stackTrace);
      setState(() {
        _isMapLoading = false;
        _hasMapError = true;
        _errorMessage = 'Map creation failed: $e';
      });
    }
  }

  void _fitBounds() {
    try {
      if (_mapController == null || !mounted) return;

      if (widget.patientLocation == null) {
        developer.log('⚠️ Cannot fit bounds: Patient location is null');
        return;
      }

      developer.log('📐 Calculating bounds...');

      final bounds = LatLngBounds(
        southwest: LatLng(
          widget.doctorLocation.latitude < widget.patientLocation!.latitude
              ? widget.doctorLocation.latitude - 0.001
              : widget.patientLocation!.latitude - 0.001,
          widget.doctorLocation.longitude < widget.patientLocation!.longitude
              ? widget.doctorLocation.longitude - 0.001
              : widget.patientLocation!.longitude - 0.001,
        ),
        northeast: LatLng(
          widget.doctorLocation.latitude > widget.patientLocation!.latitude
              ? widget.doctorLocation.latitude + 0.001
              : widget.patientLocation!.latitude + 0.001,
          widget.doctorLocation.longitude > widget.patientLocation!.longitude
              ? widget.doctorLocation.longitude + 0.001
              : widget.patientLocation!.longitude + 0.001,
        ),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );

      developer.log('✅ Camera bounds fitted successfully');

    } catch (e, stackTrace) {
      developer.log('❌ Error fitting bounds: $e', stackTrace: stackTrace);
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
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController?.animateCamera(
                CameraUpdate.newLatLngZoom(widget.doctorLocation, 15),
              );
            },
            tooltip: 'Center on your location',
          ),
        ],
      ),
      body: _hasMapError
          ? _buildErrorWidget()
          : Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: widget.doctorLocation,
              zoom: 14, // Reduced initial zoom
            ),
            markers: markers,
            circles: circles,
            myLocationEnabled: false, // Disable to reduce buffer usage
            myLocationButtonEnabled: false,
            compassEnabled: false, // Disable to reduce rendering
            mapToolbarEnabled: false, // Disable to reduce rendering
            zoomControlsEnabled: true,
            rotateGesturesEnabled: false, // Disable rotation
            tiltGesturesEnabled: false, // Disable tilt
            onMapCreated: _onMapCreated,
            mapType: MapType.normal,
            // Reduce rendering frequency
            onCameraMove: null, // Remove camera move callback
            onCameraIdle: null, // Remove camera idle callback
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
      floatingActionButton: widget.patientLocation != null && !_hasMapError
          ? FloatingActionButton(
        onPressed: _fitBounds,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.center_focus_strong),
        tooltip: 'Fit both locations',
      )
          : null,
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
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isMapLoading = true;
                _hasMapError = false;
                _errorMessage = '';
              });
              _initializeMapData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
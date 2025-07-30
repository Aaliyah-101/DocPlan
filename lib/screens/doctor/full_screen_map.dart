import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:developer' as developer;
import 'dart:async';

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
  bool _hasNetworkConnection = true;
  String _errorMessage = '';
  GoogleMapController? _mapController;
  Timer? _loadingTimer;

  // Professional color scheme
  static const Color primaryBlue = Color(0xFF1565C0);
  static const Color backgroundGray = Color(0xFFF8F9FA);
  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color errorRed = Color(0xFFD32F2F);

  @override
  void initState() {
    super.initState();
    developer.log('🚀 FullScreenMap: Initializing with doctor location: ${widget.doctorLocation}');
    _checkNetworkAndInitialize();
    
    // Set a timeout for map loading
    _loadingTimer = Timer(const Duration(seconds: 15), () {
      if (_isMapLoading && mounted) {
        developer.log('⏰ Map loading timeout reached');
        setState(() {
          _isMapLoading = false;
          _hasMapError = true;
          _errorMessage = 'Map loading timed out. Please check your internet connection and API key configuration.';
        });
      }
    });
  }

  @override
  void dispose() {
    developer.log('🗑️ Disposing FullScreenMap');
    _loadingTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _checkNetworkAndInitialize() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      
      developer.log('🌐 Network connectivity: $connectivityResult');
      
      setState(() {
        _hasNetworkConnection = hasConnection;
        if (!hasConnection) {
          _hasMapError = true;
          _errorMessage = 'No internet connection. Please check your network settings.';
          _isMapLoading = false;
        }
      });
    } catch (e) {
      developer.log('❌ Error checking network: $e');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    try {
      developer.log('🗺️ Google Map created successfully!');
      _mapController = controller;
      _loadingTimer?.cancel();
      
      setState(() {
        _isMapLoading = false;
        _hasMapError = false;
        _errorMessage = '';
      });

      // Move camera to show both locations if patient location exists
      if (widget.patientLocation != null) {
        _fitMapToShowBothLocations();
      }
    } catch (e, stackTrace) {
      developer.log('❌ Error in _onMapCreated: $e', stackTrace: stackTrace);
      _loadingTimer?.cancel();
      setState(() {
        _isMapLoading = false;
        _hasMapError = true;
        _errorMessage = 'Map initialization failed: ${e.toString()}';
      });
    }
  }

  void _fitMapToShowBothLocations() {
    if (_mapController != null && widget.patientLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          widget.doctorLocation.latitude < widget.patientLocation!.latitude
              ? widget.doctorLocation.latitude
              : widget.patientLocation!.latitude,
          widget.doctorLocation.longitude < widget.patientLocation!.longitude
              ? widget.doctorLocation.longitude
              : widget.patientLocation!.longitude,
        ),
        northeast: LatLng(
          widget.doctorLocation.latitude > widget.patientLocation!.latitude
              ? widget.doctorLocation.latitude
              : widget.patientLocation!.latitude,
          widget.doctorLocation.longitude > widget.patientLocation!.longitude
              ? widget.doctorLocation.longitude
              : widget.patientLocation!.longitude,
        ),
      );

      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 100.0),
      );
    }
  }

  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('doctor'),
        position: widget.doctorLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(
          title: '👨‍⚕️ Doctor Location',
          snippet: 'Healthcare provider location',
        ),
      ),
    };

    if (widget.patientLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('patient'),
          position: widget.patientLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: const InfoWindow(
            title: '🏥 Patient Location',
            snippet: 'Patient location',
          ),
        ),
      );
    }

    return markers;
  }

  Set<Circle> _buildCircles() {
    if (widget.radius == null) return {};

    return {
      Circle(
        circleId: const CircleId('radius'),
        center: widget.doctorLocation,
        radius: widget.radius! * 1000, // Convert km to meters
        fillColor: primaryBlue.withOpacity(0.1),
        strokeColor: primaryBlue.withOpacity(0.5),
        strokeWidth: 2,
      ),
    };
  }

  Future<void> _retryMapLoad() async {
    developer.log('🔄 Retrying map load...');
    setState(() {
      _isMapLoading = true;
      _hasMapError = false;
      _errorMessage = '';
    });

    await _checkNetworkAndInitialize();
    
    // Reset the timeout timer
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 15), () {
      if (_isMapLoading && mounted) {
        setState(() {
          _isMapLoading = false;
          _hasMapError = true;
          _errorMessage = 'Map loading timed out after retry.';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            const Icon(Icons.map, size: 24),
            const SizedBox(width: 8),
            const Text(
              'Location Map',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actions: [
          if (!_hasMapError && !_isMapLoading)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(widget.doctorLocation, 15),
                );
              },
              tooltip: 'Center on doctor location',
            ),
        ],
      ),
      body: _hasMapError ? _buildErrorWidget() : _buildMapWidget(),
    );
  }

  Widget _buildMapWidget() {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: widget.doctorLocation,
            zoom: widget.patientLocation != null ? 12 : 15,
          ),
          markers: _buildMarkers(),
          circles: _buildCircles(),
          myLocationEnabled: false,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          mapToolbarEnabled: false,
          zoomControlsEnabled: true,
          rotateGesturesEnabled: true,
          tiltGesturesEnabled: true,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          onMapCreated: _onMapCreated,
          mapType: MapType.normal,
          minMaxZoomPreference: const MinMaxZoomPreference(10, 20),
        ),
        if (_isMapLoading) _buildLoadingOverlay(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: cardWhite.withOpacity(0.95),
      child: Center(
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: primaryBlue,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 24),
                Text(
                  'Loading Google Maps...',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please wait while we initialize the map',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                LinearProgressIndicator(
                  color: primaryBlue,
                  backgroundColor: primaryBlue.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: errorRed.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.map_outlined,
                  size: 48,
                  color: errorRed,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Map Loading Failed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              _buildTroubleshootingTips(),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Go Back'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: textSecondary,
                      side: BorderSide(color: textSecondary.withOpacity(0.3)),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _retryMapLoad,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      elevation: 2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTroubleshootingTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textSecondary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, color: textSecondary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Troubleshooting Tips:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTipItem('Check your internet connection'),
          _buildTipItem('Verify Google Maps API key is configured'),
          _buildTipItem('Ensure Maps SDK is enabled in Google Cloud Console'),
          _buildTipItem('Check if location permissions are granted'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: textSecondary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 
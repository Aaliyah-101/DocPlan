import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/gradient_background.dart';

class RadiusSettingsScreen extends StatefulWidget {
  const RadiusSettingsScreen({super.key});

  @override
  State<RadiusSettingsScreen> createState() => _RadiusSettingsScreenState();
}

class _RadiusSettingsScreenState extends State<RadiusSettingsScreen> {
  final AuthService _authService = AuthService();
  bool _isLoading = false;
  bool _locationEnabled = false;
  Position? _currentPosition;
  double _radius = 1000;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
    _loadCurrentSettings();
  }

  Future<void> _checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _statusMessage = 'Location services are disabled';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _statusMessage = 'Location permission denied';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _statusMessage = 'Location permissions are permanently denied';
        });
        return;
      }

      setState(() {
        _locationEnabled = true;
        _statusMessage = 'Location services enabled';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error checking location: $e';
      });
    }
  }

  Future<void> _loadCurrentSettings() async {
    try {
      final user = _authService.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        setState(() {
          _radius = (data['radius'] ?? 1000).toDouble();
          if (data['location'] != null) {
            _currentPosition = Position(
              latitude: data['location']['latitude'],
              longitude: data['location']['longitude'],
              timestamp: DateTime.now(),
              accuracy: 0,
              altitude: 0,
              heading: 0,
              speed: 0,
              speedAccuracy: 0,
              altitudeAccuracy: 0,
              headingAccuracy: 0,
            );
          }
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading settings: $e';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_locationEnabled) {
      await _checkLocationPermission();
      if (!_locationEnabled) return;
    }

    setState(() => _isLoading = true);

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _statusMessage = 'Location updated successfully';
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error getting location: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    if (_currentPosition == null) {
      setState(() {
        _statusMessage = 'Please get your current location first';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _authService.currentUser;
      if (user == null) throw Exception('User not logged in');

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(user.uid)
          .update({
            'location': {
              'latitude': _currentPosition!.latitude,
              'longitude': _currentPosition!.longitude,
              'timestamp': DateTime.now().toIso8601String(),
            },
            'radius': _radius,
          });

      setState(() {
        _statusMessage = 'Settings saved successfully!';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Radius settings saved successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'Error saving settings: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Radius Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                // Location Status
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _locationEnabled
                        ? AppColors.success.withAlpha((255 * 0.1).toInt())
                        : AppColors.error.withAlpha((255 * 0.1).toInt()),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _locationEnabled ? AppColors.success : AppColors.error,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _locationEnabled ? Icons.location_on : Icons.location_off,
                        color: _locationEnabled
                            ? AppColors.success
                            : AppColors.error,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _locationEnabled
                                  ? 'Location Enabled'
                                  : 'Location Disabled',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _locationEnabled
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                            if (_statusMessage.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                _statusMessage,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _locationEnabled
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current Location
                Text(
                  'Current Location',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),

                if (_currentPosition != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.textSecondary),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latitude: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Longitude: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.textSecondary),
                    ),
                    child: const Text(
                      'No location set',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                CustomButton(
                  text: 'Get Current Location',
                  onPressed: _isLoading ? null : _getCurrentLocation,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.primary,
                ),
                const SizedBox(height: 24),

                // Radius Setting
                Text(
                  'Detection Radius',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.textSecondary),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Radius:'),
                          Text(
                            '${(_radius / 1000).toStringAsFixed(1)} km',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _radius,
                        min: 100,
                        max: 10000,
                        divisions: 99,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _radius = value;
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('100m', style: TextStyle(fontSize: 12)),
                          Text('10km', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                CustomButton(
                  text: 'Save Settings',
                  onPressed: _isLoading ? null : _saveSettings,
                  isLoading: _isLoading,
                  backgroundColor: AppColors.success,
                ),
                const SizedBox(height: 16),

                // Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withAlpha((255 * 0.1).toInt()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Patients outside this radius will be marked as "not in range" and you can skip their appointments.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

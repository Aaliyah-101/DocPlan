import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // For theme switching if using Provider
import '../../constants/app_colors.dart';
import '../../constants/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  String? _profilePictureUrl;
  File? _newProfileImage;
  bool _isDarkMode = false; // Replace with your theme provider logic
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = _authService.currentUser;
    if (user == null) return;
    final userModel = await _authService.getUserData(user.uid);
    if (userModel != null) {
      _nameController.text = userModel.name;
      _phoneController.text = userModel.phoneNumber;
      _countryController.text = userModel.country;
      _profilePictureUrl = userModel.profilePictureUrl;
      // TODO: Load dark mode preference from storage/provider
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() {
      _error = null;
      _loading = true;
    });
    final user = _authService.currentUser;
    if (user == null) return;
    try {
      String? imageUrl = _profilePictureUrl;
      if (_newProfileImage != null) {
        imageUrl = await _storageService.uploadProfilePicture(
          _newProfileImage!,
          user.uid,
        );
      }
      await _authService.updateUserProfile(
        uid: user.uid,
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        country: _countryController.text.trim(),
      );
      if (imageUrl != null) {
        await _authService.firestore.collection('users').doc(user.uid).update({
          'profilePictureUrl': imageUrl,
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated!'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _pickProfileImage() async {
    final picked = await _storageService.pickImageFromGallery();
    if (picked != null) {
      setState(() {
        _newProfileImage = picked;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    _isDarkMode = themeNotifier.themeMode == ThemeMode.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                // Profile Picture
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundImage: _newProfileImage != null
                            ? FileImage(_newProfileImage!)
                            : (_profilePictureUrl != null &&
                                  _profilePictureUrl!.isNotEmpty)
                            ? NetworkImage(_profilePictureUrl!) as ImageProvider
                            : const AssetImage(
                                'assets/images/doctor_background.jpg',
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickProfileImage,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Name
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                // Phone
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                const SizedBox(height: 16),
                // Country
                TextField(
                  controller: _countryController,
                  decoration: const InputDecoration(
                    labelText: 'Country',
                    prefixIcon: Icon(Icons.flag),
                  ),
                ),
                const SizedBox(height: 24),
                // Dark/Light Mode Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dark Mode', style: TextStyle(fontSize: 16)),
                    Switch(
                      value: _isDarkMode,
                      onChanged: (val) {
                        setState(() {
                          _isDarkMode = val;
                        });
                        themeNotifier.setTheme(val ? ThemeMode.dark : ThemeMode.light);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      _error!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  ),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textWhite,
                    ),
                    child: _loading
                        ? const CircularProgressIndicator(
                            color: AppColors.textWhite,
                          )
                        : const Text('Save Changes'),
                  ),
                ),
                const SizedBox(height: 32),
                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: AppColors.textWhite,
                    ),
                    onPressed: () async {
                      await AuthService().signOut();
                      if (context.mounted) {
                        Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
                      }
                    },
                    label: const Text('Sign Out'),
                  ),
                ),
              ],
            ),
    );
  }
}

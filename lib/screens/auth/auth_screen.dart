import 'package:flutter/material.dart';
import 'package:country_picker/country_picker.dart';
import '../../constants/app_colors.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'forgot_password_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();
  final _signInFormKey = GlobalKey<FormState>();
  final _signUpFormKey = GlobalKey<FormState>();

  // Controllers
  final _signInEmailController = TextEditingController();
  final _signInPasswordController = TextEditingController();
  final _signUpEmailController = TextEditingController();
  final _signUpPasswordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  // State variables
  String _selectedCountry = '';
  String _selectedCountryCode = '';
  String _selectedRole = 'patient';
  String _selectedSpecialty = '';
  bool _isLoading = false;
  bool _obscureSignInPassword = true;
  bool _obscureSignUpPassword = true;
  bool _showSignUp = false;

  // Doctor specialties
  final List<String> _specialties = [
    'Cardiologist',
    'Endocrinologist',
    'Gastroenterologist',
    'Pulmonologist',
    'Nephrologist',
    'Hematologist',
    'Neurosurgeon',
    'Cardiothoracic Surgeon',
    'Plastic Surgeon',
    'Dermatologist',
    'Oncologist',
    'Radiologist',
    'Pathologist',
    'Rheumatologist',
    'Ophthalmologist',
    'Psychiatrist',
    'Urologist',
    'Trauma Surgeon',
    'Allergist',
    'Toxicologist',
  ];

  // Days of the week
  final List<String> _daysOfWeek = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  // Time slots (hourly)
  final List<String> _timeSlots = [
    '09:00',
    '10:00',
    '11:00',
    '12:00',
    '13:00',
    '14:00',
    '15:00',
    '16:00',
    '17:00',
  ];

  // Doctor availability
  final Map<String, List<String>> _doctorAvailability = {};

  @override
  void initState() {
    super.initState();
    // Initialize availability for all days
    for (String day in _daysOfWeek) {
      _doctorAvailability[day] = [];
    }
  }

  @override
  void dispose() {
    _signInEmailController.dispose();
    _signInPasswordController.dispose();
    _signUpEmailController.dispose();
    _signUpPasswordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        flagSize: 25,
        backgroundColor: AppColors.cardBackground,
        textStyle: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
        bottomSheetHeight: 500,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
        inputDecoration: InputDecoration(
          labelText: 'Search Country',
          hintText: 'Start typing to search',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: const Color(0xFF8C98A8).withOpacity(0.2),
            ),
          ),
        ),
      ),
      onSelect: (Country country) {
        setState(() {
          _selectedCountry = country.name;
          _selectedCountryCode = country.phoneCode;
        });
      },
    );
  }

  Future<void> _signIn() async {
    if (!_signInFormKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userCredential = await _authService.signIn(
        email: _signInEmailController.text.trim(),
        password: _signInPasswordController.text,
      );

      // Fetch user data to determine role
      final user = userCredential.user;
      if (user != null) {
        // Add a small delay to ensure Firestore data is available
        await Future.delayed(const Duration(milliseconds: 500));
        final userData = await _authService.getUserData(user.uid);

        print('DEBUG: User UID: ${user.uid}');
        print('DEBUG: User data: $userData');
        print('DEBUG: User role: ${userData?.role}');

        if (mounted) {
          if (userData != null && userData.role.isNotEmpty) {
            print(
              'DEBUG: Navigating to dashboard based on role: "${userData.role}"',
            );
            // Normalize role to lowercase for comparison
            final normalizedRole = userData.role.toLowerCase().trim();
            if (normalizedRole == 'doctor') {
              print('DEBUG: Navigating to doctor dashboard');
              Navigator.pushReplacementNamed(context, '/doctor_dashboard');
            } else if (normalizedRole == 'admin') {
              print('DEBUG: Navigating to admin dashboard');
              Navigator.pushReplacementNamed(context, '/admin_dashboard');
            } else {
              print('DEBUG: Navigating to patient dashboard (default)');
              Navigator.pushReplacementNamed(context, '/patient_dashboard');
            }
          } else {
            print(
              'DEBUG: User data is null or role is empty, navigating to patient dashboard',
            );
            // Show error message to user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('User data not found. Please contact support.'),
                backgroundColor: AppColors.error,
              ),
            );
            Navigator.pushReplacementNamed(context, '/patient_dashboard');
          }
        }
      }
    } catch (e) {
      print('DEBUG: Sign in error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signUp() async {
    if (!_signUpFormKey.currentState!.validate()) return;

    if (_selectedCountry.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your country'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate doctor-specific fields
    if (_selectedRole == 'doctor') {
      if (_selectedSpecialty.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select your specialty'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Check if at least one day has time slots selected
      bool hasAvailability = _doctorAvailability.values.any(
        (slots) => slots.isNotEmpty,
      );
      if (!hasAvailability) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one available time slot'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      print('DEBUG: Sign up with role: $_selectedRole');
      final userCredential = await _authService.signUp(
        email: _signUpEmailController.text.trim(),
        password: _signUpPasswordController.text,
        name: _nameController.text.trim(),
        phoneNumber: '$_selectedCountryCode${_phoneController.text.trim()}',
        country: _selectedCountry,
        role: _selectedRole,
        specialty: _selectedRole == 'doctor' ? _selectedSpecialty : null,
        availability: _selectedRole == 'doctor' ? _doctorAvailability : null,
      );

      if (mounted) {
        // Add a small delay to ensure Firestore data is saved
        await Future.delayed(const Duration(milliseconds: 1000));

        // Verify the user data was saved correctly
        final user = userCredential.user;
        if (user != null) {
          final userData = await _authService.getUserData(user.uid);
          print('DEBUG: Verification - User data after sign up: $userData');
          print('DEBUG: Verification - Role after sign up: ${userData?.role}');
        }

        // After sign up, navigate based on role
        print('DEBUG: Navigating after sign up with role: $_selectedRole');
        if (_selectedRole == 'doctor') {
          print('DEBUG: Navigating to doctor dashboard after sign up');
          Navigator.pushReplacementNamed(context, '/doctor_dashboard');
        } else if (_selectedRole == 'admin') {
          print('DEBUG: Navigating to admin dashboard after sign up');
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          print('DEBUG: Navigating to patient dashboard after sign up');
          Navigator.pushReplacementNamed(context, '/patient_dashboard');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleTimeSlot(String day, String timeSlot) {
    setState(() {
      if (_doctorAvailability[day]!.contains(timeSlot)) {
        _doctorAvailability[day]!.remove(timeSlot);
      } else {
        _doctorAvailability[day]!.add(timeSlot);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with reduced opacity
          Opacity(
            opacity: 0.3,
            child: Image.asset(
              'lib/images/signupbackground.png',
              fit: BoxFit.cover,
            ),
          ),
          // Semi-transparent overlay for better text visibility
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 24.0,
                right: 24.0,
                top: 24.0,
                bottom: keyboardHeight > 0 ? keyboardHeight + 24.0 : 24.0,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // App Logo and Title
                  Container(
                    width: 85,
                    height: 85,
                    decoration: BoxDecoration(
                      color: AppColors.docplanBlue,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Image(
                      image: AssetImage('lib/images/booking-app_15090912.png'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'DocPlan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppColors.docplanBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Welcome to smart healthcare scheduling',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Main content area
                  _showSignUp ? _buildSignUpForm() : _buildSignInForm(),

                  const SizedBox(height: 24),

                  // Bottom buttons
                  _buildBottomButtons(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Column(
      children: [
        if (!_showSignUp) ...[
          CustomButton(
            text: 'Sign In',
            onPressed: _isLoading ? null : _signIn,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Don't have an account? ",
                style: TextStyle(color: AppColors.textWhite, fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showSignUp = true;
                  });
                },
                child: const Text(
                  'Sign Up',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          CustomButton(
            text: 'Sign Up',
            onPressed: _isLoading ? null : _signUp,
            isLoading: _isLoading,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Already have an account? ',
                style: TextStyle(color: AppColors.textWhite, fontSize: 16),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showSignUp = false;
                  });
                },
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildSignInForm() {
    return Form(
      key: _signInFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _signInEmailController,
            label: 'Email',
            icon: Icons.email,
            style: TextStyle(color: AppColors.textPrimary),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _signInPasswordController,
            label: 'Password',
            icon: Icons.lock,
            style: TextStyle(color: AppColors.textPrimary),
            obscureText: _obscureSignInPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignInPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureSignInPassword = !_obscureSignInPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Form(
      key: _signUpFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person,
            style: TextStyle(color: AppColors.textPrimary),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _signUpEmailController,
            label: 'Email',
            icon: Icons.email,
            style: TextStyle(color: AppColors.textPrimary),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          // Role Selection Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.textSecondary),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(
                  Icons.person_outline,
                  color: AppColors.textSecondary,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'patient', child: Text('Patient')),
                DropdownMenuItem(value: 'doctor', child: Text('Doctor')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ),
          const SizedBox(height: 16),
          // Doctor Specialty (only for doctors)
          if (_selectedRole == 'doctor') ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.textSecondary),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedSpecialty.isEmpty ? null : _selectedSpecialty,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  icon: Icon(
                    Icons.medical_services,
                    color: AppColors.textSecondary,
                  ),
                  hintText: 'Select Specialty',
                ),
                items: _specialties.map((specialty) {
                  return DropdownMenuItem(
                    value: specialty,
                    child: Text(specialty),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSpecialty = value ?? '';
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          CustomTextField(
            controller: TextEditingController(
              text: _selectedCountry.isEmpty ? '' : _selectedCountry,
            ),
            label: 'Country',
            icon: Icons.flag,
            onTap: _showCountryPicker,
            suffixIcon: Icon(Icons.arrow_drop_down),
            style: TextStyle(color: AppColors.textPrimary),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.textSecondary),
                ),
                child: Text(
                  _selectedCountryCode.isEmpty
                      ? '+1'
                      : '+$_selectedCountryCode',
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  icon: Icons.phone,
                  style: TextStyle(color: AppColors.textPrimary),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _signUpPasswordController,
            label: 'Password',
            icon: Icons.lock,
            obscureText: _obscureSignUpPassword,
            style: TextStyle(color: AppColors.textPrimary),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureSignUpPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureSignUpPassword = !_obscureSignUpPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          // Doctor Availability (only for doctors)
          if (_selectedRole == 'doctor') ...[
            const SizedBox(height: 20),
            const Text(
              'Select Your Availability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textWhite,
              ),
            ),
            const SizedBox(height: 16),
            ..._daysOfWeek.map((day) => _buildDayAvailability(day)),
          ],
        ],
      ),
    );
  }

  Widget _buildDayAvailability(String day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.textSecondary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            day,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _timeSlots.map((timeSlot) {
              bool isSelected = _doctorAvailability[day]!.contains(timeSlot);
              return GestureDetector(
                onTap: () => _toggleTimeSlot(day, timeSlot),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  child: Text(
                    timeSlot,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textWhite
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() =>
      this.length > 0 ? '${this[0].toUpperCase()}${this.substring(1)}' : '';
}

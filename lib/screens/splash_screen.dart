import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();

    // Check authentication state and navigate accordingly
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Wait for 3 seconds to show splash screen
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final user = _authService.currentUser;

    if (user != null) {
      // User is logged in, check their role and navigate to appropriate dashboard
      try {
        final userData = await _authService.getUserData(user.uid);
        if (mounted) {
          if (userData != null) {
            switch (userData.role) {
              case 'doctor':
                Navigator.pushReplacementNamed(context, '/doctor_dashboard');
                break;
              case 'admin':
                Navigator.pushReplacementNamed(context, '/admin_dashboard');
                break;
              case 'patient':
              default:
                Navigator.pushReplacementNamed(context, '/patient_dashboard');
                break;
            }
          } else {
            // User data not found, go to auth screen
            Navigator.pushReplacementNamed(context, '/auth');
          }
        }
      } catch (e) {
        // Error fetching user data, go to auth screen
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/auth');
        }
      }
    } else {
      // User is not logged in, go to auth screen
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.docplanBlue,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image.asset(
          //   'lib/images/docplan.jpg',
          //   fit: BoxFit.cover,
          // ),
          Center(
            child: AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // App Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.textWhite,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.medical_services,
                            size: 60,
                            color: AppColors.docplanBlue,
                          ),
                        ),
                        const SizedBox(height: 30),

                        // App Name
                        const Text(
                          'DocPlan',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Tagline
                        const Text(
                          'Smart Healthcare Scheduling',
                          style: TextStyle(
                            color: AppColors.textWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // Loading indicator
                        const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.textWhite,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/assets/app_assets.dart';
import '../../../core/theme/app_theme.dart';

/// Splash screen with app branding and initialization
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

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeApp();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _animationController.forward();
  }

  void _initializeApp() {
    // Trigger authentication check after splash animation
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // context.read<AuthBloc>().add(AuthCheckRequested()); // Temporarily disabled
        // For now, navigate directly to login since auth is disabled
        _navigateToLogin();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _scaleAnimation.value,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            AppAssets.splashLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.white,
                                child: const Icon(
                                  Icons.tour,
                                  size: 60,
                                  color: AppTheme.primaryColor,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Tourlicity',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const Text(
                  'Your Journey Begins Here',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
    );
  }

  void _navigateToLogin() {
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/login');
    }
  }
}
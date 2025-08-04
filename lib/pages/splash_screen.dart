import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late AnimationController _iconController;
  late AnimationController _textController;
  late AnimationController _loadingController;
  late AnimationController _floatingController;
  late AnimationController _rotationController;
  
  late Animation<double> _backgroundAnimation;
  late Animation<double> _iconAnimation;
  late Animation<double> _textAnimation;
  late Animation<double> _loadingAnimation;
  late Animation<double> _floatingAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _iconController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _loadingController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _floatingController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    // Initialize animations
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.easeInOut),
    );
    _iconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.elasticOut),
    );
    _textAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeInOut),
    );
    _loadingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _loadingController, curve: Curves.easeInOut),
    );
    _floatingAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    
    // Start animation sequence
    _startAnimationSequence();
    
    // Navigation logic (unchanged)
    Future.delayed(const Duration(seconds: 4), () {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    });
  }
  
  void _startAnimationSequence() async {
    // Background fade-in (0-500ms)
    _backgroundController.forward();
    
    // App icon scale-in with bounce (500-1000ms)
    await Future.delayed(const Duration(milliseconds: 500));
    _iconController.forward();
    
    // Brand text fade-in from bottom (1000-1500ms)
    await Future.delayed(const Duration(milliseconds: 500));
    _textController.forward();
    
    // Loading indicator fade-in (1500-2000ms)
    await Future.delayed(const Duration(milliseconds: 500));
    _loadingController.forward();
    
    // Start continuous animations
    _floatingController.repeat(reverse: true);
    _rotationController.repeat();
  }
  
  @override
  void dispose() {
    _backgroundController.dispose();
    _iconController.dispose();
    _textController.dispose();
    _loadingController.dispose();
    _floatingController.dispose();
    _rotationController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: SafeArea(
        child: Scaffold(
          body: AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF8FFFE).withOpacity(_backgroundAnimation.value),
                      Color(0xFFE8F8F5).withOpacity(_backgroundAnimation.value),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Floating decorative elements
                    AnimatedBuilder(
                      animation: _floatingAnimation,
                      builder: (context, child) {
                        return Stack(
                          children: [
                            // Floating circle 1
                            Positioned(
                              top: 100 + (_floatingAnimation.value * 20),
                              right: 50 + (_floatingAnimation.value * 10),
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00C48C).withOpacity(0.1),
                                      const Color(0xFF00A876).withOpacity(0.05),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Floating circle 2
                            Positioned(
                              top: 200 - (_floatingAnimation.value * 15),
                              left: 30 + (_floatingAnimation.value * 8),
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00A876).withOpacity(0.08),
                                      const Color(0xFF00C48C).withOpacity(0.03),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Floating circle 3
                            Positioned(
                              bottom: 150 + (_floatingAnimation.value * 25),
                              right: 80 - (_floatingAnimation.value * 12),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00C48C).withOpacity(0.06),
                                      const Color(0xFF00A876).withOpacity(0.02),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            // Floating circle 4
                            Positioned(
                              bottom: 250 - (_floatingAnimation.value * 18),
                              left: 60 + (_floatingAnimation.value * 15),
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(0xFF00A876).withOpacity(0.04),
                                      const Color(0xFF00C48C).withOpacity(0.01),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    // Main content
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Icon with animation
                          AnimatedBuilder(
                            animation: _iconAnimation,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _iconAnimation.value,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF00C48C), Color(0xFF00A876)],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00C48C).withOpacity(0.3),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF00C48C).withOpacity(0.1),
                                        blurRadius: 40,
                                        offset: const Offset(0, 16),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.agriculture,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 40),
                          
                          // Brand text with animation
                          AnimatedBuilder(
                            animation: _textAnimation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - _textAnimation.value)),
                                child: Opacity(
                                  opacity: _textAnimation.value,
                                  child: Column(
                                    children: [
                                      Text(
                                        'PINTAR',
                                        style: TextStyle(
                                          fontSize: 36,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF2D3748),
                                          letterSpacing: -0.5,
                                          height: 1.2,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 24),
                                      Text(
                                        'Pandowoharjo Integrated Auto Farming',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF718096),
                                          height: 1.4,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          
                          const SizedBox(height: 60),
                          
                          // Modern loading indicator with animation
                          AnimatedBuilder(
                            animation: _loadingAnimation,
                            builder: (context, child) {
                              return Opacity(
                                opacity: _loadingAnimation.value,
                                child: Column(
                                  children: [
                                    // Custom gradient loading ring
                                    AnimatedBuilder(
                                      animation: _rotationAnimation,
                                      builder: (context, child) {
                                        return Transform.rotate(
                                          angle: _rotationAnimation.value * 2 * math.pi,
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            child: CustomPaint(
                                              painter: GradientRingPainter(),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 20),
                                    Text(
                                      'Memuat aplikasi...',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF718096),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class GradientRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Create gradient paint
    final paint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF00C48C), Color(0xFF00A876), Colors.transparent],
        stops: [0.0, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Draw arc (3/4 of circle)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 1.5),
      -math.pi / 2,
      3 * math.pi / 2,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

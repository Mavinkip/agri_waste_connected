import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _navigate();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (user.email == 'admin@farm.com') {
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = doc.data()?['role'] ?? 'farmer';

      switch (role) {
        case 'driver':
          Navigator.pushReplacementNamed(context, '/driver/home');
          break;
        case 'company':
          Navigator.pushReplacementNamed(context, '/company/dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/farmer/home');
      }
    } catch (_) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E7D32),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Animated Logo ───
            SizedBox(
              width: 200,
              height: 200,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Arrows (behind the leaf)
                  RotationTransition(
                    turns: _rotationController,
                    child: Image.asset(
                      'assets/logo/arrows.png',  // ← Updated path
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                    ),
                  ),
                  // Static Leaf (on top, doesn't rotate)
                  Image.asset(
                    'assets/logo/leaf.png',  // ← Updated path
                    width: 100,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ─── App Name ───
            const Text(
              'Agri Cycle',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),

            // ─── Tagline ───
            const Text(
              'Waste is Wealth',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 32),

            // ─── Loading Indicator ───
            const CircularProgressIndicator(
              color: Colors.white54,
            ),
          ],
        ),
      ),
    );
  }
}
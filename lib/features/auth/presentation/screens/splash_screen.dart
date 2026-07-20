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

    // Start rotation animation
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _navigate();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    // Wait for authentication to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    // Check for admin (hardcoded email)
    if (user.email == 'admin@farm.com') {
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!mounted) return;

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
    } catch (e) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A7A4A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Spinning Ring with Circular Leaf ───
            SizedBox(
              width: 150,
              height: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Spinning progress ring
                  RotationTransition(
                    turns: _rotationController,
                    child: const SizedBox(
                      width: 150,
                      height: 150,
                      child: CircularProgressIndicator(
                        value: null,
                        strokeWidth: 4,
                        color: Colors.white,
                        backgroundColor: Colors.white24,
                      ),
                    ),
                  ),
                  // Circular leaf (white background removed)
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: const AssetImage('assets/logo/leaf.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
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
          ],
        ),
      ),
    );
  }
}
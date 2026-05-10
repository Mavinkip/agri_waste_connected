import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
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
          .collection('users').doc(user.uid).get();
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
    return const Scaffold(
      backgroundColor: Color(0xFF1A7A4A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text('Agri-Waste Connect',
                style: TextStyle(color: Colors.white, fontSize: 24,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Turn Waste into Wealth',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white54),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Agri-Waste Connect', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 48),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number / Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Default to Farmer for demo
                  NavigationService.pushReplacement('/farmer/home');
                },
                child: const Text('Login as Farmer'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  NavigationService.pushReplacement('/driver/login');
                },
                child: const Text('Login as Driver'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  NavigationService.pushReplacement('/admin/login');
                },
                child: const Text('Login as Admin'),
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: () {
                NavigationService.push('/register');
              },
              child: const Text('New User? Register Here'),
            ),
          ],
        ),
      ),
    );
  }
}

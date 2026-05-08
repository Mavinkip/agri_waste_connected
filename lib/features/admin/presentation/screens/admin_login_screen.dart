import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Recycle Farm Manager Login'),
            const SizedBox(height: 32),
<<<<<<< HEAD
            const TextField(
              decoration: InputDecoration(
=======
            TextField(
              decoration: const InputDecoration(
>>>>>>> upstream/master
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
<<<<<<< HEAD
            const TextField(
              obscureText: true,
              decoration: InputDecoration(
=======
            TextField(
              obscureText: true,
              decoration: const InputDecoration(
>>>>>>> upstream/master
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  NavigationService.replace('/admin/dashboard');
                },
                child: const Text('LOG IN'),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('Forgot password?'),
            ),
          ],
        ),
      ),
    );
  }
}

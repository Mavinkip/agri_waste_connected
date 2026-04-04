import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const TextField(decoration: InputDecoration(labelText: 'Full Name')),
            const TextField(decoration: InputDecoration(labelText: 'Phone Number')),
            const TextField(decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                NavigationService.pop();
              },
              child: const Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

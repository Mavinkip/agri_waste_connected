import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class DriverLoginScreen extends StatefulWidget {
  const DriverLoginScreen({super.key});

  @override
  State<DriverLoginScreen> createState() => _DriverLoginScreenState();
}

class _DriverLoginScreenState extends State<DriverLoginScreen> {
  final TextEditingController _employeeIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool rememberMe = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('DRIVER PORTAL'),
            const SizedBox(height: 32),
            TextField(
              controller: _employeeIdController,
              decoration: const InputDecoration(
                labelText: 'Employee ID',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Checkbox(
                  value: rememberMe,
                  onChanged: (value) => setState(() => rememberMe = value ?? false),
                ),
                const Text('Remember me'),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  NavigationService.replace('/driver/route');
                },
                child: const Text('LOGIN'),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Trouble logging in? Call Dispatch: 0800-XXX-XXX'),
          ],
        ),
      ),
    );
  }
}

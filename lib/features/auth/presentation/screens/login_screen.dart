import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/navigation_service.dart';

// Hardcoded admin credentials
const _adminEmail = 'admin@farm.com';
const _adminPassword = '1234567890';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _cleanPhone(String phone) =>
      phone.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    final input = _phoneController.text.trim();
    final password = _passwordController.text;

    // ── ADMIN LOGIN ──
    if (input == _adminEmail && password == _adminPassword) {
      if (mounted) NavigationService.pushReplacement('/admin/dashboard');
      return;
    }

    // ── EMAIL LOGIN (Company or other email users) ──
    if (input.contains('@')) {
      try {
        final credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: input, password: password);

        if (credential.user != null) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(credential.user!.uid)
              .get();

          if (!doc.exists) {
            setState(() {
              _error = 'Account not found. Please contact admin.';
              _loading = false;
            });
            return;
          }

          final role = doc.data()?['role'] ?? 'farmer';
          if (mounted) {
            switch (role) {
              case 'company':
                NavigationService.pushReplacement('/company/dashboard');
                break;
              case 'driver':
                NavigationService.pushReplacement('/driver/home');
                break;
              default:
                NavigationService.pushReplacement('/farmer/home');
            }
          }
        }
      } on FirebaseAuthException catch (e) {
        String msg;
        switch (e.code) {
          case 'user-not-found':
            msg = 'No account found. Please contact admin.';
            break;
          case 'wrong-password':
          case 'invalid-credential':
            msg = 'Incorrect password. Try again.';
            break;
          case 'too-many-requests':
            msg = 'Too many attempts. Please wait.';
            break;
          case 'network-request-failed':
            msg = 'No internet connection.';
            break;
          default:
            msg = 'Login failed. Please try again.';
        }
        setState(() { _error = msg; _loading = false; });
      }
      return;
    }

    // ── PHONE LOGIN (farmer / driver) ──
    try {
      final phone = _cleanPhone(input);
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: '$phone@agri.local',
        password: password,
      );

      if (credential.user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(credential.user!.uid)
            .get();

        if (!doc.exists) {
          setState(() {
            _error = 'Account not found. Please register.';
            _loading = false;
          });
          return;
        }

        final role = doc.data()?['role'] ?? 'farmer';
        if (mounted) {
          switch (role) {
            case 'driver':
              NavigationService.pushReplacement('/driver/home');
              break;
            default:
              NavigationService.pushReplacement('/farmer/home');
          }
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found':
          msg = 'No account found. Please register first.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          msg = 'Incorrect password. Try again.';
          break;
        case 'too-many-requests':
          msg = 'Too many attempts. Please wait.';
          break;
        case 'network-request-failed':
          msg = 'No internet connection.';
          break;
        default:
          msg = 'Login failed. Please try again.';
      }
      setState(() { _error = msg; _loading = false; });
    } catch (e) {
      setState(() {
        _error = 'Something went wrong. Please try again.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              Center(
                child: Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Icon(Icons.agriculture_rounded,
                      color: Colors.white, size: 50),
                ),
              ),
              const SizedBox(height: 30),
              const Text('Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Login with phone number or email',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(children: [
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number or Email',
                      prefixIcon: Icon(Icons.person),
                      hintText: '0712345678 or company@email.com',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscure,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscure
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      return null;
                    },
                  ),
                ]),
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13))),
                    ]),
                  ),
                ),

              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Login',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(
                  onPressed: () => NavigationService.push('/register'),
                  child: const Text('Register as Farmer'),
                ),
                const Text(' | ',
                    style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () =>
                      NavigationService.push('/register-driver'),
                  child: const Text('Register as Driver'),
                ),
              ]),
              TextButton(
                onPressed: () =>
                    NavigationService.push('/forgot-password'),
                child: const Text('Forgot Password?'),
              ),

              // Info hint
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Column(
                  children: [
                    Row(children: [
                      Icon(Icons.info_outline,
                          color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Company Login: Use your email address',
                          style: TextStyle(
                              fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ]),
                    SizedBox(height: 4),
                    Row(children: [
                      SizedBox(width: 24),
                      Expanded(
                        child: Text(
                          'Farmer Login: Use phone number',
                          style: TextStyle(
                              fontSize: 11, color: Colors.blue),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

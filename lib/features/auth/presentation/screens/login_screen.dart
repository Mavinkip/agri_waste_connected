<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

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

  String _cleanPhone(String phone) => phone.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });

    try {
      final phone = _cleanPhone(_phoneController.text);
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: '$phone@agri.local',
        password: _passwordController.text,
      );
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/farmer/home', (_) => false);
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'user-not-found': msg = 'No account found. Please register first.'; break;
        case 'wrong-password': msg = 'Incorrect password. Try again or reset it.'; break;
        case 'invalid-email': msg = 'Invalid phone number format.'; break;
        case 'user-disabled': msg = 'This account has been disabled. Contact support.'; break;
        case 'too-many-requests': msg = 'Too many attempts. Please wait and try again.'; break;
        case 'network-request-failed': msg = 'No internet connection. Check your network.'; break;
        default: msg = 'Login failed. Please try again.';
      }
      setState(() { _error = msg; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Something went wrong. Please try again.'; _loading = false; });
    }
  }
=======
import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
>>>>>>> upstream/master

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 60),
              Center(child: Container(width: 100, height: 100, decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(30)), child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 50))),
              const SizedBox(height: 30),
              const Text('Welcome Back!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Login with your phone number', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 40),

              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 13,
                decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '0712345678', border: OutlineInputBorder(), counterText: ''),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Phone number is required';
                  if (_cleanPhone(v).length < 10) return 'Enter a valid phone number (10+ digits)';
                  return null;
                },
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscure,
                decoration: InputDecoration(labelText: 'Password', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(), suffixIcon: IconButton(icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscure = !_obscure))),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Password is required';
                  if (v.length < 6) return 'Password must be at least 6 characters';
                  return null;
                },
              ),

              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)), child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)))]),),
                ),

              const SizedBox(height: 20),
              SizedBox(height: 52, child: ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: _loading ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 10), Text('Logging in...', style: TextStyle(color: Colors.white, fontSize: 16))]) : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              )),
              const SizedBox(height: 16),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text('Create Account')),
                const Text(' | ', style: TextStyle(color: Colors.grey)),
                TextButton(onPressed: () => Navigator.of(context).pushNamed('/forgot-password'), child: const Text('Forgot Password?')),
              ]),
            ]),
          ),
=======
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
>>>>>>> upstream/master
        ),
      ),
    );
  }
}

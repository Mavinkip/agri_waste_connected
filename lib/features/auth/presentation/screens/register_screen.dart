<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  String? _error;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _nameController.dispose(); _phoneController.dispose();
    _passwordController.dispose(); _confirmController.dispose();
    super.dispose();
  }

  String _cleanPhone(String p) => p.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      setState(() => _error = 'Please accept the terms and conditions');
      return;
    }
    setState(() { _loading = true; _error = null; });

    try {
      final phone = _cleanPhone(_phoneController.text);
      final email = '$phone@agri.local';
      final name = _nameController.text.trim();

      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: _passwordController.text);
      await FirebaseFirestore.instance.collection('users').doc(credential.user!.uid).set({
        'fullName': name, 'phoneNumber': phone, 'role': 'farmer', 'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Account created! Please login.')]), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        Navigator.of(context).pop();
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use': msg = 'This phone number is already registered. Please login.'; break;
        case 'weak-password': msg = 'Password is too weak. Use at least 6 characters.'; break;
        case 'network-request-failed': msg = 'No internet connection. Check your network.'; break;
        default: msg = 'Registration failed. Please try again.';
      }
      setState(() { _error = msg; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Something went wrong. Please try again.'; _loading = false; });
    }
  }
=======
import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});
>>>>>>> upstream/master

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Register'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 10),
            const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Join as a farmer', style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : v.trim().length < 2 ? 'Name too short' : null),
            const SizedBox(height: 14),
            TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 13, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '0712345678', border: OutlineInputBorder(), counterText: ''), validator: (v) => v == null || _cleanPhone(v).length < 10 ? 'Enter a valid phone number (10+ digits)' : null),
            const SizedBox(height: 14),
            TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()), validator: (v) => v == null || v.length < 6 ? 'Password must be at least 6 characters' : null),
            const SizedBox(height: 14),
            TextFormField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()), validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
            const SizedBox(height: 8),
            Row(children: [
              Checkbox(value: _termsAccepted, onChanged: (v) => setState(() => _termsAccepted = v!), activeColor: AppColors.primaryGreen),
              const Expanded(child: Text('I agree to the Terms & Conditions', style: TextStyle(fontSize: 13))),
            ]),
            if (_error != null) Padding(padding: const EdgeInsets.only(top: 8), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)))]))),
            const SizedBox(height: 20),
            SizedBox(height: 52, child: ElevatedButton(onPressed: _loading ? null : _register, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _loading ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 10), Text('Creating account...', style: TextStyle(color: Colors.white))]) : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
            const SizedBox(height: 14),
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Already have an account? Login')),
          ]),
=======
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
>>>>>>> upstream/master
        ),
      ),
    );
  }
}

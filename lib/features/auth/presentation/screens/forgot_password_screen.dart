import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;

  bool _loading = false;
  bool _codeSent = false;
  String? _error;
  String? _verificationId;
  String? _successMsg;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  String _cleanPhone(String p) => p.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _sendCode() async {
    final phone = _cleanPhone(_phoneController.text);
    if (phone.length < 10) { setState(() => _error = 'Enter a valid phone number'); return; }
    setState(() { _loading = true; _error = null; });

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: '+254${phone.substring(phone.length - 9)}',
        verificationCompleted: (_) {},
        verificationFailed: (e) => setState(() { _error = 'Failed to send code: ${e.message}'; _loading = false; }),
        codeSent: (verificationId, _) => setState(() { _verificationId = verificationId; _codeSent = true; _loading = false; _successMsg = 'A verification code has been sent to your phone'; }),
        codeAutoRetrievalTimeout: (_) {},
      );
    } catch (e) {
      setState(() { _error = 'Failed to send code. Check your network.'; _loading = false; });
    }
  }

  Future<void> _verifyAndReset() async {
    final code = _codeController.text.trim();
    if (code.length < 4 || _verificationId == null) { setState(() => _error = 'Enter the verification code'); return; }
    if (_newPasswordController.text.length < 6) { setState(() => _error = 'Password must be at least 6 characters'); return; }
    setState(() { _loading = true; _error = null; });

    try {
      final credential = PhoneAuthProvider.credential(verificationId: _verificationId!, smsCode: code);
      await _auth.signInWithCredential(credential);
      await _auth.currentUser?.updatePassword(_newPasswordController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Row(children: [Icon(Icons.check_circle, color: Colors.white), SizedBox(width: 8), Text('Password reset! Please login.')]), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating));
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() { _error = 'Invalid code or reset failed. Try again.'; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(title: const Text('Reset Password'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 20),
            const Icon(Icons.lock_reset, size: 64, color: AppColors.primaryGreen),
            const SizedBox(height: 16),
            const Text('Reset Your Password', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(_codeSent ? 'Enter the code sent to your phone' : 'Enter your phone number', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),

            if (!_codeSent) ...[
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, maxLength: 13, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '0712345678', border: OutlineInputBorder(), counterText: ''), validator: (v) => _cleanPhone(v ?? '').length < 10 ? 'Enter valid number' : null),
              const SizedBox(height: 16),
              SizedBox(height: 52, child: ElevatedButton(onPressed: _loading ? null : _sendCode, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send Verification Code', style: TextStyle(fontSize: 16)))),
            ] else ...[
              if (_successMsg != null) Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.check_circle, color: Colors.green, size: 18), const SizedBox(width: 8), Text(_successMsg!, style: const TextStyle(color: Colors.green, fontSize: 13))])),
              TextFormField(controller: _codeController, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: 'Verification Code', prefixIcon: Icon(Icons.pin), hintText: '123456', border: OutlineInputBorder(), counterText: ''), validator: (v) => v == null || v.length < 4 ? 'Enter code' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()), validator: (v) => v == null || v.length < 6 ? 'Min 6 characters' : null),
              const SizedBox(height: 16),
              SizedBox(height: 52, child: ElevatedButton(onPressed: _loading ? null : _verifyAndReset, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Reset Password', style: TextStyle(fontSize: 16)))),
              TextButton(onPressed: _sendCode, child: const Text('Resend Code')),
            ],

            if (_error != null) Padding(padding: const EdgeInsets.only(top: 12), child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.error_outline, color: Colors.red, size: 18), const SizedBox(width: 8), Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13)))]))),
          ]),
        ),
      ),
    );
  }
}

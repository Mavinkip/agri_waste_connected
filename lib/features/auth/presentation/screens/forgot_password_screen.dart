import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/phone_auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _phoneAuth = PhoneAuthService();
  
  bool _loading = false;
  bool _otpSent = false;
  bool _verified = false;
  String? _error;

  void _sendOTP() {
    final phone = _phoneController.text.trim();
    if (phone.length < 10) {
      setState(() => _error = 'Enter valid phone number');
      return;
    }
    setState(() { _loading = true; _error = null; });
    _phoneAuth.sendOTP(
      phoneNumber: phone,
      onCodeSent: (vid) => setState(() { _otpSent = true; _loading = false; }),
      onError: (e) => setState(() { _error = e; _loading = false; }),
    );
  }

  void _verifyOTP() async {
    if (_otpController.text.length < 4) return;
    setState(() => _loading = true);
    final result = await _phoneAuth.verifyOTP(_otpController.text);
    if (mounted) {
      if (result != null) {
        setState(() { _verified = true; _loading = false; });
      } else {
        setState(() { _error = 'Invalid OTP'; _loading = false; });
      }
    }
  }

  void _resetPassword() {
    if (_newPasswordController.text.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset! Please login.'), backgroundColor: Colors.green));
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const SizedBox(height: 20),
          const Icon(Icons.lock_reset, size: 64, color: AppColors.primaryGreen),
          const SizedBox(height: 16),
          const Text('Reset Password', textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(_verified ? 'Enter new password' : _otpSent ? 'Enter OTP sent to your phone' : 'Enter phone number', textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 24),

          if (!_otpSent) ...[
            TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), border: OutlineInputBorder())),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loading ? null : _sendOTP, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, padding: const EdgeInsets.all(14)), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Send OTP', style: TextStyle(fontSize: 16))),
          ] else if (!_verified) ...[
            TextField(controller: _otpController, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: 'OTP Code', prefixIcon: Icon(Icons.pin), border: OutlineInputBorder())),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _verifyOTP, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, padding: const EdgeInsets.all(14)), child: _loading ? const CircularProgressIndicator(color: Colors.white) : const Text('Verify OTP', style: TextStyle(fontSize: 16))),
            TextButton(onPressed: _sendOTP, child: const Text('Resend OTP')),
          ] else ...[
            TextField(controller: _newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'New Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder())),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _resetPassword, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, padding: const EdgeInsets.all(14)), child: const Text('Reset Password', style: TextStyle(fontSize: 16))),
          ],

          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
          ],
        ]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';
import '../../../../shared/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _register() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegisterRequested(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      role: UserRole.farmer,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(title: const Text('Register')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 10),
              const Text('Create Account', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Join as a farmer', style: TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 24),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Name is required' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '0712345678', border: OutlineInputBorder()), validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required' : v.trim().length < 10 ? 'Enter valid number' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()), validator: (v) => v == null || v.isEmpty ? 'Password is required' : v.length < 6 ? 'Min 6 characters' : null),
              const SizedBox(height: 14),
              TextFormField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()), validator: (v) => v != _passwordController.text ? 'Passwords do not match' : null),
              const SizedBox(height: 24),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  final loading = state is AuthLoading;
                  if (state is AuthAuthenticated) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Account created! Please login.'), backgroundColor: Colors.green));
                      Navigator.of(context).pop();
                    });
                  }
                  return SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : _register,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: loading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  );
                },
              ),
              const SizedBox(height: 14),
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Already have an account? Login')),
            ]),
          ),
        ),
      ),
    );
  }
}

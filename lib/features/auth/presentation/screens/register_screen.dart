import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../../../../shared/models/user_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _pass = TextEditingController();
  final _confirm = TextEditingController();

  void _register() {
    if (!_form.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthRegisterRequested(fullName: _name.text.trim(), phoneNumber: _phone.text.trim(), password: _pass.text, role: UserRole.farmer));
  }

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _pass.dispose(); _confirm.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (ctx, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Registered! Please login.'), backgroundColor: Colors.green));
            Navigator.of(ctx).pop();
          }
          if (state is AuthError) ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(state.message), backgroundColor: Colors.red));
        },
        builder: (ctx, state) {
          final loading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.backgroundLight,
            appBar: AppBar(title: const Text('Register')),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(key: _form, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SizedBox(height: 10),
                const Text('Create Account', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextFormField(controller: _name, enabled: !loading, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person), border: OutlineInputBorder()), validator: (v) => v == null || v!.trim().isEmpty ? 'Name required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _phone, enabled: !loading, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '0712345678', border: OutlineInputBorder()), validator: (v) => v == null || v!.trim().isEmpty ? 'Phone required' : v.trim().length < 10 ? 'Valid number required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _pass, enabled: !loading, obscureText: true, decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock), border: OutlineInputBorder()), validator: (v) => v == null || v!.isEmpty ? 'Password required' : v.length < 6 ? 'Min 6 chars' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _confirm, enabled: !loading, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm Password', prefixIcon: Icon(Icons.lock_outline), border: OutlineInputBorder()), validator: (v) => v != _pass.text ? 'Passwords dont match' : null),
                const SizedBox(height: 20),
                SizedBox(height: 48, child: ElevatedButton(onPressed: loading ? null : _register, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: loading ? const Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)), SizedBox(width: 10), Text('Registering...', style: TextStyle(color: Colors.white))]) : const Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
                const SizedBox(height: 12),
                TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Already have an account? Login')),
              ])),
            ),
          );
        },
      ),
    );
  }
}

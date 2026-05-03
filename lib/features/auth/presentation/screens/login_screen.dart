import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthLoginRequested(
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text.trim(),
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(30)),
                    child: const Icon(Icons.agriculture_rounded, color: Colors.white, size: 50),
                  ),
                ),
                const SizedBox(height: 30),
                const Text('Welcome Back!', textAlign: TextAlign.center, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone), hintText: '0712345678', border: OutlineInputBorder()),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Phone is required' : v.trim().length < 10 ? 'Enter valid number' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password', prefixIcon: const Icon(Icons.lock), border: const OutlineInputBorder(),
                    suffixIcon: IconButton(icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility), onPressed: () => setState(() => _obscurePassword = !_obscurePassword)),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Password is required' : v.length < 6 ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 24),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    final loading = state is AuthLoading;
                    if (state is AuthAuthenticated) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        Navigator.of(context).pushNamedAndRemoveUntil('/farmer/home', (route) => false);
                      });
                    }
                    return SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: loading ? null : _login,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: loading
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextButton(onPressed: () => Navigator.of(context).pushNamed('/register'), child: const Text("Don't have an account? Register")),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

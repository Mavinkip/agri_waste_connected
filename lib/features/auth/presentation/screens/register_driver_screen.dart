import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../../core/services/navigation_service.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _licenceController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscure = true;
  String? _error;
  bool _termsAccepted = false;

  final List<String> _vehicleTypes = [
    'Pickup Truck',
    'Lorry',
    'Tractor',
    'Motorcycle',
    'Other',
  ];
  String? _selectedVehicleType;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _licenceController.dispose();
    _vehicleController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _cleanPhone(String p) =>
      p.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_termsAccepted) {
      setState(() => _error = 'Please accept the terms and conditions');
      return;
    }
    if (_selectedVehicleType == null) {
      setState(() => _error = 'Please select a vehicle type');
      return;
    }

    setState(() { _loading = true; _error = null; });

    try {
      final phone = _cleanPhone(_phoneController.text);
      final email = '$phone@agri.local';

      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'fullName': _nameController.text.trim(),
        'phoneNumber': phone,
        'role': 'driver',
        'licenceNumber': _licenceController.text.trim().toUpperCase(),
        'vehicleNumber': _vehicleController.text.trim().toUpperCase(),
        'vehicleType': _selectedVehicleType,
        'isAvailable': false,
        'isActive': true,
        'completedPickups': 0,
        'averageRating': 0.0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Driver account created! Please login.'),
            ]),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        NavigationService.pushReplacement('/login');
      }
    } on FirebaseAuthException catch (e) {
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This phone number is already registered.';
          break;
        case 'weak-password':
          msg = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'network-request-failed':
          msg = 'No internet connection.';
          break;
        default:
          msg = 'Registration failed. Please try again.';
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
      appBar: AppBar(
        title: const Text('Register as Driver'),
        centerTitle: true,
        backgroundColor: AppColors.primaryBlue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: AppColors.primaryBlue.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.local_shipping,
                      color: AppColors.primaryBlue, size: 32),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Driver Registration',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: AppColors.primaryBlue)),
                        Text(
                            'You will need a valid driver\'s licence to register.',
                            style: TextStyle(
                                fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 24),

              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 2) {
                    return 'Enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                maxLength: 13,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone),
                  hintText: '0712345678',
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
                validator: (v) {
                  if (v == null || _cleanPhone(v).length < 10) {
                    return 'Enter a valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Licence Number
              TextFormField(
                controller: _licenceController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Driver\'s Licence Number',
                  prefixIcon: Icon(Icons.badge),
                  hintText: 'e.g. DL1234567',
                  border: OutlineInputBorder(),
                  helperText: 'Enter your official Kenya driving licence number',
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 5) {
                    return 'Enter a valid licence number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Vehicle Number Plate
              TextFormField(
                controller: _vehicleController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Number Plate',
                  prefixIcon: Icon(Icons.directions_car),
                  hintText: 'e.g. KCA 123A',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 4) {
                    return 'Enter vehicle number plate';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Vehicle Type dropdown
              DropdownButtonFormField<String>(
                value: _selectedVehicleType,
                decoration: const InputDecoration(
                  labelText: 'Vehicle Type',
                  prefixIcon: Icon(Icons.local_shipping),
                  border: OutlineInputBorder(),
                ),
                items: _vehicleTypes
                    .map((t) => DropdownMenuItem(
                    value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedVehicleType = v),
              ),
              const SizedBox(height: 14),

              // Password
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
                  if (v == null || v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Terms
              Row(children: [
                Checkbox(
                  value: _termsAccepted,
                  onChanged: (v) =>
                      setState(() => _termsAccepted = v!),
                  activeColor: AppColors.primaryBlue,
                ),
                const Expanded(
                  child: Text('I agree to the Terms & Conditions',
                      style: TextStyle(fontSize: 13)),
                ),
              ]),

              // Error
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline,
                          color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 13))),
                    ]),
                  ),
                ),

              const SizedBox(height: 20),

              // Register Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _loading
                      ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                      : const Text('Register as Driver',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 14),
              TextButton(
                onPressed: () => NavigationService.pop(),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../../core/services/navigation_service.dart';
import '../../../../shared/data/kenya_locations.dart';

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

  // Region selection
  String? _selectedCounty;
  String? _selectedSubCounty;
  String? _selectedWard;
  List<String> _availableSubCounties = [];
  List<String> _availableWards = [];
  List<String> _counties = [];

  @override
  void initState() {
    super.initState();
    _loadCounties();
  }

  void _loadCounties() {
    setState(() {
      _counties = KenyaLocations.getCountyNames();
      print('Loaded counties: $_counties'); // Debug print
    });
  }

  void _loadSubCounties(String county) {
    print('Loading sub-counties for: $county'); // Debug print
    final subCounties = KenyaLocations.getSubCountyNames(county);
    print('Found sub-counties: $subCounties'); // Debug print

    setState(() {
      _availableSubCounties = subCounties;
      _selectedSubCounty = null;
      _selectedWard = null;
      _availableWards = [];
    });

    if (_availableSubCounties.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No sub-counties found for $county'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _loadWards(String county, String subCounty) {
    print('Loading wards for: $county - $subCounty'); // Debug print
    final wards = KenyaLocations.getWardNames(county, subCounty);
    print('Found wards: $wards'); // Debug print

    setState(() {
      _availableWards = wards;
      _selectedWard = null;
    });

    if (_availableWards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No wards found for $subCounty'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _cleanPhone(String p) => p.replaceAll(RegExp(r'[^0-9]'), '');

  Future<void> _register() async {
    // Validate form
    if (!_formKey.currentState!.validate()) return;

    // Check terms acceptance
    if (!_termsAccepted) {
      setState(() => _error = 'Please accept the terms and conditions');
      return;
    }

    // Validate region selection
    if (_selectedCounty == null) {
      setState(() => _error = 'Please select your county');
      return;
    }

    if (_selectedSubCounty == null) {
      setState(() => _error = 'Please select your sub-county');
      return;
    }

    if (_selectedWard == null) {
      setState(() => _error = 'Please select your ward');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final phone = _cleanPhone(_phoneController.text);
      final email = '$phone@agri.local';
      final name = _nameController.text.trim();

      print('Registering user: $name, $phone, $email'); // Debug print

      // Create Firebase Auth user
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: _passwordController.text,
      );

      print('User created: ${credential.user!.uid}'); // Debug print

      // Store user data in Firestore with region info including ward
      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
        'fullName': name,
        'phoneNumber': phone,
        'role': 'farmer',
        'county': _selectedCounty,
        'subCounty': _selectedSubCounty,
        'ward': _selectedWard,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'totalEarnings': 0,
        'completedPickups': 0,
        'consistencyScore': 70,
      });

      print('User data saved to Firestore'); // Debug print

      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Account created! Please login.'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Navigate back to login
        NavigationService.pop();
      }
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}'); // Debug print
      String msg;
      switch (e.code) {
        case 'email-already-in-use':
          msg = 'This phone number is already registered. Please login.';
          break;
        case 'weak-password':
          msg = 'Password is too weak. Use at least 6 characters.';
          break;
        case 'network-request-failed':
          msg = 'No internet connection. Check your network.';
          break;
        default:
          msg = 'Registration failed: ${e.message}';
      }
      setState(() {
        _error = msg;
        _loading = false;
      });
    } catch (e) {
      print('General error: $e'); // Debug print
      setState(() {
        _error = 'Something went wrong: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              const Text(
                'Create Account',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Join as a farmer',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),

              // Full Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Name is required';
                  if (v.trim().length < 2) return 'Name too short';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Phone Number Field
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
                    return 'Enter a valid phone number (10+ digits)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // County Selection
              DropdownButtonFormField<String>(
                value: _selectedCounty,
                decoration: const InputDecoration(
                  labelText: 'County',
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                ),
                items: _counties.map((county) {
                  return DropdownMenuItem(
                    value: county,
                    child: Text(county),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCounty = value;
                    });
                    _loadSubCounties(value);
                  }
                },
                validator: (v) => v == null ? 'Please select your county' : null,
              ),
              const SizedBox(height: 14),

              // Sub-County Selection
              if (_selectedCounty != null)
                DropdownButtonFormField<String>(
                  value: _selectedSubCounty,
                  decoration: const InputDecoration(
                    labelText: 'Sub-County',
                    prefixIcon: Icon(Icons.location_on),
                    border: OutlineInputBorder(),
                  ),
                  items: _availableSubCounties.map((subCounty) {
                    return DropdownMenuItem(
                      value: subCounty,
                      child: Text(subCounty),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedSubCounty = value;
                      });
                      _loadWards(_selectedCounty!, value);
                    }
                  },
                  validator: (v) => v == null ? 'Please select your sub-county' : null,
                ),
              const SizedBox(height: 14),

              // Ward Selection
              if (_selectedSubCounty != null)
                DropdownButtonFormField<String>(
                  value: _selectedWard,
                  decoration: const InputDecoration(
                    labelText: 'Ward',
                    prefixIcon: Icon(Icons.place),
                    border: OutlineInputBorder(),
                  ),
                  items: _availableWards.map((ward) {
                    return DropdownMenuItem(
                      value: ward,
                      child: Text(ward),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedWard = value;
                    });
                  },
                  validator: (v) => v == null ? 'Please select your ward' : null,
                ),
              const SizedBox(height: 14),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // Confirm Password Field
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

              // Terms & Conditions
              Row(
                children: [
                  Checkbox(
                    value: _termsAccepted,
                    onChanged: (v) => setState(() => _termsAccepted = v!),
                    activeColor: AppColors.primaryGreen,
                  ),
                  const Expanded(
                    child: Text(
                      'I agree to the Terms & Conditions',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),

              // Error Message
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 20),

              // Register Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Creating account...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )
                      : const Text(
                    'Register',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Login Link
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

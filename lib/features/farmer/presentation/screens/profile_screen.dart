import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/farmer_app_menu.dart';
import '../widgets/profile_notifier.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: '');
  final _phoneController = TextEditingController(text: '');
  final _locationController = TextEditingController(text: '');
  final _imagePicker = ImagePicker();
  String? _profileImagePath;
  bool _editing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt, color: Colors.green)),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final photo = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 70, maxWidth: 512);
                if (photo != null) setState(() => _profileImagePath = photo.path);
              },
            ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library, color: Colors.blue)),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () async {
                Navigator.pop(ctx);
                final image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 70, maxWidth: 512);
                if (image != null) setState(() => _profileImagePath = image.path);
              },
            ),
          ]),
        ),
      ),
    );
  }

  void _saveProfile() {
    ProfileNotifier.instance.save(name: _nameController.text.trim(), photoPath: _profileImagePath);
    setState(() => _editing = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved!'), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This will permanently delete your account and all data. This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await FirebaseAuth.instance.currentUser?.delete();
              } catch (_) {}
              if (mounted) Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_editing ? Icons.check : Icons.edit, color: Colors.white),
            onPressed: _editing ? _saveProfile : () => setState(() => _editing = true),
          ),
          const FarmerAppMenu(currentScreen: 'profile'),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 10),
          // Profile Picture
          GestureDetector(
            onTap: _editing ? _pickProfileImage : null,
            child: Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  backgroundImage: _profileImagePath != null ? FileImage(File(_profileImagePath!)) : null,
                  child: _profileImagePath == null ? const Icon(Icons.person, size: 50, color: AppColors.primaryGreen) : null,
                ),
                if (_editing)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(color: AppColors.primaryGreen, shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                  ),
              ],
            ),
          ),
          if (_editing) const SizedBox(height: 8),
          if (_editing) Text('Tap to change photo', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          const SizedBox(height: 24),

          // Info Cards
          _infoCard(icon: Icons.person, label: 'Full Name', controller: _nameController, editing: _editing),
          const SizedBox(height: 10),
          _infoCard(icon: Icons.phone, label: 'Phone Number', controller: _phoneController, editing: _editing, keyboardType: TextInputType.phone),
          const SizedBox(height: 10),
          _infoCard(icon: Icons.location_on, label: 'Location', controller: _locationController, editing: _editing),
          const SizedBox(height: 16),

          // Stats
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(children: [
                _statRow('Role', 'Farmer', Icons.agriculture),
                const Divider(),
                _statRow('Member Since', DateTime.now().toString().substring(0, 10), Icons.calendar_today),
                const Divider(),
                _statRow('Total Collections', '12', Icons.local_shipping),
                const Divider(),
                _statRow('Rating', '4.5 ⭐', Icons.star),
              ]),
            ),
          ),
          const SizedBox(height: 20),

          // Delete Account
          SizedBox(
            width: double.infinity, height: 40,
            child: TextButton(
              onPressed: _confirmDeleteAccount,
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.delete_forever, color: Colors.red, size: 18),
                SizedBox(width: 8),
                Text('Delete My Account', style: TextStyle(color: Colors.red, fontSize: 14)),
              ]),
            ),
          ),
          const SizedBox(height: 12),

          // Logout
          SizedBox(
            width: double.infinity, height: 48,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false),
              icon: const Icon(Icons.logout, color: Colors.red, size: 20),
              label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String label, required TextEditingController controller, required bool editing, TextInputType? keyboardType}) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primaryGreen, size: 22)),
          const SizedBox(width: 14),
          Expanded(child: editing
              ? TextField(controller: controller, keyboardType: keyboardType, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true))
              : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                  const SizedBox(height: 2),
                  Text(controller.text.isNotEmpty ? controller.text : 'Tap edit to add', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                ])),
        ]),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.primaryGreen),
        const SizedBox(width: 10),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

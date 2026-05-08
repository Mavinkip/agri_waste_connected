import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../widgets/farmer_app_menu.dart';

class PhotoScreen extends StatefulWidget {
  const PhotoScreen({super.key});
  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  final ImagePicker _picker = ImagePicker();
  String? _imagePath;
  bool _hasPhoto = false;

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (photo != null) {
        setState(() {
          _imagePath = photo.path;
          _hasPhoto = true;
        });
        context.read<SellWizardCubit>().addPhoto(photo.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _pickGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
      );
      if (image != null) {
        setState(() {
          _imagePath = image.path;
          _hasPhoto = true;
        });
        context.read<SellWizardCubit>().addPhoto(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gallery error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showOptions() {
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
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.camera_alt, color: Colors.green, size: 24)),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Use your camera'),
              onTap: () { Navigator.pop(ctx); _takePhoto(); },
            ),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.photo_library, color: Colors.blue, size: 24)),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Select existing photo'),
              onTap: () { Navigator.pop(ctx); _pickGallery(); },
            ),
            if (_hasPhoto)
              ListTile(
                leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.delete, color: Colors.red, size: 24)),
                title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() { _imagePath = null; _hasPhoto = false; });
                  context.read<SellWizardCubit>().removePhoto();
                },
              ),
          ]),
        ),
      ),
    );
  }

  void _goNext() {
    if (!_hasPhoto) context.read<SellWizardCubit>().skipPhoto();
    Navigator.of(context).pushNamed('/farmer/sell/location');
  }

  Widget _step(int n, bool active) => Container(width: 28, height: 28, decoration: BoxDecoration(color: active ? const Color(0xFF2D5A27) : Colors.grey.shade300, borderRadius: BorderRadius.circular(14)), child: Center(child: Text('$n', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))));
  Widget _line() => Expanded(child: Container(height: 2, color: Colors.grey.shade300));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Add Photo'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        actions: const [FarmerAppMenu(currentScreen: 'home')],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Row(children: [_step(1, true), _line(), _step(2, true), _line(), _step(3, true), _line(), _step(4, false)]),
          const SizedBox(height: 20),
          const Text('Take a photo of your waste', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Optional but helps the driver', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 20),

          // Photo preview or placeholder
          GestureDetector(
            onTap: _showOptions,
            child: Container(
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 2),
              ),
              child: _hasPhoto && _imagePath != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(File(_imagePath!), fit: BoxFit.cover),
                          Positioned(top: 8, right: 8, child: GestureDetector(
                            onTap: () {
                              setState(() { _imagePath = null; _hasPhoto = false; });
                              context.read<SellWizardCubit>().removePhoto();
                            },
                            child: Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Icon(Icons.close, color: Colors.white, size: 18)),
                          )),
                        ],
                      ),
                    )
                  : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFF2D5A27).withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.add_a_photo, size: 36, color: Color(0xFF2D5A27))),
                      const SizedBox(height: 12),
                      const Text('Tap to add photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text('Camera or Gallery', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
                    ]),
            ),
          ),
          const SizedBox(height: 12),

          // Action buttons
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: _takePhoto, icon: const Icon(Icons.camera_alt, size: 18), label: const Text('Camera'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
            const SizedBox(width: 8),
            Expanded(child: OutlinedButton.icon(onPressed: _pickGallery, icon: const Icon(Icons.photo_library, size: 18), label: const Text('Gallery'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          ]),
          const SizedBox(height: 12),

          // Tips
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber.shade200)), child: const Row(children: [Icon(Icons.lightbulb, color: Colors.amber, size: 18), SizedBox(width: 8), Expanded(child: Text('Good lighting, show full pile, no plastic bags', style: TextStyle(fontSize: 12)))])),
          const Spacer(),

          // Navigation
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => Navigator.of(context).pop(), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Back'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: _goNext, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Text('Continue', style: TextStyle(fontSize: 16)))),
          ]),
          const SizedBox(height: 8),
          Center(child: TextButton(onPressed: () { context.read<SellWizardCubit>().skipPhoto(); Navigator.of(context).pushNamed('/farmer/sell/location'); }, child: const Text('Skip Photo'))),
        ]),
      ),
    );
  }
}

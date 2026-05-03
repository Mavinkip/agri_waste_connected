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

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (photo != null) {
        setState(() => _imagePath = photo.path);
        context.read<SellWizardCubit>().addPhoto(photo.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to take photo: $e')),
      );
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (image != null) {
        setState(() => _imagePath = image.path);
        context.read<SellWizardCubit>().addPhoto(image.path);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading:
                    const Icon(Icons.camera_alt, color: Colors.green, size: 28),
                title: const Text('Take Photo',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Use your camera'),
                onTap: () {
                  Navigator.pop(ctx);
                  _takePhoto();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library,
                    color: Colors.blue, size: 28),
                title: const Text('Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text('Select an existing photo'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFromGallery();
                },
              ),
              if (_imagePath != null)
                ListTile(
                  leading:
                      const Icon(Icons.delete, color: Colors.red, size: 28),
                  title: const Text('Remove Photo',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(ctx);
                    setState(() => _imagePath = null);
                    context.read<SellWizardCubit>().removePhoto();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final hasPhoto = _imagePath != null || cubit.photoPath != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Photo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: const [
          FarmerAppMenu(currentScreen: 'sell'),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
                value: 0.75, backgroundColor: Colors.grey.shade200),
            const SizedBox(height: 20),
            const Text('Take a photo (optional)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('A clear photo helps the driver identify your waste',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 20),

            // Photo preview or placeholder
            GestureDetector(
              onTap: hasPhoto ? null : _showPhotoOptions,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: hasPhoto
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePath ?? cubit.photoPath!),
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _imagePath = null);
                                cubit.removePhoto();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.close,
                                    color: Colors.white, size: 18),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo,
                              size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 12),
                          Text('Tap to add photo',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text('Camera or Gallery',
                              style: TextStyle(
                                  color: Colors.grey.shade400, fontSize: 13)),
                        ],
                      ),
              ),
            ),

            if (hasPhoto) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: _showPhotoOptions,
                  icon: const Icon(Icons.swap_horiz, size: 18),
                  label: const Text('Change Photo'),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Tips
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Good lighting & show the full pile for best results',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Back', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (!hasPhoto) cubit.skipPhoto();
                      Navigator.of(context).pushNamed('/farmer/sell/location');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child:
                        const Text('Continue', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () {
                  cubit.skipPhoto();
                  Navigator.of(context).pushNamed('/farmer/sell/location');
                },
                child: const Text('Skip Photo', style: TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

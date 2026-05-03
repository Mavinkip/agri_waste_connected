import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  String? selectedLanguage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Your Language / Chagua Lugha'),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('English'),
              leading: Radio<String>(
                value: 'English',
                groupValue: selectedLanguage,
                onChanged: (value) => setState(() => selectedLanguage = value),
              ),
            ),
            ListTile(
              title: const Text('Kiswahili'),
              leading: Radio<String>(
                value: 'Kiswahili',
                groupValue: selectedLanguage,
                onChanged: (value) => setState(() => selectedLanguage = value),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: selectedLanguage == null ? null : () {
                NavigationService.replace('/farmer/home');
              },
              child: const Text('CONTINUE'),
            ),
          ],
        ),
      ),
    );
  }
}

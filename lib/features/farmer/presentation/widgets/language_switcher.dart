import 'package:flutter/material.dart';
import '../../../../shared/services/translations.dart';

class LanguageSwitcher extends StatefulWidget {
  const LanguageSwitcher({super.key});

  @override
  State<LanguageSwitcher> createState() => _LanguageSwitcherState();
}

class _LanguageSwitcherState extends State<LanguageSwitcher> {
  String _currentLang = 'en'; // Default English

  void _toggleLanguage() {
    setState(() {
      _currentLang = _currentLang == 'en' ? 'sw' : 'en';
    });
  }

  static String currentLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: InkWell(
        onTap: () {
          _toggleLanguage();
          currentLanguage = _currentLang;
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _currentLang == 'en' ? '🇬🇧' : '🇰🇪',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 4),
              Text(
                _currentLang == 'en' ? 'EN' : 'SW',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

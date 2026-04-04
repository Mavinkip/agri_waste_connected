import 'package:flutter/material.dart';
import '../../../../../core/services/navigation_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-advance to login after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        NavigationService.pushReplacement('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('Agri-Waste Connect'),
            SizedBox(height: 16),
            Text('Turn Waste into Wealth'),
            SizedBox(height: 16),
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('No smartphone? Dial *384*50#'),
          ],
        ),
      ),
    );
  }
}

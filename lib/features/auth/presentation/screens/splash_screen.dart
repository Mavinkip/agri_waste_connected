import 'package:flutter/material.dart';
<<<<<<< HEAD

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
=======
import '../../../../../core/services/navigation_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

>>>>>>> upstream/master
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

<<<<<<< HEAD
class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _scale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
=======
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
>>>>>>> upstream/master
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
<<<<<<< HEAD
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Transform.scale(
                scale: _scale.value,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20)]),
                  child: const Icon(Icons.agriculture_rounded, size: 60, color: Color(0xFF2D5A27)),
                ),
              ),
              const SizedBox(height: 24),
              Opacity(
                opacity: _fade.value,
                child: Column(children: [
                  const Text('Agri-Waste', style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold, color: Colors.white)),
                  const Text('Connect', style: TextStyle(fontSize: 16, color: Colors.white70, letterSpacing: 5)),
                ]),
              ),
            ]),
          ),
=======
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
>>>>>>> upstream/master
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineBanner extends StatefulWidget {
  final Widget child;
  const OfflineBanner({super.key, required this.child});

  static final ValueNotifier<bool> isOffline = ValueNotifier<bool>(false);
  static late StreamSubscription _subscription;

  static void init() {
    _subscription = Connectivity().onConnectivityChanged.listen((result) {
      isOffline.value = result == ConnectivityResult.none;
    });
    Connectivity().checkConnectivity().then((result) {
      isOffline.value = result == ConnectivityResult.none;
    });
  }

  static void dispose() {
    _subscription.cancel();
  }

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    OfflineBanner.init();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: OfflineBanner.isOffline,
      builder: (context, offline, _) {
        if (offline) {
          _animController.forward();
        } else {
          _animController.reverse();
        }

        return Column(children: [
          // Online indicator (subtle green bar)
          if (!offline)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 2),
              color: Colors.green.shade600.withValues(alpha: 0.8),
              child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.wifi, color: Colors.white, size: 10),
                SizedBox(width: 4),
                Text('Online', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w600)),
              ]),
            ),

          // Offline banner (animated orange bar)
          if (offline)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.orange.shade800, Colors.orange.shade600]),
                  boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 6, offset: const Offset(0, 2))],
                ),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                  const SizedBox(width: 8),
                  const Text('You are offline', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 4),
                  Text('• Changes will sync when connected', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 11)),
                ]),
              ),
            ),

          // Main content
          Expanded(child: widget.child),
        ]);
      },
    );
  }
}

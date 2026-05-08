// lib/features/farmer/presentation/widgets/farmer_app_menu.dart
import 'package:flutter/material.dart';

class FarmerAppMenu extends StatelessWidget {
  final String currentScreen;
  
  const FarmerAppMenu({
    super.key,
    this.currentScreen = '',
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) {
        switch (value) {
          case 'home':
            Navigator.of(context).pushNamedAndRemoveUntil('/farmer/home', (route) => false);
            break;
          case 'profile':
            Navigator.of(context).pushNamed('/farmer/profile');
            break;
          case 'earnings':
            Navigator.of(context).pushNamed('/farmer/earnings');
            break;
          case 'sell':
            Navigator.of(context).pushNamed('/farmer/sell/waste-type');
            break;
          case 'schedule':
            Navigator.of(context).pushNamed('/farmer/schedule');
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'home',
          enabled: currentScreen != 'home',
          child: const ListTile(
            leading: Icon(Icons.home, size: 20),
            title: Text('Home', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'profile',
          enabled: currentScreen != 'profile',
          child: const ListTile(
            leading: Icon(Icons.person, size: 20),
            title: Text('Profile', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'earnings',
          enabled: currentScreen != 'earnings',
          child: const ListTile(
            leading: Icon(Icons.account_balance_wallet, size: 20),
            title: Text('Earnings', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'sell',
          enabled: currentScreen != 'sell',
          child: const ListTile(
            leading: Icon(Icons.add_circle_outline, size: 20),
            title: Text('Sell Waste', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
        PopupMenuItem(
          value: 'schedule',
          enabled: currentScreen != 'schedule',
          child: const ListTile(
            leading: Icon(Icons.schedule, size: 20),
            title: Text('Schedule', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            dense: true,
          ),
        ),
      ],
    );
  }
}
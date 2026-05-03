import 'package:flutter/material.dart';

class FarmerAppMenu extends StatelessWidget {
  final String currentScreen;
  
  const FarmerAppMenu({super.key, this.currentScreen = ''});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        switch (value) {
          case 'home':
            Navigator.of(context).pushNamedAndRemoveUntil('/farmer/home', (route) => false);
          case 'profile':
            Navigator.of(context).pushNamed('/farmer/profile');
          case 'earnings':
            Navigator.of(context).pushNamed('/farmer/earnings');
          case 'sell':
            Navigator.of(context).pushNamed('/farmer/sell/waste-type');
          case 'schedule':
            Navigator.of(context).pushNamed('/farmer/schedule');
        }
      },
      itemBuilder: (context) => [
        _item(Icons.home, 'Home', 'home'),
        _item(Icons.person, 'Profile', 'profile'),
        _item(Icons.account_balance_wallet, 'Earnings', 'earnings'),
        _item(Icons.add_circle_outline, 'Sell Waste', 'sell'),
        _item(Icons.schedule, 'Schedule', 'schedule'),
      ],
    );
  }

  PopupMenuItem<String> _item(IconData icon, String title, String value) {
    final disabled = currentScreen == value;
    return PopupMenuItem<String>(
      value: value,
      enabled: !disabled,
      child: Row(
        children: [
          Icon(icon, size: 20, color: disabled ? Colors.grey : null),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(fontSize: 14, color: disabled ? Colors.grey : null)),
        ],
      ),
    );
  }
}

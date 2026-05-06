import 'package:flutter/material.dart';

class FarmerAppMenu extends StatelessWidget {
  final String currentScreen;
  const FarmerAppMenu({super.key, this.currentScreen = ''});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (value) {
        if (!context.mounted) return;
        switch (value) {
          case 'home': Navigator.of(context).pushNamedAndRemoveUntil('/farmer/home', (_) => false);
          case 'profile': Navigator.of(context).pushNamed('/farmer/profile');
          case 'notifications': Navigator.of(context).pushNamed('/farmer/notifications');
          case 'help': Navigator.of(context).pushNamed('/farmer/help');
          case 'logout': Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
        }
      },
      itemBuilder: (context) => [
        _item(Icons.home, 'Home', 'home'),
        _item(Icons.person, 'Profile', 'profile'),
        _item(Icons.notifications, 'Notifications', 'notifications'),
        _item(Icons.help_outline, 'Help', 'help'),
        const PopupMenuDivider(),
        _item(Icons.logout, 'Logout', 'logout'),
      ],
    );
  }

  PopupMenuItem<String> _item(IconData icon, String title, String value) {
    final disabled = currentScreen == value;
    return PopupMenuItem<String>(
      value: value, enabled: !disabled,
      child: Row(children: [
        Icon(icon, size: 20, color: disabled ? Colors.grey : null),
        const SizedBox(width: 12),
        Text(title, style: TextStyle(fontSize: 14, color: disabled ? Colors.grey : null)),
      ]),
    );
  }
}

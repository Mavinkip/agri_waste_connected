import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';

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
          case 'home':
            Navigator.of(context).pushNamedAndRemoveUntil('/farmer/home', (route) => false);
          case 'earnings':
            Navigator.of(context).pushNamed('/farmer/earnings');
          case 'sell':
            Navigator.of(context).pushNamed('/farmer/sell/waste-type');
          case 'schedule':
            Navigator.of(context).pushNamed('/farmer/schedule');
          case 'logout':
            context.read<AuthBloc>().add(AuthLogoutRequested());
            Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      },
      itemBuilder: (context) => [
        _item(Icons.home, 'Home', 'home'),
        _item(Icons.account_balance_wallet, 'Earnings', 'earnings'),
        _item(Icons.add_circle_outline, 'Sell Waste', 'sell'),
        _item(Icons.schedule, 'Schedule', 'schedule'),
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

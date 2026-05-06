import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../widgets/farmer_app_menu.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final listing = cubit.state.createdListing;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(title: const Text('Success'), centerTitle: true, automaticallyImplyLeading: false, actions: const [FarmerAppMenu(currentScreen: 'home')]),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Spacer(),
            // Success icon
            Container(width: 100, height: 100, decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), shape: BoxShape.circle), child: const Icon(Icons.check_circle_rounded, size: 60, color: Colors.green)),
            const SizedBox(height: 24),
            const Text('Order Placed! 🎉', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('A driver will come to collect your waste', textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.grey)),
            const SizedBox(height: 24),

            // Ticket card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
              child: Column(children: [
                _row('Ticket #', listing?.id ?? 'AG-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}'),
                const Divider(height: 20),
                _row('Status', 'Pending'),
                const Divider(height: 20),
                _row('Pickup', 'Within 48 hours'),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('You will receive an SMS when the driver is on the way', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Colors.grey)),
            const Spacer(),
            SizedBox(width: double.infinity, height: 52, child: ElevatedButton(onPressed: () { cubit.resetWizard(); Navigator.of(context).pushNamedAndRemoveUntil('/farmer/home', (_) => false); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Back to Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
          ]),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: TextStyle(color: Colors.grey.shade600)), Text(value, style: const TextStyle(fontWeight: FontWeight.w600))]);
  }
}

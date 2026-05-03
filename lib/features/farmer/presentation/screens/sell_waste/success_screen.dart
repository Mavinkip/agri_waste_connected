import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sell_wizard_cubit.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    final listing = cubit.state.createdListing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'home') {
                cubit.resetWizard();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/farmer/home', (route) => false);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'home', child: Text('Home')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    size: 50, color: Colors.green),
              ),
              const SizedBox(height: 20),
              const Text('SUCCESS! 🎉',
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green)),
              const SizedBox(height: 8),
              const Text('Your waste is listed for pickup!',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _row(
                        'Ticket #',
                        listing?.id ??
                            'AG-${DateTime.now().millisecondsSinceEpoch}'),
                    const Divider(),
                    _row('Status', 'Pending'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text("You'll receive an SMS when a driver is assigned.",
                  style: TextStyle(color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    cubit.resetWizard();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        '/farmer/home', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Back to Dashboard',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sell_wizard_cubit.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Estimate Quantity'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'home') {
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
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(
                value: 0.50, backgroundColor: Colors.grey.shade200),
            const SizedBox(height: 20),
            const Text('How much do you have?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('Tap a preset or enter exact quantity',
                style: TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 24),
            // Presets
            ...[
              '🌱 Small (10-50 kg)',
              '🌿 Medium (60-200 kg)',
              '🌳 Large (210-500 kg)',
              '🚛 Truckload (510+ kg)'
            ].asMap().entries.map((e) {
              final kg = [30.0, 130.0, 355.0, 750.0][e.key];
              return _buildPreset(context, cubit, e.value, kg);
            }),
            const SizedBox(height: 20),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Or enter exact kg',
                suffixText: 'kg',
                prefixIcon: const Icon(Icons.scale),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (val) {
                final q = double.tryParse(val);
                if (q != null && q > 0) {
                  cubit.enterQuantity(q);
                  Navigator.of(context).pushNamed('/farmer/sell/photo');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreset(
      BuildContext context, SellWizardCubit cubit, String label, double kg) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () {
          cubit.enterQuantity(kg);
          Navigator.of(context).pushNamed('/farmer/sell/photo');
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w500)),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

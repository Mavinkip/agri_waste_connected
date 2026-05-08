import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../widgets/farmer_app_menu.dart';

class QuantityScreen extends StatelessWidget {
  const QuantityScreen({super.key});

  void _select(BuildContext context, double kg) {
    context.read<SellWizardCubit>().enterQuantity(kg);
    Navigator.of(context).pushNamed('/farmer/sell/photo');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Quantity'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        actions: const [FarmerAppMenu(currentScreen: 'home')],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Progress
          Row(children: [
            _step(1, true), _line(), _step(2, true), _line(), _step(3, false), _line(), _step(4, false),
          ]),
          const SizedBox(height: 20),
          const Text('How much waste do you have?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Estimate the quantity in kilograms', style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 24),

          // Preset cards
          _preset(context, '🌱', 'Small', '10 - 50 kg', 'About 1-5 bags', 30, const Color(0xFF81C784)),
          _preset(context, '🌿', 'Medium', '60 - 200 kg', 'About 6-20 bags', 130, const Color(0xFF66BB6A)),
          _preset(context, '🌳', 'Large', '210 - 500 kg', 'About 21-50 bags', 355, const Color(0xFF4CAF50)),
          _preset(context, '🚛', 'Truckload', '510+ kg', '51+ bags', 750, const Color(0xFF388E3C)),
          const SizedBox(height: 12),

          // Manual entry
          const Text('Or enter exact quantity:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          const SizedBox(height: 8),
          TextField(
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter kg', suffixText: 'kg',
              prefixIcon: const Icon(Icons.scale),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true, fillColor: Colors.white,
            ),
            onSubmitted: (v) {
              final q = double.tryParse(v);
              if (q != null && q > 0) _select(context, q);
            },
          ),
        ]),
      ),
    );
  }

  Widget _step(int number, bool active) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(color: active ? const Color(0xFF2D5A27) : Colors.grey.shade300, borderRadius: BorderRadius.circular(14)),
      child: Center(child: Text('$number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
    );
  }

  Widget _line() => Expanded(child: Container(height: 2, color: Colors.grey.shade300));

  Widget _preset(BuildContext context, String emoji, String title, String range, String bags, double kg, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () => _select(context, kg),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              const SizedBox(height: 2),
              Text('$range  •  $bags', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
            ])),
            SizedBox(
              width: 44, height: 44,
              child: Container(decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Center(child: Text('${kg.toInt()}kg', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)))),
            ),
          ]),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../../../../shared/models/waste_listing_model.dart';
import '../../widgets/farmer_app_menu.dart';

class WasteTypeScreen extends StatelessWidget {
  const WasteTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Sell Waste'),
        centerTitle: true,
        leading: IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.of(context).pushReplacementNamed('/farmer/home')),
        actions: const [FarmerAppMenu(currentScreen: 'home')],
      ),
      body: Column(children: [
        // Progress bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: Row(children: [
            _step(1, true), _line(), _step(2, false), _line(), _step(3, false), _line(), _step(4, false),
          ]),
        ),
        const SizedBox(height: 8),
        // Title
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('What type of waste do you have?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Select one to continue', style: TextStyle(fontSize: 14, color: Colors.grey)),
        ),
        const SizedBox(height: 12),
        // Waste type list
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: [
              _tile(context, cubit, Icons.grass_outlined, 'Crop Residue', 'Maize stalks, wheat straw, rice straw', WasteType.cropResidue, const Color(0xFF2E7D32)),
              _tile(context, cubit, Icons.eco_outlined, 'Vegetable Waste', 'Kales, cabbage, tomato rejects', WasteType.vegetableWaste, const Color(0xFF558B2F)),
              _tile(context, cubit, Icons.local_florist_outlined, 'Fruit Waste', 'Mango, banana, avocado waste', WasteType.fruitWaste, const Color(0xFFFF6F00)),
              _tile(context, cubit, Icons.pets_outlined, 'Livestock Manure', 'Cow, goat, chicken manure', WasteType.livestockManure, const Color(0xFF5D4037)),
              _tile(context, cubit, Icons.coffee_outlined, 'Coffee Husks', 'Coffee processing waste', WasteType.coffeeHusks, const Color(0xFF4E342E)),
              _tile(context, cubit, Icons.grain_outlined, 'Rice Hulls', 'Rice milling byproduct', WasteType.riceHulls, const Color(0xFFFFA000)),
              _tile(context, cubit, Icons.agriculture_outlined, 'Corn Stover', 'Maize stalks after harvest', WasteType.cornStover, const Color(0xFF00897B)),
              _tile(context, cubit, Icons.category_outlined, 'Other Waste', 'Any other agricultural waste', WasteType.other, const Color(0xFF78909C)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _step(int number, bool active) {
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2D5A27) : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(child: Text('$number', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
    );
  }

  Widget _line() => Expanded(child: Container(height: 2, color: Colors.grey.shade300));

  Widget _tile(BuildContext context, SellWizardCubit cubit, IconData icon, String title, String subtitle, WasteType type, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        onTap: () {
          cubit.selectWasteType(type);
          Navigator.of(context).pushNamed('/farmer/sell/quantity');
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ]),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Text('Select', style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
            ),
          ]),
        ),
      ),
    );
  }
}

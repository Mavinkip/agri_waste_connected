import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/sell_wizard_cubit.dart';
import '../../bloc/farmer_bloc.dart';
import '../../../../../shared/models/waste_listing_model.dart';
import '../../../data/repositories/farmer_repository.dart';
import '../../../../../../core/di/injection.dart';

class WasteTypeScreen extends StatefulWidget {
  const WasteTypeScreen({super.key});

  @override
  State<WasteTypeScreen> createState() => _WasteTypeScreenState();
}

class _WasteTypeScreenState extends State<WasteTypeScreen> {
  PricingInfo? _pricingInfo;
  double? _consistencyScore;

  @override
  void initState() {
    super.initState();
    final farmerBloc = sl<FarmerBloc>()
      ..add(const LoadPricingInfo())
      ..add(const LoadConsistencyScore());

    farmerBloc.stream.listen((state) {
      if (state is PricingInfoLoaded) {
        setState(() => _pricingInfo = state.pricingInfo);
      } else if (state is ConsistencyScoreLoaded) {
        setState(() => _consistencyScore = state.score);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SellWizardCubit>();
    if (cubit == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Waste Type'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              Navigator.of(context).pushReplacementNamed('/farmer/home'),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'home') {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/farmer/home', (route) => false);
              } else if (value == 'earnings') {
                Navigator.of(context).pushNamed('/farmer/earnings');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'home', child: Text('Home')),
              const PopupMenuItem(value: 'earnings', child: Text('Earnings')),
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
                value: 0.25, backgroundColor: Colors.grey.shade200),
            const SizedBox(height: 20),
            const Text('What are you selling?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(
              _pricingInfo != null
                  ? 'Prices set by admin • Tap to select'
                  : 'Loading prices...',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                children: [
                  _buildCard(context, cubit, Icons.grass, 'Crop Residue',
                      WasteType.cropResidue, Colors.green),
                  _buildCard(context, cubit, Icons.local_florist, 'Fruit Waste',
                      WasteType.fruitWaste, Colors.orange),
                  _buildCard(context, cubit, Icons.eco, 'Vegetable Waste',
                      WasteType.vegetableWaste, Colors.lightGreen),
                  _buildCard(context, cubit, Icons.pets, 'Livestock Manure',
                      WasteType.livestockManure, Colors.brown),
                  _buildCard(context, cubit, Icons.coffee, 'Coffee Husks',
                      WasteType.coffeeHusks, Colors.brown.shade700),
                  _buildCard(context, cubit, Icons.grain, 'Rice Hulls',
                      WasteType.riceHulls, Colors.amber),
                  _buildCard(context, cubit, Icons.agriculture, 'Corn Stover',
                      WasteType.cornStover, Colors.teal),
                  _buildCard(context, cubit, Icons.category, 'Other Waste',
                      WasteType.other, Colors.grey),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, SellWizardCubit cubit, IconData icon,
      String label, WasteType type, Color color) {
    // Get price from admin-set pricing
    String priceText = 'Loading...';
    if (_pricingInfo != null) {
      final price = _pricingInfo!.getPriceForWasteType(
        type.name, // Uses enum name like "cropResidue" as key
        _consistencyScore ?? 0,
      );
      priceText = 'KSh ${price.toStringAsFixed(2)}/kg';
    }

    return GestureDetector(
      onTap: () {
        cubit.selectWasteType(type);
        Navigator.of(context).pushNamed('/farmer/sell/quantity');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 10),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 13, height: 1.2)),
            const SizedBox(height: 4),
            Text(priceText,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

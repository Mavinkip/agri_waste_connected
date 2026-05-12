import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class CompanyPricingScreen extends StatefulWidget {
  final String companyId;
  final Map<String, dynamic> companyData;

  const CompanyPricingScreen({
    super.key,
    required this.companyId,
    required this.companyData,
  });

  @override
  State<CompanyPricingScreen> createState() => _CompanyPricingScreenState();
}

class _CompanyPricingScreenState extends State<CompanyPricingScreen> {
  final List<String> _wasteTypes = [
    'cropResidue', 'livestockManure', 'fruitWaste',
    'coffeeHusks', 'vegetableWaste', 'sugarcaneBagasse',
  ];
  
  late Map<String, TextEditingController> _controllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controllers = {};
    final currentPrices = widget.companyData['priceList'] as Map<String, dynamic>? ?? {};
    for (var type in _wasteTypes) {
      _controllers[type] = TextEditingController(
        text: (currentPrices[type] ?? 0).toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _savePrices() async {
    setState(() => _isSaving = true);
    
    final Map<String, double> priceList = {};
    for (var type in _wasteTypes) {
      final price = double.tryParse(_controllers[type]!.text);
      if (price != null && price > 0) {
        priceList[type] = price;
      }
    }
    
    await FirebaseFirestore.instance
        .collection('companies')
        .doc(widget.companyId)
        .update({'priceList': priceList});
    
    setState(() => _isSaving = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prices updated successfully!'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Set Your Buying Prices', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Set competitive prices to attract more farmers', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ..._wasteTypes.map((type) => _buildPriceCard(type)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _savePrices,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save All Prices', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(String wasteType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_formatWasteType(wasteType), style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Text('per kilogram', style: TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            SizedBox(
              width: 120,
              child: TextField(
                controller: _controllers[wasteType],
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'KSh/kg',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatWasteType(String type) {
    final map = {
      'cropResidue': '🌾 Crop Residue',
      'livestockManure': '🐄 Livestock Manure',
      'fruitWaste': '🍎 Fruit Waste',
      'coffeeHusks': '☕ Coffee Husks',
      'vegetableWaste': '🥬 Vegetable Waste',
      'sugarcaneBagasse': '🌿 Sugarcane Bagasse',
    };
    return map[type] ?? type;
  }
}

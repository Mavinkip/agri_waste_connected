import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/models/community_model.dart';
import '../../../../../shared/data/kenya_locations.dart';
import 'community_detail_screen.dart';

class CommunityManagementScreen extends StatefulWidget {
  const CommunityManagementScreen({super.key});

  @override
  State<CommunityManagementScreen> createState() =>
      _CommunityManagementScreenState();
}

class _CommunityManagementScreenState
    extends State<CommunityManagementScreen> {
  final _firestore = FirebaseFirestore.instance;

  final List<String> _wasteTypes = [
    'cropResidue',
    'livestockManure',
    'fruitWaste',
    'coffeeHusks',
    'vegetableWaste',
    'sugarcaneBagasse',
    'mixedOrganic',
    'riceHusks',
    'coconutWaste',
    'maizeStover',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Community Management'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add),
        label: const Text('New Community'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('communities').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_off, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No communities yet',
                      style: TextStyle(color: Colors.grey)),
                  Text('Tap + to create one',
                      style: TextStyle(
                          color: Colors.grey, fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final community = CommunityModel.fromJson(
                  {...data, 'id': docs[i].id});
              return _CommunityCard(
                community: community,
                wasteType: data['wasteType'] ?? 'mixedOrganic',
                pricePerKg: (data['agreedPricePerKg'] as num?)?.toDouble() ?? 5,
                onTap: () => _showCommunityDetail(community),
              );
            },
          );
        },
      ),
    );
  }

  void _showCreateDialog() {
    final nameCtrl = TextEditingController();
    final targetCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    String? county, subCounty, ward, wasteType;
    DateTime? targetDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create Community',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),

                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Community Name *',
                    hintText: 'e.g. Nakuru Green Cluster',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                // Waste Type Selection
                DropdownButtonFormField<String>(
                  value: wasteType,
                  decoration: const InputDecoration(
                    labelText: 'Waste Type *',
                    prefixIcon: Icon(Icons.recycling),
                    border: OutlineInputBorder(),
                  ),
                  items: _wasteTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_formatWasteType(type)),
                    );
                  }).toList(),
                  onChanged: (v) => setS(() => wasteType = v),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: targetCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Target Weight (kg) *',
                    hintText: 'e.g. 1000',
                    border: OutlineInputBorder(),
                    suffixText: 'kg',
                  ),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: priceCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price per KG (KSh) *',
                    hintText: 'e.g. 5',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.money),
                    suffixText: 'KSh/kg',
                  ),
                ),
                const SizedBox(height: 12),

                // County Selection
                DropdownButtonFormField<String>(
                  value: county,
                  decoration: const InputDecoration(
                    labelText: 'County *',
                    border: OutlineInputBorder(),
                  ),
                  items: KenyaLocations.getCountyNames()
                      .map((c) => DropdownMenuItem(
                      value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setS(() {
                    county = v;
                    subCounty = null;
                    ward = null;
                  }),
                ),
                const SizedBox(height: 12),

                if (county != null)
                  DropdownButtonFormField<String>(
                    value: subCounty,
                    decoration: const InputDecoration(
                      labelText: 'Sub-County *',
                      border: OutlineInputBorder(),
                    ),
                    items: KenyaLocations.getSubCountyNames(county!)
                        .map((s) => DropdownMenuItem(
                        value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setS(() {
                      subCounty = v;
                      ward = null;
                    }),
                  ),
                if (county != null) const SizedBox(height: 12),

                if (subCounty != null)
                  DropdownButtonFormField<String>(
                    value: ward,
                    decoration: const InputDecoration(
                      labelText: 'Ward (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    items: KenyaLocations.getWardNames(
                        county!, subCounty!)
                        .map((w) => DropdownMenuItem(
                        value: w, child: Text(w)))
                        .toList(),
                    onChanged: (v) => setS(() => ward = v),
                  ),
                if (subCounty != null)
                  const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now()
                          .add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now()
                          .add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setS(() => targetDate = picked);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(targetDate == null
                      ? 'Set Target Date (optional)'
                      : 'Target: ${targetDate!.day}/${targetDate!.month}/${targetDate!.year}'),
                ),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) {
                      _showError(ctx, 'Enter community name');
                      return;
                    }
                    if (wasteType == null) {
                      _showError(ctx, 'Select waste type');
                      return;
                    }
                    if (targetCtrl.text.trim().isEmpty) {
                      _showError(ctx, 'Enter target weight');
                      return;
                    }
                    if (priceCtrl.text.trim().isEmpty) {
                      _showError(ctx, 'Enter price per KG');
                      return;
                    }
                    if (county == null) {
                      _showError(ctx, 'Select county');
                      return;
                    }
                    if (subCounty == null) {
                      _showError(ctx, 'Select sub-county');
                      return;
                    }

                    final targetWeight = double.tryParse(targetCtrl.text);
                    if (targetWeight == null || targetWeight <= 0) {
                      _showError(ctx, 'Invalid target weight');
                      return;
                    }

                    final price = double.tryParse(priceCtrl.text);
                    if (price == null || price <= 0) {
                      _showError(ctx, 'Invalid price');
                      return;
                    }

                    await _firestore.collection('communities').add({
                      'name': nameCtrl.text.trim(),
                      'wasteType': wasteType,
                      'agreedPricePerKg': price,
                      'adminId': FirebaseAuth.instance.currentUser?.uid ?? 'admin',
                      'county': county,
                      'subCounty': subCounty,
                      'ward': ward ?? '',
                      'targetWeightKg': targetWeight,
                      'currentEstimatedKg': 0,
                      'actualCollectedKg': 0,
                      'farmerIds': [],
                      'status': 'forming',
                      'createdAt': DateTime.now().toIso8601String(),
                      'targetDate': targetDate?.toIso8601String(),
                    });

                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(
                          content: Text('Community created successfully!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen),
                  child: const Text('Create Community'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showCommunityDetail(CommunityModel community) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailScreen(community: community),
      ),
    );
  }

  String _formatWasteType(String type) {
    final map = {
      'cropResidue': 'Crop Residue',
      'livestockManure': 'Livestock Manure',
      'fruitWaste': 'Fruit Waste',
      'coffeeHusks': 'Coffee Husks',
      'vegetableWaste': 'Vegetable Waste',
      'sugarcaneBagasse': 'Sugarcane Bagasse',
      'mixedOrganic': 'Mixed Organic Waste',
      'riceHusks': 'Rice Husks',
      'coconutWaste': 'Coconut Waste',
      'maizeStover': 'Maize Stover',
    };
    return map[type] ?? type;
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityModel community;
  final String wasteType;
  final double pricePerKg;
  final VoidCallback onTap;

  const _CommunityCard({
    required this.community,
    required this.wasteType,
    required this.pricePerKg,
    required this.onTap,
  });

  Color get _statusColor {
    switch (community.status) {
      case CommunityStatus.active:
        return Colors.green;
      case CommunityStatus.collected:
        return Colors.blue;
      case CommunityStatus.completed:
        return Colors.purple;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(community.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        Text(
                          _formatWasteType(wasteType),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      community.status.name.toUpperCase(),
                      style: TextStyle(
                          color: _statusColor,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text('${community.subCounty}, ${community.county}',
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 13)),
              const SizedBox(height: 8),
              Text(
                'KSh ${pricePerKg.toStringAsFixed(0)}/kg',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: AppColors.primaryGreen),
              ),
              const SizedBox(height: 8),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: community.progressPercent,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        community.targetReached
                            ? Colors.green
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '${community.currentEstimatedKg.toInt()}/${community.targetWeightKg.toInt()} kg',
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.group,
                    size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text('${community.farmerIds.length} farmers',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
                if (community.targetReached) ...[
                  const SizedBox(width: 12),
                  const Icon(Icons.check_circle,
                      size: 14, color: Colors.green),
                  const SizedBox(width: 4),
                  const Text('Target reached!',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.green,
                          fontWeight: FontWeight.w600)),
                ],
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _formatWasteType(String type) {
    final map = {
      'cropResidue': 'Crop Residue',
      'livestockManure': 'Livestock Manure',
      'fruitWaste': 'Fruit Waste',
      'coffeeHusks': 'Coffee Husks',
      'vegetableWaste': 'Vegetable Waste',
      'sugarcaneBagasse': 'Sugarcane Bagasse',
      'mixedOrganic': 'Mixed Organic Waste',
      'riceHusks': 'Rice Husks',
      'coconutWaste': 'Coconut Waste',
      'maizeStover': 'Maize Stover',
    };
    return map[type] ?? type;
  }
}

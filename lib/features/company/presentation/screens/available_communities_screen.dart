import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class AvailableCommunitiesScreen extends StatefulWidget {
  final String companyId;
  final Map<String, dynamic> companyData;

  const AvailableCommunitiesScreen({
    super.key,
    required this.companyId,
    required this.companyData,
  });

  @override
  State<AvailableCommunitiesScreen> createState() => _AvailableCommunitiesScreenState();
}

class _AvailableCommunitiesScreenState extends State<AvailableCommunitiesScreen> {
  String? _selectedWasteType;
  final List<String> _wasteTypes = ['cropResidue', 'livestockManure', 'fruitWaste', 'coffeeHusks', 'vegetableWaste', 'sugarcaneBagasse'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: DropdownButtonFormField<String>(
            value: _selectedWasteType,
            decoration: const InputDecoration(labelText: 'Filter by Waste Type', border: OutlineInputBorder()),
            items: _wasteTypes.map((type) => DropdownMenuItem(value: type, child: Text(type))).toList(),
            onChanged: (value) => setState(() => _selectedWasteType = value),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('communities')
                .where('status', isEqualTo: 'forming')
                .where('county', isEqualTo: widget.companyData['county'])
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              var communities = snapshot.data!.docs;
              if (_selectedWasteType != null) {
                communities = communities.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return data['wasteType'] == _selectedWasteType;
                }).toList();
              }

              if (communities.isEmpty) {
                return const Center(child: Text('No communities found in your area'));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: communities.length,
                itemBuilder: (ctx, index) {
                  final data = communities[index].data() as Map<String, dynamic>;
                  return CommunityCard(
                    communityId: communities[index].id,
                    data: data,
                    companyId: widget.companyId,
                    companyData: widget.companyData,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CommunityCard extends StatelessWidget {
  final String communityId;
  final Map<String, dynamic> data;
  final String companyId;
  final Map<String, dynamic> companyData;

  const CommunityCard({
    required this.communityId,
    required this.data,
    required this.companyId,
    required this.companyData,
  });

  @override
  Widget build(BuildContext context) {
    final currentWeight = (data['currentEstimatedKg'] ?? 0).toDouble();
    final targetWeight = (data['targetWeightKg'] ?? 1000).toDouble();
    final progress = currentWeight / targetWeight;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.people_alt, color: AppColors.primaryGreen),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'Community', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      Text('${data['farmerIds']?.length ?? 0} farmers • ${data['subCounty'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Chip(
                  label: Text('${(progress * 100).toInt()}%'),
                  backgroundColor: Colors.green.shade100,
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: AppColors.primaryGreen),
            const SizedBox(height: 8),
            Text('${currentWeight.toInt()} / ${targetWeight.toInt()} kg collected', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showPriceDialog(context),
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Set Price'),
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryGreen),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _claimCommunity(context),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Claim'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPriceDialog(BuildContext context) {
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Your Price'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Waste Type: ${data['wasteType'] ?? 'Mixed'}'),
            const SizedBox(height: 8),
            TextField(
              controller: priceCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Price per KG (KSh)', border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceCtrl.text);
              if (price != null && price > 0) {
                await FirebaseFirestore.instance.collection('communities').doc(communityId).update({
                  'agreedPricePerKg': price,
                  'assignedCompanyId': companyId,
                  'assignedCompanyName': companyData['name'],
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Price set successfully!')));
              }
            },
            child: const Text('Set Price'),
          ),
        ],
      ),
    );
  }

  void _claimCommunity(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Claim Community'),
        content: const Text('By claiming this community, you agree to collect all waste once the target weight is reached.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('communities').doc(communityId).update({
                'assignedCompanyId': companyId,
                'assignedCompanyName': companyData['name'],
                'status': 'active',
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text('Community claimed successfully!')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }
}

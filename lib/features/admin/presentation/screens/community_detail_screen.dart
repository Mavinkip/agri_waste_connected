import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/models/community_model.dart';
import '../../../../../shared/widgets/app_map.dart';

class CommunityDetailScreen extends StatelessWidget {
  final CommunityModel community;

  const CommunityDetailScreen({super.key, required this.community});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(community.name),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(community.id)
            .snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final updated = data != null
              ? CommunityModel.fromJson({...data, 'id': community.id})
              : community;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Progress Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Collection Progress',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${updated.currentEstimatedKg.toInt()} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'of ${updated.targetWeightKg.toInt()} kg target',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: updated.progressPercent,
                          minHeight: 10,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white), // ✅ Fixed
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${(updated.progressPercent * 100).toStringAsFixed(0)}% complete',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Collection Point ──
                if (updated.collectionPointFarmerName != null) ...[
                  const Text(
                    'Collection Point',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                updated.collectionPointFarmerName!,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                updated.collectionPointAddress ?? '',
                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Map ──
                const Text(
                  'Farmer Locations',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 8),
                AppMap(
                  latitude: updated.collectionPointLat ?? -0.3031,
                  longitude: updated.collectionPointLng ?? 36.0800,
                  title: updated.name,
                  height: 220,
                  interactive: true,
                ),
                const SizedBox(height: 16),

                // ── Farmers List ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Farmers (${updated.farmerIds.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    TextButton.icon(
                      onPressed: () => _showAddFarmerDialog(context, updated),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Add Farmer'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _FarmersList(communityId: updated.id),
                const SizedBox(height: 16),

                // ── Actions ──
                if (updated.targetReached && updated.status == CommunityStatus.forming) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.celebration, color: Colors.green),
                            SizedBox(width: 8),
                            Text(
                              'Target Reached!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ready to schedule a pickup. Activate community to notify drivers.',
                          style: TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => _activateCommunity(context, updated),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                          child: const Text('Activate for Pickup'),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddFarmerDialog(BuildContext context, CommunityModel community) {
    final phoneCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Farmer to Community'),
        content: TextField(
          controller: phoneCtrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Farmer Phone Number',
            hintText: '0712345678',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = phoneCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
              if (phone.length < 10) return;

              // Find user by phone
              final query = await FirebaseFirestore.instance
                  .collection('users')
                  .where('phoneNumber', isEqualTo: phone)
                  .where('role', isEqualTo: 'farmer')
                  .limit(1)
                  .get();

              if (query.docs.isEmpty) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Farmer not found'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
                return;
              }

              final farmerId = query.docs.first.id;
              await FirebaseFirestore.instance
                  .collection('communities')
                  .doc(community.id)
                  .update({
                'farmerIds': FieldValue.arrayUnion([farmerId]),
              });

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(farmerId)
                  .update({'communityId': community.id});

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _activateCommunity(BuildContext context, CommunityModel community) async {
    await FirebaseFirestore.instance
        .collection('communities')
        .doc(community.id)
        .update({'status': 'active'});

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Community activated for pickup!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

class _FarmersList extends StatelessWidget {
  final String communityId;
  const _FarmersList({required this.communityId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('communityId', isEqualTo: communityId)
          .snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Text(
            'No farmers in this community yet.',
            style: TextStyle(color: Colors.grey, fontSize: 13),
          );
        }
        return Column(
          children: docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                  child: Text(
                    (d['fullName'] as String? ?? 'F')[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(d['fullName'] ?? 'Unknown'),
                subtitle: Text(d['phoneNumber'] ?? ''),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${(d['estimatedWasteKg'] ?? 0).toInt()} kg',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const Text(
                      'estimated',
                      style: TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/services/navigation_service.dart';
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('communities')
            .doc(community.id)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() as Map<String, dynamic>?;
          final updated = data != null
              ? CommunityModel.fromJson({...data, 'id': community.id})
              : community;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress Card
                _buildProgressCard(updated),
                const SizedBox(height: 16),

                // Collection Point
                if (updated.collectionPointFarmerName != null)
                  _buildCollectionPointCard(updated),

                const SizedBox(height: 16),

                // Map
                const Text(
                  'Community Location',
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

                // Farmers List with Contributions
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Farmers (${updated.farmerIds.length})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _showAddFarmerDialog(context, updated),
                          icon: const Icon(Icons.person_add, size: 18),
                          label: const Text('Add Farmer'),
                        ),
                        TextButton.icon(
                          onPressed: () => _showInviteDialog(context, updated),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Invite'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _FarmersList(communityId: updated.id),
                const SizedBox(height: 16),

                // Community Stats Card
                _buildCommunityStatsCard(updated),
                const SizedBox(height: 16),

                // Actions
                if (updated.targetReached && updated.status == CommunityStatus.forming)
                  _buildActivationCard(context, updated),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressCard(CommunityModel updated) {
    final progressPercent = updated.progressPercent;

    return Container(
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
              value: progressPercent,
              minHeight: 10,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(progressPercent * 100).toStringAsFixed(0)}% complete',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionPointCard(CommunityModel updated) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              IconButton(
                icon: const Icon(Icons.navigation, color: Colors.amber),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunityStatsCard(CommunityModel updated) {
    final totalFarmers = updated.farmerIds.length;
    final avgContribution = totalFarmers > 0
        ? updated.currentEstimatedKg / totalFarmers
        : 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Community Statistics',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatCard(
                'Total Farmers',
                '$totalFarmers',
                Icons.people,
                Colors.blue,
              ),
              _buildStatCard(
                'Avg Contribution',
                '${avgContribution.toInt()} kg',
                Icons.bar_chart,
                Colors.orange,
              ),
              _buildStatCard(
                'Status',
                updated.status.name,
                Icons.trending_up,
                updated.status == CommunityStatus.active ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildActivationCard(BuildContext context, CommunityModel updated) {
    return Container(
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
    );
  }

  void _showAddFarmerDialog(BuildContext context, CommunityModel community) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 500,
            maxHeight: MediaQuery.of(ctx).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_add, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Add Farmer to Community',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: _AddFarmerContent(community: community),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInviteDialog(BuildContext context, CommunityModel community) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Invite Farmers'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Share this code with farmers to join:'),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                community.id,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Farmers must register with:\n'
                  'County: ${community.county ?? "Your county"}\n'
                  'Sub-County: ${community.subCounty ?? "Your sub-county"}',
              style: const TextStyle(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
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
          content: Text('Community activated for pickup! Drivers have been notified.'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}

// Separate widget for add farmer content
class _AddFarmerContent extends StatefulWidget {
  final CommunityModel community;
  const _AddFarmerContent({required this.community});

  @override
  State<_AddFarmerContent> createState() => _AddFarmerContentState();
}

class _AddFarmerContentState extends State<_AddFarmerContent> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Region info
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.location_on, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Community Location:',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'County: ${widget.community.county ?? "Not set"}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    Text(
                      'Sub-County: ${widget.community.subCounty ?? "Not set"}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Search field
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              labelText: 'Search by phone number',
              hintText: '0712345678',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            keyboardType: TextInputType.phone,
            onChanged: (value) {
              setState(() {
                searchQuery = value;
              });
            },
          ),
        ),

        const SizedBox(height: 16),

        // Farmers list header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Farmers in this region:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Farmers list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getFarmers(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              var farmers = snapshot.data?.docs ?? [];

              // Filter by phone number if search query provided
              if (searchQuery.isNotEmpty && searchQuery.length >= 6) {
                farmers = farmers.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final phone = data['phoneNumber'] ?? '';
                  return phone.contains(searchQuery);
                }).toList();
              }

              if (farmers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 8),
                      const Text(
                        'No farmers found in this region',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'County: ${widget.community.county ?? "Unknown"}\nSub-County: ${widget.community.subCounty ?? "Unknown"}',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: farmers.length,
                itemBuilder: (context, index) {
                  final doc = farmers[index];
                  final data = doc.data() as Map<String, dynamic>;
                  final isAlreadyInCommunity = widget.community.farmerIds.contains(doc.id);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                        child: Text(
                          (data['fullName'] as String? ?? 'F')[0].toUpperCase(),
                        ),
                      ),
                      title: Text(
                        data['fullName'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data['phoneNumber'] ?? ''),
                          const SizedBox(height: 2),
                          Text(
                            '${data['county'] ?? "N/A"} • ${data['subCounty'] ?? "N/A"} • ${data['estimatedWasteKg'] ?? 0} kg',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: isAlreadyInCommunity
                          ? const Chip(
                        label: Text('Added'),
                        backgroundColor: Colors.grey,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      )
                          : ElevatedButton(
                        onPressed: () => _addFarmer(
                          context,
                          doc.id,
                          data,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        child: const Text('Add'),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Close button
        Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ),
      ],
    );
  }

  Stream<QuerySnapshot> _getFarmers() {
    Query query = FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'farmer');

    // Filter by county
    if (widget.community.county != null && widget.community.county!.isNotEmpty) {
      query = query.where('county', isEqualTo: widget.community.county);
    } else {
      return FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'nonexistent').snapshots();
    }

    // Filter by sub-county
    if (widget.community.subCounty != null && widget.community.subCounty!.isNotEmpty) {
      query = query.where('subCounty', isEqualTo: widget.community.subCounty);
    } else {
      return FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'nonexistent').snapshots();
    }

    return query.snapshots();
  }

  Future<void> _addFarmer(BuildContext context, String farmerId, Map<String, dynamic> farmerData) async {
    try {
      // Add farmer to community
      await FirebaseFirestore.instance
          .collection('communities')
          .doc(widget.community.id)
          .update({
        'farmerIds': FieldValue.arrayUnion([farmerId]),
        'currentEstimatedKg': FieldValue.increment(farmerData['estimatedWasteKg'] ?? 0),
      });

      // Update farmer's community reference
      await FirebaseFirestore.instance
          .collection('users')
          .doc(farmerId)
          .update({
        'communityId': widget.community.id,
        'community': widget.community.name,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${farmerData['fullName'] ?? 'Farmer'} added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the UI by closing dialog (parent will rebuild from stream)
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding farmer: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Icon(Icons.people_outline, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(
                  'No farmers in this community yet.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap + to add farmers from your region',
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          );
        }

        // Sort farmers by contribution (highest first)
        final sortedDocs = List.from(docs);
        sortedDocs.sort((a, b) {
          final aContribution = (a.data() as Map<String, dynamic>)['estimatedWasteKg'] ?? 0;
          final bContribution = (b.data() as Map<String, dynamic>)['estimatedWasteKg'] ?? 0;
          return bContribution.compareTo(aContribution);
        });

        return Column(
          children: sortedDocs.asMap().entries.map((entry) {
            final index = entry.key;
            final doc = entry.value;
            final d = doc.data() as Map<String, dynamic>;
            final contribution = (d['estimatedWasteKg'] ?? 0).toInt();
            final isTopFarmer = index < 3;

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                      child: Text(
                        (d['fullName'] as String? ?? 'F')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (isTopFarmer && contribution > 0)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            index == 0 ? Icons.emoji_events :
                            index == 1 ? Icons.wallet :
                            Icons.star,
                            size: 10,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  d['fullName'] ?? 'Unknown',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d['phoneNumber'] ?? ''),
                    if (d['joinedAt'] != null)
                      Text(
                        'Joined: ${(d['joinedAt'] as Timestamp).toDate().toString().substring(0, 10)}',
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    Text(
                      '${d['county'] ?? "N/A"} • ${d['subCounty'] ?? "N/A"}',
                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$contribution kg',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isTopFarmer ? Colors.amber : AppColors.primaryGreen,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'contributed',
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
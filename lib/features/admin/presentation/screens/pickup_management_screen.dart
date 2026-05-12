import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/navigation_service.dart';

class PickupManagementScreen extends StatefulWidget {
  const PickupManagementScreen({super.key});

  @override
  State<PickupManagementScreen> createState() => _PickupManagementScreenState();
}

class _PickupManagementScreenState extends State<PickupManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Management'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '🚜 Community', icon: Icon(Icons.people_alt)),
            Tab(text: '👨‍🌾 Individual', icon: Icon(Icons.person)),
            Tab(text: '⚙️ Assigned', icon: Icon(Icons.local_shipping)),
            Tab(text: '✅ Completed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommunityPickups(),
          _buildIndividualPickups(),
          _buildAssignedPickups(),
          _buildCompletedPickups(),
        ],
      ),
    );
  }

  // COMMUNITY BULK PICKUPS
  Widget _buildCommunityPickups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('communities')
          .where('status', whereIn: ['active', 'forming'])
          .where('currentEstimatedKg', isGreaterThan: 0)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final communities = snapshot.data?.docs ?? [];
        if (communities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_off, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No active community pickups'),
                Text('Communities need to reach target weight first'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: communities.length,
          itemBuilder: (ctx, index) {
            final data = communities[index].data() as Map<String, dynamic>;
            return CommunityPickupCard(
              id: communities[index].id,
              data: data,
              onAssign: (driverId) => _assignCommunityPickup(communities[index].id, driverId, data),
            );
          },
        );
      },
    );
  }

  // INDIVIDUAL FARMER PICKUPS
  Widget _buildIndividualPickups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('listings')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pickups = snapshot.data?.docs ?? [];
        if (pickups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No pending individual pickups'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pickups.length,
          itemBuilder: (ctx, index) {
            final data = pickups[index].data() as Map<String, dynamic>;
            return IndividualPickupCard(
              id: pickups[index].id,
              data: data,
              onAssign: (driverId) => _assignIndividualPickup(pickups[index].id, driverId, data),
            );
          },
        );
      },
    );
  }

  // ASSIGNED PICKUPS (Currently being handled)
  Widget _buildAssignedPickups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('listings')
          .where('status', isEqualTo: 'assigned')
          .orderBy('assignedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pickups = snapshot.data?.docs ?? [];
        if (pickups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.local_shipping, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No assigned pickups'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pickups.length,
          itemBuilder: (ctx, index) {
            final data = pickups[index].data() as Map<String, dynamic>;
            return AssignedPickupCard(
              id: pickups[index].id,
              data: data,
              onComplete: () => _completePickup(pickups[index].id),
            );
          },
        );
      },
    );
  }

  // COMPLETED PICKUPS
  Widget _buildCompletedPickups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('listings')
          .where('status', isEqualTo: 'completed')
          .orderBy('completedAt', descending: true)
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final pickups = snapshot.data?.docs ?? [];
        if (pickups.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No completed pickups yet'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: pickups.length,
          itemBuilder: (ctx, index) {
            final data = pickups[index].data() as Map<String, dynamic>;
            return CompletedPickupCard(data: data);
          },
        );
      },
    );
  }

  Future<void> _assignCommunityPickup(String communityId, String driverId, Map<String, dynamic> communityData) async {
    try {
      await _firestore.runTransaction((tx) async {
        final commRef = _firestore.collection('communities').doc(communityId);
        final commSnap = await tx.get(commRef);

        // Create a pickup listing for the community
        final pickupRef = _firestore.collection('listings').doc();
        tx.set(pickupRef, {
          'type': 'community',
          'communityId': communityId,
          'communityName': communityData['name'],
          'driverId': driverId,
          'farmerIds': communityData['farmerIds'] ?? [],
          'farmerCount': (communityData['farmerIds'] ?? []).length,
          'estimatedQuantity': communityData['currentEstimatedKg'] ?? 0,
          'actualQuantity': 0,
          'pricePerKg': communityData['agreedPricePerKg'] ?? 5,
          'companyId': communityData['assignedCompanyId'],
          'status': 'assigned',
          'pickupAddress': '${communityData['ward']}, ${communityData['subCounty']}, ${communityData['county']}',
          'createdAt': FieldValue.serverTimestamp(),
          'assignedAt': FieldValue.serverTimestamp(),
          'isCommunityPickup': true,
        });

        // Update community status
        tx.update(commRef, {
          'status': 'assigned',
          'assignedDriverId': driverId,
          'assignedAt': FieldValue.serverTimestamp(),
        });
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Community pickup assigned to driver successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _assignIndividualPickup(String pickupId, String driverId, Map<String, dynamic> pickupData) async {
    try {
      await _firestore.collection('listings').doc(pickupId).update({
        'driverId': driverId,
        'status': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup assigned to driver successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _completePickup(String pickupId) async {
    // Navigate to completion screen or show dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Pickup'),
        content: const Text('Mark this pickup as completed?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _firestore.collection('listings').doc(pickupId).update({
                'status': 'completed',
                'completedAt': FieldValue.serverTimestamp(),
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pickup marked as completed')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}

// Community Pickup Card
class CommunityPickupCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final Function(String) onAssign;

  const CommunityPickupCard({
    required this.id,
    required this.data,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (data['currentEstimatedKg'] ?? 0) / (data['targetWeightKg'] ?? 1);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.orange.shade50, Colors.orange.shade100],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
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
                      color: Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.people_alt, color: Colors.orange),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['name'] ?? 'Community',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${data['farmerIds']?.length ?? 0} farmers',
                          style: const TextStyle(color: Colors.grey),
                        ),
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
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                color: Colors.orange,
              ),
              const SizedBox(height: 8),
              Text(
                '${data['currentEstimatedKg'] ?? 0}/${data['targetWeightKg'] ?? 0} kg collected',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📍 Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${data['subCounty']}, ${data['county']}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💰 Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('KSh ${data['agreedPricePerKg'] ?? 5}/kg'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignDriverDialog(context),
                  icon: const Icon(Icons.local_shipping),
                  label: const Text('Assign Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignDriverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Driver to Community Pickup'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: _DriverList(onSelect: onAssign),
        ),
      ),
    );
  }
}

// Individual Pickup Card
class IndividualPickupCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final Function(String) onAssign;

  const IndividualPickupCard({
    required this.id,
    required this.data,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = data['createdAt'] != null &&
        DateTime.now().difference((data['createdAt'] as Timestamp).toDate()).inDays > 2;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isUrgent ? Border.all(color: Colors.red, width: 2) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isUrgent ? Colors.red.shade100 : AppColors.primaryGreen.withOpacity(0.1),
                    child: Icon(
                      Icons.person,
                      color: isUrgent ? Colors.red : AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['farmerName'] ?? 'Unknown Farmer',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          data['wasteType'] ?? 'Mixed Organic',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isUrgent)
                    const Chip(
                      label: Text('URGENT', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.red,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📦 Quantity', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('${data['estimatedQuantity'] ?? 0} kg'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💰 Price', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('KSh ${data['pricePerKg'] ?? 5}/kg'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📅 Schedule', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(data['scheduleDay'] ?? 'Flexible'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '📍 ${data['pickupAddress'] ?? 'Address not provided'}',
                style: const TextStyle(fontSize: 12),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showAssignDriverDialog(context),
                  icon: const Icon(Icons.local_shipping),
                  label: const Text('Assign Driver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAssignDriverDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Assign Driver'),
        content: SizedBox(
          width: 300,
          height: 400,
          child: _DriverList(onSelect: onAssign),
        ),
      ),
    );
  }
}

// Assigned Pickup Card
class AssignedPickupCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onComplete;

  const AssignedPickupCard({
    required this.id,
    required this.data,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final isCommunity = data['isCommunityPickup'] == true;

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
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isCommunity ? Icons.people_alt : Icons.person,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCommunity ? data['communityName'] ?? 'Community Pickup' : (data['farmerName'] ?? 'Individual Pickup'),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Driver assigned: ${data['driverId'] ?? 'Unknown'}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  label: Text('ASSIGNED', style: TextStyle(fontSize: 10)),
                  backgroundColor: Colors.blue,
                  labelStyle: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '📍 ${data['pickupAddress'] ?? 'Address not provided'}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              '📦 ${data['estimatedQuantity'] ?? 0} kg @ KSh ${data['pricePerKg'] ?? 5}/kg',
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onComplete,
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Mark Completed'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Completed Pickup Card
class CompletedPickupCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const CompletedPickupCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['farmerName'] ?? data['communityName'] ?? 'Pickup',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${data['actualQuantity'] ?? data['estimatedQuantity'] ?? 0} kg completed',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (data['completedAt'] != null)
              Text(
                _formatDate(data['completedAt'] as Timestamp),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}';
  }
}

// Driver Selection List
class _DriverList extends StatefulWidget {
  final Function(String) onSelect;

  const _DriverList({required this.onSelect});

  @override
  State<_DriverList> createState() => _DriverListState();
}

class _DriverListState extends State<_DriverList> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .where('isActive', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final drivers = snapshot.data?.docs ?? [];
        if (drivers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('No available drivers'),
                SizedBox(height: 8),
                Text('Please register drivers first'),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: drivers.length,
          itemBuilder: (context, index) {
            final doc = drivers[index];
            final data = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primaryGreen),
              ),
              title: Text(data['name'] ?? data['fullName'] ?? 'Driver'),
              subtitle: Text(data['phone'] ?? data['phoneNumber'] ?? 'No phone'),
              trailing: data['isAvailable'] == true
                  ? const Chip(
                label: Text('Available', style: TextStyle(fontSize: 10)),
                backgroundColor: Colors.green,
                labelStyle: TextStyle(color: Colors.white),
              )
                  : null,
              onTap: () {
                Navigator.pop(context);
                widget.onSelect(doc.id);
              },
            );
          },
        );
      },
    );
  }
}
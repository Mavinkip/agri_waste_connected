import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/data/kenya_locations.dart';

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

  void _refreshAssignedPickups() {
    setState(() {});
    _debugCheckAssigned();
  }

  void _debugCheckAssigned() async {
    try {
      final snapshot = await _firestore
          .collection('listings')
          .where('status', isEqualTo: 'assigned')
          .get();

      print('📊 === ASSIGNED PICKUPS DEBUG ===');
      print('Found ${snapshot.docs.length} assigned pickups');

      for (var doc in snapshot.docs) {
        final data = doc.data();
        print('📋 ID: ${doc.id}');
        print('   Farmer: ${data['farmerName']}');
        print('   Driver: ${data['driverName']}');
        print('   Status: ${data['status']}');
        print('   ---');
      }
    } catch (e) {
      print('❌ Debug error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pickup Management'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAssignedPickups,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Community', icon: Icon(Icons.people_alt)),
            Tab(text: 'Individual', icon: Icon(Icons.person)),
            Tab(text: 'Assigned', icon: Icon(Icons.local_shipping)),
            Tab(text: 'Completed', icon: Icon(Icons.check_circle)),
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

  // ─── COMMUNITY BULK PICKUPS ───
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

  // ─── INDIVIDUAL FARMER PICKUPS ───
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

  // ─── ASSIGNED PICKUPS ───
  Widget _buildAssignedPickups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('listings')
          .where('status', isEqualTo: 'assigned')
          .orderBy('assignedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          print('📊 Assigned pickups found: ${snapshot.data!.docs.length}');
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            print('  - ID: ${doc.id}, Driver: ${data['driverName']}, Status: ${data['status']}');
          }
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('❌ Error loading assigned pickups: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _refreshAssignedPickups,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
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
                SizedBox(height: 8),
                Text(
                  'Assign a driver to a pickup to see it here',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
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
              onComplete: () => _showCompletePickupDialog(pickups[index].id),
            );
          },
        );
      },
    );
  }

  // ─── COMPLETED PICKUPS ───
  Widget _buildCompletedPickups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('listings')
          .where('status', isEqualTo: 'completed')
      // .orderBy('completedAt', descending: true)  // Commented out until index is created
          .limit(50)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          print('❌ Error loading completed pickups: ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
                const SizedBox(height: 16),
                Text('Error loading completed pickups'),
                const SizedBox(height: 8),
                Text(
                  '${snapshot.error}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => setState(() {}),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
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
                SizedBox(height: 8),
                Text(
                  'Completed pickups will appear here',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
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

  // ─── SHOW COMPLETE PICKUP DIALOG ───
  void _showCompletePickupDialog(String pickupId) {
    int? selectedRating;
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Complete Pickup'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Rate the driver and enter actual weight',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      labelText: 'Rate Driver *',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedRating,
                    items: [1, 2, 3, 4, 5].map((rating) {
                      return DropdownMenuItem<int>(
                        value: rating,
                        child: Row(
                          children: [
                            ...List.generate(rating, (index) =>
                            const Icon(Icons.star, color: Colors.amber, size: 16)
                            ),
                            const SizedBox(width: 4),
                            Text('$rating Star${rating > 1 ? 's' : ''}'),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedRating = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: weightController,
                    decoration: const InputDecoration(
                      labelText: 'Actual Weight (kg)',
                      hintText: 'Leave empty to use estimated weight',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedRating == null) {
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(
                        content: Text('Please rate the driver'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final actualWeight = weightController.text.isNotEmpty
                      ? double.tryParse(weightController.text)
                      : null;

                  await _completePickupWithRating(
                    pickupId,
                    rating: selectedRating!,
                    actualWeight: actualWeight,
                  );
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Complete'),
              ),
            ],
          );
        },
      ),
    );
  }

  // ─── COMPLETE PICKUP WITH RATING ───
  Future<void> _completePickupWithRating(
      String pickupId, {
        required int rating,
        double? actualWeight,
      }) async {
    try {
      final pickupDoc = await _firestore.collection('listings').doc(pickupId).get();
      final data = pickupDoc.data() as Map<String, dynamic>;
      final driverId = data['driverId'];
      final driverName = data['driverName'] ?? 'Unknown Driver';
      final estimatedQty = data['estimatedQuantity'] ?? 0;
      final actualQty = actualWeight ?? estimatedQty;

      print('📝 Completing pickup for driver: $driverName (ID: $driverId)');

      // Update pickup
      await _firestore.collection('listings').doc(pickupId).update({
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
        'actualQuantity': actualQty,
        'rating': rating,
        'ratingGivenAt': FieldValue.serverTimestamp(),
      });

      // Update driver
      if (driverId != null) {
        final driverRef = _firestore.collection('users').doc(driverId);
        final driverDoc = await driverRef.get();

        if (driverDoc.exists) {
          final driverData = driverDoc.data() as Map<String, dynamic>;
          int completedCount = (driverData['completedPickups'] ?? 0) + 1;
          double currentAvgRating = (driverData['averageRating'] ?? 0).toDouble();
          int totalCompleted = (driverData['totalCompleted'] ?? 0) + 1;

          double newAverageRating = ((currentAvgRating * (totalCompleted - 1)) + rating) / totalCompleted;

          await driverRef.update({
            'assignedPickups': FieldValue.increment(-1),
            'completedPickups': FieldValue.increment(1),
            'totalCompleted': FieldValue.increment(1),
            'averageRating': newAverageRating,
            'status': 'idle',
          });

          print('✅ Driver $driverName updated:');
          print('   Completed: $completedCount');
          print('   Avg Rating: $newAverageRating');
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Pickup completed! Rating: $rating ⭐'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshAssignedPickups();
        _tabController.animateTo(3);
      }
    } catch (e) {
      print('❌ Error completing pickup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── ASSIGN COMMUNITY PICKUP ───
  Future<void> _assignCommunityPickup(String communityId, String driverId, Map<String, dynamic> communityData) async {
    try {
      // Get driver data FIRST
      final driverDoc = await _firestore.collection('users').doc(driverId).get();
      if (!driverDoc.exists) {
        throw Exception('Driver not found');
      }

      final driverData = driverDoc.data() as Map<String, dynamic>;
      final driverName = driverData['fullName'] ?? driverData['name'] ?? 'Unknown Driver';

      print('📝 Assigning community pickup to driver: $driverName (ID: $driverId)');

      await _firestore.runTransaction((tx) async {
        final commRef = _firestore.collection('communities').doc(communityId);
        final commSnap = await tx.get(commRef);

        final pickupRef = _firestore.collection('listings').doc();

        final county = communityData['county'] ?? '';
        final subCounty = communityData['subCounty'] ?? '';
        final ward = communityData['ward'] ?? '';
        final pickupCoords = KenyaLocations.getLocationCoordinates(
          county: county,
          subCounty: subCounty,
          ward: ward,
        );

        tx.set(pickupRef, {
          'type': 'community',
          'communityId': communityId,
          'communityName': communityData['name'],
          'driverId': driverId,
          'driverName': driverName,
          'farmerIds': communityData['farmerIds'] ?? [],
          'farmerCount': (communityData['farmerIds'] ?? []).length,
          'estimatedQuantity': communityData['currentEstimatedKg'] ?? 0,
          'actualQuantity': 0,
          'pricePerKg': communityData['agreedPricePerKg'] ?? 5,
          'companyId': communityData['assignedCompanyId'],
          'status': 'assigned',
          'county': county,
          'subCounty': subCounty,
          'ward': ward,
          'pickupAddress': '$ward, $subCounty, $county',
          'pickupLat': pickupCoords?.latitude,
          'pickupLng': pickupCoords?.longitude,
          'createdAt': FieldValue.serverTimestamp(),
          'assignedAt': FieldValue.serverTimestamp(),
          'assignedBy': 'Admin',
          'isCommunityPickup': true,
        });

        tx.update(commRef, {
          'status': 'assigned',
          'assignedDriverId': driverId,
          'assignedDriverName': driverName,
          'assignedAt': FieldValue.serverTimestamp(),
        });

        final driverRef = _firestore.collection('users').doc(driverId);
        tx.update(driverRef, {
          'assignedPickups': FieldValue.increment(1),
          'status': 'active',
        });
      });

      print('✅ Community pickup assigned to $driverName');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Community pickup assigned to $driverName'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshAssignedPickups();
        _tabController.animateTo(2);
      }
    } catch (e) {
      print('❌ Error assigning community pickup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─── ASSIGN INDIVIDUAL PICKUP ───
  Future<void> _assignIndividualPickup(String pickupId, String driverId, Map<String, dynamic> pickupData) async {
    try {
      // Get driver data FIRST
      final driverDoc = await _firestore.collection('users').doc(driverId).get();
      if (!driverDoc.exists) {
        throw Exception('Driver not found');
      }

      final driverData = driverDoc.data() as Map<String, dynamic>;
      final driverName = driverData['fullName'] ?? driverData['name'] ?? 'Unknown Driver';

      print('📝 Assigning pickup to driver: $driverName (ID: $driverId)');

      final county = pickupData['county'] ?? '';
      final subCounty = pickupData['subCounty'] ?? '';
      final ward = pickupData['ward'] ?? '';
      final pickupCoords = KenyaLocations.getLocationCoordinates(
        county: county,
        subCounty: subCounty,
        ward: ward,
      );

      // Update pickup with driver info
      await _firestore.collection('listings').doc(pickupId).update({
        'driverId': driverId,
        'driverName': driverName,
        'status': 'assigned',
        'assignedAt': FieldValue.serverTimestamp(),
        'assignedBy': 'Admin',
        'pickupLat': pickupCoords?.latitude,
        'pickupLng': pickupCoords?.longitude,
      });

      // Update driver's assigned count
      await _firestore.collection('users').doc(driverId).update({
        'assignedPickups': FieldValue.increment(1),
        'status': 'active',
      });

      print('✅ Pickup assigned to $driverName');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Pickup assigned to $driverName'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshAssignedPickups();
        _tabController.animateTo(2);
      }
    } catch (e) {
      print('❌ Error assigning pickup: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }
}

// ─── ASSIGNED PICKUP CARD ───
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
            // Header
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
                        isCommunity
                            ? data['communityName'] ?? 'Community Pickup'
                            : (data['farmerName'] ?? 'Individual Pickup'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.person_outline, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Driver: ${data['driverName'] ?? data['driverId'] ?? 'Unknown'}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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

            // Details
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Quantity', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('${data['estimatedQuantity'] ?? 0} kg'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Price', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text('KSh ${data['pricePerKg'] ?? 5}/kg'),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Type', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      Text(
                        data['wasteType'] ?? 'Mixed',
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Location
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    data['pickupAddress'] ?? data['ward'] ?? 'Address not provided',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            if (data['assignedAt'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Assigned: ${_formatDate(data['assignedAt'] as Timestamp)}',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
            const SizedBox(height: 12),

            // Complete Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.check_circle),
                label: const Text('Mark Completed'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green.shade300),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ─── COMPLETED PICKUP CARD ───
class CompletedPickupCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const CompletedPickupCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final rating = data['rating'];
    final driverName = data['driverName'] ?? 'Unknown Driver';

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
                  if (driverName != null)
                    Text(
                      'Driver: $driverName',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  if (rating != null)
                    Row(
                      children: [
                        ...List.generate(rating, (index) =>
                        const Icon(Icons.star, color: Colors.amber, size: 14)
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '($rating)',
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            if (data['completedAt'] != null)
              Text(
                _formatDateShort(data['completedAt'] as Timestamp),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDateShort(Timestamp timestamp) {
    final date = timestamp.toDate();
    return '${date.day}/${date.month}';
  }
}

// ─── COMMUNITY PICKUP CARD ───
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
                        const Text('Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${data['subCounty'] ?? ''}, ${data['county'] ?? ''}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
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
          child: _DriverList(
            onSelect: onAssign,
            pickupCounty: data['county'],
            pickupSubCounty: data['subCounty'],
            pickupWard: data['ward'],
          ),
        ),
      ),
    );
  }
}

// ─── INDIVIDUAL PICKUP CARD ───
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
                        const Text('Quantity', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('${data['estimatedQuantity'] ?? 0} kg'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Price', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text('KSh ${data['pricePerKg'] ?? 5}/kg'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Schedule', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(data['scheduleDay'] ?? 'Flexible'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                data['pickupAddress'] ?? data['ward'] ?? 'Address not provided',
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
          child: _DriverList(
            onSelect: onAssign,
            pickupCounty: data['county'],
            pickupSubCounty: data['subCounty'],
            pickupWard: data['ward'],
          ),
        ),
      ),
    );
  }
}

// ─── DRIVER SELECTION LIST ───
class _DriverList extends StatefulWidget {
  final Function(String) onSelect;
  final String? pickupCounty;
  final String? pickupSubCounty;
  final String? pickupWard;

  const _DriverList({
    required this.onSelect,
    this.pickupCounty,
    this.pickupSubCounty,
    this.pickupWard,
  });

  @override
  State<_DriverList> createState() => _DriverListState();
}

class _DriverListState extends State<_DriverList> {
  final _firestore = FirebaseFirestore.instance;
  String _filterOption = 'available';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Only drivers with assigned routes can pick up',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _buildFilterChip('Available', 'available'),
              const SizedBox(width: 8),
              _buildFilterChip('Nearby', 'nearby'),
              const SizedBox(width: 8),
              _buildFilterChip('All', 'all'),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
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
                      Text('No drivers registered'),
                    ],
                  ),
                );
              }

              var filteredDrivers = drivers.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final hasAssignedRoute = data['assignedRoute'] != null;

                if (!hasAssignedRoute) {
                  return false;
                }

                final routeStatus = data['status'] ?? 'idle';
                final hasRoute = routeStatus == 'active' || routeStatus == 'busy';

                if (_filterOption == 'available') {
                  return hasRoute && (data['isAvailable'] == true || data['status'] == 'active');
                }

                if (_filterOption == 'nearby') {
                  final driverCounty = data['county'] ?? '';
                  final driverSubCounty = data['subCounty'] ?? '';

                  final isInSameCounty = widget.pickupCounty != null &&
                      driverCounty.toLowerCase() == widget.pickupCounty!.toLowerCase();
                  final isInSameSubCounty = widget.pickupSubCounty != null &&
                      driverSubCounty.toLowerCase() == widget.pickupSubCounty!.toLowerCase();

                  return hasRoute && (isInSameCounty || isInSameSubCounty);
                }

                return hasRoute;
              }).toList();

              if (filteredDrivers.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route, size: 48, color: Colors.orange.shade300),
                      const SizedBox(height: 16),
                      Text(
                        _filterOption == 'nearby'
                            ? 'No drivers with routes in this area'
                            : 'No drivers with assigned routes',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Drivers must have a route assigned first',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: filteredDrivers.length,
                itemBuilder: (context, index) {
                  final doc = filteredDrivers.elementAt(index);
                  final data = doc.data() as Map<String, dynamic>;

                  final assignedRoute = data['assignedRoute'] as Map<String, dynamic>?;
                  final routeName = assignedRoute?['routeName'] ?? 'No Route';
                  final isNearby = widget.pickupCounty != null &&
                      data['county'] == widget.pickupCounty;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isNearby
                          ? Colors.green.withOpacity(0.2)
                          : Colors.blue.withOpacity(0.1),
                      child: Icon(
                        Icons.person,
                        color: isNearby ? Colors.green : Colors.blue,
                      ),
                    ),
                    title: Text(data['name'] ?? data['fullName'] ?? 'Driver'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${data['phone'] ?? data['phoneNumber'] ?? 'No phone'}'),
                        Text(
                          '${data['county'] ?? 'Unknown'}' +
                              (data['subCounty'] != null ? ', ${data['subCounty']}' : ''),
                          style: TextStyle(
                            fontSize: 10,
                            color: isNearby ? Colors.green.shade700 : Colors.grey.shade500,
                          ),
                        ),
                        Row(
                          children: [
                            Icon(Icons.route, size: 10, color: Colors.blue.shade400),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                'Route: $routeName',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isNearby)
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                        if (isNearby) const SizedBox(width: 4),
                        if (data['status'] == 'active' || data['isAvailable'] == true)
                          const Chip(
                            label: Text('Available', style: TextStyle(fontSize: 9)),
                            backgroundColor: Colors.green,
                            labelStyle: TextStyle(color: Colors.white),
                          ),
                      ],
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onSelect(doc.id);
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filterOption == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filterOption = value;
        });
      },
      backgroundColor: Colors.grey.shade100,
      selectedColor: AppColors.primaryGreen.withOpacity(0.2),
      checkmarkColor: AppColors.primaryGreen,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primaryGreen : Colors.grey.shade700,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
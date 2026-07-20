import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/repositories/farmer_repository.dart';
import '../bloc/farmer_bloc.dart';
import '../widgets/profile_menu.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});

  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FarmerBloc>().add(const LoadRoutineSchedule());
  }

  Future<void> _createPickupRequest(String selectedDay, String selectedTimeSlot) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final userData = userDoc.data()!;

      // Get company price based on location
      final companyQuery = await FirebaseFirestore.instance
          .collection('companies')
          .where('county', isEqualTo: userData['county'])
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      double pricePerKg = 5; // default price
      String companyId = '';
      String companyName = '';

      if (companyQuery.docs.isNotEmpty) {
        final companyData = companyQuery.docs.first.data();
        companyId = companyQuery.docs.first.id;
        companyName = companyData['name'] ?? 'Company';
        final priceList = companyData['priceList'] as Map<String, dynamic>?;
        if (priceList != null && priceList['mixedOrganic'] != null) {
          pricePerKg = (priceList['mixedOrganic'] as num).toDouble();
        }
      }

      // Create pickup request
      await FirebaseFirestore.instance.collection('listings').add({
        'farmerId': user.uid,
        'farmerName': userData['name'] ?? userData['fullName'] ?? 'Farmer',
        'farmerPhone': userData['phone'] ?? userData['phoneNumber'] ?? '',
        'wasteType': 'mixedOrganic',
        'estimatedQuantity': 0,
        'actualQuantity': 0,
        'pricePerKg': pricePerKg,
        'companyId': companyId,
        'companyName': companyName,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'pickupAddress': '${userData['ward'] ?? ''}, ${userData['subCounty'] ?? ''}, ${userData['county'] ?? ''}',
        'pickupLat': userData['latitude'],
        'pickupLng': userData['longitude'],
        'scheduleDay': selectedDay,
        'scheduleTime': selectedTimeSlot,
        'isRoutinePickup': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pickup request created! Admin will assign a driver.'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print('Error creating pickup request: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating pickup: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.calendar_month_rounded, size: 26),
            SizedBox(width: 10),
            Text('Pickup Schedule'),
          ],
        ),
        actions: const [
          FarmerAppMenu(),
          SizedBox(width: 8),
        ],
      ),
      body: BlocBuilder<FarmerBloc, FarmerState>(
        builder: (context, state) {
          if (state is FarmerScheduleLoading || state is FarmerLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            );
          }

          if (state is FarmerScheduleLoaded) {
            return _buildScheduleContent(state.schedules);
          }

          if (state is FarmerError) {
            return _buildErrorWidget(state.message);
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryGreen),
          );
        },
      ),
    );
  }

  Widget _buildScheduleContent(List<RoutineSchedule> schedules) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return RefreshIndicator(
      onRefresh: () async {
        context.read<FarmerBloc>().add(const LoadRoutineSchedule());
      },
      color: AppColors.primaryGreen,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Pickup Tracking Section (NEW)
            _buildActivePickupTracking(uid),
            const SizedBox(height: 20),

            // Community Pickup Tracking Section (NEW)
            _buildCommunityPickupTracking(uid),
            const SizedBox(height: 20),

            // Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2D5A27), Color(0xFF4CAF50)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Routine Pickups',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your waste will be picked up automatically on scheduled days. '
                        'No need to create manual listings!',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Schedule List
            const Text(
              'Your Schedule',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 12),

            if (schedules.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No schedule set. Tap below to create one.'),
                ),
              )
            else
              ...schedules.map((schedule) => _ScheduleCard(schedule: schedule)),

            const SizedBox(height: 24),

            // Update Schedule Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () => _showUpdateScheduleDialog(context),
                icon: const Icon(Icons.edit_calendar_rounded),
                label: const Text(
                  'Update Schedule',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Active Pickup Tracking Widget
  Widget _buildActivePickupTracking(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('farmerId', isEqualTo: uid)
          .where('status', whereIn: ['pending', 'assigned'])
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final pickup = snapshot.data!.docs.first;
        final data = pickup.data() as Map<String, dynamic>;
        final status = data['status'];

        if (status == 'pending') {
          return _buildPendingPickupCard(data);
        } else if (status == 'assigned') {
          final driverId = data['driverId'];
          if (driverId != null) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(driverId)
                  .snapshots(),
              builder: (context, driverSnapshot) {
                final driverData = driverSnapshot.hasData && driverSnapshot.data!.exists
                    ? driverSnapshot.data!.data() as Map<String, dynamic>
                    : null;
                return _buildAssignedPickupCard(data, driverData);
              },
            );
          }
          return _buildAssignedPickupCard(data, null);
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Community Pickup Tracking Widget
  Widget _buildCommunityPickupTracking(String uid) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('communities')
          .where('farmerIds', arrayContains: uid)
          .where('status', whereIn: ['assigned', 'active'])
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const SizedBox.shrink();
        }

        final community = snapshot.data!.docs.first;
        final data = community.data() as Map<String, dynamic>;
        final status = data['status'];

        if (status == 'assigned') {
          final driverId = data['assignedDriverId'];
          if (driverId != null) {
            return StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .doc(driverId)
                  .snapshots(),
              builder: (context, driverSnapshot) {
                final driverData = driverSnapshot.hasData && driverSnapshot.data!.exists
                    ? driverSnapshot.data!.data() as Map<String, dynamic>
                    : null;
                return _buildCommunityPickupCard(data, driverData);
              },
            );
          }
          return _buildCommunityPickupCard(data, null);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildPendingPickupCard(Map<String, dynamic> data) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.shade300, width: 2),
      ),
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
                    child: const Icon(Icons.pending_actions, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '⏳ Pickup Request Pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                        Text(
                          'Waiting for admin to assign a driver',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
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
                        const Text('📅 Schedule', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${data['scheduleDay'] ?? 'Flexible'} • ${data['scheduleTime'] ?? 'Anytime'}'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💰 Price', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('KSh ${data['pricePerKg'] ?? 5}/kg'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAssignedPickupCard(Map<String, dynamic> data, Map<String, dynamic>? driverData) {
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final waitingDays = DateTime.now().difference(createdAt).inDays;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade300, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.blue.shade100],
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
                      color: Colors.blue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.local_shipping, color: Colors.blue, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🚚 Pickup Assigned!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Driver is on the way',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                  ),
                  if (waitingDays >= 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'URGENT',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Driver Info
              if (driverData != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: const Icon(Icons.person, color: Colors.blue),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Assigned Driver', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  driverData['name'] ?? driverData['fullName'] ?? 'Driver',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  driverData['phone'] ?? driverData['phoneNumber'] ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (driverData['isAvailable'] == true)
                            const Chip(
                              label: Text('En Route', style: TextStyle(fontSize: 10)),
                              backgroundColor: Colors.green,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDriverContactDialog(context, driverData),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Contact Driver'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: const BorderSide(color: Colors.blue),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Pickup Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📍 Location', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text(data['pickupAddress']?.split(',').first ?? 'Address'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📅 Schedule', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${data['scheduleDay'] ?? 'Today'} • ${data['scheduleTime'] ?? 'Flexible'}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Indicator
              LinearProgressIndicator(
                value: 0.5,
                backgroundColor: Colors.grey.shade200,
                color: Colors.blue,
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🔄 Requested', style: TextStyle(fontSize: 11)),
                  const Text('🚚 Assigned', style: TextStyle(fontSize: 11, color: Colors.blue)),
                  Text('🏁 Completed', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityPickupCard(Map<String, dynamic> data, Map<String, dynamic>? driverData) {
    final estimatedKg = data['currentEstimatedKg'] ?? 0;
    final pricePerKg = data['agreedPricePerKg'] ?? 5;
    final estimatedEarnings = estimatedKg * pricePerKg;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade300, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [Colors.green.shade50, Colors.green.shade100],
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
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.people_alt, color: Colors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🌾 Community Pickup Scheduled!',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          data['name'] ?? 'Your Community',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'IN PROGRESS',
                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Driver Info
              if (driverData != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.person, color: Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Assigned Driver', style: TextStyle(fontSize: 12, color: Colors.grey)),
                                Text(
                                  driverData['name'] ?? driverData['fullName'] ?? 'Driver',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  driverData['phone'] ?? driverData['phoneNumber'] ?? '',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          if (driverData['isAvailable'] == true)
                            const Chip(
                              label: Text('En Route', style: TextStyle(fontSize: 10)),
                              backgroundColor: Colors.orange,
                              labelStyle: TextStyle(color: Colors.white),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _showDriverContactDialog(context, driverData),
                          icon: const Icon(Icons.phone, size: 18),
                          label: const Text('Contact Driver'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Pickup Details
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('👥 Farmers', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${data['farmerIds']?.length ?? 0} farmers in community'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('📦 Total Waste', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('${estimatedKg.toInt()} kg', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('💰 Est. Earnings', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        Text('KSh ${estimatedEarnings.toInt()}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Progress Indicator
              LinearProgressIndicator(
                value: 0.7,
                backgroundColor: Colors.grey.shade200,
                color: Colors.green,
                minHeight: 6,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('🔄 Target Reached', style: TextStyle(fontSize: 11)),
                  const Text('🚚 Driver Assigned', style: TextStyle(fontSize: 11, color: Colors.green)),
                  Text('🏁 Collection', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDriverContactDialog(BuildContext context, Map<String, dynamic>? driverData) {
    if (driverData == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Driver'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: const Icon(Icons.person, color: AppColors.primaryGreen),
              ),
              title: Text(driverData['name'] ?? driverData['fullName'] ?? 'Driver'),
              subtitle: const Text('Driver Name'),
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.withOpacity(0.1),
                child: const Icon(Icons.phone, color: Colors.blue),
              ),
              title: Text(driverData['phone'] ?? driverData['phoneNumber'] ?? 'N/A'),
              subtitle: const Text('Phone Number'),
              onTap: () {
                // You can add phone call functionality here
                Navigator.pop(ctx);
              },
            ),
            if (driverData['vehicleNumber'] != null)
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange.withOpacity(0.1),
                  child: const Icon(Icons.directions_car, color: Colors.orange),
                ),
                title: Text(driverData['vehicleNumber']),
                subtitle: const Text('Vehicle Number'),
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

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(message),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<FarmerBloc>().add(const LoadRoutineSchedule());
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateScheduleDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ScheduleForm(
        onCreatePickup: _createPickupRequest,
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final RoutineSchedule schedule;

  const _ScheduleCard({required this.schedule});

  @override
  Widget build(BuildContext context) {
    final isActive = schedule.isActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.primaryGreen.withOpacity(0.3) : Colors.grey.shade200,
          width: isActive ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primaryGreen.withOpacity(0.1)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _getDayIcon(schedule.dayOfWeek),
              color: isActive ? AppColors.primaryGreen : Colors.grey,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      schedule.dayOfWeek ?? 'Not Set',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.darkGray : Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.success.withOpacity(0.1)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isActive ? 'Active' : 'Paused',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isActive ? AppColors.success : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded, size: 16, color: isActive ? AppColors.mediumGray : Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      schedule.timeSlot ?? 'Flexible',
                      style: TextStyle(fontSize: 14, color: isActive ? AppColors.mediumGray : Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.repeat_rounded, size: 16, color: isActive ? AppColors.mediumGray : Colors.grey),
                    const SizedBox(width: 4),
                    Text('Weekly', style: TextStyle(fontSize: 14, color: isActive ? AppColors.mediumGray : Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          Switch(
            value: isActive,
            onChanged: (value) {
              context.read<FarmerBloc>().add(
                UpdateRoutineSchedule(
                  isActive: value,
                  preferredDay: schedule.dayOfWeek,
                  preferredTimeSlot: schedule.timeSlot,
                ),
              );
            },
            activeTrackColor: AppColors.primaryGreen,
          ),
        ],
      ),
    );
  }

  IconData _getDayIcon(String? day) {
    switch (day?.toLowerCase()) {
      case 'monday': return Icons.looks_one_rounded;
      case 'tuesday': return Icons.looks_two_rounded;
      case 'wednesday': return Icons.looks_3_rounded;
      case 'thursday': return Icons.looks_4_rounded;
      case 'friday': return Icons.looks_5_rounded;
      case 'saturday': return Icons.looks_6_rounded;
      case 'sunday': return Icons.calendar_today_rounded;
      default: return Icons.calendar_month_rounded;
    }
  }
}

class _ScheduleForm extends StatefulWidget {
  final Function(String, String) onCreatePickup;

  const _ScheduleForm({required this.onCreatePickup});

  @override
  State<_ScheduleForm> createState() => _ScheduleFormState();
}

class _ScheduleFormState extends State<_ScheduleForm> {
  bool _isActive = true;
  String _selectedDay = 'Monday';
  String _selectedTimeSlot = 'Morning (6AM - 10AM)';
  bool _isCreating = false;

  final _days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  final _timeSlots = [
    'Morning (6AM - 10AM)',
    'Midday (10AM - 2PM)',
    'Afternoon (2PM - 6PM)',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Update Pickup Schedule',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.darkGray),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Enable Routine Pickups', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Switch(
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
                activeTrackColor: AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text('Preferred Day', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkGray)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _days.map((day) {
              final isSelected = _selectedDay == day;
              return GestureDetector(
                onTap: () => setState(() => _selectedDay = day),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryGreen : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.primaryGreen : Colors.grey.shade300),
                  ),
                  child: Text(
                    day.substring(0, 3),
                    style: TextStyle(color: isSelected ? Colors.white : AppColors.darkGray, fontWeight: FontWeight.w600),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Preferred Time', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.darkGray)),
          const SizedBox(height: 8),
          ..._timeSlots.map((slot) {
            final isSelected = _selectedTimeSlot == slot;
            return RadioListTile<String>(
              value: slot,
              groupValue: _selectedTimeSlot,
              onChanged: (value) => setState(() => _selectedTimeSlot = value!),
              title: Text(slot, style: const TextStyle(fontSize: 14)),
              activeColor: AppColors.primaryGreen,
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isCreating ? null : () async {
                setState(() => _isCreating = true);
                context.read<FarmerBloc>().add(
                  UpdateRoutineSchedule(
                    isActive: _isActive,
                    preferredDay: _selectedDay,
                    preferredTimeSlot: _selectedTimeSlot,
                  ),
                );
                if (_isActive) {
                  await widget.onCreatePickup(_selectedDay, _selectedTimeSlot);
                }
                setState(() => _isCreating = false);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Schedule updated successfully!'),
                      behavior: SnackBarBehavior.floating,
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isCreating
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save Schedule', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/navigation_service.dart';

class DriverHomeScreen extends StatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _driverData;
  Map<String, dynamic>? _assignedRoute;
  bool _loading = true;
  int _completedCount = 0;

  @override
  void initState() {
    super.initState();
    _loadDriverData();
  }

  Future<void> _loadDriverData() async {
    setState(() => _loading = true);

    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('🔍 Loading data for driver: ${user.uid}');

        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          print('✅ Driver data loaded: ${data['fullName']}');

          setState(() {
            _driverData = data;
            _assignedRoute = data['assignedRoute'] as Map<String, dynamic>?;
          });

          print('📍 Assigned Route: ${_assignedRoute?['routeName'] ?? 'None'}');
          print('📍 Pickup: ${_assignedRoute?['pickupLocation']?['fullAddress'] ?? 'N/A'}');
          print('📍 Destination: ${_assignedRoute?['destination'] ?? 'N/A'}');

          await _loadCompletedCount();
        } else {
          print('❌ Driver document does not exist');
        }
      }
    } catch (e) {
      print('❌ Error loading driver data: $e');
    }

    setState(() => _loading = false);
  }

  Future<void> _loadCompletedCount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final query = await _firestore
          .collection('listings')
          .where('driverId', isEqualTo: user.uid)
          .where('status', isEqualTo: 'completed')
          .get();

      setState(() {
        _completedCount = query.docs.length;
      });
    } catch (e) {
      print('Error loading completed count: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Driver Dashboard'),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDriverData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _auth.signOut();
              NavigationService.pushReplacement('/login');
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _loadDriverData,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Driver Info Card
              _buildDriverInfoCard(),
              const SizedBox(height: 16),

              // Stats
              _buildStatsRow(),
              const SizedBox(height: 16),

              // Assigned Route Section
              const Text(
                "Today's Route",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Route Card
              Expanded(
                child: _assignedRoute != null
                    ? _buildRouteCard()
                    : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.route, size: 64, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      Text(
                        'No route assigned',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Contact admin for route assignment',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDriverInfoCard() {
    final pickupLocation = _assignedRoute?['pickupLocation'] as Map<String, dynamic>?;
    final pickupAddress = pickupLocation?['fullAddress'] ?? 'No pickup assigned';
    final destination = _assignedRoute?['destination'] ?? 'No destination assigned';
    final status = _driverData?['status'] ?? 'idle';
    final progress = (_driverData?['routeProgress'] ?? 0.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  _driverData?['fullName']?.isNotEmpty == true
                      ? _driverData!['fullName'][0].toUpperCase()
                      : 'D',
                  style: const TextStyle(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _driverData?['fullName'] ?? 'Driver',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Vehicle: ${_driverData?['vehicleType'] ?? 'N/A'} ${_driverData?['vehicleNumber'] ?? ''}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: status == 'active' ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    color: status == 'active' ? Colors.green : Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Route Progress
          if (status == 'active') ...[
            Row(
              children: [
                Text(
                  'Route Progress',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStat('Route', _assignedRoute != null ? '1' : '0'),
          _buildStat('Completed', _completedCount.toString()),
          _buildStat('Status', _driverData?['status'] ?? 'idle'),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildRouteCard() {
    final pickupLocation = _assignedRoute?['pickupLocation'] as Map<String, dynamic>?;
    final pickupAddress = pickupLocation?['fullAddress'] ?? 'No pickup assigned';
    final destination = _assignedRoute?['destination'] ?? 'No destination assigned';
    final routeName = _assignedRoute?['routeName'] ?? 'Unnamed Route';
    final scheduledDate = _assignedRoute?['scheduledDate'] ?? 'Not scheduled';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Route Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.route, color: Colors.green.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        routeName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Scheduled: $scheduledDate',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400),
              ],
            ),
            const Divider(height: 24),

            // Pickup Location
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_on, color: Colors.green.shade700, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pickup Location',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        pickupAddress,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Destination
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.location_city, color: Colors.red.shade700, size: 16),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Destination',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Pass the route data to the route screen
                  NavigationService.pushNamed(
                    '/driver/route',
                    arguments: {
                      'routeName': routeName,
                      'pickupLocation': pickupLocation,
                      'destination': destination,
                      'scheduledDate': scheduledDate,
                      'driverData': _driverData,
                    },
                  );
                },
                icon: const Icon(Icons.navigation),
                label: const Text('VIEW ROUTE'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
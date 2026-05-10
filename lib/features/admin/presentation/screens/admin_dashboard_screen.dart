import 'admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../../core/services/navigation_service.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/widgets/app_map.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  int _totalFarmers = 0;
  int _totalDrivers = 0;
  int _totalCommunities = 0;
  int _totalCompanies = 0;
  int _activePickups = 0;
  double _totalWasteCollected = 0;
  List<Map<String, dynamic>> _farmerLocations = [];
  List<Map<String, dynamic>> _recentFarmers = [];
  List<Map<String, dynamic>> _urgentPickups = [];
  bool _loading = true;
  String? _error;

  // Section expansion states
  bool _showFarmersList = false;
  bool _showUrgentPickups = false;
  bool _showStats = false;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Load farmers with locations
      final farmersSnap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'farmer')
          .get();
      _totalFarmers = farmersSnap.size;

      // Get farmers with coordinates for map
      _farmerLocations = farmersSnap.docs
          .where((doc) {
        final data = doc.data();
        return data['latitude'] != null && data['longitude'] != null;
      })
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['fullName'] ?? 'Unknown',
          'latitude': data['latitude'],
          'longitude': data['longitude'],
          'waste': (data['estimatedWasteKg'] ?? 0).toInt(),
          'phone': data['phoneNumber'] ?? '',
        };
      }).toList();

      // Get recent farmers
      _recentFarmers = farmersSnap.docs
          .take(5)
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'name': data['fullName'] ?? 'Unknown',
          'phone': data['phoneNumber'] ?? '',
          'county': data['county'] ?? 'Unknown',
          'waste': (data['estimatedWasteKg'] ?? 0).toInt(),
          'joinedAt': data['createdAt'] != null
              ? (data['createdAt'] as Timestamp).toDate()
              : DateTime.now(),
          'latitude': data['latitude'],
          'longitude': data['longitude'],
        };
      }).toList();

      // Load drivers
      final driversSnap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'driver')
          .get();
      _totalDrivers = driversSnap.size;

      // Load communities
      final communitiesSnap = await _firestore.collection('communities').get();
      _totalCommunities = communitiesSnap.size;

      // Load companies
      final companiesSnap = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'company')
          .get();
      _totalCompanies = companiesSnap.size;

      // Load active pickups
      final pickupsSnap = await _firestore
          .collection('listings')
          .where('status', whereIn: ['pending', 'assigned'])
          .get();
      _activePickups = pickupsSnap.size;

      // Calculate total waste collected
      final completedSnap = await _firestore
          .collection('listings')
          .where('status', isEqualTo: 'completed')
          .get();
      _totalWasteCollected = completedSnap.docs.fold<double>(
          0,
              (sum, doc) => sum + ((doc.data()['actualQuantity'] ?? doc.data()['estimatedQuantity'] ?? 0).toDouble())
      );

      // Load urgent pickups
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final urgentSnap = await _firestore
          .collection('listings')
          .where('status', isEqualTo: 'pending')
          .get();
      _urgentPickups = urgentSnap.docs
          .where((doc) {
        final createdAt = doc.data()['createdAt'] as Timestamp?;
        return createdAt != null && createdAt.toDate().isBefore(twoDaysAgo);
      })
          .map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'farmerName': data['farmerName'] ?? 'Unknown',
          'wasteType': data['wasteType'] ?? 'Waste',
          'quantity': (data['estimatedQuantity'] ?? 0).toInt(),
          'waitingDays': DateTime.now().difference(
              (data['createdAt'] as Timestamp).toDate()
          ).inDays,
          'latitude': data['pickupLat'],
          'longitude': data['pickupLng'],
        };
      }).toList();

    } catch (e) {
      print('Error loading dashboard: $e');
      setState(() {
        _error = 'Failed to load dashboard data. Pull down to refresh.';
      });
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(child: Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
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
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : RefreshIndicator(
        onRefresh: _loadDashboardData,
        color: AppColors.primaryGreen,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              _buildWelcomeCard(),
              const SizedBox(height: 20),

              // Quick Actions (Always visible)
              _buildQuickActions(),
              const SizedBox(height: 20),

              // Farmer Locations Map
              _buildFarmerMap(),
              const SizedBox(height: 20),

              // Collapsible Stats Section
              _buildCollapsibleSection(
                title: 'Platform Statistics',
                icon: Icons.analytics,
                isExpanded: _showStats,
                onToggle: () => setState(() => _showStats = !_showStats),
                child: _buildStatsGrid(),
              ),
              const SizedBox(height: 12),

              // Collapsible Recent Farmers Section
              _buildCollapsibleSection(
                title: 'Recent Farmers',
                icon: Icons.people,
                isExpanded: _showFarmersList,
                onToggle: () => setState(() => _showFarmersList = !_showFarmersList),
                child: _buildRecentFarmersList(),
              ),
              const SizedBox(height: 12),

              // Collapsible Urgent Pickups Section
              if (_urgentPickups.isNotEmpty)
                _buildCollapsibleSection(
                  title: 'Urgent Pickups (${_urgentPickups.length})',
                  icon: Icons.warning_amber,
                  isExpanded: _showUrgentPickups,
                  onToggle: () => setState(() => _showUrgentPickups = !_showUrgentPickups),
                  child: _buildUrgentPickupsList(),
                ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildWelcomeCard() {
    final adminName = _auth.currentUser?.email ?? 'Admin';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
         
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: AppColors.primaryGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
        ],
      ),
    );
  }

  Widget _buildFarmerMap() {
    if (_farmerLocations.isEmpty) {
      return Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map_outlined, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'No farmer locations available',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Farmers need to enable location services',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Get center point (average of all locations)
    double centerLat = _farmerLocations.fold<double>(0, (sum, f) => sum + (f['latitude'] ?? 0)) / _farmerLocations.length;
    double centerLng = _farmerLocations.fold<double>(0, (sum, f) => sum + (f['longitude'] ?? 0)) / _farmerLocations.length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.map, color: AppColors.primaryGreen),
                SizedBox(width: 8),
                Text(
                  'Farmer Locations Map',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          AppMap(
            latitude: centerLat,
            longitude: centerLng,
            title: '${_farmerLocations.length} Farmers',
            height: 300,
            interactive: true,
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _farmerLocations.take(5).map((farmer) {
                return Chip(
                  label: Text(
                    farmer['name'],
                    style: const TextStyle(fontSize: 12),
                  ),
                  avatar: const Icon(Icons.location_on, size: 16),
                  backgroundColor: Colors.green.shade50,
                  onDeleted: () {},
                  deleteIcon: const SizedBox.shrink(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    // In admin_dashboard_screen.dart, update quick actions:
    final actions = [
      ('Farmers', Icons.people, Colors.green, _showFarmersDetail),
      ('Drivers', Icons.local_shipping, Colors.blue, _showDriversDetail),
      ('Communities', Icons.people_alt, Colors.orange, _showCommunitiesDetail),
      ('Companies', Icons.business, Colors.purple, () {
        NavigationService.push('/admin/companies');
      }),
      ('Pickups', Icons.pending_actions, Colors.red, () {
        NavigationService.push('/admin/pickups');
      }),
      ('Reports', Icons.analytics, Colors.brown, _showReportsDetail),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return InkWell(
                onTap: action.$4,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: action.$3.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(action.$2, color: action.$3, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        action.$1,
                        style: TextStyle(color: action.$3, fontSize: 13, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      ('Total Farmers', _totalFarmers.toString(), Icons.people, Colors.green),
      ('Active Drivers', _totalDrivers.toString(), Icons.local_shipping, Colors.blue),
      ('Communities', _totalCommunities.toString(), Icons.people_alt, Colors.orange),
      ('Companies', _totalCompanies.toString(), Icons.business, Colors.purple),
      ('Active Pickups', _activePickups.toString(), Icons.pending_actions, Colors.red),
      ('Waste Collected', '${_totalWasteCollected.toInt()} kg', Icons.recycling, Colors.teal),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: stat.$4.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stat.$3, color: stat.$4, size: 28),
              const SizedBox(height: 8),
              Text(
                stat.$2,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: stat.$4,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stat.$1,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentFarmersList() {
    if (_recentFarmers.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No farmers registered yet'),
        ),
      );
    }

    return Column(
      children: _recentFarmers.asMap().entries.map((entry) {
        final farmer = entry.value;
        return Column(
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                child: Text(
                  farmer['name'][0].toUpperCase(),
                  style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(farmer['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text('${farmer['phone']} • ${farmer['county']} • ${farmer['waste']} kg'),
              trailing: Chip(
                label: Text(_formatDate(farmer['joinedAt']), style: const TextStyle(fontSize: 10)),
                backgroundColor: Colors.grey.shade100,
              ),
              onTap: () => _showFarmerDetails(farmer),
            ),
            if (entry.key != _recentFarmers.length - 1) const Divider(height: 0, indent: 72),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildUrgentPickupsList() {
    return Column(
      children: _urgentPickups.asMap().entries.map((entry) {
        final pickup = entry.value;
        return Column(
          children: [
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: Text(pickup['farmerName']),
              subtitle: Text(
                '${pickup['wasteType']} • ${pickup['quantity']} kg • Waiting ${pickup['waitingDays']} days',
              ),
              trailing: SizedBox(
                width: 120,
                child: ElevatedButton(
                  onPressed: () => _assignDriver(pickup),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Assign'),
                ),
              ),
            ),
            if (entry.key != _urgentPickups.length - 1) const Divider(height: 0, indent: 72),
          ],
        );
      }).toList(),
    );
  }

  // Detail dialogs
  void _showFarmersDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Farmers Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: $_totalFarmers farmers',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _recentFarmers.length,
                itemBuilder: (context, index) {
                  final farmer = _recentFarmers[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                        child: Text(farmer['name'][0].toUpperCase()),
                      ),
                      title: Text(farmer['name']),
                      subtitle: Text('${farmer['phone']} • ${farmer['waste']} kg'),
                      trailing: IconButton(
                        icon: const Icon(Icons.visibility),
                        onPressed: () => _showFarmerDetails(farmer),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriversDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Drivers Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: $_totalDrivers drivers',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_shipping, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '$_totalDrivers Active Drivers',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => NavigationService.push('/admin/fleet'),
                    child: const Text('Manage Fleet'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommunitiesDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Communities Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: $_totalCommunities communities',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_alt, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '$_totalCommunities Active Communities',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => NavigationService.push('/admin/communities'),
                    child: const Text('Manage Communities'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompaniesDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Companies Overview',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: $_totalCompanies companies',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    '$_totalCompanies Partner Companies',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPickupsDetail() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Active Pickups',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Total: $_activePickups pending collections',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            if (_urgentPickups.isNotEmpty) ...[
              const Text(
                'Urgent (Waiting > 2 days)',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 8),
              ..._urgentPickups.map((pickup) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning, color: Colors.orange),
                  title: Text(pickup['farmerName']),
                  subtitle: Text('${pickup['wasteType']} • ${pickup['quantity']} kg'),
                  trailing: Text('${pickup['waitingDays']} days', style: const TextStyle(color: Colors.red)),
                ),
              )),
            ] else
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No active pickups at the moment'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showReportsDetail() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildReportTile('Weekly Summary', Icons.analytics, () {}),
            _buildReportTile('Monthly Earnings', Icons.attach_money, () {}),
            _buildReportTile('Farmer Performance', Icons.people, () {}),
            _buildReportTile('Waste Collection', Icons.recycling, () {}),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildReportTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primaryGreen),
      ),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showFarmerDetails(Map<String, dynamic> farmer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(farmer['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.phone, farmer['phone']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.location_on, farmer['county']),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.recycling, '${farmer['waste']} kg estimated'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, _formatDate(farmer['joinedAt'])),
            if (farmer['latitude'] != null && farmer['longitude'] != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    // Navigate to map view centered on farmer
                  },
                  icon: const Icon(Icons.map),
                  label: const Text('View on Map'),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  void _assignDriver(Map<String, dynamic> pickup) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Driver'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select a driver for this pickup'),
            // Add driver selection dropdown here
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Driver assigned successfully')),
              );
            },
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) return '${(difference.inDays / 30).floor()}mo ago';
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }
}
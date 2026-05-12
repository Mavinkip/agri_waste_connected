import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../../shared/models/company_model.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  int _selectedIndex = 0;
  CompanyModel? _company;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyData();
  }

  Future<void> _loadCompanyData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      NavigationService.pushReplacement('/login');
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists && mounted) {
      setState(() {
        _company = CompanyModel.fromMap(user.uid, doc.data()!);
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      NavigationService.pushReplacement('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primaryGreen)),
      );
    }

    if (_company == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Failed to load company data'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCompanyData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(_company!.name),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _HomeTab(company: _company!),
          _PricingTab(company: _company!),
          _CommunitiesTab(company: _company!),
          _ProfileTab(company: _company!),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.attach_money), label: 'Pricing'),
          NavigationDestination(icon: Icon(Icons.people_alt), label: 'Communities'),
          NavigationDestination(icon: Icon(Icons.business), label: 'Profile'),
        ],
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final CompanyModel company;

  const _HomeTab({required this.company});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('companyId', isEqualTo: company.id)
          .snapshots(),
      builder: (context, snapshot) {
        int assignedPickups = 0;
        int completedPickups = 0;
        double totalWaste = 0;

        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'assigned') assignedPickups++;
            if (data['status'] == 'completed') {
              completedPickups++;
              totalWaste += (data['actualQuantity'] ?? data['estimatedQuantity'] ?? 0).toDouble();
            }
          }
        }

        return RefreshIndicator(
          onRefresh: () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text('Company Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildOverviewItem(Icons.pending_actions, 'Assigned', assignedPickups.toString(), Colors.orange),
                            _buildOverviewItem(Icons.check_circle, 'Completed', completedPickups.toString(), Colors.green),
                            _buildOverviewItem(Icons.recycling, 'Total Waste', '${totalWaste.toInt()} kg', Colors.blue),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Statistics', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        _buildStatRow('Total Waste Processed', '${company.totalWasteProcessed.toInt()} kg', Icons.recycling),
                        const Divider(),
                        _buildStatRow('Total Paid', 'KSh ${company.totalPaid.toInt()}', Icons.money),
                        const Divider(),
                        _buildStatRow('Active Status', company.isActive ? 'Active' : 'Inactive',
                            company.isActive ? Icons.check_circle : Icons.cancel,
                            color: company.isActive ? Colors.green : Colors.red),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOverviewItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon, {Color color = Colors.grey}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class _PricingTab extends StatefulWidget {
  final CompanyModel company;

  const _PricingTab({required this.company});

  @override
  State<_PricingTab> createState() => _PricingTabState();
}

class _PricingTabState extends State<_PricingTab> {
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
    for (var type in _wasteTypes) {
      _controllers[type] = TextEditingController(
        text: (widget.company.priceList[type] ?? 0).toString(),
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
        .collection('users')
        .doc(widget.company.id)
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
    return SingleChildScrollView(
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
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save All Prices', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceCard(String wasteType) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

class _CommunitiesTab extends StatelessWidget {
  final CompanyModel company;

  const _CommunitiesTab({required this.company});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('communities')
          .where('status', isEqualTo: 'forming')
          .where('county', isEqualTo: company.county)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        var communities = snapshot.data!.docs;

        if (communities.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.people_alt, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text('No communities found in your area'),
                Text('Check back later when communities form', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {},
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: communities.length,
            itemBuilder: (ctx, index) {
              final data = communities[index].data() as Map<String, dynamic>;
              return _CommunityCard(
                communityId: communities[index].id,
                data: data,
                company: company,
              );
            },
          ),
        );
      },
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final String communityId;
  final Map<String, dynamic> data;
  final CompanyModel company;

  const _CommunityCard({
    required this.communityId,
    required this.data,
    required this.company,
  });

  @override
  Widget build(BuildContext context) {
    final currentWeight = (data['currentEstimatedKg'] ?? 0).toDouble();
    final targetWeight = (data['targetWeightKg'] ?? 1000).toDouble();
    final progress = currentWeight / targetWeight;
    final isClaimed = data['assignedCompanyId'] == company.id;
    final companyPrice = company.priceList[data['wasteType']] ?? 5;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isClaimed ? Border.all(color: Colors.green, width: 2) : null,
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
                        Text(
                          data['name'] ?? 'Community',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        Text(
                          '${data['farmerIds']?.length ?? 0} farmers • ${data['subCounty'] ?? ''}',
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  if (isClaimed)
                    const Chip(
                      label: Text('CLAIMED', style: TextStyle(fontSize: 10)),
                      backgroundColor: Colors.green,
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text('Waste Type: ${_formatWasteType(data['wasteType'] ?? 'mixedOrganic')}'),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                backgroundColor: Colors.grey.shade200,
                color: AppColors.primaryGreen,
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${currentWeight.toInt()} / ${targetWeight.toInt()} kg collected'),
                  Text('${(progress * 100).toInt()}%'),
                ],
              ),
              const SizedBox(height: 12),
              if (!isClaimed) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info, size: 16, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your offered price: KSh $companyPrice/kg',
                          style: const TextStyle(fontSize: 12, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _claimCommunity(context, companyPrice),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Claim This Community'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
              if (isClaimed)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _viewDetails(context),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryGreen,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _claimCommunity(BuildContext context, double price) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Claim Community'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('By claiming this community:'),
            const SizedBox(height: 8),
            Text('• You will pay KSh $price per kg'),
            const Text('• You agree to collect all waste once target is reached'),
            const Text('• This price will be locked for this community'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await FirebaseFirestore.instance.collection('communities').doc(communityId).update({
                'assignedCompanyId': company.id,
                'assignedCompanyName': company.name,
                'agreedPricePerKg': price,
                'status': 'active',
              });
              Navigator.pop(ctx);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Community claimed successfully!'), backgroundColor: Colors.green),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Claim'),
          ),
        ],
      ),
    );
  }

  void _viewDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name'] ?? 'Community', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('📍 Location: ${data['subCounty']}, ${data['county']}'),
            Text('👥 Farmers: ${data['farmerIds']?.length ?? 0}'),
            Text('📦 Target: ${data['targetWeightKg'] ?? 0} kg'),
            Text('💰 Your Price: KSh ${data['agreedPricePerKg'] ?? 0}/kg'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
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

class _ProfileTab extends StatelessWidget {
  final CompanyModel company;

  const _ProfileTab({required this.company});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.business, size: 60, color: AppColors.primaryGreen),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    company.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: company.isActive ? Colors.green.shade100 : Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      company.isActive ? 'ACTIVE' : 'INACTIVE',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: company.isActive ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Contact Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.email, 'Email', company.email),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.phone, 'Phone', company.phone),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.location_on, 'Location', '${company.subCounty}, ${company.county}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.place, 'Ward', company.ward),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.home, 'Address', company.address),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Statistics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildInfoRow(Icons.recycling, 'Total Waste Processed', '${company.totalWasteProcessed.toInt()} kg'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.money, 'Total Paid', 'KSh ${company.totalPaid.toInt()}'),
                  const SizedBox(height: 8),
                  _buildInfoRow(Icons.calendar_today, 'Member Since', _formatDate(company.createdAt)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

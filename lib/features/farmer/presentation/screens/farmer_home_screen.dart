import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/farmer_app_menu.dart';
import '../widgets/offline_banner.dart';
import '../widgets/language_provider.dart';
import '../widgets/profile_notifier.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});
  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _lang = LanguageNotifier();
  final _profile = ProfileNotifier.instance;

  StreamSubscription<QuerySnapshot>? _listingsStream;
  StreamSubscription<DocumentSnapshot>? _communityStream;
  double _monthlyEarnings = 0;
  int _activeListings = 0;
  int _completedSales = 0;
  int _totalPickups = 0;
  double _avgRating = 0;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _loading = true;

  // Community tracking variables
  double _communityContribution = 0;
  double _communityGoal = 0;
  String? _communityId;
  String _communityName = 'No Community';
  String _communityStatus = '';
  String? _collectionPointAddress;
  List<Map<String, dynamic>> _availableCommunities = [];
  bool _isInCommunity = false;

  @override
  void initState() {
    super.initState();
    _profile.load();
    _startStream();
    _loadUserCommunity();
    _loadAvailableCommunities();
  }

  void _startStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _listingsStream = _firestore.collection('listings').where('farmerId', isEqualTo: uid).snapshots().listen((snap) {
      int active = 0, completed = 0;
      double earnings = 0;
      double totalWaste = 0;
      List<Map<String, dynamic>> recent = [];
      for (var doc in snap.docs) {
        final d = doc.data();
        final status = d['status'] ?? '';
        final qty = (d['estimatedQuantity'] ?? 0).toDouble();
        totalWaste += qty;
        if (status == 'pending' || status == 'assigned') active++;
        if (status == 'completed') { completed++; earnings += qty * 5.0; }
        recent.add({
          'wasteType': d['wasteType'] ?? 'Waste',
          'quantity': qty.toInt(),
          'status': status,
          'amount': (qty * 5.0).toInt(),
          'date': (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()
        });
      }
      recent.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      if (mounted) setState(() {
        _activeListings = active;
        _completedSales = completed;
        _totalPickups = snap.docs.length;
        _monthlyEarnings = earnings;
        _avgRating = snap.docs.isNotEmpty ? 4.5 : 0;
        _recentTransactions = recent;
        _loading = false;
        _communityContribution = totalWaste;
      });

      // Update community contribution in Firestore
      if (_communityId != null && totalWaste > 0) {
        _updateCommunityContribution(totalWaste);
      }
    });
  }

  Future<void> _updateCommunityContribution(double wasteAmount) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || _communityId == null) return;

    try {
      // Update user's waste estimate
      await _firestore.collection('users').doc(uid).update({
        'estimatedWasteKg': wasteAmount,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      // Update community total contribution
      final communityRef = _firestore.collection('communities').doc(_communityId);
      final communityDoc = await communityRef.get();
      if (communityDoc.exists) {
        final currentTotal = (communityDoc.data()?['currentEstimatedKg'] ?? 0).toDouble();
        await communityRef.update({
          'currentEstimatedKg': currentTotal + wasteAmount,
        });
      }
    } catch (e) {
      print('Error updating contribution: $e');
    }
  }

  Future<void> _loadUserCommunity() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    try {
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        _communityId = userData['communityId'];

        if (_communityId != null && _communityId!.isNotEmpty) {
          _isInCommunity = true;
          _listenToCommunity(_communityId!);
        } else {
          setState(() {
            _isInCommunity = false;
            _communityName = 'No Community';
          });
        }
      }
    } catch (e) {
      print('Error loading user community: $e');
    }
  }

  void _listenToCommunity(String communityId) {
    _communityStream = _firestore.collection('communities').doc(communityId).snapshots().listen((snap) {
      if (snap.exists && mounted) {
        final data = snap.data()!;
        setState(() {
          _communityName = data['name'] ?? 'Community';
          _communityGoal = (data['targetWeightKg'] ?? 10000).toDouble();
          _communityStatus = data['status'] ?? 'forming';
          _collectionPointAddress = data['collectionPointAddress'];
        });
      }
    });
  }

  Future<void> _loadAvailableCommunities() async {
    try {
      final communitiesSnap = await _firestore
          .collection('communities')
          .where('status', isEqualTo: 'forming')
          .get();

      setState(() {
        _availableCommunities = communitiesSnap.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            'name': data['name'] ?? 'Unknown',
            'goal': (data['targetWeightKg'] ?? 10000).toDouble(),
            'currentContribution': (data['currentEstimatedKg'] ?? 0).toDouble(),
            'members': (data['farmerIds'] as List?)?.length ?? 0,
            'county': data['county'] ?? '',
            'subCounty': data['subCounty'] ?? '',
            'status': data['status'] ?? 'forming',
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading communities: $e');
    }
  }

  Future<void> _joinCommunity(String communityId, String communityName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Add farmer to community
      await _firestore.collection('communities').doc(communityId).update({
        'farmerIds': FieldValue.arrayUnion([uid]),
      });

      // Update user with community info
      await _firestore.collection('users').doc(uid).update({
        'communityId': communityId,
        'community': communityName,
        'joinedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _communityId = communityId;
          _communityName = communityName;
          _isInCommunity = true;
        });
        _listenToCommunity(communityId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Joined $communityName successfully!')),
        );
        _loadAvailableCommunities();
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to join community. Please try again.')),
      );
    }
  }

  Future<void> _showAvailableCommunities() async {
    await _loadAvailableCommunities();

    if (_availableCommunities.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No communities available to join at the moment.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Communities',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Join a community to contribute toward collective recycling goals',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                itemCount: _availableCommunities.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final community = _availableCommunities[index];
                  final progress = (community['currentContribution'] / community['goal']).clamp(0.0, 1.0);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D5A27).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.people_alt, color: Color(0xFF2D5A27)),
                      ),
                      title: Text(
                        community['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${community['county']}, ${community['subCounty']}'),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey.shade200,
                                  color: const Color(0xFF4CAF50),
                                  minHeight: 4,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${(progress * 100).toInt()}%',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                          Text(
                            '${community['members']} farmers • ${community['goal'].toInt()} kg goal',
                            style: const TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => _joinCommunity(community['id'], community['name']),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2D5A27),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text('Join'),
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

  Future<void> _viewCommunityDetails() async {
    if (_communityId == null) return;

    final communityDoc = await _firestore.collection('communities').doc(_communityId).get();
    if (!communityDoc.exists) return;

    final data = communityDoc.data()!;
    final progress = (_communityContribution / _communityGoal).clamp(0.0, 1.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people_alt, color: Color(0xFF2D5A27), size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _communityName,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor().withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _communityStatus.toUpperCase(),
                style: TextStyle(color: _getStatusColor(), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Goal: ${_communityGoal.toInt()} kg',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (_communityContribution / _communityGoal).clamp(0.0, 1.0),
              backgroundColor: Colors.grey.shade200,
              color: const Color(0xFF4CAF50),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),
            Text(
              '${((_communityContribution / _communityGoal) * 100).toStringAsFixed(1)}% Complete',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat('Your Contribution', '${_communityContribution.toInt()} kg'),
                _buildStat('Community Progress', '${_communityContribution.toInt()}/${_communityGoal.toInt()} kg'),
                _buildStat('Members', '${(data['farmerIds'] as List?)?.length ?? 0}'),
              ],
            ),
            if (_collectionPointAddress != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Collection Point: $_collectionPointAddress',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D5A27),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_communityStatus) {
      case 'active': return Colors.green;
      case 'collected': return Colors.blue;
      case 'completed': return Colors.purple;
      default: return Colors.orange;
    }
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _listingsStream?.cancel();
    _communityStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_lang, _profile]),
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          titleSpacing: 8,
          title: Row(children: [
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/farmer/profile'),
              child: CircleAvatar(radius: 18, backgroundColor: Colors.white.withOpacity(0.2), backgroundImage: _profile.photoPath != null ? FileImage(File(_profile.photoPath!)) : null, child: _profile.photoPath == null ? Text(_profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'F', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)) : null),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_profile.name.isNotEmpty ? 'Welcome, ${_profile.name}' : 'Agri-Waste Connect', style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ]),
          ]),
          actions: [
            GestureDetector(onTap: _lang.toggle, child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Text(_lang.lang == 'en' ? 'SW' : 'EN', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
            IconButton(icon: const Icon(Icons.notifications_outlined, size: 22), onPressed: () => Navigator.of(context).pushNamed('/farmer/notifications')),
            const FarmerAppMenu(currentScreen: 'home'),
          ],
        ),
        body: OfflineBanner(child: _loading ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D5A27))) : _dashboard()),
      ),
    );
  }

  Widget _dashboard() {
    return RefreshIndicator(
      color: const Color(0xFF2D5A27),
      onRefresh: () async {
        _profile.load();
        await _loadUserCommunity();
        await _loadAvailableCommunities();
        await Future.delayed(const Duration(milliseconds: 300));
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          _earningsCard(),
          const SizedBox(height: 10),
          _isInCommunity ? _communityCard() : _joinCommunityCard(),
          const SizedBox(height: 10),
          _statsGrid(),
          const SizedBox(height: 14),
          _quickActions(),
          const SizedBox(height: 14),
          _recentActivity(),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _earningsCard() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/farmer/earnings'),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1B5E20).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 16), const SizedBox(width: 6), Text(_lang.t('Monthly Earnings'), style: const TextStyle(fontSize: 13, color: Colors.white70))]), const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14)]),
          const SizedBox(height: 8),
          Text('KSh ${_monthlyEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
      ),
    );
  }

  Widget _communityCard() {
    final progress = (_communityContribution / _communityGoal).clamp(0.0, 1.0);

    return GestureDetector(
      onTap: _viewCommunityDetails,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E7D32).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt, color: Colors.white70, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'Community: $_communityName',
                      style: const TextStyle(fontSize: 13, color: Colors.white70),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _communityStatus,
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_communityContribution.toInt()} kg',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    Text(
                      _lang.t('Your Contribution'),
                      style: const TextStyle(fontSize: 11, color: Colors.white70),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Goal: ${_communityGoal.toInt()} kg',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          color: Colors.amber,
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% Complete',
                        style: const TextStyle(fontSize: 10, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _joinCommunityCard() {
    return GestureDetector(
      onTap: _showAvailableCommunities,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A6FA5), Color(0xFF6B9FD6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.group_add, color: Colors.white, size: 32),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Join a Community',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Connect with other farmers & reach collective goals',
                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _statsGrid() {
    final items = [
      (Icons.list_alt, '$_activeListings', _lang.t('Open Orders'), Colors.blue, '/farmer/sell/waste-type'),
      (Icons.check_circle, '$_completedSales', _lang.t('Sold'), Colors.green, null),
      (Icons.local_shipping, '$_totalPickups', _lang.t('Collections'), Colors.orange, null),
      (Icons.star, _avgRating.toStringAsFixed(1), _lang.t('My Rating'), Colors.amber, null),
    ];
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15),
      itemBuilder: (ctx, i) {
        final item = items[i];
        return GestureDetector(
          onTap: item.$5 != null ? () => Navigator.of(context).pushNamed(item.$5!) : null,
          child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: item.$4.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(item.$1, color: item.$4, size: 20)),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$2, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: item.$4)), Text(item.$3, style: const TextStyle(fontSize: 11, color: Colors.black54))]),
          ])),
        );
      },
    );
  }

  Widget _quickActions() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_lang.t('Quick Actions'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Row(children: [
        _btn(Icons.add_circle, _lang.t('Sell'), Colors.green, '/farmer/sell/waste-type'), const SizedBox(width: 6),
        _btn(Icons.wallet, _lang.t('Earnings'), Colors.blue, '/farmer/earnings'), const SizedBox(width: 6),
        _btn(Icons.calendar_month, _lang.t('Schedule'), Colors.orange, '/farmer/schedule'),
      ]),
    ]);
  }

  Widget _btn(IconData icon, String label, Color color, String route) {
    return Expanded(child: InkWell(onTap: () => Navigator.of(context).pushNamed(route), borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))), child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 4), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11))]))));
  }

  Widget _recentActivity() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_lang.t('Recent Activity'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 6),
      _recentTransactions.isEmpty
          ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Text('No activity yet', style: TextStyle(color: Colors.grey, fontSize: 12)))
          : Column(children: _recentTransactions.map((tx) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)), child: Row(children: [
        CircleAvatar(radius: 14, backgroundColor: const Color(0xFF2D5A27).withOpacity(0.1), child: const Icon(Icons.check, size: 14, color: Color(0xFF2D5A27))), const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tx['wasteType'] ?? 'Waste', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text('${tx['quantity']}kg', style: const TextStyle(fontSize: 11, color: Colors.grey))])),
        Text('+KSh ${tx['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
      ]))).toList()),
    ]);
  }
}
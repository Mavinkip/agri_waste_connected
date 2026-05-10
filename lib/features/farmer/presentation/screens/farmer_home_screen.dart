import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';
import 'schedule_screen.dart';
import 'profile_screen.dart';
import 'earnings_history_screen.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});
  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  int _tab = 0;
  UserModel? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() => _user = UserModel.fromMap(uid, doc.data()!));
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushNamedAndRemoveUntil(
        context, '/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Agri-Waste Connect'),
          backgroundColor: const Color(0xFF1A7A4A),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () =>
                    Navigator.pushNamed(context, '/farmer/notifications')),
            IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
          ],
        ),
        body: IndexedStack(
          index: _tab,
          children: [
            _HomeTab(user: _user),
            const EarningsHistoryScreen(),
            const ScheduleScreen(),
            const ProfileScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: (i) => setState(() => _tab = i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined),
                selectedIcon: Icon(Icons.account_balance_wallet), label: 'Earnings'),
            NavigationDestination(icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_today), label: 'Schedule'),
            NavigationDestination(icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () =>
              Navigator.pushNamed(context, '/farmer/sell/waste-type'),
          backgroundColor: const Color(0xFF1A7A4A),
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Sell Waste',
              style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final UserModel? user;
  const _HomeTab({this.user});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Hello, ${user?.name ?? "..."}!',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text('${user?.subCounty ?? ""}, ${user?.county ?? ""}',
              style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          _EarningsCard(uid: uid),
          const SizedBox(height: 12),
          if (user != null && user!.communityIds.isNotEmpty)
            ...user!.communityIds
                .map((id) => _CommunityCard(communityId: id))
          else
            _JoinCommunityCard(),
          const SizedBox(height: 12),
          Row(children: [
            _QuickAction(
                icon: Icons.sell,
                label: 'Sell',
                onTap: () => Navigator.pushNamed(
                    context, '/farmer/sell/waste-type')),
            _QuickAction(
                icon: Icons.account_balance_wallet,
                label: 'Earnings',
                onTap: () =>
                    Navigator.pushNamed(context, '/farmer/earnings')),
            _QuickAction(
                icon: Icons.calendar_today,
                label: 'Schedule',
                onTap: () =>
                    Navigator.pushNamed(context, '/farmer/schedule')),
            _QuickAction(
                icon: Icons.help_outline,
                label: 'Help',
                onTap: () =>
                    Navigator.pushNamed(context, '/farmer/help')),
          ]),
          const SizedBox(height: 16),
          const Text('Recent Activity',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          _RecentListings(uid: uid),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _EarningsCard extends StatelessWidget {
  final String uid;
  const _EarningsCard({required this.uid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('transactions')
          .where('farmerId', isEqualTo: uid)
          .where('status', isEqualTo: 'completed')
          .snapshots(),
      builder: (ctx, snap) {
        double total = 0;
        if (snap.hasData) {
          for (final d in snap.data!.docs) {
            total += (d['amount'] as num?)?.toDouble() ?? 0;
          }
        }
        return Card(
          color: const Color(0xFF1A7A4A),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(children: [
              const Icon(Icons.account_balance_wallet,
                  color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Earnings',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    Text('KSh ${total.toStringAsFixed(0)}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold)),
                  ]),
            ]),
          ),
        );
      },
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final String communityId;
  const _CommunityCard({required this.communityId});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('communities')
          .doc(communityId)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData || !snap.data!.exists) {
          return const SizedBox.shrink();
        }
        final data = snap.data!.data() as Map<String, dynamic>;
        final current =
            (data['currentEstimatedKg'] as num?)?.toDouble() ?? 0;
        final target =
            (data['targetWeightKg'] as num?)?.toDouble() ?? 1;
        final progress = (current / target).clamp(0.0, 1.0);
        final status = data['status'] ?? 'forming';
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.group, color: Color(0xFF1C4E80)),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(data['name'] ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold))),
                    Chip(
                      label: Text(status.toUpperCase(),
                          style: const TextStyle(fontSize: 10)),
                      backgroundColor: status == 'active'
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                    ),
                  ]),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      color: const Color(0xFF1A7A4A)),
                  const SizedBox(height: 4),
                  Text(
                      '${current.toStringAsFixed(0)} / '
                          '${target.toStringAsFixed(0)} kg',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
                ]),
          ),
        );
      },
    );
  }
}

class _JoinCommunityCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: ListTile(
        leading:
        const Icon(Icons.group_add, color: Color(0xFF1C4E80)),
        title: const Text('Join a Community'),
        subtitle: const Text(
            'Pool waste with other farmers for better prices'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () =>
            Navigator.pushNamed(context, '/farmer/communities'),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _QuickAction(
      {required this.icon,
        required this.label,
        required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(children: [
          CircleAvatar(
            backgroundColor:
            const Color(0xFF1A7A4A).withOpacity(0.1),
            child: Icon(icon, color: const Color(0xFF1A7A4A)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ]),
      ),
    );
  }
}

class _RecentListings extends StatelessWidget {
  final String uid;
  const _RecentListings({required this.uid});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('listings')
          .where('farmerId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .limit(5)
          .snapshots(),
      builder: (ctx, snap) {
        if (!snap.hasData) {
          return const LinearProgressIndicator();
        }
        if (snap.data!.docs.isEmpty) {
          return const Text('No listings yet. Tap Sell to start!',
              style: TextStyle(color: Colors.grey));
        }
        return Column(
          children: snap.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return ListTile(
              leading:
              const Icon(Icons.eco, color: Color(0xFF1A7A4A)),
              title: Text(d['wasteType'] ?? ''),
              subtitle: Text(
                  '${d["estimatedQuantity"] ?? 0} kg  '
                      '${d["status"] ?? ""}'),
              dense: true,
            );
          }).toList(),
        );
      },
    );
  }
}

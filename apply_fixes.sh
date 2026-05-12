#!/bin/bash
set -e
ROOT="lib"

mkdir -p "$ROOT/features/auth/presentation/screens"
mkdir -p "$ROOT/features/farmer/presentation/screens"
mkdir -p "$ROOT/features/admin/presentation/screens"
mkdir -p "$ROOT/features/company/presentation/screens"
mkdir -p "$ROOT/features/driver/presentation/screens"
mkdir -p "$ROOT/shared/models"
mkdir -p "$ROOT/core/navigation"
echo "Directories ready"

# ─── 1. SPLASH ───────────────────────────────
cat > "$ROOT/features/auth/presentation/screens/splash_screen.dart" << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    if (user.email == 'admin@farm.com') {
      Navigator.pushReplacementNamed(context, '/admin/dashboard');
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(user.uid).get();
      final role = doc.data()?['role'] ?? 'farmer';
      switch (role) {
        case 'driver':
          Navigator.pushReplacementNamed(context, '/driver/home');
          break;
        case 'company':
          Navigator.pushReplacementNamed(context, '/company/dashboard');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/farmer/home');
      }
    } catch (_) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF1A7A4A),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.eco, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text('Agri-Waste Connect',
                style: TextStyle(color: Colors.white, fontSize: 24,
                    fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Text('Turn Waste into Wealth',
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
DARTEOF
echo "OK splash_screen.dart"

# ─── 2. LOGIN ────────────────────────────────
cat > "$ROOT/features/auth/presentation/screens/login_screen.dart" << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() { _loading = true; _error = null; });
    try {
      final phone = _phoneCtrl.text.trim();
      final pass  = _passCtrl.text.trim();
      if (phone == 'admin' && pass == 'admin123') {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: 'admin@farm.com', password: pass);
        if (mounted) Navigator.pushNamedAndRemoveUntil(
            context, '/admin/dashboard', (r) => false);
        return;
      }
      final email = phone + '@agri.local';
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('users').doc(uid).get();
      final role = doc.data()?['role'] ?? 'farmer';
      if (!mounted) return;
      switch (role) {
        case 'driver':
          Navigator.pushNamedAndRemoveUntil(
              context, '/driver/home', (r) => false);
          break;
        case 'company':
          Navigator.pushNamedAndRemoveUntil(
              context, '/company/dashboard', (r) => false);
          break;
        default:
          Navigator.pushNamedAndRemoveUntil(
              context, '/farmer/home', (r) => false);
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
              const Icon(Icons.eco, size: 56, color: Color(0xFF1A7A4A)),
              const SizedBox(height: 12),
              const Text('Agri-Waste Connect',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,
                      color: Color(0xFF1A7A4A))),
              const SizedBox(height: 40),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone),
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder()),
              ),
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(_error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _login,
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A7A4A),
                    padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forgot-password'),
                child: const Text('Forgot password?'),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/register'),
                child: const Text("Don't have an account? Register as farmer"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
DARTEOF
echo "OK login_screen.dart"

# ─── 3. USER MODEL ───────────────────────────
cat > "$ROOT/shared/models/user_model.dart" << 'DARTEOF'
class UserModel {
  final String uid;
  final String name;
  final String phone;
  final String role;
  final String county;
  final String subCounty;
  final List<String> communityIds;
  final double? latitude;
  final double? longitude;
  final double totalEarnings;
  final double consistencyScore;

  const UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    required this.role,
    required this.county,
    required this.subCounty,
    this.communityIds = const [],
    this.latitude,
    this.longitude,
    this.totalEarnings = 0,
    this.consistencyScore = 0,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      role: data['role'] ?? 'farmer',
      county: data['county'] ?? '',
      subCounty: data['subCounty'] ?? '',
      communityIds: List<String>.from(data['communityIds'] ?? []),
      latitude: (data['latitude'] as num?)?.toDouble(),
      longitude: (data['longitude'] as num?)?.toDouble(),
      totalEarnings: (data['totalEarnings'] as num?)?.toDouble() ?? 0,
      consistencyScore: (data['consistencyScore'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'phone': phone,
    'role': role,
    'county': county,
    'subCounty': subCounty,
    'communityIds': communityIds,
    'latitude': latitude,
    'longitude': longitude,
    'totalEarnings': totalEarnings,
    'consistencyScore': consistencyScore,
  };

  UserModel copyWith({List<String>? communityIds}) => UserModel(
    uid: uid, name: name, phone: phone, role: role,
    county: county, subCounty: subCounty,
    communityIds: communityIds ?? this.communityIds,
    latitude: latitude, longitude: longitude,
    totalEarnings: totalEarnings, consistencyScore: consistencyScore,
  );
}
DARTEOF
echo "OK user_model.dart"

# ─── 4. FARMER HOME ──────────────────────────
cat > "$ROOT/features/farmer/presentation/screens/farmer_home_screen.dart" << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';

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
            _EarningsTab(),
            _ScheduleTab(),
            _ProfileTab(),
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

class _EarningsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/farmer/earnings'),
          child: const Text('Open Earnings History'),
        ),
      );
}

class _ScheduleTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/farmer/schedule'),
          child: const Text('Open Schedule'),
        ),
      );
}

class _ProfileTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
        child: ElevatedButton(
          onPressed: () =>
              Navigator.pushNamed(context, '/farmer/profile'),
          child: const Text('Open Profile'),
        ),
      );
}
DARTEOF
echo "OK farmer_home_screen.dart"

# ─── 5. JOIN COMMUNITY ───────────────────────
cat > "$ROOT/features/farmer/presentation/screens/join_community_screen.dart" << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/user_model.dart';

class JoinCommunityScreen extends StatefulWidget {
  const JoinCommunityScreen({super.key});
  @override
  State<JoinCommunityScreen> createState() => _JoinCommunityScreenState();
}

class _JoinCommunityScreenState extends State<JoinCommunityScreen> {
  final _db = FirebaseFirestore.instance;
  UserModel? _user;
  String? _selectedWasteType;
  bool _joining = false;

  final _wasteTypes = [
    'cropResidue',
    'livestockManure',
    'fruitWaste',
    'coffeeHusks',
    'vegetableWaste',
    'sugarcaneBagasse',
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && mounted) {
      setState(() => _user = UserModel.fromMap(uid, doc.data()!));
    }
  }

  Future<void> _joinCommunity(
      String communityId, double estimatedKg) async {
    if (_user == null) return;
    setState(() => _joining = true);
    try {
      await _db.runTransaction((tx) async {
        final commRef =
            _db.collection('communities').doc(communityId);
        final userRef =
            _db.collection('users').doc(_user!.uid);
        final commSnap = await tx.get(commRef);
        final data = commSnap.data()!;
        final currentKg =
            (data['currentEstimatedKg'] as num?)?.toDouble() ?? 0;
        final targetKg =
            (data['targetWeightKg'] as num?)?.toDouble() ?? 0;
        final newKg = currentKg + estimatedKg;
        tx.update(commRef, {
          'farmerIds': FieldValue.arrayUnion([_user!.uid]),
          'farmerEstimates.${_user!.uid}': estimatedKg,
          'currentEstimatedKg': newKg,
          if (newKg >= targetKg) 'status': 'active',
        });
        tx.update(userRef, {
          'communityIds': FieldValue.arrayUnion([communityId]),
        });
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Joined community successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join a Community'),
        backgroundColor: const Color(0xFF1A7A4A),
        foregroundColor: Colors.white,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  value: _selectedWasteType,
                  decoration: const InputDecoration(
                      labelText: 'Select your waste type',
                      border: OutlineInputBorder()),
                  items: _wasteTypes
                      .map((t) => DropdownMenuItem(
                          value: t, child: Text(t)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _selectedWasteType = v),
                ),
              ),
              Expanded(
                child: _selectedWasteType == null
                    ? const Center(
                        child: Text(
                            'Select a waste type to see communities'))
                    : StreamBuilder<QuerySnapshot>(
                        stream: _db
                            .collection('communities')
                            .where('wasteType',
                                isEqualTo: _selectedWasteType)
                            .where('subCounty',
                                isEqualTo: _user!.subCounty)
                            .where('status', isEqualTo: 'forming')
                            .snapshots(),
                        builder: (ctx, snap) {
                          if (!snap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final docs = snap.data!.docs.where((d) {
                            final ids = List<String>.from(
                                (d.data() as Map)['farmerIds'] ??
                                    []);
                            return !ids.contains(_user!.uid);
                          }).toList();
                          if (docs.isEmpty) {
                            return const Center(
                                child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'No open communities in your area.\n'
                                'Ask admin to create one.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            ));
                          }
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16),
                            itemCount: docs.length,
                            itemBuilder: (ctx, i) {
                              final d = docs[i].data()
                                  as Map<String, dynamic>;
                              final current =
                                  (d['currentEstimatedKg'] as num?)
                                          ?.toDouble() ??
                                      0;
                              final target =
                                  (d['targetWeightKg'] as num?)
                                          ?.toDouble() ??
                                      1;
                              final progress =
                                  (current / target).clamp(0.0, 1.0);
                              return Card(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                    Text(d['name'] ?? '',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('KSh ${d["agreedPricePerKg"] ?? 0}/kg'
                                        '  Target: ${target.toStringAsFixed(0)} kg'),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                        value: progress,
                                        color: const Color(0xFF1A7A4A)),
                                    const SizedBox(height: 4),
                                    Text(
                                        '${current.toStringAsFixed(0)} kg accumulated'),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _joining
                                            ? null
                                            : () => _showJoinDialog(
                                                docs[i].id),
                                        style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(
                                                0xFF1A7A4A)),
                                        child: const Text('Join',
                                            style: TextStyle(
                                                color: Colors.white)),
                                      ),
                                    ),
                                  ]),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ]),
    );
  }

  Future<void> _showJoinDialog(String communityId) async {
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Your estimated waste'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
              labelText: 'Estimated kg', suffixText: 'kg'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Join')),
        ],
      ),
    );
    if (ok == true) {
      final kg = double.tryParse(ctrl.text) ?? 0;
      if (kg > 0) _joinCommunity(communityId, kg);
    }
  }
}
DARTEOF
echo "OK join_community_screen.dart"

# ─── 6. ADMIN SHELL ──────────────────────────
cat > "$ROOT/features/admin/presentation/screens/admin_shell.dart" << 'DARTEOF'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final leave = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Exit app?'),
            content: const Text('Leave Agri-Waste Connect?'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Stay')),
              ElevatedButton(
                  onPressed: () => Navigator.pop(ctx, true),
                  child: const Text('Exit')),
            ],
          ),
        );
        if (leave == true) SystemNavigator.pop();
        return false;
      },
      child: child,
    );
  }
}
DARTEOF
echo "OK admin_shell.dart"

# ─── 7. APP ROUTES ───────────────────────────
cat > "$ROOT/core/navigation/app_routes.dart" << 'DARTEOF'
import 'package:flutter/material.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/farmer/presentation/screens/farmer_home_screen.dart';
import '../../features/farmer/presentation/screens/join_community_screen.dart';

class AppRoutes {
  static const splash             = '/splash';
  static const login              = '/login';
  static const register           = '/register';
  static const farmerHome         = '/farmer/home';
  static const farmerCommunities  = '/farmer/communities';
  static const farmerSellWasteType= '/farmer/sell/waste-type';
  static const farmerEarnings     = '/farmer/earnings';
  static const farmerSchedule     = '/farmer/schedule';
  static const farmerProfile      = '/farmer/profile';
  static const farmerNotifications= '/farmer/notifications';
  static const farmerHelp         = '/farmer/help';
  static const adminDashboard     = '/admin/dashboard';
  static const driverHome         = '/driver/home';
  static const companyDashboard   = '/company/dashboard';

  static Map<String, WidgetBuilder> get routes => {
    splash:            (_) => const SplashScreen(),
    login:             (_) => const LoginScreen(),
    farmerHome:        (_) => const FarmerHomeScreen(),
    farmerCommunities: (_) => const JoinCommunityScreen(),
  };
}
DARTEOF
echo "OK app_routes.dart"

echo ""
echo "======================================"
echo "ALL DONE - 7 files written"
echo "======================================"
echo ""
echo "Now edit main.dart:"
echo "  initialRoute: AppRoutes.splash,"
echo "  routes: AppRoutes.routes,"
echo ""
echo "Wrap admin dashboard Scaffold with AdminShell"
echo ""
echo "Then: flutter pub get && flutter run"

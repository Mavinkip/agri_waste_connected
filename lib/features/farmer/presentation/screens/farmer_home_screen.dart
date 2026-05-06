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
  double _monthlyEarnings = 0;
  int _activeListings = 0;
  int _completedSales = 0;
  int _totalPickups = 0;
  double _avgRating = 0;
  List<Map<String, dynamic>> _recentTransactions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _profile.load();
    _startStream();
  }

  void _startStream() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    _listingsStream = _firestore.collection('listings').where('farmerId', isEqualTo: uid).snapshots().listen((snap) {
      int active = 0, completed = 0;
      double earnings = 0;
      List<Map<String, dynamic>> recent = [];
      for (var doc in snap.docs) {
        final d = doc.data();
        final status = d['status'] ?? '';
        final qty = (d['estimatedQuantity'] ?? 0).toDouble();
        if (status == 'pending' || status == 'assigned') active++;
        if (status == 'completed') { completed++; earnings += qty * 5.0; }
        recent.add({'wasteType': d['wasteType'] ?? 'Waste', 'quantity': qty.toInt(), 'status': status, 'amount': (qty * 5.0).toInt(), 'date': (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now()});
      }
      recent.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
      if (mounted) setState(() { _activeListings = active; _completedSales = completed; _totalPickups = snap.docs.length; _monthlyEarnings = earnings; _avgRating = snap.docs.isNotEmpty ? 4.5 : 0; _recentTransactions = recent; _loading = false; });
    });
  }

  @override
  void dispose() { _listingsStream?.cancel(); super.dispose(); }

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
              child: CircleAvatar(radius: 18, backgroundColor: Colors.white.withValues(alpha: 0.2), backgroundImage: _profile.photoPath != null ? FileImage(File(_profile.photoPath!)) : null, child: _profile.photoPath == null ? Text(_profile.name.isNotEmpty ? _profile.name[0].toUpperCase() : 'F', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)) : null),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text(_profile.name.isNotEmpty ? 'Welcome, ${_profile.name}' : 'Agri-Waste Connect', style: const TextStyle(fontSize: 10, color: Colors.white70)),
            ]),
          ]),
          actions: [
            GestureDetector(onTap: _lang.toggle, child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Text(_lang.lang == 'en' ? 'SW' : 'EN', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)))),
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
      onRefresh: () async { _profile.load(); await Future.delayed(const Duration(milliseconds: 300)); },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(), padding: const EdgeInsets.all(12),
        child: Column(children: [
          _earningsCard(), const SizedBox(height: 10),
          _statsGrid(), const SizedBox(height: 14),
          _quickActions(), const SizedBox(height: 14),
          _recentActivity(), const SizedBox(height: 8),
        ]),
      ),
    );
  }

  Widget _earningsCard() {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/farmer/earnings'),
      child: Container(
        width: double.infinity, padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]), borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: const Color(0xFF1B5E20).withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Row(children: [const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 16), const SizedBox(width: 6), Text(_lang.t('Monthly Earnings'), style: const TextStyle(fontSize: 13, color: Colors.white70))]), const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14)]),
          const SizedBox(height: 8),
          Text('KSh ${_monthlyEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
        ]),
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
            Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: item.$4.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(item.$1, color: item.$4, size: 20)),
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
    return Expanded(child: InkWell(onTap: () => Navigator.of(context).pushNamed(route), borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))), child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 4), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11))]))));
  }

  Widget _recentActivity() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_lang.t('Recent Activity'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 6),
      _recentTransactions.isEmpty
          ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)), child: const Text('No activity yet', style: TextStyle(color: Colors.grey, fontSize: 12)))
          : Column(children: _recentTransactions.map((tx) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)), child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: const Color(0xFF2D5A27).withValues(alpha: 0.1), child: const Icon(Icons.check, size: 14, color: Color(0xFF2D5A27))), const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tx['wasteType'] ?? 'Waste', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text('${tx['quantity']}kg', style: const TextStyle(fontSize: 11, color: Colors.grey))])),
            Text('+KSh ${tx['amount']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
          ]))).toList()),
    ]);
  }
}

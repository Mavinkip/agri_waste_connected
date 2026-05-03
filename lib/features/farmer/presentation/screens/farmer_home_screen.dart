import '../../../../core/services/connectivity_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/farmer_bloc.dart';
import '../../data/repositories/farmer_repository.dart';
import '../../../../shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../widgets/farmer_app_menu.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});
  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  FarmerDashboardStats? _stats;
  List<EarningTransaction> _transactions = [];
  String _farmerName = '';

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  double get _monthlyEarnings {
    if (_transactions.isEmpty) return 0;
    final now = DateTime.now();
    return _transactions.where((t) => t.date.month == now.month && t.date.year == now.year).fold(0.0, (s, t) => s + t.amount);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadName();
      if (!mounted) return;
      final bloc = context.read<FarmerBloc>();
      bloc.add(const LoadDashboardStats());
      bloc.add(const LoadEarningsSummary());
      bloc.add(const LoadFarmerProfile());
    });
  }

  void _loadName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getString('user_data');
      if (data != null) {
        final user = UserModel.fromJson(jsonDecode(data));
        if (mounted) setState(() => _farmerName = user.fullName);
      }
    } catch (_) {}
  }

  void _showActiveListings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Your Active Listings', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_stats == null || _stats!.activeListings == 0)
            const Padding(padding: EdgeInsets.all(20), child: Center(child: Text('No active listings', style: TextStyle(color: Colors.grey, fontSize: 15))))
          else ...[
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.green.shade200)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.grass, color: Colors.green)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Crop Residue', style: TextStyle(fontWeight: FontWeight.w600)), Text('50kg • Pending pickup', style: TextStyle(fontSize: 12, color: Colors.grey))])), const Text('KSh 250', style: TextStyle(fontWeight: FontWeight.bold))])),
            const SizedBox(height: 8),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.orange.shade200)), child: Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.orange.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.eco, color: Colors.orange)), const SizedBox(width: 12), const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Vegetable Waste', style: TextStyle(fontWeight: FontWeight.w600)), Text('30kg • Scheduled', style: TextStyle(fontSize: 12, color: Colors.grey))])), const Text('KSh 120', style: TextStyle(fontWeight: FontWeight.bold))])),
          ],
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmerBloc, FarmerState>(
      listener: (context, state) {
        if (state is FarmerDashboardLoaded) setState(() => _stats = state.stats);
        if (state is FarmerEarningsLoaded) setState(() => _transactions = state.transactions);
        if (state is FarmerProfileLoaded) setState(() => _farmerName = state.profile.fullName);
      },
      child: Scaffold(
        appBar: AppBar(
          title: _farmerName.isNotEmpty
              ? Text('$_greeting, $_farmerName', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
              : const Text('Loading...', style: TextStyle(fontSize: 16)),
          actions: [
            IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () => Navigator.of(context).pushNamed('/farmer/schedule')),
            const FarmerAppMenu(currentScreen: 'home'),
          ],
        ),
        body: _stats == null
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D5A27)))
            : RefreshIndicator(
                onRefresh: () async {
                  final b = context.read<FarmerBloc>();
                  b.add(const LoadDashboardStats());
                  b.add(const LoadEarningsSummary());
                  b.add(const LoadFarmerProfile());
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // GREETING + EARNINGS
                    Container(
                      width: double.infinity, padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)]), borderRadius: BorderRadius.circular(14)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('$_greeting, $_farmerName', style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        const Text('Monthly Earnings', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/farmer/earnings'),
                          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text('KSh ${_monthlyEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                            const Icon(Icons.arrow_forward_ios, color: Colors.white60, size: 16),
                          ]),
                        ),
                        const SizedBox(height: 2),
                        const Text('Tap to view all earnings', style: TextStyle(color: Colors.white60, fontSize: 11)),
                      ]),
                    ),
                    const SizedBox(height: 14),

                    // QUICK ACTIONS
                    Row(children: [
                      Expanded(child: _actionBtn('Sell\nWaste', Icons.add_circle_outline, const Color(0xFF1B5E20), '/farmer/sell/waste-type')),
                      const SizedBox(width: 8),
                      Expanded(child: _actionBtn('My\nEarnings', Icons.account_balance_wallet, Colors.blue.shade700, '/farmer/earnings')),
                      const SizedBox(width: 8),
                      Expanded(child: _actionBtn('Pickup\nSchedule', Icons.calendar_month, Colors.orange.shade700, '/farmer/schedule')),
                    ]),
                    const SizedBox(height: 14),

                    // STATS
                    Row(children: [
                      Expanded(child: GestureDetector(onTap: _showActiveListings, child: _statCard('Active', '${_stats!.activeListings}', Icons.list_alt, Colors.blue))),
                      const SizedBox(width: 8),
                      Expanded(child: _statCard('Completed', '${_stats!.completedSales}', Icons.check_circle, Colors.green)),
                      const SizedBox(width: 8),
                      Expanded(child: _statCard('Pickups', '${_stats!.totalPickups}', Icons.local_shipping, Colors.orange)),
                    ]),
                    const SizedBox(height: 16),

                    // RECENT TRANSACTIONS
                    const Text('Recent Transactions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    if (_transactions.isEmpty)
                      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)), child: const Center(child: Text('No transactions yet', style: TextStyle(color: Colors.grey)))),
                    if (_transactions.isNotEmpty)
                      ..._transactions.take(4).map((tx) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
                            child: Row(children: [
                              Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFF1B5E20).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.monetization_on, color: Color(0xFF1B5E20), size: 20)),
                              const SizedBox(width: 10),
                              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tx.wasteType.isNotEmpty ? tx.wasteType : 'Waste Sale', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text('${tx.date.day}/${tx.date.month}  ${tx.quantity.toStringAsFixed(0)}kg', style: const TextStyle(fontSize: 11, color: Colors.grey))])),
                              Text('+KSh ${tx.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                            ]),
                          )),
                    const SizedBox(height: 8),
                    Center(child: TextButton(onPressed: () => Navigator.of(context).pushNamed('/farmer/earnings'), child: const Text('View All Transactions →'))),
                  ]),
                ),
              ),
      ),
    );
  }

  Widget _actionBtn(String label, IconData icon, Color color, String route) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed(route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
        child: Column(children: [Icon(icon, color: color, size: 26), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12, height: 1.3))]),
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade200)),
      child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)), Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey))]),
    );
  }
}

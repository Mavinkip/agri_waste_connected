import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/farmer_bloc.dart';
import '../../data/repositories/farmer_repository.dart';
import '../widgets/farmer_app_menu.dart';
import '../widgets/offline_banner.dart';
import '../widgets/language_provider.dart';

class FarmerHomeScreen extends StatefulWidget {
  const FarmerHomeScreen({super.key});
  @override
  State<FarmerHomeScreen> createState() => _FarmerHomeScreenState();
}

class _FarmerHomeScreenState extends State<FarmerHomeScreen> {
  FarmerDashboardStats? _stats;
  List<EarningTransaction> _transactions = [];
  String _farmerName = '';
  final _lang = LanguageNotifier();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    if (!mounted) return;
    final bloc = context.read<FarmerBloc>();
    bloc.add(const LoadDashboardStats());
    bloc.add(const LoadEarningsSummary());
  }

  void _onStateChange(BuildContext context, FarmerState state) {
    if (state is FarmerDashboardLoaded) setState(() => _stats = state.stats);
    if (state is FarmerEarningsLoaded) setState(() => _transactions = state.transactions);
  }

  double get _monthlyEarnings {
    final now = DateTime.now();
    return _transactions.where((t) => t.date.month == now.month && t.date.year == now.year).fold(0.0, (s, t) => s + t.amount);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FarmerBloc, FarmerState>(
      listener: _onStateChange,
      child: ListenableBuilder(
        listenable: _lang,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_lang.t('Dashboard'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(_farmerName.isEmpty ? _lang.t('Loading...') : '${_lang.t('Welcome')}, $_farmerName', style: const TextStyle(fontSize: 11, color: Colors.white70)),
            ]),
            actions: [
              GestureDetector(
                onTap: _lang.toggle,
                child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(12)), child: Text(_lang.lang == 'en' ? 'SW' : 'EN', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
              ),
              IconButton(icon: const Icon(Icons.notifications_outlined, size: 22), onPressed: () => Navigator.of(context).pushNamed('/farmer/notifications')),
              const FarmerAppMenu(currentScreen: 'home'),
            ],
          ),
          body: OfflineBanner(child: _stats == null ? const Center(child: CircularProgressIndicator(color: Color(0xFF2D5A27))) : _dashboard()),
        ),
      ),
    );
  }

  Widget _dashboard() {
    return RefreshIndicator(
      color: const Color(0xFF2D5A27),
      onRefresh: () async { _loadData(); await Future.delayed(const Duration(milliseconds: 500)); },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          _earningsCard(), const SizedBox(height: 10),
          _statsGrid(), const SizedBox(height: 14),
          _chart(), const SizedBox(height: 14),
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
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [const Icon(Icons.account_balance_wallet, color: Colors.white70, size: 16), const SizedBox(width: 6), Text(_lang.t('Monthly Earnings'), style: const TextStyle(fontSize: 13, color: Colors.white70))]),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 14),
          ]),
          const SizedBox(height: 8),
          Text('KSh ${_monthlyEarnings.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('${_transactions.length} ${_lang.t('transactions this month')}', style: const TextStyle(fontSize: 11, color: Colors.white54)),
        ]),
      ),
    );
  }

  Widget _statsGrid() {
    final items = [
      (Icons.list_alt, _stats!.activeListings.toString(), _lang.t('Open Orders'), Colors.blue, '/farmer/sell/waste-type'),
      (Icons.check_circle, _stats!.completedSales.toString(), _lang.t('Sold'), Colors.green, '/farmer/earnings'),
      (Icons.local_shipping, _stats!.totalPickups.toString(), _lang.t('Collections'), Colors.orange, null),
      (Icons.star, _stats!.averageRating.toStringAsFixed(1), _lang.t('My Rating'), Colors.amber, null),
    ];
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 4,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: 1.15),
      itemBuilder: (ctx, i) {
        final item = items[i];
        return GestureDetector(
          onTap: item.$5 != null ? () => Navigator.of(context).pushNamed(item.$5!) : null,
          child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))]),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(color: item.$4.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(item.$1, color: item.$4, size: 20)),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.$2, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: item.$4)),
                Text(item.$3, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ]),
            ]),
          ),
        );
      },
    );
  }

  Widget _chart() {
    if (_transactions.isEmpty) {
      return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)), child: const Column(children: [Icon(Icons.show_chart, size: 36, color: Colors.grey), SizedBox(height: 8), Text('No earnings yet', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey))]));
    }
    final recent = _transactions.take(6).toList();
    final max = recent.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_lang.t('Earnings'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 8),
      Row(crossAxisAlignment: CrossAxisAlignment.end, children: recent.map((tx) {
        final h = (tx.amount / (max <= 0 ? 1 : max)) * 45;
        return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: Column(children: [
          Container(height: h, decoration: BoxDecoration(borderRadius: BorderRadius.circular(3), gradient: const LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Color(0xFF2D5A27), Color(0xFF81C784)]))),
          const SizedBox(height: 2), Text('KSh ${tx.amount.toInt()}', maxLines: 1, style: const TextStyle(fontSize: 8, color: Colors.grey)),
        ])));
      }).toList()),
    ]);
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
    return Expanded(child: InkWell(
      onTap: () => Navigator.of(context).pushNamed(route),
      borderRadius: BorderRadius.circular(12),
      child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))), child: Column(children: [Icon(icon, color: color, size: 22), const SizedBox(height: 4), Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 11))])),
    ));
  }

  Widget _recentActivity() {
    final recent = _transactions.take(5).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(_lang.t('Recent Activity'), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)), const SizedBox(height: 6),
      recent.isEmpty
          ? Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade100)), child: const Column(children: [Icon(Icons.receipt_long, size: 28, color: Colors.grey), SizedBox(height: 4), Text('No activity yet', style: TextStyle(color: Colors.grey, fontSize: 12))]))
          : Column(children: recent.map((tx) => Container(margin: const EdgeInsets.only(bottom: 6), padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.grey.shade100)), child: Row(children: [
            CircleAvatar(radius: 14, backgroundColor: const Color(0xFF2D5A27).withValues(alpha: 0.1), child: const Icon(Icons.check, size: 14, color: Color(0xFF2D5A27))), const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(tx.wasteType.isNotEmpty ? tx.wasteType : 'Waste', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Text('${tx.date.day}/${tx.date.month} - ${tx.quantity.toInt()}kg', style: const TextStyle(fontSize: 11, color: Colors.grey))])),
            Text('+KSh ${tx.amount.toInt()}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green)),
          ]))).toList()),
    ]);
  }
}

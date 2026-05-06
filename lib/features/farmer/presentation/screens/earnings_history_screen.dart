import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/farmer_bloc.dart';
import '../widgets/farmer_app_menu.dart';

class EarningsHistoryScreen extends StatefulWidget {
  const EarningsHistoryScreen({super.key});
  @override
  State<EarningsHistoryScreen> createState() => _EarningsHistoryScreenState();
}

class _EarningsHistoryScreenState extends State<EarningsHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<FarmerBloc>().add(const LoadEarningsSummary());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        actions: const [FarmerAppMenu(currentScreen: 'earnings')],
      ),
      body: BlocBuilder<FarmerBloc, FarmerState>(
        builder: (context, state) {
          if (state is FarmerEarningsLoaded) {
            final txns = state.transactions;
            final total = txns.fold(0.0, (s, t) => s + t.amount);
            final now = DateTime.now();
            final monthly = txns.where((t) => t.date.month == now.month && t.date.year == now.year).fold(0.0, (s, t) => s + t.amount);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                _summaryCard('Total Earned', 'KSh ${total.toStringAsFixed(0)}', Colors.green),
                const SizedBox(height: 8),
                _summaryCard('This Month', 'KSh ${monthly.toStringAsFixed(0)}', Colors.blue),
                const SizedBox(height: 8),
                _summaryCard('Total Transactions', '${txns.length}', const Color(0xFF2D5A27)),
                const SizedBox(height: 20),

                SizedBox(width: double.infinity, height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('M-Pesa withdrawal coming soon'), backgroundColor: Colors.green)),
                    icon: const Icon(Icons.account_balance_wallet), label: const Text('Withdraw via M-Pesa', style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2D5A27), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  ),
                ),
                const SizedBox(height: 20),

                const Text('Transaction History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                if (txns.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: Text('No transactions yet', style: TextStyle(color: Colors.grey))))
                else
                  ListView.builder(
                    shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: txns.length,
                    itemBuilder: (ctx, i) {
                      final tx = txns[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          leading: CircleAvatar(radius: 18, backgroundColor: Colors.green.withValues(alpha: 0.1), child: const Icon(Icons.check_circle, color: Colors.green, size: 20)),
                          title: Text(tx.wasteType.isNotEmpty ? tx.wasteType : 'Earnings', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          subtitle: Text('${tx.date.day}/${tx.date.month}/${tx.date.year} - ${tx.quantity.toStringAsFixed(0)} kg', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          trailing: Text('+KSh ${tx.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.green)),
                        ),
                      );
                    },
                  ),
              ]),
            );
          }
          if (state is FarmerError) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12), Text(state.message),
              ElevatedButton(onPressed: () => context.read<FarmerBloc>().add(const LoadEarningsSummary()), child: const Text('Retry')),
            ]));
          }
          return const Center(child: CircularProgressIndicator(color: Color(0xFF2D5A27)));
        },
      ),
    );
  }

  Widget _summaryCard(String label, String value, Color color) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
      ]),
    );
  }
}

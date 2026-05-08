import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../bloc/farmer_bloc.dart';
import '../widgets/farmer_app_menu.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        actions: const [FarmerAppMenu(currentScreen: 'help')],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ─── CONTACT CARDS ───
          const Text('Contact Us', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _contactCard(Icons.phone, 'Call Support', '0700 123 456', Colors.blue, () {}),
          const SizedBox(height: 8),
          _contactCard(Icons.chat, 'WhatsApp', 'Chat with us on WhatsApp', Colors.green, () {}),
          const SizedBox(height: 20),

          // ─── HOW IT WORKS ───
          const Text('How It Works', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _stepCard('1', 'Select Waste', 'Choose the type of agricultural waste you have', Icons.grass, Colors.green),
          _stepCard('2', 'Set Location', 'Tell us where to pick up your waste', Icons.location_on, Colors.blue),
          _stepCard('3', 'Get Paid', 'Receive payment via M-Pesa after collection', Icons.monetization_on, Colors.orange),
          const SizedBox(height: 20),

          // ─── PAYMENTS ───
          const Text('How Payments Work', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.green.shade200)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.account_balance_wallet, color: Colors.green), SizedBox(width: 8), Text('M-Pesa Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16))]),
              SizedBox(height: 8),
              Text('• Payment sent after driver verifies your waste', style: TextStyle(fontSize: 13)),
              Text('• Arrives within 24 hours after collection', style: TextStyle(fontSize: 13)),
              Text('• Check your M-Pesa messages for confirmation', style: TextStyle(fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 20),

          // ─── FAQ ───
          const Text('Frequently Asked Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _faqTile('How do I get paid?', 'Payment is sent to your M-Pesa account after the driver verifies and weighs your waste.'),
          _faqTile('When will my waste be collected?', 'Routine pickups happen on your scheduled day. Manual requests are within 48 hours.'),
          _faqTile('What if my waste is rejected?', 'The driver will tell you why. Common reasons: wrong type, contaminated waste, or too little quantity.'),
          _faqTile('How is the price determined?', 'Prices are set by the admin based on waste type and quality. You can see prices before listing.'),
          const SizedBox(height: 24),

          // ─── ABOUT ───
          Container(
            width: double.infinity, padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(14)),
            child: const Column(children: [
              Icon(Icons.agriculture, size: 40, color: AppColors.primaryGreen),
              SizedBox(height: 8),
              Text('Agri-Waste Connect', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text('v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(height: 4),
              Text('Turning waste into wealth for Kenyan farmers', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _contactCard(IconData icon, String title, String subtitle, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
        child: Row(children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 24)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
            Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          ])),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ]),
      ),
    );
  }

  Widget _stepCard(String number, String title, String description, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        CircleAvatar(radius: 18, backgroundColor: color, child: Text(number, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
        const SizedBox(width: 12),
        Container(width: 40, height: 40, decoration: BoxDecoration(color: color.withAlpha(20), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
          Text(description, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ])),
      ]),
    );
  }

  Widget _faqTile(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      children: [Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text(answer, style: const TextStyle(color: Colors.grey, fontSize: 13)))],
      shape: const Border(bottom: BorderSide(color: Colors.grey, width: 0.3)),
    );
  }
}

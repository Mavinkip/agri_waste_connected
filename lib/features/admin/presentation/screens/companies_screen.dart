import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../core/constants/app_colors.dart';
import '../../../../../shared/models/recycling_company_model.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  final _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recycling Companies'),
        backgroundColor: AppColors.primaryGreen,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCompanyDialog,
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_business),
        label: const Text('Add Company'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('recycling_companies').snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.factory, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No companies added yet',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (ctx, i) {
              final d = docs[i].data() as Map<String, dynamic>;
              final company = RecyclingCompanyModel.fromJson(
                  {...d, 'id': docs[i].id});
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.factory,
                        color: AppColors.primaryGreen),
                  ),
                  title: Text(company.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(company.county),
                      Text(company.phone,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: Switch(
                    value: company.isActive,
                    onChanged: (v) => _firestore
                        .collection('recycling_companies')
                        .doc(company.id)
                        .update({'isActive': v}),
                    activeColor: AppColors.primaryGreen,
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCompanyDialog() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String? county;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius:
          BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Padding(
          padding: EdgeInsets.only(
            left: 24, right: 24, top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Add Recycling Company',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _field(nameCtrl, 'Company Name',
                    Icons.business),
                const SizedBox(height: 10),
                _field(contactCtrl, 'Contact Person',
                    Icons.person),
                const SizedBox(height: 10),
                _field(phoneCtrl, 'Phone Number',
                    Icons.phone,
                    type: TextInputType.phone),
                const SizedBox(height: 10),
                _field(emailCtrl, 'Email', Icons.email,
                    type: TextInputType.emailAddress),
                const SizedBox(height: 10),
                _field(addressCtrl, 'Address',
                    Icons.location_on),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.trim().isEmpty) return;
                    await _firestore
                        .collection('recycling_companies')
                        .add({
                      'name': nameCtrl.text.trim(),
                      'contactPerson': contactCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'email': emailCtrl.text.trim(),
                      'address': addressCtrl.text.trim(),
                      'county': county ?? '',
                      'lat': 0.0,
                      'lng': 0.0,
                      'wasteTypesAccepted': [],
                      'buyingPrices': {},
                      'isActive': true,
                      'createdAt':
                      DateTime.now().toIso8601String(),
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryGreen),
                  child: const Text('Add Company'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
      IconData icon,
      {TextInputType? type}) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        isDense: true,
      ),
    );
  }
}
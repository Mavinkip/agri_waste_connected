import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/data/kenya_locations.dart';

class CompanyManagementScreen extends StatefulWidget {
  const CompanyManagementScreen({super.key});

  @override
  State<CompanyManagementScreen> createState() => _CompanyManagementScreenState();
}

class _CompanyManagementScreenState extends State<CompanyManagementScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Company Management'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCompanyDialog,
        icon: const Icon(Icons.business),
        label: const Text('Add Company'),
        backgroundColor: AppColors.primaryGreen,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('users')
            .where('role', isEqualTo: 'company')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final companies = snapshot.data?.docs ?? [];
          if (companies.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No companies registered'),
                  Text('Tap + to add a company', style: TextStyle(fontSize: 12)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: companies.length,
            itemBuilder: (ctx, index) {
              final data = companies[index].data() as Map<String, dynamic>;
              return CompanyCard(
                id: companies[index].id,
                data: data,
                onTap: () => _showCompanyDetails(companies[index].id, data),
                onDelete: () => _deleteCompany(companies[index].id),
              );
            },
          );
        },
      ),
    );
  }

  void _showAddCompanyDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    String? county, subCounty, ward;
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('Add Company'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Company Name *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone *'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(labelText: 'Email *'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password *'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm Password *'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: county,
                  decoration: const InputDecoration(labelText: 'County *'),
                  items: KenyaLocations.getCountyNames()
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setState(() => county = v),
                ),
                const SizedBox(height: 8),
                if (county != null)
                  DropdownButtonFormField<String>(
                    value: subCounty,
                    decoration: const InputDecoration(labelText: 'Sub-County *'),
                    items: KenyaLocations.getSubCountyNames(county!)
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                    onChanged: (v) => setState(() => subCounty = v),
                  ),
                const SizedBox(height: 8),
                if (subCounty != null)
                  DropdownButtonFormField<String>(
                    value: ward,
                    decoration: const InputDecoration(labelText: 'Ward'),
                    items: KenyaLocations.getWardNames(county!, subCounty!)
                        .map((w) => DropdownMenuItem(value: w, child: Text(w)))
                        .toList(),
                    onChanged: (v) => setState(() => ward = v),
                  ),
                const SizedBox(height: 8),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                if (nameCtrl.text.trim().isEmpty) {
                  _showError(ctx, 'Enter company name');
                  return;
                }
                if (phoneCtrl.text.trim().isEmpty) {
                  _showError(ctx, 'Enter phone number');
                  return;
                }
                if (emailCtrl.text.trim().isEmpty) {
                  _showError(ctx, 'Enter email');
                  return;
                }
                if (passCtrl.text.trim().length < 6) {
                  _showError(ctx, 'Password must be at least 6 characters');
                  return;
                }
                if (passCtrl.text != confirmCtrl.text) {
                  _showError(ctx, 'Passwords do not match');
                  return;
                }
                if (county == null) {
                  _showError(ctx, 'Select county');
                  return;
                }
                if (subCounty == null) {
                  _showError(ctx, 'Select sub-county');
                  return;
                }

                setState(() => isLoading = true);

                try {
                  // Create Firebase Auth user
                  final credential = await _auth.createUserWithEmailAndPassword(
                    email: emailCtrl.text.trim(),
                    password: passCtrl.text.trim(),
                  );

                  // Store in users collection with role 'company'
                  await _firestore.collection('users').doc(credential.user!.uid).set({
                    'name': nameCtrl.text.trim(),
                    'phone': phoneCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'role': 'company',
                    'county': county,
                    'subCounty': subCounty,
                    'ward': ward ?? '',
                    'address': addressCtrl.text.trim(),
                    'isActive': true,
                    'totalWasteProcessed': 0,
                    'totalPaid': 0,
                    'preferredWasteTypes': [], // Company will set their own
                    'priceList': {}, // Company will set their own prices
                    'targetWeeklyKg': 5000,
                    'currentWeeklyKg': 0,
                    'createdAt': FieldValue.serverTimestamp(),
                    'createdBy': _auth.currentUser?.uid ?? 'admin',
                  });

                  if (ctx.mounted) {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      const SnackBar(content: Text('Company created successfully!'), backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  _showError(ctx, 'Failed to create company: $e');
                  setState(() => isLoading = false);
                }
              },
              child: isLoading
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompanyDetails(String id, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['name'] ?? 'Company',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('📞 ${data['phone'] ?? 'N/A'}'),
            Text('📧 ${data['email'] ?? 'N/A'}'),
            Text('📍 ${data['county'] ?? ''}, ${data['subCounty'] ?? ''}'),
            if (data['ward'] != null && data['ward'].isNotEmpty)
              Text('📍 Ward: ${data['ward']}'),
            const SizedBox(height: 16),
            const Text('Company Info:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('• Status: ${data['isActive'] == true ? "Active" : "Inactive"}'),
            Text('• Total Waste Processed: ${data['totalWasteProcessed'] ?? 0} kg'),
            Text('• Total Paid: KSh ${data['totalPaid'] ?? 0}'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _resetPassword(id, data['email']),
                    icon: const Icon(Icons.lock_reset),
                    label: const Text('Reset Password'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _toggleCompanyStatus(id, data['isActive'] ?? true),
                    icon: Icon(data['isActive'] ?? true ? Icons.block : Icons.check_circle),
                    label: Text(data['isActive'] ?? true ? 'Deactivate' : 'Activate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: data['isActive'] ?? true ? Colors.red : Colors.green,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _resetPassword(String companyId, String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending reset email: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _toggleCompanyStatus(String companyId, bool currentStatus) async {
    await _firestore.collection('users').doc(companyId).update({
      'isActive': !currentStatus,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Company ${!currentStatus ? "activated" : "deactivated"}')),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _deleteCompany(String companyId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Company'),
        content: const Text('Are you sure? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        // Delete from Firestore
        await _firestore.collection('users').doc(companyId).delete();

        // Note: Deleting Firebase Auth user requires Admin SDK - do this via Firebase Console
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Company deleted from Firestore. Delete user from Firebase Console separately.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting company: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final String id;
  final Map<String, dynamic> data;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const CompanyCard({
    required this.id,
    required this.data,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
          child: const Icon(Icons.business, color: AppColors.primaryGreen),
        ),
        title: Text(data['name'] ?? 'Unknown'),
        subtitle: Text('${data['county'] ?? ''} • ${data['subCounty'] ?? ''}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Chip(
              label: Text(data['isActive'] == true ? 'Active' : 'Inactive'),
              backgroundColor: data['isActive'] == true ? Colors.green.shade100 : Colors.red.shade100,
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

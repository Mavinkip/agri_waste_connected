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
  List<QueryDocumentSnapshot> _communities = [];
  bool _loading = true;

  final _wasteTypes = [
    'cropResidue',
    'livestockManure',
    'fruitWaste',
    'coffeeHusks',
    'vegetableWaste',
    'sugarcaneBagasse',
    'mixedOrganic',
    'riceHusks',
    'coconutWaste',
    'maizeStover',
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
      // Load communities after user is loaded
      if (_selectedWasteType != null) {
        _loadCommunities();
      }
    }
  }

  Future<void> _loadCommunities() async {
    if (_user == null || _selectedWasteType == null) return;

    setState(() => _loading = true);

    try {
      print('Loading communities for wasteType: $_selectedWasteType');
      print('User subCounty: ${_user!.subCounty}');

      // Query communities that match wasteType and subCounty
      QuerySnapshot snapshot = await _db
          .collection('communities')
          .where('wasteType', isEqualTo: _selectedWasteType)
          .where('subCounty', isEqualTo: _user!.subCounty)
          .where('status', isEqualTo: 'forming')
          .get();

      print('Found ${snapshot.docs.length} communities');

      // Filter out communities the farmer already joined
      final filteredDocs = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final farmerIds = List<String>.from(data['farmerIds'] ?? []);
        return !farmerIds.contains(_user!.uid);
      }).toList();

      setState(() {
        _communities = filteredDocs;
        _loading = false;
      });
    } catch (e) {
      print('Error loading communities: $e');
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading communities: $e')),
      );
    }
  }

  Future<void> _joinCommunity(String communityId, double estimatedKg) async {
    if (_user == null) return;
    setState(() => _joining = true);
    try {
      await _db.runTransaction((tx) async {
        final commRef = _db.collection('communities').doc(communityId);
        final userRef = _db.collection('users').doc(_user!.uid);
        final commSnap = await tx.get(commRef);
        final data = commSnap.data()!;
        final currentKg = (data['currentEstimatedKg'] as num?)?.toDouble() ?? 0;
        final targetKg = (data['targetWeightKg'] as num?)?.toDouble() ?? 0;
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
          const SnackBar(content: Text('Joined community successfully!')),
        );
        // Refresh the list
        await _loadCommunities();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
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
              border: OutlineInputBorder(),
            ),
            items: _wasteTypes
                .map((t) => DropdownMenuItem(
                value: t,
                child: Text(_formatWasteType(t))))
                .toList(),
            onChanged: (v) {
              setState(() {
                _selectedWasteType = v;
                _communities = [];
              });
              if (v != null) {
                _loadCommunities();
              }
            },
          ),
        ),
        Expanded(
          child: _selectedWasteType == null
              ? const Center(
              child: Text('Select a waste type to see communities'))
              : _loading
              ? const Center(child: CircularProgressIndicator())
              : _communities.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off,
                    size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text(
                  'No communities found in your area',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try a different waste type or wait for admin to create one\n'
                      'Your location: ${_user!.subCounty}, ${_user!.county}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.symmetric(
                horizontal: 16),
            itemCount: _communities.length,
            itemBuilder: (ctx, i) {
              final doc = _communities[i];
              final d = doc.data() as Map<String, dynamic>;
              final current = (d['currentEstimatedKg']
              as num?)?.toDouble() ?? 0;
              final target = (d['targetWeightKg']
              as num?)?.toDouble() ?? 1;
              final progress = (current / target).clamp(0.0, 1.0);
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              d['name'] ?? 'Unnamed',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: d['status'] == 'active'
                                  ? Colors.green.shade100
                                  : Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              d['status'] ?? 'forming',
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${d['county'] ?? ''} • ${d['subCounty'] ?? ''}',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'KSh ${d['agreedPricePerKg'] ?? 0}/kg  •  '
                            'Target: ${target.toStringAsFixed(0)} kg',
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                          value: progress,
                          color: const Color(0xFF1A7A4A)),
                      const SizedBox(height: 4),
                      Text(
                        '${current.toStringAsFixed(0)} kg accumulated',
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _joining
                              ? null
                              : () => _showJoinDialog(doc.id),
                          style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xFF1A7A4A)),
                          child: const Text('Join',
                              style: TextStyle(
                                  color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
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
      if (kg > 0) {
        await _joinCommunity(communityId, kg);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid weight')),
        );
      }
    }
  }

  String _formatWasteType(String type) {
    final map = {
      'cropResidue': 'Crop Residue',
      'livestockManure': 'Livestock Manure',
      'fruitWaste': 'Fruit Waste',
      'coffeeHusks': 'Coffee Husks',
      'vegetableWaste': 'Vegetable Waste',
      'sugarcaneBagasse': 'Sugarcane Bagasse',
      'mixedOrganic': 'Mixed Organic Waste',
      'riceHusks': 'Rice Husks',
      'coconutWaste': 'Coconut Waste',
      'maizeStover': 'Maize Stover',
    };
    return map[type] ?? type;
  }
}
